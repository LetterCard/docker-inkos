# Security Policy


## InkOS Docker 安全策略


本项目致力于提供一个：

- 稳定
- 可维护
- 可审计

的 InkOS Docker 运行环境。


本镜像由：

**bugseeker**

维护。



---

# 🔐 安全设计原则


本 Docker 镜像遵循：


```
最小化运行环境

+

自动漏洞检测

+

供应链透明

+

数据隔离
```



---

# 🐳 基础镜像安全


使用：


```
node:22-bookworm-slim
```


原因：


- 官方维护
- 生命周期明确
- 系统组件精简
- 减少攻击面



---

# 🔍 自动漏洞扫描


每次镜像发布流程：


```
Docker Build

↓

Trivy Scan

↓

SBOM Generate

↓

Docker Hub Release
```



---

## Trivy 检测范围


扫描：


### 系统层


包括：

- Debian 软件包
- 系统库
- 已知 CVE



### 应用层


包括：

- Node.js 依赖
- npm package
- 第三方组件



重点关注：


```
HIGH

CRITICAL
```



---

# 📋 SBOM 软件清单


每个版本自动生成：


```
Software Bill of Materials
```



记录：


- 软件名称
- 软件版本
- 依赖关系
- 软件来源



用途：


- 软件供应链管理
- 安全审计
- 漏洞追踪



---

# 🔄 镜像发布安全流程


完整流程：


```
InkOS 上游更新

        ↓

版本检测

        ↓

Docker Buildx

        ↓

镜像生成

        ↓

漏洞扫描

        ↓

SBOM生成

        ↓

Docker Hub发布
```



---

# 📦 数据安全


本镜像不会把用户数据写入镜像。


所有用户数据通过 Volume 保存。


包括：


```
/root/.inkos

/workspace

/logs
```



升级镜像时：

不会覆盖：

- API 配置
- 小说项目
- 创作数据



---

# 🔑 密钥管理


推荐：

不要将：

```
.env

secrets.json

API Key
```


提交到 GitHub。



建议：

保存于：

```
/vol1/docker/inkos/config
```



---

# 🛡 私有 CI/CD


本镜像构建仓库采用私有 GitHub 仓库。


目的：

- 保护 CI/CD 配置
- 防止泄露构建细节
- 保护 Docker Hub 发布凭证



公开信息：

- Docker 镜像
- README
- 安全说明



---

# 🚨 漏洞反馈


如果发现安全问题：

请通过项目维护渠道反馈。



请提供：

- 问题描述
- 影响范围
- 复现方式
- 相关日志



我们会尽快评估并处理。



---

# 安全更新原则


当发现严重漏洞：

将优先：

1. 修复构建环境
2. 更新基础镜像
3. 重新扫描
4. 发布修复版本


