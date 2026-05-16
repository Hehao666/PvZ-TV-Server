FROM maven:3.9-eclipse-temurin-17 AS builder
WORKDIR /build
COPY pom.xml .
# 先下载依赖
RUN mvn dependency:go-offline -B
COPY src ./src
# 将依赖复制到 lib 目录
RUN mvn dependency:copy-dependencies -DoutputDirectory=lib
# 打包项目类 JAR，并指定 finalName 为 app
RUN mvn package -DskipTests -B -DfinalName=app
# 此时 target/app.jar 就是项目自身的 JAR
# 将 lib 和 JAR 准备好
RUN mkdir /build/output
RUN cp target/app.jar /build/output/
RUN cp -r lib /build/output/lib

FROM eclipse-temurin:17-jre-focal
WORKDIR /app
RUN mkdir -p /app/data
COPY --from=builder /build/output/app.jar /app/app.jar
COPY --from=builder /build/output/lib /app/lib
EXPOSE 26667/tcp
EXPOSE 26667/udp
ENTRYPOINT ["java", "-cp", "/app/app.jar:/app/lib/*", "org.marshive.DashboardServer", "--base=26667"]
