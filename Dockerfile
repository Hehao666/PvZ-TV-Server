# 阶段一：构建阶段 (使用多架构支持良好的 Maven 镜像)
FROM maven:3.8.5-eclipse-temurin-17 AS builder
WORKDIR /app
COPY . .
RUN mvn clean package -DskipTests

# 阶段二：运行阶段 (多架构支持，JRE 体积更小，完美支持 arm64)
FROM eclipse-temurin:17-jre-focal
WORKDIR /app
COPY --from=builder /app/target/PvZ-TV-server.jar app.jar

RUN mkdir -p /app/data
EXPOSE 26667
EXPOSE 8080

ENTRYPOINT ["java", "-jar", "app.jar"]
CMD ["--base=26667"]
