# ============ 第一阶段：Maven 构建 ============
FROM maven:3.9-eclipse-temurin-17 AS builder
WORKDIR /build
COPY pom.xml .
RUN mvn dependency:go-offline -B
COPY src ./src
RUN mvn clean package -DskipTests -B
# 将 target 下的第一个 JAR 复制并重命名为 app.jar，避免文件名不通配问题
RUN cp "$(ls /build/target/*.jar | head -1)" /build/app.jar

# ============ 第二阶段：运行镜像 ============
FROM eclipse-temurin:17-jre-focal
WORKDIR /app
RUN mkdir -p /app/lib /app/data
COPY --from=builder /build/app.jar /app/lib/PvZ-TV-server.jar
WORKDIR /app/data
EXPOSE 26667/tcp
EXPOSE 26667/udp

# 主类名通过环境变量配置（需自行替换为真实主类）
ENV MAIN_CLASS=org.marshive.DashboardServer

# 使用 java -cp 启动，避开 manifest 缺失问题
ENTRYPOINT java -cp /app/lib/PvZ-TV-server.jar $MAIN_CLASS --base=26667
