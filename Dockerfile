FROM maven:3.9-eclipse-temurin-17 AS builder
WORKDIR /build
COPY pom.xml .
RUN mvn dependency:go-offline -B
COPY src ./src
RUN mvn dependency:copy-dependencies -DoutputDirectory=lib
RUN mvn package -DskipTests -B -DfinalName=app
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
ENV MAIN_CLASS=org.marshive.DashboardServer  # 改成你的真实主类
ENTRYPOINT java -cp "/app/app.jar:/app/lib/*" $MAIN_CLASS --base=26667
