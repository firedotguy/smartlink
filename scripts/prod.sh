#!/bin/bash
set -e

flutter build web --release

rm -rf /var/www/flutter/*
sudo cp -a build/web/. /var/www/flutter/
