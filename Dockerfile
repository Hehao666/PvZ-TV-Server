FROM maven:3.9-eclipse-temurin-17 AS builder
WORKDIR /build
COPY pom.xml .
RUN mvn dependency:go-offline -B
COPY src ./src
RUN mvn clean package -DskipTests -B
# 将生成的 jar 重命名为统一的名称，无论 artifactId 和 version 如何
RUN cp "$(ls /build/target/*.jar | head -1)" /build/app.jar

FROM eclipse-temurin:17-jre-focal
WORKDIR /app
RUN mkdir -p /app/lib /app/data
COPY --from=builder /build/app.jar /app/lib/PvZ-TV-server.jar
WORKDIR /app/data
EXPOSE 26667/tcp
EXPOSE 26667/udp
ENTRYPOINT ["java", "-jar", "/app/lib/PvZ-TV-server.jar", "--base=26667"]
