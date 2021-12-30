#!/bin/bash
docker rm image lorenzooone/m2gba_translation:builder
docker build --target builder . -t lorenzooone/m2gba_translation:builder
