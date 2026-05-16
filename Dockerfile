# 第一阶段：用 Maven 编译源码
FROM maven:3.9-eclipse-temurin-17 AS builder
WORKDIR /build
COPY pom.xml .
RUN mvn dependency:go-offline -B
COPY src ./src
RUN mvn clean package -DskipTests -B

# 第二阶段：只保留 JRE 和 JAR
FROM eclipse-temurin:17-jre-alpine
WORKDIR /app
COPY --from=builder /build/target/PvZ-TV-Server-*.jar PvZ-TV-server.jar
EXPOSE 26667/tcp
EXPOSE 26667/udp
ENTRYPOINT ["java", "-jar", "PvZ-TV-server.jar", "--base=26667"]
