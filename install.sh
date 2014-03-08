#!/bin/bash

for F in $(find -L . -mindepth 2 -type f | grep -v "^\./\."); do # look up and symlink each file
    TARGET=`echo ${F} | sed 's/^\.//'`;
    if [[ $TARGET == /home/me/* ]]; then # place correct username for home dir
        TARGET=${TARGET/\/me\//\/`whoami`\/}
    fi;

    TARGET_DIR=`dirname ${TARGET}`

    if [ ! -d ${TARGET_DIR} ]; then # create directory first
        mkdir -p $TARGET_DIR
    fi

    if [ ! -f ${TARGET} ]; then
        sudo ln -s `readlink -f ${F}` ${TARGET}
    fi
done
