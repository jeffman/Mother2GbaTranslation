#!/bin/bash
docker rm image mother2gba:build
docker build . -t mother2gba:build
