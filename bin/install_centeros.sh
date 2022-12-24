#!/bin/bash

NGX_CONF="/usr/local/openresty/nginx/conf/nginx.conf"
NGX_TL_OPS_CONF="/usr/local/openresty/nginx/conf/nginx_tlops.conf"
TL_OPS_PATH="/usr/local/tl-ops-manage/"
TL_OPS_CONF_PATH="/usr/local/tl-ops-manage/conf/tl_ops_manage.conf"
TL_OPS_LUA_PATH="/usr/local/openresty/lualib/?.lua;;/usr/local/tl-ops-manage/?.lua;;"
TL_OPS_LUAC_PATH="/usr/local/openresty/lualib/?.so;;"
TL_OPS_VER="v2.9.2"

echo_msg(){
    cur_time=$(date "+%Y-%m-%d %H:%M:%S")
    echo "------------------------------------------------------------------------------------"
    echo "-----------------------------【tl-ops-manage】--------------------------------------"
    echo "--------------------------TIME: $cur_time"
    echo "--------------------------MSG: $1 "
    echo "------------------------------------------------------------------------------------"
    sleep 1
}

tl_ops_manage_install(){
mkdir -p $TL_OPS_PATH

    echo_msg "tl-ops-manage install start"
    wget -O tlopsmanage.tar.gz https://github.com/iamtsm/tl-ops-manage/archive/refs/tags/$TL_OPS_VER.tar.gz

    echo_msg "unpackage tl-ops-manage start"
    tar -zxvf tlopsmanage.tar.gz -C $TL_OPS_PATH

    mv $TL_OPS_PATH/tl-ops-manage*/* $TL_OPS_PATH
    rm -rf $TL_OPS_PATH/tl-ops-manage*/

    sed -i "s:/path/to/tl-ops-manage/:$TL_OPS_PATH:g" $TL_OPS_PATH"conf/tl_ops_manage.conf"
    sed -i "s:/path/to/tl-ops-manage/:$TL_OPS_PATH:g" $TL_OPS_PATH"tl_ops_manage_env.lua"

    cp $NGX_CONF $NGX_TL_OPS_CONF

    LINE=$(sed -n '/include/=' $NGX_TL_OPS_CONF | sed -n "1"p)
    sed -e "$LINE a\ \t include $TL_OPS_CONF_PATH;\n\t lua_package_path \"$TL_OPS_LUA_PATH\";\n\t lua_package_cpath \"$TL_OPS_LUAC_PATH\";" $NGX_TL_OPS_CONF > $NGX_CONF

    echo_msg "tl-ops-manage start done !"
}

main(){
    echo_msg "centos env check start"

    if [ ! -x "$(command -v openresty)" ]; then
        wget https://openresty.org/package/centos/openresty.repo
        mv openresty.repo /etc/yum.repos.d/

        echo_msg "update package start"

        yum check-update

        yum install -y openresty

        echo_msg "install openresty done !"

        echo_msg "$(command openresty -v)"
    else
        echo_msg "openresty already installed"
    fi

    if [ -d $TL_OPS_PATH ]; then
        echo_msg "$TL_OPS_PATH dir already exist"
        exit
    fi
    tl_ops_manage_install
}

main

