# ==========================================
# 阶段一：构建阶段（基于原生 ARM64 镜像）
# ==========================================
FROM maven:3.8.5-eclipse-temurin-17 AS builder
WORKDIR /app
COPY . .
RUN mvn clean package -DskipTests

# ==========================================
# 阶段二：运行阶段（选用极度轻量、对 ARM64 极其友好的 Alpine 镜像）
# ==========================================
FROM eclipse-temurin:17-jre-alpine
WORKDIR /app

# 核心修复：创建 /app/lib 目录以兼容你程序可能的类路径（Classpath）寻找逻辑
RUN mkdir -p /app/lib /app/data

# 兼容性复制：
# 1. 尝试把 target 下的主 jar 包复制为 /app/lib/PvZ-TV-server.jar (解决你之前的报错)
# 2. 如果打包生成在 target/lib/，也一并拷贝进去
COPY --from=builder /app/target/*.jar /app/lib/PvZ-TV-server.jar
# 如果你的项目有外部依赖 jar，这顺便能把它们带过去，防止跑起来报 ClassNotFound
COPY --from=builder /app/target/lib/* /app/lib/ 2>/dev/null || true

EXPOSE 26667
EXPOSE 8080

# 运行路径完美匹配你的报错信息：/app/lib/PvZ-TV-server.jar
ENTRYPOINT ["java", "-jar", "/app/lib/PvZ-TV-server.jar"]
CMD ["--base=26667"]
