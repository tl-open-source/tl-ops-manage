---- file name: resty/redis_iresty.lua
local redis_c = require "resty.redis"
 
 
local ok, new_tab = pcall(require, "table.new")
if not ok or type(new_tab) ~= "function" then
    new_tab = function (narr, nrec) return {} end
end
 
 
local _M = new_tab(0, 155)
_M._VERSION = '0.02'
 
 
local commands = {
    "append",   "bgsave",       "blpop",        "brpoplpush",   "auth",         "bitcount",
    "brpop",    "client",       "bgrewriteaof", "bitop",        "config",       "dbsize",
    "debug",    "decr",         "del",          "discard",      "echo",         "eval",
    "exec",     "expire",       "expireat",     "flushdb",      "get",          "getrange",
    "getset",   "hexists",      "hget",         "hincrby",      "hincrbyfloat", "hlen",
    "hmget",    "hset",         "hsetnx",       "incrby",       "keys",         "lastsave",
    "llen",     "lpushx",       "lset",         "migrate",      "monitor",      "msetnx",
    "persist",  "ping",         "pttl",         "publish",      "quit",         "randomkey",
    "restore",  "rpop",         "rpushx",       "scan",         "sdiff",        "select",
    "setex",    "shutdown",     "sismember",    "smembers",     "spop",         "sscan",
    "strlen",   "sunionstore",  "ttl",          "type",         "watch",        "zcount",
    "zrange",   "zrem",         "zrevrange",    "zscan",        "zscore",       "hmset",
    "hvals",    "incrbyfloat",  "lindex",       "lpop",         "lrange",       "ltrim",
    "move",     "multi",        "pexpire",      "psetex",       ----[[ "punsubscribe", ]]
    "rename",   "info",         "linsert",      "lpush",        "lrem",         "mget",
    "mset",     "object",       "pexpireat",    "psubscribe",   "pubsub",       "renamenx",
    "rpush",    "save",         "script",       "setbit",       "setrange",     "sinterstore",
    "slowlog",  "sort",         "srem",         "sunion",       "time",         "rpoplpush",
    "sadd",     "scard",        "sdiffstore",   "set",          "setnx",        "sinter",
    "slaveof",  "smove",        "srandmember",  ----[[ "subscribe",  ]]           "sync",
    ----[[ "unsubscribe", ]]      "zunionstore",  "evalsha",      "decrby",       "dump",
    "exists",   "flushall",     "getbit",       "hdel",         "hgetall",      "hkeys",
    "hscan",    "incr",         "zadd",         "zincrby",      "zrangebyscore","zrank",
    "zremrangebyrank",          "zremrangebyscore",             "zrevrangebyscore", 
    "zrevrank", "unwatch",      "zcard",        "zinterstore"
 }
 
 
local mt = { __index = _M }
 
 
local function is_redis_null( res )
    if type(res) == "table" then
        for k,v in pairs(res) do
            if v ~= ngx.null then
                return false
            end 
        end
        return true
    elseif res == ngx.null then
        return true
    elseif res == nil then
        return true
    end
 
    return false
end
 
---- change connect address as you need
function _M.connect_mod( self, redis )
    redis:set_timeout(self.check_timeout)
    local ok, err = redis:connect("127.0.0.1", 6379)
    if not ok then
        return err;
    end


    return ok;
end
 
function _M.set_keepalive_mod( redis )
    ---- put it into the connection pool of size 100, with 60 seconds max idle time
    return redis:set_keepalive(60000, 1000)
end
 
function _M.init_pipeline( self )
    self._reqs = {}
end
 
function _M.commit_pipeline( self )
    local reqs = self._reqs
 
    if nil == reqs or 0 == #reqs then
        return {}, "no pipeline"
    else
        self._reqs = nil
    end
 
    local redis, err = redis_c:new()
    if not redis then
        return nil, err
    end
 
    local ok, err = self:connect_mod(redis)
    if not ok then
        return {}, err
    end
 
    redis:init_pipeline()
    for _, vals in ipairs(reqs) do
        local fun = redis[vals[1]]
        table.remove(vals , 1)
        fun(redis, unpack(vals))
    end
 
    local results, err = redis:commit_pipeline()
    if not results or err then
        return {}, err
    end
 
    if is_redis_null(results) then
        results = {}
        ngx.log(ngx.WARN, "is null")
    end
 
    self.set_keepalive_mod(redis)
 
    for i,value in ipairs(results) do
        if is_redis_null(value) then
            results[i] = nil
        end
    end
    return results, err
end
 
function _M.subscribe( self, channel )
    local redis, err = redis_c:new()
    if not redis then
        return nil, err
    end
 
    local ok, err = self:connect_mod(redis)
    if not ok or err then
        return nil, err
    end
 
    local res, err = redis:subscribe(channel)
    if not res then
        return nil, err
    end
 
    local function do_read_func ( do_read )
        if do_read == nil or do_read == true then
            res, err = redis:read_reply()
            if not res then
                return nil, err
            end
            return res
        end
        redis:unsubscribe(channel)
        self.set_keepalive_mod(redis)
        return
    end
 
    return do_read_func
end
 
 
local function do_command(self, cmd, ... )
    if self._reqs then
        table.insert(self._reqs, {cmd, ...})
        return 
    end
 
    local redis, err = redis_c:new()
    if not redis then
        return nil, err
    end
 
    local ok, err = self:connect_mod(redis)
    if not ok or err then
        return nil, err
    end
 
    local fun = redis[cmd]
    local result, err = fun(redis, ...)
    if not result or err then
        return nil, err
    end
 
    if is_redis_null(result) then
        result = nil
    end
 
    self.set_keepalive_mod(redis)
 
    return result, err
end
 
 
for i = 1, #commands do
    local cmd = commands[i]
    _M[cmd] =
            function (self, ...)
                return do_command(self, cmd, ...)
            end
end
 
 
function _M.new(self, opts)
    opts = opts or {}
    local check_timeout = (opts.check_timeout and opts.check_timeout * 1000) or 1000  ----1s
    local db_index= opts.db_index or 0
    return setmetatable({
            check_timeout = check_timeout,
            db_index = db_index,
            _reqs = nil }, mt)
end
 
 
return _M