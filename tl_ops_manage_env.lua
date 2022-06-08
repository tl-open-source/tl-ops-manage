return {
    log = {
        log_dir = [[/path/to/tl-source/tl-ops-manage/]],---- log 路径
        store_dir = [[/path/to/tl-source/tl-ops-manage/store/]],
    
        format_json = true      -- 是否json格式输出log
    },
    cache = {
        redis = true           -- 是否启用redis存数据
    },
}