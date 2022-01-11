-- Copyright (C) 2016 Yunfeng Meng

-- twitter snowflake
--[[
-- 保留位：保留1 bit符号位0
-- 时间戳: 41 bit表示时间, 精确到毫秒
-- 机器id: 10 bit表示, 最多可以部署1024台机器
-- 序列号: 12 bit表示, 意味着每台机器, 每毫秒最多可以生成4096个id
--]]

local type       = type
local tostring   = tostring
local tonumber   = tonumber
local sub        = string.sub
local now        = ngx.now
local floor      = math.floor
local bit        = require "bit"
local band       = bit.band
local rshift     = bit.rshift
local loadstring = loadstring


--常量
local TIMESTAMP_SINCE_YEAR = 2015 -- 时间戳起始年份
local SECONDS_OF_YEAR      = 365 * 24 * 60 * 60 -- 1年的总秒数


local _M = { _VERSION = '0.01' }


local inc = 0
-- 获取自增序列号(12位)
local function _get_inc()
    inc = (inc + 1) % 4096
    return inc
end


-- 获取机器id(10位)
local function _get_mid(mid)
    if not mid or type(mid) ~= 'number' then
        mid = ngx.worker.pid() -- 用worker进程id代替
    end
    return mid % 1024
end


-- 获取时间戳(41位, 以秒为单位, 小数部分是毫秒)
-- 注: 标准时间戳是格林威治时间1970年01月01日00时00分00秒起至今的总秒数; 为增加使用年限, 根据 TIMESTAMP_SINCE_YEAR 调整起始年份
local function _get_timestamp()
    return now() - (TIMESTAMP_SINCE_YEAR - 1970) * SECONDS_OF_YEAR
end


-- LuaJIT 64位长整型末尾带'LL'
local function _int64tostring(str)
    return sub(tostring(str), 1, -3)
end


-- @param number mid 机器id
function _M.generate_id(mid)
    local timestamp = _get_timestamp()
    local mid = _get_mid(mid)
    local inc = _get_inc()
    local id = 1LL * ((timestamp * 1000) % 0x20000000000) * 0x400000 + mid * 0x1000 + inc -- timestamp转换为毫秒并取余 + 左移22位, mid左移12位

    return _int64tostring(id), timestamp, mid, inc
end


-- 根据生成的id解析并提取timestamp_std（只精确到单位秒）, mid, inc, timestamp
-- @param string id 64位长整型字符串
function _M.decode_id(id)
    local id = loadstring('return ' .. tostring(id) .. 'LL')() -- 将长整型字符串转换为int64_t
    local timestamp = band(rshift(id, 22), 0x1FFFFFFFFFF)
    local timestamp_std = timestamp / 1000 + (TIMESTAMP_SINCE_YEAR - 1970) * SECONDS_OF_YEAR -- 标准时间戳
    local mid = band(rshift(id, 12), 0x3FF)
    local inc = band(id, 0xfff)

    return tonumber(_int64tostring(timestamp_std)), tonumber(_int64tostring(mid)), tonumber(_int64tostring(inc)), _int64tostring(timestamp)
end

return _M