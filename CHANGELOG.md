# Changelog


InkOS Docker 镜像版本记录。


---

# v0.0.0


发布日期：

2026-08-03



状态：

Initial Release



## 新增


- 首次发布 InkOS Docker 镜像
- 基于 node:22-bookworm-slim
- 支持 Docker Compose 部署
- 支持 amd64 / arm64
- 集成 GitHub Actions 自动构建
- 自动同步 InkOS 上游版本
- 集成 Trivy 安全扫描
- 集成 GitHub Security
- 自动生成 SBOM



## 数据目录


支持：


```
/root/.inkos

/workspace

/logs
```



## 安全状态


```
PASS
```



---

# 版本规则


Docker 镜像版本跟随 InkOS 上游版本。


例如：


InkOS:

```
v1.2.0
```


Docker:

```
bugseeker/inkos:v1.2.0
```



同时维护：

```
bugseeker/inkos:latest
```



---

# 发布流程


```
上游更新

↓

版本检测

↓

源码固定版本构建

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

# 维护仓库


https://github.com/LetterCard/inkos-docker


维护者：

bugseeker
