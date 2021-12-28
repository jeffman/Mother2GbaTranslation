#!/bin/bash
docker rm image mother2gba:test
docker build . -t mother2gba:test
