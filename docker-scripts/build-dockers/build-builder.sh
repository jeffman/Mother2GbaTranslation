#!/bin/bash
docker image rm lorenzooone/m2gba_translation:builder
docker build --target builder . -t lorenzooone/m2gba_translation:builder
