<div align="center">

# ✍️ InkOS Docker

**InkOS —— 面向小说与故事创作的 AI Agent 系统**

通过 Agent 工作流辅助创作 · 审阅 · 修改，内置 Web Studio 工作台

✨ 构建与更新全在云端 · 🚀 秒级启动 · 📁 单目录持久化 · 🔄 长期自动维护

适用于 **NAS** · **家庭服务器** · **云服务器**

[![Docker Pulls](https://img.shields.io/docker/pulls/bugseeker/inkos?label=拉取量)](https://hub.docker.com/r/bugseeker/inkos)
[![Docker Image Version](https://img.shields.io/docker/v/bugseeker/inkos/latest?label=最新版本)](https://hub.docker.com/r/bugseeker/inkos)
[![Docker Image Size](https://img.shields.io/docker/image-size/bugseeker/inkos/latest?label=镜像大小)](https://hub.docker.com/r/bugseeker/inkos)
[![Last Updated](https://img.shields.io/badge/dynamic/json?url=https%3A%2F%2Fhub.docker.com%2Fv2%2Frepositories%2Fbugseeker%2Finkos%2Ftags%2Flatest&query=last_updated&label=最近构建&color=blue)](https://hub.docker.com/r/bugseeker/inkos)
[![Arch](https://img.shields.io/badge/架构-linux%2Famd64%20%2B%20arm64-4c9f38)](https://hub.docker.com/r/bugseeker/inkos)
[![Registry](https://img.shields.io/badge/推送-Docker%20Hub%20%2B%20GHCR-blue)](https://hub.docker.com/r/bugseeker/inkos)

<sub>徽章数据全部来自 Docker Hub 公开 API，无需登录；构建成败详情见 [GitHub Actions](https://github.com/LetterCard/inkos/actions)（代码仓库为私有）</sub>

</div>

---

## 🎯 核心能力

| 📖 小说创作 | 🎬 剧本开发 | 🌍 世界观构建 | 🎭 角色设计 |
| :-: | :-: | :-: | :-: |
| 🔍 内容审核 | ✏️ 自动修改 | 🧠 Agent 工作流 | 🖥 Web Studio |

---

## 📥 镜像拉取

🐳 从 Docker Hub 拉取
```bash
docker pull bugseeker/inkos:latest
```
🐙 从 GitHub Container Registry 拉取
```bash
docker pull ghcr.io/lettercard/inkos:latest
```

💡 提示：两个镜像内容完全一致，选择离你网络更近的注册中心即可获得更快的下载速度。
---

## 🚀 快速部署

### 1️⃣ 创建数据目录

```bash
mkdir -p /vol1/docker/inkos/data
```

### 2️⃣ 编写 docker-compose.yml

```yaml
services:
  inkos:
    # 镜像由云端 CI（GitHub Actions）每日自动构建并推送 Docker Hub。
    # 升级方式：docker compose pull && docker compose up -d
    image: bugseeker/inkos:latest
    container_name: inkos
    restart: unless-stopped
    network_mode: bridge
    ports:
      - "4567:4567"
    volumes:
      # 唯一持久化目录：项目配置、小说数据、API Key、.env 全部在此
      - /vol1/docker/inkos/data:/data
    environment:
      TZ: Asia/Shanghai
      INKOS_STUDIO_PORT: 4567
      # 可选：首次启动时自动写入 /data/.env（项目级初始化配置，之后以 Studio 配置为准）
      # INKOS_LLM_PROVIDER=openai
      # INKOS_LLM_BASE_URL=https://api.openai.com/v1
      # INKOS_LLM_API_KEY=your_api_key
      # INKOS_LLM_MODEL=gpt-4o
```

### 3️⃣ 启动

```bash
docker compose up -d
```

> 🚀 启动仅做本地文件操作、无网络请求，**秒级可用**。访问 `http://NAS-IP:4567`

---

## 📁 数据持久化

只映射 **一个目录**：`/vol1/docker/inkos/data` → `/data`。`/data` 即 InkOS 项目根目录，结构与原项目完全一致：

```
data/
├── inkos.json            # 项目配置（Studio 服务配置）
├── .env                  # 项目级 .env（初始化配置）
├── .inkos/               # 全局配置 + 运行数据
│   ├── .env              # 全局 ~/.inkos/.env
│   ├── secrets.json      # 🔑 API Key
│   ├── materials/        # 素材库
│   ├── sessions/         # 会话记录
│   ├── uploads/          # 上传文件
│   ├── skills/           # 外部技能
│   └── tasks/            # 后台任务
├── books/                # 小说项目（memory.db / play.db）
└── radar/                # 雷达监控数据
```

### 📄 .env 位置（无需额外映射）

| 类型 | 容器内 | 宿主机 |
| :- | :- | :- |
| 项目级 `.env` | `/data/.env` | `$DATA_DIR/.env` |
| 全局 `~/.inkos/.env` | `/root/.inkos/.env` ⟶ `/data/.inkos/.env`（软链接）| `$DATA_DIR/.inkos/.env` |

> 💡 两个 `.env` 都在 `/data` 内，升级镜像不丢失。Studio「从环境变量导入」优先级：**项目级 > 全局**

---

## 🔑 AI 模型配置

### 🖥 方式一：Web Studio（推荐）

访问 `http://NAS-IP:4567` → **Studio → 服务配置**，填写服务商 / API Key / Base URL / 模型。

配置持久化到 `inkos.json` + `.inkos/secrets.json`，更新镜像不丢失。

### 📝 方式二：.env 初始化

在 compose `environment` 中提供，或手动创建 `/data/.env`，首次启动自动写入：

```env
INKOS_LLM_PROVIDER=openai
INKOS_LLM_BASE_URL=https://api.openai.com/v1
INKOS_LLM_API_KEY=your_api_key
INKOS_LLM_MODEL=gpt-4o
```

随后 **Studio → 服务配置 → 从环境变量导入** 即可生效。

> ⚠️ `.env` 仅作初始化，实际运行配置以 Studio 为准

---

## ⚙️ 环境变量

| 变量 | 说明 |
| :- | :- |
| `INKOS_STUDIO_PORT` | Web Studio 端口 |
| `INKOS_VERSION` | 镜像构建版本（信息性）|
| `INKOS_LLM_PROVIDER` | 模型服务商 |
| `INKOS_LLM_BASE_URL` | OpenAI 兼容接口地址 |
| `INKOS_LLM_API_KEY` | API Key |
| `INKOS_LLM_MODEL` | 模型名称 |

---

## 🔄 自动更新

1. **每日检测**（UTC 03:00）— 检查 npm 上游新版本；Docker Hub 已有同版本则跳过本次构建
2. **冒烟测试** — 构建 amd64 并启动容器，验证 Studio HTTP 与 CLI，通过才继续
3. **正式构建** — linux/amd64 + linux/arm64 双架构
4. **推送镜像** — Docker Hub + GHCR（`latest` + 版本号）
5. **漏洞扫描** — Trivy（HIGH/CRITICAL，报告模式，不阻断自动更新）

- ✅ 构建 / 更新全在云端，本地只拉镜像，**零构建资源占用**
- ✅ 镜像内禁止自更新：版本在云端固定，行为可预测、可回滚
- ✅ 镜像带 `version` / `revision` / `created` 标签，全程可追溯


**更新容器：**

```bash
docker compose pull && docker compose up -d
```

> 💡 **回滚**：将 compose 中 `image` 改为固定版本号（如 `bugseeker/inkos:1.0.0`），再执行 `docker compose up -d`

**或 Watchtower 全自动更新：**

```bash
docker run -d --name watchtower \
  -v /var/run/docker.sock:/var/run/docker.sock \
  containrrr/watchtower --cleanup
```

---

## 🖥 镜像信息

| 🏷 标签 | 🖥 架构 | 🪶 基础镜像 |
| :- | :- | :- |
| `:latest` 最新<br>`:版本号` 固定回滚 | linux/amd64<br>linux/arm64 | `node:22-alpine`（极简运行时，不含构建产物）<br>自带 node:sqlite 加速 |

> 📦 体积：构建时自动扫描运行时代码引用，动态裁剪未被引用的死重，对上游任意版本自适应。

---

## 📦 项目来源

| | |
| :- | :- |
| InkOS | https://github.com/Narcooo/inkos |
| Docker | https://github.com/LetterCard/inkos |
| Docker Hub | https://hub.docker.com/r/bugseeker/inkos |
| GHCR | https://github.com/users/lettercard/packages/container/package/inkos |

---

<div align="center">

遵循 InkOS 原项目许可证 · Made with ❤️

</div>
