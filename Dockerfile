# 阶段一：构建
FROM maven:3.8.5-openjdk-17 AS builder
WORKDIR /app
COPY . .
RUN mvn clean package -DskipTests

# 阶段二：运行
FROM openjdk:17-jdk-slim
WORKDIR /app
# 从构建阶段复制 jar 包
COPY --from=builder /app/target/PvZ-TV-server.jar app.jar

# 创建数据挂载目录
RUN mkdir -p /app/data

# 暴露服务端口（假设游戏服务默认端口是 26667，Dashboard 端口假设为 8080，请按实际修改）
EXPOSE 26667
EXPOSE 8080

# 启动命令：默认运行游戏服务器，把 db 文件指定到 /app/data 目录下（这里假设你的程序支持指定 db 路径，或者默认在当前目录）
ENTRYPOINT ["java", "-jar", "app.jar"]
CMD ["--base=26667"]
