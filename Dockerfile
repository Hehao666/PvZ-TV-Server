FROM eclipse-temurin:17-jre-focal
WORKDIR /app
RUN mkdir -p /app/lib /app/data

COPY target/*.jar /app/lib/PvZ-TV-server.jar
COPY target/li[b]/ /app/lib/

# 🌟 核心修复：强行把整个 /app 目录改成 777 最高可读写执行权限
RUN chmod -R 777 /app

EXPOSE 26667
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "/app/lib/PvZ-TV-server.jar"]
CMD ["--base=26667"]
