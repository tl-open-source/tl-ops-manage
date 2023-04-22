#!/bin/bash

NGX_CONF="/usr/local/openresty/nginx/conf/nginx.conf"
NGX_TL_OPS_CONF="/usr/local/openresty/nginx/conf/nginx_tlops.conf"
TL_OPS_PATH="/usr/local/tl-ops-manage/"
TL_OPS_CONF_PATH="/usr/local/tl-ops-manage/conf/tl_ops_manage.conf"
TL_OPS_LUA_PATH="/usr/local/openresty/lualib/?.lua;;/usr/local/tl-ops-manage/?.lua;;"
TL_OPS_LUAC_PATH="/usr/local/openresty/lualib/?.so;;"
TL_OPS_VER="v3.4.5"

echo_msg(){
    cur_time=$(date "+%Y-%m-%d %H:%M:%S")
    echo "------------------------------------------------------------------------------------"
    echo "-----------------------------【tl-ops-manage】--------------------------------------"
    echo "--------------------------TIME: $cur_time"
    echo "--------------------------MSG: $1 "
    echo "------------------------------------------------------------------------------------"
    sleep 1
}

x86_amd_openresty_install(){
    # for 16 ~ 20
    if [[ $(lsb_release -d) =~ 'Ubuntu 1' ]] || [[ $(lsb_release -d) =~ 'Ubuntu 20' ]]; then
        echo_msg "$(arch) - $(lsb_release -d) install start"
        apt-get -y install --no-install-recommends wget gnupg ca-certificates
        wget -O - https://openresty.org/package/pubkey.gpg | apt-key add -
        echo "deb http://openresty.org/package/ubuntu $(lsb_release -sc) main" | tee /etc/apt/sources.list.d/openresty.list

    # for 22+
    elif [[ $(lsb_release -d) =~ 'Ubuntu 2' ]]; then
        echo_msg "$(arch) - $(lsb_release -d) install start"
        apt-get -y install --no-install-recommends wget gnupg ca-certificates
        wget -O - https://openresty.org/package/pubkey.gpg | apt-key add -
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/openresty.gpg] http://openresty.org/package/ubuntu $(lsb_release -sc) main" \
        | tee /etc/apt/sources.list.d/openresty.list > /dev/null
    fi

    apt-get update
    apt-get -y install openresty
}

arm_aarch_openresty_install(){
    # for 16 ~ 20
    if [[ $(lsb_release -d) =~ 'Ubuntu 1' ]] || [[ $(lsb_release -d) =~ 'Ubuntu 20' ]]; then
        echo_msg "$(arch) - $(lsb_release -d) install start"
        apt-get -y install --no-install-recommends wget gnupg ca-certificates
        wget -O - https://openresty.org/package/pubkey.gpg | apt-key add -
        echo "deb http://openresty.org/package/arm64/ubuntu $(lsb_release -sc) main" | tee /etc/apt/sources.list.d/openresty.list

    # for 22+
    elif [[ $(lsb_release -d) =~ 'Ubuntu 2' ]]; then
        echo_msg "$(arch) - $(lsb_release -d) install start"
        apt-get -y install --no-install-recommends wget gnupg ca-certificates
        wget -O - https://openresty.org/package/pubkey.gpg | apt-key add -
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/openresty.gpg] http://openresty.org/package/arm64/ubuntu $(lsb_release -sc) main" \
        | tee /etc/apt/sources.list.d/openresty.list > /dev/null
    fi

    apt-get update
    apt-get -y install openresty
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
    echo_msg "ubuntu env check start"

    if [ ! -x "$(command -v openresty)" ]; then
        echo_msg "update package start"
        apt-get update

        if [[ $(arch) =~ "x86_64" ]] || [[ $(arch) =~ "amd64" ]]; then
            x86_amd_openresty_install
        elif [[ $(arch) =~ "arm64" ]] || [[ $(arch) =~ "aarch64" ]]; then
            arm_aarch_openresty_install
        else
            echo_msg "arch unknown!!"
            exit
        fi

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

