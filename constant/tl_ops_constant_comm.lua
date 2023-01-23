local tl_ops_constant_comm = {
    tl_ops_status = {-- service status 状态
        online = 0,
        offline = 1,
        error = 2
    }, 
    tl_ops_rt = {-- rt 返回值
        ok = 0,
        error = -1,
        args_error = -2,
        not_found = -3,
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
    }
};

return tl_ops_constant_comm;