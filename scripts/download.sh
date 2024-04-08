#!/bin/bash

function isTrue() {
  local value=${1,,}

  result=

  case ${value} in
  true | on)
    result=0
    ;;
  *)
    result=1
    ;;
  esac

  return ${result}
}

function get() {
  local flags=()
  if isTrue "${DEBUG_GET:-false}"; then
    flags+=("--debug")
  fi
  mc-image-helper "${flags[@]}" get "$@"
}

function getFromPaperMc() {
  local project=${1?}
  local version=${2?}
  local buildId=${3?}

  # Doc : https://papermc.io/api

  if [[ ${version^^} = LATEST ]]; then
    if ! version=$(get --json-path=".versions[-1]" "https://papermc.io/api/v2/projects/${project}"); then
      echo "ERROR: failed to lookup PaperMC versions"
      exit 1
    fi
  fi

  if [[ ${buildId^^} = LATEST ]]; then
    if ! buildId=$(get --json-path=".builds[-1]" "https://papermc.io/api/v2/projects/${project}/versions/${version}"); then
        echo "ERROR: failed to lookup PaperMC build from version ${version}"
        exit 1
    fi
  fi


  if ! jar=$(get --json-path=".downloads.application.name" "https://papermc.io/api/v2/projects/${project}/versions/${version}/builds/${buildId}"); then
    echo "ERROR: failed to lookup PaperMC download file from version=${version} build=${buildId}"
    exit 1
  fi

  PAPER_DL_URL="https://papermc.io/api/v2/projects/${project}/versions/${version}/builds/${buildId}/downloads/${jar}"
}

mkdir /download

echo "Downloading frp..."

curl -s ${UNION_API_ROOT}/network/public | jq -r '.union_entry.frp_version' | xargs -I {VER} wget -O - https://github.com/fatedier/frp/releases/download/v{VER}/frp_{VER}_linux_amd64.tar.gz | tar -xzf - -C .

mv ./frp_*/* ${FRP_HOME}

echo "Downloading velocity..."

getFromPaperMc velocity latest latest

wget -O /download/velocity.jar ${PAPER_DL_URL}

echo "Downloading authlib-injector..."

curl -s https://authlib-injector.yushi.moe/artifact/latest.json | jq -r '.download_url' | xargs -I {URL} \
    wget -O /download/authlib-injector.jar {URL}

echo "Downloading MUA plugins..."

wget -O /download/ProxiedProxy.jar $(/usr/bin/github.sh --repo=CakeDreamer/ProxiedProxy --filename=.*\.jar --pre-release=true) 
wget -O /download/UnionSyncAnnouncement.jar $(/usr/bin/github.sh --repo=MUAlliance/UnionSyncAnnouncement --filename=.*\.jar --pre-release=true) 
wget -O /download/mua-proxy-plugin.jar $(/usr/bin/github.sh --repo=MagicalSheep/mua-proxy-plugin --filename=.*\.jar --pre-release=true)
wget -O /download/MapModCompanion.jar $(/usr/bin/github.sh --repo=turikhay/MapModCompanion --filename=.*\.jar --pre-release=true)
