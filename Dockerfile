FROM maven:3.9-eclipse-temurin-17 AS builder
WORKDIR /build
COPY pom.xml .
RUN mvn dependency:go-offline -B
COPY src ./src
RUN mvn clean package -DskipTests -B
# 调试输出，确保 JAR 生成
RUN ls -la /build/target/

FROM eclipse-temurin:17-jre-focal
WORKDIR /app
RUN mkdir -p /app/lib /app/data
# 精确复制 JAR（注意大小写）
COPY --from=builder /build/target/PvZ-TV-Server-1.0-SNAPSHOT.jar /app/lib/PvZ-TV-server.jar
WORKDIR /app/data
EXPOSE 26667/tcp
EXPOSE 26667/udp
ENTRYPOINT ["java", "-jar", "/app/lib/PvZ-TV-server.jar", "--base=26667"]
