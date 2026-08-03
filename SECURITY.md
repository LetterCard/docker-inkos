# Security Policy

## InkOS Docker 安全策略

本项目：

https://github.com/LetterCard/inkos-docker

为 InkOS 提供 Docker 化部署方案。

目标：

-   稳定运行
-   安全维护
-   可追踪构建
-   透明发布

------------------------------------------------------------------------

# 🔐 安全设计

本项目采用：

    最小化运行环境
    +
    自动漏洞扫描
    +
    软件供应链管理
    +
    版本可追溯

------------------------------------------------------------------------

# 🐳 基础镜像安全

使用：

    node:22-bookworm-slim

优势：

-   官方维护
-   精简系统
-   减少攻击面
-   生命周期明确

------------------------------------------------------------------------

# 🔍 自动安全检测

每次镜像发布流程：

    Docker Build
    ↓
    Trivy Vulnerability Scan
    ↓
    GitHub Security Analysis
    ↓
    SBOM 软件清单生成
    ↓
    Docker Hub 发布

------------------------------------------------------------------------

# 🛡 Trivy 漏洞扫描

扫描：

-   Linux 软件包
-   基础镜像漏洞
-   Node.js 依赖
-   npm 第三方组件
-   已知 CVE

重点关注：

    HIGH
    CRITICAL

------------------------------------------------------------------------

# 📋 SBOM 软件清单

每个版本生成：

    Software Bill of Materials

包含：

-   软件组件
-   版本信息
-   依赖关系

用途：

-   软件供应链审计
-   漏洞追踪
-   安全分析

------------------------------------------------------------------------

# 📊 安全报告

公开报告：

https://github.com/LetterCard/inkos-docker/tree/main/security-reports

包含：

    security-reports/

    ├── security-report.png
    ├── security-status.md
    ├── trivy-report.md
    └── sbom.spdx.json

------------------------------------------------------------------------

# 🔑 密钥管理

本项目不会提交：

    .env
    API Key
    Token
    Secret

用户配置保存在 Docker 持久化目录：

    /data

NAS 示例：

    /vol1/docker/inkos/data

------------------------------------------------------------------------

# 💾 数据安全

用户数据通过 Docker Volume 保存。

包括：

-   API 配置
-   模型配置
-   创作项目
-   Studio 数据

升级镜像不会覆盖用户数据。

------------------------------------------------------------------------

# 🔄 镜像升级安全

流程：

    InkOS 新版本
    ↓
    GitHub Actions 自动构建
    ↓
    Docker Buildx 多架构构建
    ↓
    安全扫描
    ↓
    Docker Hub 发布

支持：

    latest
    版本号标签

------------------------------------------------------------------------

# 🚨 漏洞反馈

Issue:

https://github.com/LetterCard/inkos-docker/issues

建议提供：

-   问题描述
-   影响范围
-   复现方式
-   相关日志
-   环境信息

------------------------------------------------------------------------

# 📦 维护信息

上游：

https://github.com/Narcooo/inkos

镜像：

https://hub.docker.com/r/bugseeker/inkos

维护：

https://github.com/LetterCard/inkos-docker

维护者：

**bugseeker**

------------------------------------------------------------------------

# License

本项目 Docker 化方案遵循 InkOS 原项目许可证。
