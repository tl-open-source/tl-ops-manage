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
    }
};


return tl_ops_constant_comm;