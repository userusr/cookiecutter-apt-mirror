#!/usr/bin/env bash
set -e
IFS=$'\n\t'

cleanup() {
    rm "$GPG_KEYRING"
}

SCRIPTPATH="$( cd "$(dirname "$0")" ; pwd -P )"
APT_MIRROR_CONF="${SCRIPTPATH}/../etc/mirror.list"

if [ "$#" -ne 1 ]; then
    BASE_PATH=$(\
        cat ${APT_MIRROR_CONF} \
      | perl -ne 'print $1 if /^\s*set\s+base_path\s+(.*)\s*$/'\
    )

    echo Searching base_path parameter in $APT_MIRROR_CONF
    echo base_path = $BASE_PATH
    echo
else
    BASE_PATH="$1"
fi

MIRROR_DIR=${MIRROR_DIR:="${BASE_PATH}"}
EXPORT_KEYS_DIR=${EXPORT_KEYS_DIR:="${MIRROR_DIR}/mirror/keys"}

if [ ! -d $MIRROR_DIR ]; then
    echo Mirror directory does not exists.
    exit 1
fi

if [ ! -d $EXPORT_KEYS_DIR ]; then
    mkdir -p $EXPORT_KEYS_DIR
fi

if [ ! -z "$GPG_KEY_SERVER" ]; then
    GPG_KEY_SERVER_OPT="--keyserver $GPG_KEY_SERVER"
else
    GPG_KEY_SERVER_OPT=''
fi

if [ -z "$GPG_KEYRING" ]; then
    GPG_KEYRING=$(mktemp --suffix=.gpg)
    trap cleanup EXIT
fi

echo -n Searching for keys in $MIRROR_DIR ...

KEYS=$(\
    find ${MIRROR_DIR} -name InRelease -exec \
          gpg --status-fd 1 --verify {} 2>/dev/null \; \
        | grep 'NO_PUBKEY\|GOODSIG' \
        | awk '{print $3}' \
        | sort \
        | uniq \
    )

echo " $(echo $KEYS | wc -w) keys found"
echo Importing key into keyring "$GPG_KEYRING" ...

set +e
echo ${KEYS} \
    | xargs \
        gpg --ignore-time-conflict \
            --no-options \
            --status-fd 1 \
            --no-default-keyring \
            --keyring ${GPG_KEYRING} \
            ${GPG_KEY_SERVER_OPT} \
            --recv \
            2>/dev/null \
    | grep IMPORTED

set -e
echo
echo -n Exporting keys to: $EXPORT_KEYS_DIR ...

echo ${KEYS} \
    | xargs \
        gpg --no-options \
            --batch \
            --yes \
            --no-default-keyring \
            --keyring ${GPG_KEYRING} \
            --armor \
            --output $EXPORT_KEYS_DIR/ALL_KEYS.gpg \
            --export \
            2>/dev/null

for i in $KEYS; do
    gpg --no-options \
        --batch \
        --yes \
        --no-default-keyring \
        --keyring ${GPG_KEYRING} \
        --armor \
        --output $EXPORT_KEYS_DIR/$i.gpg \
        --export
        2>/dev/null
done

echo done
