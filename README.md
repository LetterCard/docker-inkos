# ✍️ InkOS Docker

InkOS 是一个面向小说与故事创作的 AI Agent 系统。

通过 AI Agent 工作流帮助创作者完成：

- 📖 小说创作
- 🎬 剧本开发
- 🌍 世界观构建
- 🎭 角色设计
- 🔍 内容审核
- ✏️ 自动修改优化

支持写作、审阅、修改等完整创作流程，并提供 Web Studio 工作台。

相比传统源码构建方式：

- 不需要容器启动时编译源码
- 不需要安装完整开发环境
- 不需要重新构建前端资源
- 减少启动阶段任务
- 单目录映射
- 不依赖宿主机 Node.js
- 不需要 SSH 编译环境
- Docker Compose 一键部署

容器启动后即可运行 InkOS Studio。

适合：

- NAS 长期运行
- 家庭服务器
- 云服务器部署


---

## 🪶 轻量化设计

采用：

node:22-bookworm-slim

作为基础镜像。

优势：

✅ 官方维护
✅ Debian 稳定环境
✅ 兼容性强
✅ 减少无用开发依赖

运行环境只包含：

- Node.js
- InkOS Runtime
- 必要系统组件

不包含：

- Git
- 编译工具链
- 源码文件
- 开发依赖

降低镜像体积和攻击面。

---

# 🚀 快速部署

## 创建目录

```bash
mkdir -p /vol1/docker/inkos/data
```

## docker-compose.yml

```yaml
services:
  inkos:
    image: bugseeker/inkos:latest
    container_name: inkos
    restart: unless-stopped
    network_mode: bridge
    ports:
      - "4567:4567"
    volumes:
      - /vol1/docker/inkos/data:/data
    environment:
      TZ: Asia/Shanghai
      INKOS_STUDIO_PORT: 4567
```

## 启动

```bash
docker compose up -d
```

访问：

```
http://NAS-IP:4567
```

---

# ⚙️ 数据持久化

容器：

```
/data
```

宿主机：

```
/vol1/docker/inkos/data
```

目录：

```
data/

├── .env
├── .inkos
├── projects
├── logs
└── 其他运行数据
```

升级、重建、替换镜像不会影响：

- API Key
- 模型配置
- 小说项目
- 创作记录

---

# 🔑 AI 模型配置

InkOS 支持两种配置方式：

## 方式一：Web Studio 配置（推荐）

启动后访问：

```
http://NAS-IP:4567
```

进入：

```
Studio
 ↓
服务配置
```

填写：

- 服务商
- API Key
- Base URL
- 模型名称

保存后配置会持久化到：

```
/data
```

以后更新镜像、重启容器均不会丢失。

---

## 方式二：使用 .env 初始化

创建：

```
/vol1/docker/inkos/data/.env
```

内容：

```env
INKOS_LLM_PROVIDER=openai
INKOS_LLM_BASE_URL=https://api.openai.com/v1
INKOS_LLM_API_KEY=your_api_key
INKOS_LLM_MODEL=gpt-4o
```

支持 OpenAI 兼容接口：

```env
INKOS_LLM_PROVIDER=openai
INKOS_LLM_BASE_URL=https://your-api/v1
INKOS_LLM_API_KEY=your_key
INKOS_LLM_MODEL=model_name
```

首次启动后：

```
/data/.env
```

会作为初始化配置。

进入：

```
Studio
 ↓
服务配置
 ↓
从环境变量导入
```

即可导入。

注意：

`.env` 只是初始化数据。

实际运行配置以：

```
/data
```

中的 Studio 配置为准。

---

# ⚙️ 环境变量

|变量|说明|
|-|-|
|INKOS_STUDIO_PORT|Web Studio端口|
|INKOS_VERSION|固定版本，关闭自动更新|
|INKOS_LLM_PROVIDER|模型服务商|
|INKOS_LLM_BASE_URL|OpenAI兼容接口地址|
|INKOS_LLM_API_KEY|API Key|
|INKOS_LLM_MODEL|模型名称|

---

# 🔄 自动更新架构

```
@actalk/inkos 发布新版
↓
GitHub Actions 定时检测
↓
自动更新 VERSION
↓
Docker Buildx 构建
↓
发布 Docker 镜像
```

---

# 🏗 自动构建流程

```
InkOS 新版本发布
↓
npm Registry
↓
GitHub Actions
↓
Docker Buildx
↓
linux/amd64 + linux/arm64
↓
安全扫描
↓
Docker Hub 发布
```

---

# 🖥 支持架构

```
linux/amd64
linux/arm64
```

---

# 🏷 镜像版本

最新版：

```
bugseeker/inkos:latest
```

固定版本：

```
bugseeker/inkos:版本号
```

---

# 🔐 安全体系

基础镜像：

```
node:22-bookworm-slim
```

自动执行：

✅ Trivy 漏洞扫描

✅ GitHub Security 检测

✅ SBOM 软件清单生成

安全报告：

https://github.com/LetterCard/inkos-docker/tree/main/security-reports

![InkOS Docker Security Report](https://raw.githubusercontent.com/LetterCard/inkos-docker/refs/heads/main/security-reports/security-report.png)

---

# 📦 项目来源

InkOS：

https://github.com/Narcooo/inkos

Docker：

https://github.com/LetterCard/inkos-docker

Docker Hub：

https://hub.docker.com/r/bugseeker/inkos

---

# License

遵循 InkOS 原项目许可证。
