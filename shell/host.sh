#!/bin/bash

if [ $1 = 'up' ]; then
    LOCAL_PATH='./www/'
    if [ ! -d ${LOCAL_PATH} ]; then
        mkdir ${LOCAL_PATH}
    fi
fi