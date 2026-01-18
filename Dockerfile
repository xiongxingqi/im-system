FROM eclipse-temurin:25-alpine
LABEL authors="celestrong"

ARG JAVA_VERSION
ENV TZ=Asia/Shanghai

# 文件目录预创建
# RUN mkdir /opt/app && mkdir /opt/app/cert && mkdir /opt/app/log

WORKDIR /opt/app

# 核心可执行文件
COPY ./service/target/service-${JAVA_VERSION}.jar ./service.jar
# copy 项目证书，配置文件等
# COPY file.cert  ./cert/

ENTRYPOINT ["java","-jar","./service.jar"]
# 环境配置可被替换
CMD ["--spring.profiles.active=test"]