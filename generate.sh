##
## Script to generate custom PKGBUILDs
##

md5() {
    md5sum $1 | awk '{print $1}'
}

if [ $# -eq 0 ]; then
    source ./releases.conf
else
    if [ $1 == "clean" ]; then
        rm -rf build
	exit 0
    fi
    RELEASENAME=$1
fi

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

