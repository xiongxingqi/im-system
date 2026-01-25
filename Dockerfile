FROM eclipse-temurin:25-alpine
LABEL authors="celestrong" maintainer="celestrong"

ARG APP_VERSION=0.0.1-SNAPSHOT

# 设置环境变量
ENV TZ=Asia/Shanghai \
    LANG=C.UTF-8 \
    APP_HOME=/opt/app \
    APP_VERSION=${APP_VERSION}

# JVM 核心参数优化
# 1. 使用 MaxRAMPercentage 代替固定的 -Xmx
# -XX:MaxRAMPercentage=75.0 -XX:InitialRAMPercentage=50.0
# 2. 增加 PreferContainerQuotaForCPUCount 优化容器内 CPU 感知
ENV JAVA_OPTS="-Xms1g -Xmx1g \
               -XX:+UseG1GC -XX:MaxMetaspaceSize=256m \
               -Duser.timezone=${TZ} -Dfile.encoding=UTF-8 \
               -Djava.security.egd=file:/dev/./urandom \
               --add-opens java.base/java.lang=ALL-UNNAMED \
               --add-opens java.base/java.nio=ALL-UNNAMED \
               -XX:+ExitOnOutOfMemoryError -XX:+HeapDumpOnOutOfMemoryError \
               -XX:HeapDumpPath=${APP_HOME}/log/oom.hprof"


RUN groupadd -r erii && useradd -r -g erii erii
# 1. 安装时区包 (保持 root 权限执行)
# 2. 提前创建工作目录和日志目录
RUN set -eux; \
    apk add --no-cache tzdata; \
    ln -snf /usr/share/zoneinfo/${TZ} /etc/localtime; \
    echo ${TZ} > /etc/timezone; \
    mkdir -p ${APP_HOME}/log; \
    chown -R erii:erii ${APP_HOME}


WORKDIR ${APP_HOME}

# 拷贝 jar 包，并直接修改所有者为 nobody
# 此时仍为 root 权限，可以执行 chown
COPY --chown=erii:erii ./service/target/service-${APP_VERSION}.jar ./service.jar


# 切换到非 root 用户执行程序
USER erii

# 使用 exec 确保信号传递，让 Java 能够优雅停机
ENTRYPOINT ["sh", "-c", "exec java ${JAVA_OPTS} -jar ./service.jar $0 $@"]

# 默认参数
CMD ["--spring.profiles.active=test"]