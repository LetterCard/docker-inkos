
# 🌟 什么是 InkOS？

InkOS 是一个专注于**故事创作（Story Creation）的 AI Agent 系统**。

它不是简单的文本生成工具，而是一个围绕创作流程设计的智能创作助手。

InkOS 可以帮助创作者从：

```
创意构思
    ↓
世界观设计
    ↓
角色设定
    ↓
剧情规划
    ↓
章节创作
    ↓
内容修改
    ↓
多语言输出
```

完成完整的故事生产流程。

适用于：

- 小说作者
- 编剧
- 游戏剧情设计者
- IP 创作者
- 内容创作者

---

# 🚀 InkOS 可以做什么？

## 📚 长篇小说创作

帮助创建和维护：

- 世界观
- 人物关系
- 故事情节
- 章节内容
- 长篇连载上下文

适用于：

- 网络小说
- 系列故事
- 长篇作品

---

## 🎬 剧本与 IP 创作

支持：

- 影视剧本
- 游戏剧情
- 互动故事
- IP 世界观开发

帮助创作者快速完成：

```
想法
    ↓
设定
    ↓
剧情
    ↓
成稿
```

---

## 🎮 互动故事创作

支持管理：

- 角色状态
- 世界规则
- 剧情分支
- 故事变量

适合：

- 互动小说
- 文字游戏
- 开放世界故事

---

## 🌍 多语言创作

支持：

- 多语言写作
- 内容翻译
- 术语保持
- 跨语言创作

帮助作品面向更多语言市场。

---

# 🐳 为什么使用这个 Docker 镜像？

原始 InkOS 项目主要面向开发环境。

本项目将 InkOS 进行 Docker 化适配，让它更加适合长期运行。

**目标：** 让用户无需配置复杂 Node 环境，即可运行自己的 InkOS 服务。

**提供：**

- ✅ 一键部署
- ✅ 自动更新
- ✅ 多架构支持
- ✅ NAS 支持
- ✅ 数据持久化
- ✅ 自动安全检测
- ✅ Docker Compose 部署

---

# 📦 项目来源

## 上游项目

**InkOS：** https://github.com/Narcooo/inkos

---

## Docker 化方案

本镜像 Dockerfile 基于 **LetterCard Docker 方案**。

维护：https://github.com/LetterCard

---

## 镜像维护

**Docker 镜像：** `bugseeker/inkos`

由 **bugseeker** 负责维护，包括：

- Docker 镜像构建
- 自动化发布
- NAS 部署优化
- 安全检测流程

---

# ⚙️ 镜像特性

## 🔄 自动跟随上游版本

自动检测 InkOS 更新。

**版本获取优先级：**

```
Git Release Tag
    ↓
package.json version
    ↓
Docker 镜像发布
```

---

## 🏗 自动化构建

完整流程：

```
InkOS 更新
    ↓
GitHub Actions
    ↓
Docker Buildx
    ↓
安全扫描
    ↓
Docker Hub 发布
```

无需人工重新编译。

---

## 🖥 多架构支持

支持：

```
linux/amd64
linux/arm64
```

适用于：

- Intel NAS
- AMD NAS
- ARM 服务器
- 云服务器

---

## 🏷 版本管理

镜像提供：

- **最新版本：** `bugseeker/inkos:latest`
- **固定版本：** `bugseeker/inkos:v版本号`

支持：

- 最新体验
- 稳定部署
- 历史回滚

---

# 🔐 安全体系

长期运行服务，安全非常重要。本镜像建立自动化安全流程。

---

## 基础镜像

采用：`node:22-bookworm-slim`

优势：

- 官方维护
- 精简系统
- 减少攻击面
- 定期更新

---

## 漏洞扫描

每次镜像发布后自动执行 **Trivy Security Scan**。

检测：

- 系统软件漏洞
- Node.js 依赖
- npm 组件风险

重点关注：`HIGH` 与 `CRITICAL`

---

## SBOM 软件清单

自动生成 **Software Bill of Materials**。

包含：

- 软件组件
- 依赖版本
- 软件来源

用于：

- 软件供应链管理
- 漏洞追踪
- 安全审计

---

## 安全报告

安全扫描结果保存于 `GitHub Actions Artifact`。

由于 CI/CD 仓库采用私有模式：

- 不公开内部构建信息
- 不泄露扫描细节
- 保留完整审计记录

---

# 💾 数据持久化

所有用户数据通过 Docker Volume 保存。

**目录：**

```
/root/.inkos
/data/books
/data/logs
```

更新镜像不会影响：

- 创作项目
- 配置文件
- 日志

---

# 🏠 Docker Compose 部署

适用于：

- 飞牛 NAS
- 群晖 NAS
- 威联通
- Linux 服务器

---

## 创建目录

```
/vol1/docker/inkos
├── config
├── books
└── logs
```

---

## docker-compose.yml

```yaml
services:
  inkos:
    image: bugseeker/inkos:latest
    container_name: inkos
    restart: unless-stopped
    ports:
      - "4567:4567"
    volumes:
      - /vol1/docker/inkos/config:/root/.inkos
      - /vol1/docker/inkos/books:/data/books
      - /vol1/docker/inkos/logs:/data/logs
    environment:
      TZ: Asia/Shanghai
```

**启动：**

```bash
docker compose up -d
```

**访问：** http://NAS-IP:4567

---

# 🔄 更新镜像

获取最新版本：

```bash
docker compose pull
```

重新启动：

```bash
docker compose up -d
```

---

# 📌 镜像地址

**Docker Hub：** https://hub.docker.com/r/bugseeker/inkos

**镜像：** `bugseeker/inkos`

---

# 🙏 致谢

感谢：

- **InkOS：** https://github.com/Narcooo/inkos
- **Docker 化方案：** https://github.com/LetterCard

感谢开源社区贡献。

---

# License

遵循 InkOS 原项目许可证。
