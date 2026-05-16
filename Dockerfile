# 只需要运行环境，选择对 ARM64 极其友好的 Alpine 镜像
FROM eclipse-temurin:17-jre-alpine
WORKDIR /app

# 1. 创建你的程序需要的目录
RUN mkdir -p /app/lib /app/data

# 2. 关键：直接将 GitHub Actions 在宿主机已经打包好的 target 里的东西复制进来
# 这样能绝对保证 /app/lib/PvZ-TV-server.jar 存在
COPY target/*.jar /app/lib/PvZ-TV-server.jar

# 3. 顺便把可能存在的依赖库、第三方 jar 也拷贝进去（防止报 ClassNotFound 错误）
COPY target/lib/* /app/lib/ 2>/dev/null || true

# 暴露端口
EXPOSE 26667
EXPOSE 8080

# 启动路径完美契合报错日志
ENTRYPOINT ["java", "-jar", "/app/lib/PvZ-TV-server.jar"]
CMD ["--base=26667"]
