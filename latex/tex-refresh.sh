#!/usr/bin/env bash

set -e

echo "\e[34mRefreshin TeX and font databases...\e[0m"

sudo env PATH="$PATH" mktexlsr
luaotfload-tool -fu
fc-cache -fv

echo "\e[32mTeX and font databases refreshed successfully.\e[0m"
