# ✍️ InkOS Docker

## Story Creation AI Agent


InkOS 是一个面向小说与故事创作的 AI Agent 系统。


帮助创作者完成：

- 📖 小说创作
- 🎬 剧本开发
- 🌍 世界观构建
- 🎭 角色设计
- 🔄 内容审阅与修改


通过 Docker 快速部署自己的 AI 创作工作空间。


---

# 🐳 为什么使用这个 Docker 镜像？


官方 InkOS 更偏向开发者安装方式。


本项目将 InkOS 封装为长期运行的 Docker 服务。


适合：

- NAS 用户
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



## Docker 化方案

https://github.com/LetterCard



## 镜像维护

Docker Hub：

```
bugseeker/inkos
```


维护者：

**bugseeker**


负责：

- Docker 构建
- CI/CD 自动化
- 镜像发布
- 安全检测
- NAS 部署优化



---

# ⚙️ 镜像特性


## 🔄 自动跟随上游版本


自动检测 InkOS 更新。


版本优先级：

```
GitHub Release Tag

↓

package.json version

↓

Docker Image
```


无需手动重新构建。


---

## 🏗 自动构建流程


```
InkOS 更新

↓

GitHub Actions

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


最新版本：

```
bugseeker/inkos:latest
```


固定版本：

```
bugseeker/inkos:v版本号
```


例如：

```
bugseeker/inkos:v1.2.0
```


支持：

- 最新体验
- 稳定部署
- 历史回滚



---

# 🔐 安全体系


镜像采用自动化安全检测流程。


## 基础镜像

```
node:22-bookworm-slim
```


特点：

- 官方维护
- 精简系统
- 减少攻击面



## 自动检测


每次发布执行：

- Trivy 漏洞扫描
- Node.js 依赖检查
- SBOM 软件清单生成


重点关注：

```
HIGH

CRITICAL
```


详细安全说明：

见：

```
SECURITY.md
```


---

# 💾 数据持久化


Docker 镜像只负责运行环境。


用户数据独立保存。


目录：

|宿主机|容器|用途|
|-|-|-|
|config|/root/.inkos|InkOS配置|
|workspace|/workspace|项目数据|
|logs|/logs|运行日志|


升级镜像不会影响：

- API 配置
- 小说项目
- 创作数据



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

    ports:
      - "4567:4567"

    volumes:
      - /vol1/docker/inkos/config:/root/.inkos
      - /vol1/docker/inkos/workspace:/workspace
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

## InkOS 全局配置


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

INKOS_DEFAULT_LANGUAGE=zh
```


---

## 项目级配置


位置：

```
workspace/项目名称/.env
```


用于：

- 独立模型
- 独立 API
- 单项目参数



优先级：

```
项目 .env

↓

全局 .env

↓

Docker environment
```


---

# 🔄 更新


拉取最新镜像：

```bash
docker compose pull
```


重新启动：

```bash
docker compose up -d
```


---

# 📌 镜像地址


Docker Hub：

https://hub.docker.com/r/bugseeker/inkos


镜像：

```
bugseeker/inkos
```



---

# 🙏 致谢


InkOS：

https://github.com/Narcooo/inkos


Docker 方案：

https://github.com/LetterCard



感谢开源社区贡献。



---

# License


遵循 InkOS 原项目许可证。
