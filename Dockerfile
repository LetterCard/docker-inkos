FROM node:22-bookworm

# 设置工作目录
WORKDIR /app

# 启用 Corepack 并激活 pnpm
RUN corepack enable && \
    corepack prepare pnpm@9 --activate

# 克隆 InkOS 源码
RUN git clone https://github.com/Narcooo/inkos.git .

# 安装依赖并构建项目
RUN pnpm install --frozen-lockfile && \
    pnpm build

# 全局安装 CLI
RUN npm install -g .

# 切换到数据目录
WORKDIR /data

# 启动命令
CMD ["inkos"]
