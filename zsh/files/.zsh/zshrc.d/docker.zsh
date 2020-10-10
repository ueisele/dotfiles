if ! command -v docker &> /dev/null ; then
    return
fi

docker () {
  if [[ $1 == "run" ]]; then
    shift
    command docker run -e TERM=${TERM:-"xterm-256color"} $(_env_github_user) $(_env_github_token) "$@"
  else
    command docker "$@"
  fi
}

_env_github_user () {
  [[ -n "${GITHUB_USER}" ]] && echo "-e GITHUB_USER=${GITHUB_USER}"
}

_env_github_token () {
  [[ -n "${GITHUB_TOKEN}" ]] && echo "-e GITHUB_TOKEN=${GITHUB_TOKEN}"
}