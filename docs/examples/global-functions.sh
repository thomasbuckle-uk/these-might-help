#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

CURRENT_BASH=$(ps -p $$ | awk '{ print $4 }' | tail -n 1)
case "${CURRENT_BASH}" in
-zsh | zsh)
  CURRENT_DIR=$(cd "$(dirname "${0}")" && pwd)
  ;;
-bash | bash)
  CURRENT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
  ;;
*)
  echo 1>&2
  echo -e "\033[0;31m\`${CURRENT_BASH}\` does not seems to be supported\033[0m" 1>&2
  echo 1>&2
  return 1
  ;;
esac

up() {
  (
    ./system/up.sh
    ./registry/build.sh

    for project in $(find ./* -mindepth 1 -type f -name 'up.sh' | grep -v 'system'); do
      $project
    done

    ./system/tunnelling.sh dev info
  )

}

# Kill all running containers
#unalias docker-killall 2>/dev/null >dev/null || true
docker-killall() {
  printf "\n>>> Killing all Containers\n\n" && docker kill $(docker ps --format "{{.Names}}")
}

# Delete all stopped containers.
docker-cleanc() {
  printf "\n>>> Deleting stopped containers\n\n" && docker rm $(docker ps -a --format "{{.Names}}")
}
# Delete all untagged images.
docker-cleanui() {
  printf "\n>>> Deleting untagged images\n\n" && docker rmi $(docker images -q -f dangling=true)
}

# Delete all images
docker-cleani() {
  printf "\n>>> Deleting images locally\n\n" && docker rmi -f $(docker images -q)
}
# Delete all networks
docker-cleann() {
  printf "\n>>> Deleting networks\n\n" && docker network rm $(docker network ls --format "{{.Name}}")
}
# Delete all volumes
docker-cleanv() {
  printf "\n>>> Deleting volumes\n\n" && yes | docker volume prune
}
# Deleting stopped containers, networks and volumes.
docker-clean() {
  printf "\n>>> Deleting stopped containers, networks and volumes\n\n" && ( (docker-cleanc || true) && (docker-cleann || true) && (docker-cleanv || true))
}
# ARMAGEDDON
docker-armageddon() {
  printf "\n>>> ARMGAGEDDON\n\n" && ( (docker-cleanc || true) && (docker-cleanui || true) && (docker-cleani || true) && (docker-cleann || true) && (docker-cleanv || true))
}
#WSL Specific deletion for files downloaded from a browser in windows then imported to WSL2
delete_junk_files() {
  printf "\n>>> Performing Cleanup of .identifier and .attrs files\n\n" && find . -name "*:Zone.Identifier" -or -name "*dropbox.attrs" -type f -delete

}
# Formatted docker ps
docker-ps() {
  docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Status}}"
}

usage() {
  echo "Usage: global-functions.sh [ARG]"
  echo "  [ARG] one of:"
  echo "    [up]: Creates all required images, volumes, networks and containers including System containers and the Registry"
  echo "    [docker-list]: List containers using formatting ps"
  echo "    [remove-junk-files]: WSL Specific deletion for files downloaded from a browser in windows then imported to WSL2"
  echo "    [docker-armageddon]: Remove/Reset all Images, Networks, Volumes and Containers"
  echo "    [docker-clean]: Delete all stopped containers and untagged images"
  echo "    [docker-clean-volumes]: Delete all volumes"
  echo "    [docker-clean-networks]: Delete all networks"
  echo "    [docker-clean-images]: Delete all images"
  echo "    [docker-clean-images-untagged]: Delete all untagged images"
  echo "    [docker-clean-containers]: Delete all stopped containers"
  echo "    [docker-kill-all]: Kill all running containers"
  echo ""
}

main() {

  readonly CURRENT_DIR=$(cd "$(dirname "$0")" && pwd)
  cd "${CURRENT_DIR:?}/"

  source ./.env

  if [ $# -eq 1 ]; then
    readonly command=${1:-'help'}
  fi

  case ${command} in
  docker-kill-all)
    docker-killall
    ;;
  docker-clean-containers)
    docker-cleanc
    ;;
  docker-clean-images-untagged)
    docker-cleanui
    ;;
  docker-clean-images)
    docker-cleani
    ;;
  docker-clean-networks)
    docker-cleann
    ;;
  docker-clean)
    docker-clean
    ;;
  docker-armageddon)
    docker-armageddon
    ;;
  remove-junk-files)
    delete_junk_files
    ;;
  docker-list)
    docker-ps
    ;;
  help)
    usage
    ;;
  up)
    up
    ;;
  *)
    if [ -z "$*" ]; then
      printf '\e[4;33mWARN: No ARGs given %s\n\e[0m' >&2
    else
      printf '\e[4;33mWARN: Unknown arg : %s\n\e[0m' "${command}" >&2
    fi

    usage
    exit 1
    ;;
  esac

}
#Entrypoint of command
main "${@}"