#!/usr/bin/env bash
# 设置为严格模式
set -euo pipefail
readonly LOG_PREFIX="im-system"
source ./log-tool.sh
readonly APP_NAME="im-service"

main(){
  local deploy_env="${1}"

  if [[ "${deploy_env:-}" != "test" && "${deploy_env:-}" != "pro" ]]; then
      err "请输入正确的部署环境！test OR pro"
  fi
  # 获取项目版本号
  local app_version
  app_version=$(mvn help:evaluate -Dexpression=project.version -q -DforceStdout)

  info "开始构建项目,当前版本：${app_version}"
  mvn clean package -DskipTests

  info "开始构建项目docker镜像！"

  docker build --build-arg APP_VERSION="${app_version}" -t "${APP_NAME}:${app_version}" .


}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi


