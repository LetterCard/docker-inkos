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

本项目将 InkOS 封装为长期运行 Docker 服务，方便部署到 NAS、服务器以及云环境。

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

第三版架构统一使用：

```
/data
```

宿主机：

```
/vol1/docker/inkos/data
```

目录映射：

|宿主机|容器|用途|
|-|-|-|
|data|/data|InkOS全部数据|

升级镜像不会影响：

- API Key
- 模型配置
- 小说项目
- 创作记录

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
