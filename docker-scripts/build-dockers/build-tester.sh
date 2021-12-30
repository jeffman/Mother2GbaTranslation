#!/bin/bash
docker rm image lorenzooone/m2gba_translation:tester
docker build --target tester . -t lorenzooone/m2gba_translation:tester
