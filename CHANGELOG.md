# Changelog


InkOS Docker 镜像版本记录。



格式：

```
版本

发布日期

变更内容

安全状态
```



---

# v0.0.0


发布日期：

2026-08-03



状态：

Initial Release



内容：


- 首次发布 InkOS Docker 镜像
- 基于 node:22-bookworm-slim
- 支持 Docker Compose
- 支持 amd64 / arm64
- 集成 GitHub Actions 自动构建
- 集成 Trivy 安全扫描
- 集成 SBOM 生成



安全：

```
PASS
```



---

# 后续版本


示例：


## v1.x.x


更新：

- 同步 InkOS 上游版本
- 更新 Docker 依赖
- 优化构建流程


安全：

```
PASS
```


---

# 版本规则


镜像版本跟随 InkOS 上游版本。


例如：


上游：

```
v1.2.0
```


Docker：

```
bugseeker/inkos:v1.2.0
```



同时保持：


```
bugseeker/inkos:latest
```



---

# 发布流程


```
上游更新

↓

自动检测

↓

构建镜像

↓

安全扫描

↓

生成SBOM

↓

发布Docker Hub

↓

更新Release
```


