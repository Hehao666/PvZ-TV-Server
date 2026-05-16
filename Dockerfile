FROM eclipse-temurin:17-jre-alpine

# 安装工具
RUN apk add --no-cache sqlite bash curl

WORKDIR /app

# 直接复制 jar 文件
COPY target/PvZ-TV-server.jar /app/app.jar

# 创建数据目录
RUN mkdir -p /app/data /app/logs

EXPOSE 26667 8080

# 健康检查
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:26667/health || exit 1

# 使用 exec 形式支持参数传递
ENTRYPOINT ["java", "-jar", "/app/app.jar"]
