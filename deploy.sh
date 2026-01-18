#!/usr/bin/env bash
# 设置为严格模式
set -euo pipefail
readonly LOG_PREFIX="im-system"
source ./log-tool.sh
readonly APP_NAME="im-service"

main(){
  local version
  local deploy_env="${1}"

  if [[ "${deploy_env:-}" != "test" && "${deploy_env:-}" != "pro" ]]; then
      err "请输入正确的部署环境！test OR pro"
  fi
  # 获取项目版本号
  version=$(mvn help:evaluate -Dexpression=project.version -q -DforceStdout)

  info "开始构建项目,当前版本：${version}"
  mvn clean package -DskipTests

  info "开始构建项目docker镜像！"

  docker build -t "${APP_NAME}:${version}" .

}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi


