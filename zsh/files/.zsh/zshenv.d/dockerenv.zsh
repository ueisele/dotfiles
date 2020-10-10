# Return if requirements are not found.
if (( ! $+commands[docker] )); then
  return 1
fi

# Ensure array does not contain duplicates.
typeset -gU docker_env_vars

# Environment variables, which are passed to Docker containers
docker_env_vars=(
  TERM
  USER_FULLNAME
  USER_EMAIL
  GITHUB_USER
  GITHUB_TOKEN
  $docker_env_vars
)