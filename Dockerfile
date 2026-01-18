FROM eclipse-temurin:25-alpine
LABEL authors="celestrong" maintainer="celestrong"

ARG APP_VERSION=0.0.1-SNAPSHOT

ENV TZ=Asia/Shanghai
ENV LANG=C.UTF-8
# JVM核心参数（可根据你的服务器配置调整内存大小）
ENV JAVA_OPTS="-Xms1g -Xmx1g -XX:+UseG1GC -XX:MaxMetaspaceSize=256m \
               -Duser.timezone=${TZ} -Dfile.encoding=UTF-8 -Djava.security.egd=file:/dev/./urandom \
               --add-opens java.base/java.lang=ALL-UNNAMED --add-opens java.base/java.nio=ALL-UNNAMED \
               -XX:+ExitOnOutOfMemoryError -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=/opt/app/log/oom.hprof"

USER nobody:nobody

WORKDIR /opt/app
# Alpine镜像安装时区包，解决时区失效+精简安装无缓存
RUN apk add --no-cache tzdata && \
    ln -snf /usr/share/zoneinfo/${TZ} /etc/localtime && echo ${TZ} > /etc/timezone && \
    mkdir -p /opt/app/log && \
    chmod -R 755 /opt/app && \
    chown -R nobody:nobody /opt/app


# 拷贝jar包时，直接指定所有者为nobody，无需后续chown
COPY --chown=nobody:nobody ./service/target/service-${APP_VERSION}.jar ./service.jar

ENTRYPOINT ["sh","-c","java ${JAVA_OPTS} -jar ./service.jar $0 $@"]
# 环境配置可被替换
CMD ["--spring.profiles.active=test"]