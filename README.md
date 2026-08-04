<div align="center">

# ✍️ InkOS Docker

**InkOS —— 面向小说与故事创作的 AI Agent 系统**

通过 Agent 工作流辅助创作 · 审阅 · 修改，内置 Web Studio 工作台

✨ 构建与更新全在云端 · 🚀 秒级启动 · 📁 单目录持久化 · 🔄 长期自动维护

适用于 **NAS** · **家庭服务器** · **云服务器**

</div>

---

## 🎯 核心能力

| 📖 小说创作 | 🎬 剧本开发 | 🌍 世界观构建 | 🎭 角色设计 |
| :-: | :-: | :-: | :-: |
| 🔍 内容审核 | ✏️ 自动修改 | 🧠 Agent 工作流 | 🖥 Web Studio |

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

```
InkOS 发布新版 → GitHub Actions 每日检测（UTC 03:00）
→ 云端构建 amd64 + arm64 → Trivy 漏洞扫描 → 推送 Docker Hub
```

- ✅ 构建 / 更新全在云端，本地只拉镜像，**零构建资源占用**
- ✅ 镜像内不自更新：版本在云端固定，行为可预测、可回滚
- ✅ 镜像带 `version` / `revision` / `created` 标签，全程可追溯

**更新容器：**

```bash
docker compose pull && docker compose up -d
```

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
| `:latest` 最新<br>`:版本号` 固定回滚 | linux/amd64<br>linux/arm64 | `node:22-bookworm-slim`<br>自带 node:sqlite 加速 |

---

## 📦 项目来源

| | |
| :- | :- |
| InkOS | https://github.com/Narcooo/inkos |
| Docker | https://github.com/LetterCard/inkos-docker |
| Docker Hub | https://hub.docker.com/r/bugseeker/inkos |

---

<div align="center">

遵循 InkOS 原项目许可证 · Made with ❤️

</div>
