#!/usr/bin/env bash
# author: joe.zheng
# version: 21.9.15

set -e

SELF="$(basename $0)"

PROXY_HOST="http://proxy-prc.intel.com"
PROXY_PORT=""
PROXY_SKIP="localhost,sh.intel.com,istio-system.svc,127.0.0.0/8,172.16.0.0/20,192.168.0.0/16,10.0.0.0/8"
PORT_HTTP="911"
PORT_HTTPS="912"
REPO_MIRROR="https://docker.mirrors.ustc.edu.cn"

DRY_RUN="n"

HELP=$(cat <<EOF
Usage: $SELF [-M <mirror>] [-N <noproxy>] [-H <port>] [-S <port>] [-n] [-h]
  [<host>] [<port>]
  Install Docker and configure it, e.g. proxy, mirror

  -M <mirror>:  registry mirror, default: $REPO_MIRROR
  -N <noproxy>: no_proxy settings, default: $PROXY_SKIP
  -H <port>:    proxy port for http, default: $PORT_HTTP
  -S <port>:    proxy port for https, default: $PORT_HTTPS
  -n:           dry run, print out information only, default: $DRY_RUN
  -h:           print the usage message

  <host>:       proxy host, "" to disable proxy, default: $PROXY_HOST
  <port>:       proxy port, override -HS options, default: $PROXY_PORT

Examples:

  1. Deploy with default configuration
     $SELF

  2. Deploy without proxy
     $SELF ""

  3. Deploy with specified proxy host and port (913 for http and https)
     $SELF http://proxy.example.com 913

  4. Deploy with specified proxy host and port (911 for http, 912 for https)
     $SELF -H 911 -S 912 http://proxy.example.com
EOF
)

while getopts ":N:M:H:S:nh" opt
do
  case $opt in
    M ) REPO_MIRROR=$OPTARG;;
    N ) PROXY_SKIP=$OPTARG;;
    H ) PORT_HTTP=$OPTARG;;
    S ) PORT_HTTPS=$OPTARG;;
    n ) DRY_RUN='y';;
    h ) echo "$HELP" && exit;;
    * ) echo "no such option: $opt" && exit 1;;
  esac
done
shift $((OPTIND-1))

if (( $# >= 1 )); then
  PROXY_HOST="$1"
fi
if (( $# >= 2 )); then
  PROXY_PORT="$2"
fi

SERVICE_CONFIG="/etc/systemd/system/docker.service.d/http-proxy.conf"
DOCKERD_CONFIG="/etc/docker/daemon.json"
DOCKERC_CONFIG="~/.docker/config.json"

# export proxy settings
if [[ -n $PROXY_HOST ]]; then
  export http_proxy=$PROXY_HOST:${PROXY_PORT:-$PORT_HTTP}
  export https_proxy=$PROXY_HOST:${PROXY_PORT:-$PORT_HTTPS}
  export no_proxy=$PROXY_SKIP
else
  export http_proxy=
  export https_proxy=
  export no_proxy=
fi

for v in DRY_RUN PROXY_HOST PROXY_PORT PROXY_SKIP PORT_HTTP PORT_HTTPS \
  REPO_MIRROR SERVICE_CONFIG DOCKERD_CONFIG DOCKERC_CONFIG; do
  eval echo "$v: \${$v}"
done

[[ $DRY_RUN == "y" ]] && exit

echo "check prerequisites"
if [[ -z $(which curl) ]]; then
  echo "curl is not available"
  exit 1
fi
if [[ -z $(which python3) ]]; then
  echo "python3 is not available"
  exit 1
fi

# ensure Docker is installed
if [[ -z $(which docker) ]]; then
  echo "docker is not available, install it"
  curl -fsSL https://get.docker.com | bash -s docker --mirror Aliyun
  echo "docker installation is done"
fi

if [[ -e $SERVICE_CONFIG || -e $DOCKERD_CONFIG || -e $DOCKERC_CONFIG ]]; then
  cat <<EOF
any of the following configuration files already exist
* $SERVICE_CONFIG
* $DOCKERD_CONFIG
* $DOCKERC_CONFIG
EOF
  read -p "overwrite them and continue? y/N: " result
  if [[ $result != "y" ]]; then
    exit
  fi
fi

echo "configure docker client: $DOCKERC_CONFIG"
DOCKERC_CONFIG="$DOCKERC_CONFIG" python3 <<'EOF'
import os, json, pathlib, collections

nest_dict = lambda: collections.defaultdict(nest_dict)

f = pathlib.Path(os.environ['DOCKERC_CONFIG']).expanduser()
d = nest_dict()

try:
  with f.open() as fh:
    d.update(json.load(fh))
except FileNotFoundError:
  pass

m = dict(httpProxy='http_proxy', httpsProxy='https_proxy', noProxy='no_proxy')
d['proxies']['default'].update({ k : os.environ[v] for k, v in m.items() })

f.parent.mkdir(parents=True, exist_ok=True)
with f.open('w') as fh:
  json.dump(d, fh, indent=4)
EOF

echo "configure docker daemon"
echo "configure $SERVICE_CONFIG"
sudo mkdir -p $(dirname $SERVICE_CONFIG)
cat <<EOF | sudo tee $SERVICE_CONFIG
[Service]
Environment="HTTP_PROXY=$http_proxy"
Environment="HTTPS_PROXY=$https_proxy"
Environment="NO_PROXY=$no_proxy"
EOF

echo "configure $DOCKERD_CONFIG"
sudo mkdir -p $(dirname $DOCKERD_CONFIG)
mirrors=""
if [[ -n $REPO_MIRROR ]]; then
  mirrors="\"registry-mirrors\": [\"$REPO_MIRROR\"],"
fi
cat <<EOF | sudo tee $DOCKERD_CONFIG
{
  "log-opts": {
    "max-size": "500m"
  },
  $mirrors
  "insecure-registries": ["10.0.0.0/8", "127.0.0.0/8"]
}
EOF

echo "enable docker service"
sudo systemctl enable docker

echo "restart docker service"
sudo systemctl daemon-reload
sudo systemctl restart docker

if groups | grep -qwv docker; then
  echo "add docker group to $USER"
  sudo usermod -aG docker $USER
  echo "logout and login again or reboot to take effect"
fi
echo "done"
