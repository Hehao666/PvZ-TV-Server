FROM maven:3.9-eclipse-temurin-17 AS builder
WORKDIR /build
COPY pom.xml .
RUN mvn dependency:go-offline -B
COPY src ./src
RUN mvn clean package -DskipTests -B

FROM eclipse-temurin:17-jre-focal
WORKDIR /app
# 把 JAR 放到 lib 子目录，避免被挂载覆盖
COPY --from=builder /build/target/PvZ-TV-Server-*.jar ./lib/PvZ-TV-server.jar
# 创建专门存放数据库的目录
RUN mkdir -p /app/data
# 将工作目录切换到 data，程序启动后 db 文件会生成在此处
WORKDIR /app/data
EXPOSE 26667/tcp
EXPOSE 26667/udp
# 用绝对路径执行 JAR
ENTRYPOINT ["java", "-jar", "/app/lib/PvZ-TV-server.jar", "--base=26667"]
