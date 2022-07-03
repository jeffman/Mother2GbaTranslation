#!/bin/bash
docker image rm lorenzooone/m2gba_translation:patch_builder
docker build --target patch_builder . -t lorenzooone/m2gba_translation:patch_builder
