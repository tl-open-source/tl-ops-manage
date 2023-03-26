#!/usr/bin/env bash

export PATH=/usr/local/openresty/nginx/sbin:$PATH

exec prove "$@"