return {
    log = {
        level = 1, -- 1=debug, 2=std, 3=err
        log_dir = [[/path/to/tl-ops-manage/]],
        store_dir = [[/path/to/tl-ops-manage/store/]],
        format_json = true      -- 是否json格式输出log
    },
    cache = {
        redis = false           -- 是否启用redis存数据
    }
}
