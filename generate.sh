##
## Script to generate custom PKGBUILDs
##

md5() {
    md5sum $1 | awk '{print $1}'
}

confirm_or_exit () {
  # call with a prompt string or use a default
  read -r -p "${1:-Are you sure? [y/N]} " response
  case $response in
    [yY][eE][sS]|[yY]) 
      true
      ;;
    *)
      echo "${2:-Exiting}"
      exit 2
      ;;
  esac
}

if [ $# -eq 0 ]; then
  CONFFILE="./release.conf"
else
  if [ $1 == "clean" ]; then
    rm -rf build
    exit 0
  fi
  CONFFILE="./release.conf.d/$1.conf"
fi

if [ ! -f "${CONFFILE}" ];
then
  echo "Conf file not found."
  exit 1
fi

echo "Going to use ${CONFFILE} to make PKGBUILD."

confirm_or_exit "Is this okay? [y/N] " "Doing nothing."

source "${CONFFILE}"

mkdir -p build
cat riak.template | m4 -DRELEASENAME=${RELEASENAME} > ./build/riak-${RELEASENAME}
cat riak-admin.template | m4 -DRELEASENAME=${RELEASENAME} > ./build/riak-${RELEASENAME}-admin
cat riak.rc.template | m4 -DRELEASENAME=${RELEASENAME} > ./build/riak-${RELEASENAME}.rc
cat riak.service.template | m4 -DRELEASENAME=${RELEASENAME} > ./build/riak-${RELEASENAME}.service
cat vars.config.template | m4 -DWEBIP=${WEBIP} -DWEBPORT=${WEBPORT} -DHANDOFFPORT=${HANDOFFPORT} -DPBIP=${PBIP} -DPBPORT=${PBPORT} > ./build/vars.config

VARS_CONFIG_MD5=$(md5 "./build/vars.config")
RIAK_BIN_MD5=$(md5 "./build/riak-${RELEASENAME}")
RIAK_ADMIN_BIN_MD5=$(md5 "./build/riak-${RELEASENAME}-admin")
RIAK_RC_MD5=$(md5 "./build/riak-${RELEASENAME}.rc")
RIAK_SERVICE_MD5=$(md5 "./build/riak-${RELEASENAME}.service")

cat riak.install.template | m4 -DRELEASENAME=${RELEASENAME} > ./build/riak.install
cat PKGBUILD.template | m4 -DRELEASENAME=${RELEASENAME} -DVARS_CONFIG_MD5=${VARS_CONFIG_MD5} -DRIAK_BIN_MD5=${RIAK_BIN_MD5} -DRIAK_ADMIN_BIN_MD5=${RIAK_ADMIN_BIN_MD5} -DRIAK_RC_MD5=${RIAK_RC_MD5} -DRIAK_SERVICE_MD5=${RIAK_SERVICE_MD5} > ./build/PKGBUILD

echo "PKGBUILD and related files generated in ./build"

