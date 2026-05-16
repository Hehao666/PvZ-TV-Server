# 换成完美支持 arm64 的 focal(Ubuntu) 或 standard 镜像
FROM eclipse-temurin:17-jre-focal
WORKDIR /app

# 创建目录
RUN mkdir -p /app/lib /app/data

# 复制宿主机编译好的 jar 包
COPY target/*.jar /app/lib/PvZ-TV-server.jar
COPY target/lib/* /app/lib/ 2>/dev/null || true

EXPOSE 26667
EXPOSE 8080

ENTRYPOINT ["java", "-jar", "/app/lib/PvZ-TV-server.jar"]
CMD ["--base=26667"]
