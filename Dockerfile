FROM eclipse-temurin:17-jre-focal
WORKDIR /app

# 创建所需目录
RUN mkdir -p /app/lib /app/data

# 1. 精准复制主 Jar 包
COPY target/*.jar /app/lib/PvZ-TV-server.jar

# 2. 安全地复制可选的 lib 目录（优雅兼容没有 lib 目录的情况）
# 利用 Docker 的通配符特性：如果 target/ 目录下没有 lib 文件夹，这一行会被自动忽略而不会报错
COPY target/li[b]/ /app/lib/

EXPOSE 26667
EXPOSE 8080

ENTRYPOINT ["java", "-jar", "/app/lib/PvZ-TV-server.jar"]
CMD ["--base=26667"]
