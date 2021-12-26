#!/bin/bash

mv $CI_PROJECT_DIR/fake_secrets.yaml $CI_PROJECT_DIR/secrets.yaml
for config in `find . -maxdepth 1 -type f -name "*.yaml" -not -name "*.template.yaml" -not -name "secrets.yaml" 2>/dev/null`
do
    echo "Validating $config"
    esphome compile $config
done