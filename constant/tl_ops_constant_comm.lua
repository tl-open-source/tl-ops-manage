local tl_ops_constant_comm = {
    tl_ops_status = {-- service status 状态
        -- 在线
        online = 0,
        -- 下线
        offline = 1,
        -- 错误
        error = 2
    }, 
    tl_ops_rt = {-- rt 返回值
        -- 成功
        ok = 0,
        -- 错误
        error = -1,
        -- 参数有误
        args_error = -2,
        -- 找不到
        not_found = -3,
        -- 解析错误
        parse_error = -4
    },
    tl_ops_match_mode = {-- api匹配模式
        -- 精准匹配模式
        all = "all",
        -- 正则匹配
        reg = "jo",
        -- 正则忽略大小写
        regi = "joi",
        -- 最长字符串匹配
        regid = "joid"
    },
    tl_ops_api_type = {-- api类型
        -- 接口类型
        api = "api",
        -- 文件资源
        page = "page"
    }
};

return tl_ops_constant_comm;