#!/bin/bash

USER_GROUP=$(id -Gn mike | cut -d" " -f1)
USER_NAME=`whoami`

VERBOSE=1
OVERWRITE=0

echo "Install for ${USER_NAME}:${USER_GROUP}"

function verbose()
{
  [[ ${VERBOSE} ]] && echo ".$@"
}

for F in $(find -L . -mindepth 2 -type f | grep -v "^\./\."); do # look up and symlink each file
    TARGET=`echo ${F} | sed 's/^\.//'`;
    if [[ $TARGET == /home/me/* ]]; then # place correct username for home dir
        TARGET=${TARGET/\/me\//\/`whoami`\/}
    fi;

    TARGET_DIR=`dirname ${TARGET}`

    if [ ! -d ${TARGET_DIR} ]; then # create directory first
        mkdir -p $TARGET_DIR
    fi

    if [[ ${OVERWRITE} ]]; then
        sudo rm ${TARGET}
    fi

    if [[ ! -f ${TARGET} ]]; then
        verbose ${TARGET}
        sudo ln -s `readlink -f ${F}` ${TARGET}
        sudo chown ${USER_NAME}:${USER_GROUP} ${TARGET}
    fi
done
