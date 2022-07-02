#!/bin/bash

TAG=$(./dockgen.lua fedora 36 lapp 0.8.1 upp panda)
docker run                          \
    --privileged                    \
    --volume "$PWD":/mnt/app        \
    -t -i "$TAG"                    \
    bash
