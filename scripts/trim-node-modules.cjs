#!/usr/bin/env node
/**
 * 按运行时引用自动裁剪 node_modules 死重（替代人工维护的硬编码裁剪列表）。
 *
 * 兼容策略（对上游任意版本安全）：
 *   1. 扫描运行时代码（排除 node_modules 与前端打包产物 assets），提取全部裸包引用
 *   2. 递归展开被引用包的 dependencies 闭包 —— 被引用的整棵树一律保留
 *   3. 迭代扫描：对被保留的包再扫其自身运行时代码（覆盖 workspace 子包如
 *      inkos-studio 内部引用 hono 的情况），新增引用再传播，直至收敛
 *   4. 字符串宽松兜底：主包代码中"出现过名字"的顶层包也保留（防正则漏扫）
 *   5. 只删除 1~4 均未命中的顶层包 —— 保留方向永远保守，只删明确死重
 *
 * 用法：node trim-node-modules.cjs <inkos 包绝对路径> [--dry-run]
 */
'use strict';

const fs = require('fs');
const path = require('path');

const PKG = process.argv[2];
const DRY_RUN = process.argv.includes('--dry-run');
if (!PKG) {
  console.error('usage: node trim-node-modules.cjs <pkgPath> [--dry-run]');
  process.exit(2);
}

const NM = path.join(PKG, 'node_modules');
if (!fs.existsSync(NM)) {
  console.error(`node_modules 不存在: ${NM}`);
  process.exit(2);
}

// ---------- 1. 收集运行时代码文件（排除 node_modules 与前端打包产物 assets） ----------
function walk(dir, out = []) {
  if (!fs.existsSync(dir)) return out;
  for (const e of fs.readdirSync(dir, { withFileTypes: true })) {
    const p = path.join(dir, e.name);
    if (e.isDirectory()) {
      if (e.name === 'node_modules' || e.name === 'assets') continue;
      walk(p, out);
    } else if (/\.(c?js|mjs)$/.test(e.name)) {
      out.push(p);
    }
  }
  return out;
}

// ---------- 2. 裸包引用提取 ----------
const bareRe =
  /(?:require|import)\s*\(\s*["']([^"']+)["']\s*\)|from\s+["']([^"']+)["']|require\.resolve\s*\(\s*["']([^"']+)["']\s*\)/g;

// 规范化裸包名；非裸包（node: 内置、相对/绝对路径）返回 null
function isBare(s) {
  if (!s) return null;
  if (s.startsWith('node:')) return null;
  if (s.startsWith('.') || s.startsWith('/') || s.startsWith('#')) return null;
  const seg = s.split('/');
  return s.startsWith('@') ? seg.slice(0, 2).join('/') : seg[0];
}

// 从单个文件提取裸引用到 set，返回是否新增
function extractRefs(file, set) {
  let src;
  try {
    src = fs.readFileSync(file, 'utf8');
  } catch {
    return false;
  }
  let added = false;
  let m;
  while ((m = bareRe.exec(src))) {
    const bare = isBare(m[1] || m[2] || m[3]);
    if (bare && !set.has(bare)) {
      set.add(bare);
      added = true;
    }
  }
  return added;
}

const referenced = new Set();
const mainFiles = walk(PKG);
for (const f of mainFiles) extractRefs(f, referenced);

// ---------- 3. 顶层包清单 ----------
function listTop(dir) {
  const out = [];
  if (!fs.existsSync(dir)) return out;
  for (const e of fs.readdirSync(dir, { withFileTypes: true })) {
    if (e.name.startsWith('.')) continue;
    if (e.isDirectory() && e.name.startsWith('@')) {
      for (const sub of fs.readdirSync(path.join(dir, e.name))) {
        out.push(`${e.name}/${sub}`);
      }
    } else if (e.isDirectory()) {
      out.push(e.name);
    }
  }
  return out;
}
const top = listTop(NM);

