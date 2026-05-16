# 多阶段构建
FROM maven:3.9-eclipse-temurin-17 AS builder

WORKDIR /build
COPY pom.xml .
RUN mvn dependency:go-offline

COPY src ./src
RUN mvn clean package -DskipTests

# 运行阶段 - 使用支持多架构的镜像
FROM eclipse-temurin:17-jre

WORKDIR /app

# 安装工具（使用 apt）
RUN apt-get update && \
    apt-get install -y sqlite3 curl bash && \
    rm -rf /var/lib/apt/lists/*

COPY --from=builder /build/target/PvZ-TV-server*.jar /app/app.jar

RUN mkdir -p /app/data /app/logs

EXPOSE 26667 8080

HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
  CMD curl -f http://localhost:26667/health || exit 1

ENTRYPOINT ["java", "-jar", "/app/app.jar"]
