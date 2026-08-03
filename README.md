# ✍️ InkOS Docker

InkOS 是一个面向小说与故事创作的 AI Agent 系统。
通过 AI Agent 工作流帮助创作者完成：
- 📖 小说创作
- 🎬 剧本开发
- 🌍 世界观构建
- 🎭 角色设计
- 🔍 内容审核
- ✏️ 自动修改优化
支持写作、审阅、修改等完整创作流程，
并提供 Web Studio 工作台。
通过 Docker 快速部署自己的 AI 创作环境。

---

# 🚀 快速部署

## 创建目录
```bash
mkdir -p /vol1/docker/inkos/{config,workspace,logs}
```
---
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
      # InkOS 全局配置
      # API Key / 模型配置
      - /vol1/docker/inkos/config:/root/.inkos

      # 创作项目目录
      # 小说 / 剧本 / 世界观数据
      - /vol1/docker/inkos/workspace:/workspace

      # 日志
      - /vol1/docker/inkos/logs:/logs
    environment:
      TZ: Asia/Shanghai
```
启动：

```bash
docker compose up -d
```
访问：

```
http://NAS-IP:4567
```

---

# ⚙️ 配置参数

## Docker 环境变量
|变量|默认值|说明|
|-|-|-|
|TZ|Asia/Shanghai|时区|
---
## InkOS 配置
位置：
```
/vol1/docker/inkos/config/.env
```
示例：

```env
INKOS_LLM_PROVIDER=openai
INKOS_LLM_BASE_URL=https://api.openai.com/v1
INKOS_LLM_API_KEY=your_api_key
INKOS_LLM_MODEL=gpt-4.1
```

---

## 项目配置
位置：

```
workspace/项目名称/.env
```
用于：
- 单项目模型
- 独立 API
- 创作参数

---

# 🔄 更新镜像

拉取：

```bash
docker compose pull
```
重启：
```bash
docker compose up -d
```

---

# 💾 数据持久化

Docker 镜像只负责运行环境。
用户数据独立保存。
|宿主机目录|容器目录|用途|
|-|-|-|
|config|/root/.inkos|配置文件|
|workspace|/workspace|项目数据|
|logs|/logs|运行日志|

升级镜像不会影响：
- API 配置
- 小说项目
- 创作记录

---

# 🐳 为什么使用这个 Docker 镜像？

官方 InkOS 更偏向开发者安装方式。
本项目将 InkOS 封装为长期运行的 Docker 服务，
方便部署到：
- NAS
- 家庭服务器
- 云服务器
- Linux 主机
提供：
✅ 一键部署
✅ 自动跟随上游版本
✅ 固定版本镜像
✅ amd64 / arm64 支持
✅ 数据持久化
✅ 自动安全检测

---

# 📦 项目来源

## 上游项目
InkOS：
https://github.com/Narcooo/inkos

---

## Docker 化方案

负责：
- Docker 镜像构建
- CI/CD 自动化
- 版本同步
- 安全检测
- NAS 部署优化

---

# 🐳 镜像维护

Docker Hub：
https://hub.docker.com/r/bugseeker/inkos

维护仓库：
https://github.com/LetterCard/inkos-docker

---

# ⚙️ 镜像特性

## 🔄 自动跟随上游版本
自动检测 InkOS 更新。
版本来源：
```
GitHub Release Tag
↓
package.json version
↓
Docker Image
```
镜像版本与源码版本保持一致。

---

## 🏗 自动构建流程
```
InkOS 更新
↓
GitHub Actions
↓
指定版本源码构建
↓
Docker Buildx
↓
安全扫描
↓
SBOM生成
↓
Docker Hub发布
```

---

## 🖥 支持架构
```
linux/amd64
linux/arm64
```
适用于：
- Intel NAS
- AMD NAS
- ARM服务器
- 云服务器

---

# 🏷 镜像版本

最新版：
```
bugseeker/inkos:latest
```
固定版本：
```
bugseeker/inkos:v版本号
```
例如：
```
bugseeker/inkos:v1.7.1
```
支持：
- 最新体验
- 稳定部署
- 历史回滚

---

# 🔐 安全体系

本镜像采用自动化安全流程。

## 基础镜像
```
node:22-bookworm-slim
```
特点：
- 官方维护
- 精简系统
- 减少攻击面

---

## 自动安全检测
每次发布执行：
✅ Trivy 漏洞扫描
✅ GitHub Security 检测
✅ SBOM 软件清单生成
检测：
- 系统依赖
- Node.js 依赖
- 软件组件风险

---

## 安全报告
最新安全报告：
https://github.com/LetterCard/inkos-docker/tree/main/security-reports

![InkOS Docker Security Report](https://raw.githubusercontent.com/LetterCard/inkos-docker/refs/heads/main/security-reports/security-report.png)

```
security-reports/
│
├── security-report.png      ⭐ Docker Hub展示
│
├── security-status.md       简洁状态
│
├── trivy-report.md          完整漏洞扫描
│
└── sbom.spdx.json           软件供应链清单
```

---

# 🙏 致谢

感谢：

InkOS 作者：
https://github.com/Narcooo/inkos

Docker 维护：
https://github.com/LetterCard/inkos-docker

感谢开源社区贡献。

---

# License

遵循 InkOS 原项目许可证。