// ---------- 4. 真实依赖图（含嵌套 node_modules） ----------
// 依赖可能嵌套在父包内（cli-table3/node_modules/string-width），而它自己的依赖又可能
// 被提升到顶层（emoji-regex）。遍历全部 node_modules 建立依赖图（同名多版本合并，
// 保守方向），并记录每个包的实际安装目录（供第 5 步迭代扫描使用）。
const depMap = new Map();
const pkgDirs = new Map(); // name -> [实际目录]
function scanNMDirs(dir) {
  let entries;
  try {
    entries = fs.readdirSync(dir, { withFileTypes: true });
  } catch {
    return;
  }
  for (const e of entries) {
    if (e.name.startsWith('.')) continue;
    const p = path.join(dir, e.name);
    if (!e.isDirectory()) continue;
    if (e.name.startsWith('@')) {
      for (const sub of fs.readdirSync(p)) {
        if (sub.startsWith('.')) continue;
        const sp = path.join(p, sub);
        if (fs.existsSync(path.join(sp, 'package.json'))) addPkg(sp);
        if (fs.existsSync(path.join(sp, 'node_modules'))) scanNMDirs(path.join(sp, 'node_modules'));
      }
      continue;
    }
    if (fs.existsSync(path.join(p, 'package.json'))) addPkg(p);
    if (fs.existsSync(path.join(p, 'node_modules'))) scanNMDirs(path.join(p, 'node_modules'));
  }
}
function addPkg(dir) {
  try {
    const pj = JSON.parse(fs.readFileSync(path.join(dir, 'package.json'), 'utf8'));
    if (!pj.name) return;
    const deps = Object.keys(pj.dependencies || {});
    if (depMap.has(pj.name)) {
      const cur = depMap.get(pj.name);
      for (const d of deps) if (!cur.includes(d)) cur.push(d);
    } else {
      depMap.set(pj.name, [...deps]);
    }
    if (!pkgDirs.has(pj.name)) pkgDirs.set(pj.name, []);
    pkgDirs.get(pj.name).push(dir);
  } catch {
    /* ignore */
  }
}
scanNMDirs(NM);

// ---------- 5. 保留传播 + 迭代扫描，直至收敛 ----------
function propagate() {
  const keep = new Set(referenced);
  let changed = true;
  while (changed) {
    changed = false;
    for (const [name, deps] of depMap) {
      if (!keep.has(name)) continue;
      for (const d of deps) {
        const norm = isBare(d);
        if (norm && !keep.has(norm)) {
          keep.add(norm);
          changed = true;
        }
      }
    }
  }
  return keep;
}

let keep = propagate();
// 迭代：对已保留的包扫描其自身运行时代码（覆盖 workspace 子包内部引用），
// 新增引用后重新传播，直至引用集合不再增长（镜像只会多保留，不会误删）。
const scannedPkgs = new Set();
let refsChanged = true;
while (refsChanged) {
  refsChanged = false;
  for (const name of [...keep]) {
    if (scannedPkgs.has(name)) continue;
    scannedPkgs.add(name);
    for (const dir of pkgDirs.get(name) || []) {
      for (const f of walk(dir)) {
        if (extractRefs(f, referenced)) refsChanged = true;
      }
    }
  }
  if (refsChanged) keep = propagate();
}

// ---------- 6. 字符串宽松兜底：主包代码中出现过包名的顶层包也保留 ----------
function escapeRe(s) {
  return s.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
}
const bufs = mainFiles.map((f) => {
  try {
    return fs.readFileSync(f);
  } catch {
    return null;
  }
});
for (const t of top) {
  if (keep.has(t)) continue;
  const needle = t.startsWith('@') ? t.split('/')[1] : t;
  const re = new RegExp(`\\b${escapeRe(needle)}\\b`, 'i');
  if (bufs.some((b) => b && re.test(b))) keep.add(t);
}

// ---------- 7. 删除未命中的顶层包 ----------
function dirSize(d) {
  let s = 0;
  try {
    for (const e of fs.readdirSync(d, { withFileTypes: true })) {
      const p = path.join(d, e.name);
      s += e.isDirectory() ? dirSize(p) : fs.statSync(p).size;
    }
  } catch {
    /* ignore */
  }
  return s;
}

let freed = 0;
let trimmed = 0;
for (const t of top) {
  if (keep.has(t)) continue;
  const p = path.join(NM, t);
  const sz = dirSize(p);
  if (DRY_RUN) {
    console.log(`[dry-run] would TRIM: ${t} (-${(sz / 1024 / 1024).toFixed(1)}MB)`);
  } else {
    fs.rmSync(p, { recursive: true, force: true });
    console.log(`TRIM: ${t} (-${(sz / 1024 / 1024).toFixed(1)}MB)`);
  }
  freed += sz;
  trimmed++;
}
const suffix = DRY_RUN ? '（干跑，未实际删除）' : '';
console.log(
  `[trim]${suffix} scanned ${mainFiles.length}+ files, ${top.length} top pkgs, kept ${keep.size}, trimmed ${trimmed}, freed ${(freed / 1024 / 1024).toFixed(1)}MB`
);
