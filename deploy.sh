#!/usr/bin/env bash
# 设置为严格模式
set -euo pipefail
source ./log-tool.sh

readonly  APP_NAME="im-service"

main(){
  local version
  # 获取项目版本号
  version=$(mvn help:evaluate -Dexpression=project.version -q -DforceStdout)

  info "开始构建项目im-system-${version}"
  mvn clean package -DskipTests

  info "开始构建docker镜像"

}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi


