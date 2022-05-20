# tl openresty store module

### 考虑用多层结构来持久化数据，目前支持三层，shared dict，redis，store(索引文件存储格式)

# 1. 使用方式
 
### 1.1 引入cache依赖
按照场景需要创建对应的business-name,每个business-name是一个存储文件和一个对应索引文件
```
    local cache = require("cache.tl_ops_cache"):new("business-name");
```

### 1.2 按需调用
目前支持六种模式，000分别代表shared dict,redis,store, 例如 : 101代表开启shared dict,store,且不开启redis模式
```
    cache:set101("key", "value");
    cache:get101("key", "value");
```

### 1.3 默认场景
目前默认是采用111模式, get(), set()对应的就是get111(), set111()
```
    cache:set("key", "value");
    cache:get("key", "value");
```

# 2. store场景实现思路
通过文件指针seek来简要实现文件存储，目前单个最大文件支持4GB。具体实现代码可查看这两个文件
    
    utils/tl_ops_utils_store.lua, cache/tl_ops_cache_store.lua

### 2.1 索引文件
名称统一为 ： business-name.tlindex

### 2.2 存储文件
名称统一为 ： business-name.tlstore