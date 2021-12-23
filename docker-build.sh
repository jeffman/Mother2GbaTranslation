#!/bin/bash
rm -rf ./out
mkdir -p ./out
docker rm image mother2gba:build
docker build ./ -t mother2gba:build
docker run --rm -it -v $PWD/out:/opt/out mother2gba:build

