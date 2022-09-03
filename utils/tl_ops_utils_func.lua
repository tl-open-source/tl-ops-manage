-- tl_ops_utils
-- en : utils
-- zn : 工具类
-- @author iamtsm
-- @email 1905333456@qq.com

local cjson, _  = require("cjson.safe");
local lock      = require("lib.lock");
local shared    = ngx.shared.tlopsbalance;
local find      = ngx.re.find

local _M = {}


-- new tab
function _M:new_tab(narr, nrec)
    local ok, new_tab = pcall(require, "table.new")
    if not ok or type(new_tab) ~= "function" then
        new_tab = function (narr, nrec) return {} end
    end
    return new_tab(narr, nrec)
end


-- 获取当前路径
-- @split : 截取的路径字符
-- @appent : 补充的路径字符
function _M:get_current_dir_path ( split, append )
    local function sum(a, b)
        return a + b
    end
    local info = debug.getinfo(sum)
    local path = info.source
    path = string.sub(path, 2, -1)
    path = string.match(path, "^(.*)\\")
    path = string.gsub(path,'\\','/')

    if type(split) == 'string' and split ~= '' then
        path = string.gsub(path , split , '')
    end

    if type(append) == 'string' and append ~= '' then
        path = path .. append
    end

    return path
end


-- table所有属性转lua table格式string
-- @table数据
function _M:table_data_to_string ( t )
	local content = "["
	for k, v in pairs(t) do
		local data
		if type(v) == "table" then
			data = self:table_data_to_string(v)
		else
			data = tostring(v)
		end
		content = content .. k .. "=" .. data .. ";"
	end
	return content .. "]"
end

-- table转json string
-- @t table数据
function _M:data_to_string ( t )
	local content = ""
	for _, v in pairs(t) do
		if type(v) == "table" then
			content = content .. cjson.encode(v)
		else
			content = content .. tostring(v)
		end
	end
	return content
end


-- 获取tablev的value
function _M:get_table_value_deep_one(table, key)
    for k,v in pairs(table) do
        if k == key then
            return v;
        end
    end
end

-- 获取tablev的value, 嵌套一级
function _M:get_table_value_deep_two(table, key)
    for k,v in pairs(table) do
        if type(v) == 'table' and v then
            for v_key, v_value in pairs(v) do
                if v_key == key then 
                    return v_value;
                end
            end
        end
    end
end

-- 获取tablev的value, 嵌套二级
function _M:get_table_value_deep_three (table, key)
    for k,v in pairs(table) do
        if type(v) == 'table' and v then
            for v_key, v_value in pairs(v) do
                if type(v_value) == 'table' and v_value then
                    for v_key_key, v_value_value in pairs(v_value) do
                        if v_key_key == key then 
                            return v_value_value;
                        end
                    end
                end
            end
        end
    end
end

-- 获取tablev的value
function _M:get_table_value_by_deep (table, key, deep)
    if deep == 1 then
        return self:get_table_value_deep_one(table,key);
    elseif deep == 2 then
        return self:get_table_value_deep_two(table,key);
    elseif deep == 3 then
        return self:get_table_value_deep_three(table,key);
    end
end

-- 获取post数据table格式， name : 参数名， deep : 在table中处于的层级
function _M:get_req_post_args_by_name (name, deep)
    ngx.req.read_body()
    local post_args_tab,_ = ngx.req.get_body_data()

    if not post_args_tab or post_args_tab == nil then
        return false, _;
    end

    post_args_tab = cjson.decode(post_args_tab);
    
    return self:get_table_value_by_deep(post_args_tab, name, deep);
end

-- 返回str匹配结果
function _M:get_str_matcher (reg, str)
    local res = find(str, reg , 'jo');
    if not res or res == nil then 
        return false , res;
    else 
        return true, res;
    end    
end

-- 返回table内key匹配结果
function _M:get_str_matcher (reg, table)
    local res_tb = {};

    for k, v in pairs(table) do  
        if type(k) == 'string' then 
            local rt,res = get_str_matcher(reg, k);
            res_tb[k] = res;
        end
    end

    return true, res_tb;
end

--返回lua文件内的table格式数据
function _M:get_str_table_by_lua_file (filename)
    local res, _ = require(filename);
    if not res or res == nil then
        return false, filename .. " nil" .. _;
    else 
        return true, res;
    end
end    

--返回lua文件内的json格式数据
function _M:get_str_json_by_lua_file (filename)
    local res,_ = require(filename);
    if not res or str == nil then
        return false, filename .. " nil" .. _;
    end

    local str, _ = cjson.encode(res);
    if not str or str == nil then
        return false, "str nil " .. _;
    end
    
    return true, str;
end    

-- 设置response为text
function _M:set_ngx_response_type_text ()
    ngx.header['Content-Type'] = 'text/plant';
end

-- 设置response为json
function _M:set_ngx_response_type_json ()
    ngx.header['Content-Type'] = 'application/json';
end

-- 获取uri
function _M:get_req_uri()
    return ngx.var.request_uri;
end

--返回json返回值
function _M:get_str_json_by_return_arg (code, msg, data)
    local res_json = cjson.encode({
        code = code,
        msg = msg,
        data = data
    });
    
    return res_json;
end

--成功返回
function _M:set_ngx_req_return_ok (code, msg, data)
    self:set_ngx_response_type_json();
    ngx.status = 200;
    ngx.say(self:get_str_json_by_return_arg(code, msg, data));
    ngx.flush();
end

--指定格式返回
function _M:set_ngx_req_return_content (status, content, content_type)
    ngx.header['Content-Type'] = content_type;
    ngx.status = status;
    ngx.say(content);
    ngx.flush();
end

--返回正则的str
function _M:get_str_matcher_str (str, reg)
    if str == "" or reg == "" then
        return nil, "args empty";
    end    

    local mather = find(str , reg , 'jo');
    if not mather or mather == nil then
        return nil, "no matcher";
    end

    return mather;
end

-- 返回table中value正则匹配上的str，返回匹配的结果
function _M:get_table_matcher_str (table, key, str)
    local matcher_list = {};
    local count = 0;
    for k ,list in pairs(table) do
        if k == key then
            for i, obj in pairs(list) do
                local matcher, _ = self:get_str_matcher_str(str, obj.url)
                if matcher ~= "" and matcher ~= nil and type(matcher) == 'table' then
                    matcher_list[count] = matcher;
                    count = count + 1;
                end
            end
        end
    end
    return matcher_list;
end

--返回table中value正则匹配上的最长str，返回匹配的结果
function _M:get_table_matcher_longer_str (table, key, str) 
    local longer_str = "";

    local matcher = self:get_table_matcher_str(table, key, str);
    if not matcher then
        return longer_str;
    end

    for i ,match in pairs(matcher) do
        if match and type(match) == 'table' then
            if #match[0] > #longer_str then
                longer_str = match[0];
            end
        end
    end

    return longer_str, matcher;
end

-- 返回table中value正则匹配上的str 给apiList用， 返回匹配的{ip : '', url : ''}
function _M:get_table_matcher_str_for_api_list (table, key, str)
    local matcher_list = {};
    local count = 0;
    for k ,list in pairs(table) do
        if k == key then
            for i, obj in pairs(list) do
                local matcher, _ = self:get_str_matcher_str(str, obj.url)
                if matcher ~= "" and matcher ~= nil and type(matcher) == 'table' then
                    matcher_list[count] = obj;
                    count = count + 1;
                end
            end
        end
    end
    return matcher_list;
end

--返回table中value正则匹配上的最长str    给apiList用， 返回匹配的{ip : '', url : ''}
function _M:get_table_matcher_longer_str_for_api_list (table, key, str) 
    local longer_str = "";
    local res_obj_index = 0;

    local matcher = self:get_table_matcher_str_for_api_list(table, key, str);
    if not matcher then
        return longer_str;
    end

    for i ,obj in pairs(matcher) do
        if obj and type(obj) == 'table' then
            local url = obj.url;
            if #url > #longer_str then
                longer_str = url;
                res_obj_index = i;
            end
        end
    end

    return matcher[res_obj_index], matcher;
end


-- 返回table中是否存在该元素
function _M:get_table_element_exsit ( tables,  element )
    if not str then
        return nil
    end

    if type(element) == 'string' then
        for i = 0, #tables do
            if tables[i] == element then
                return true
            end
        end
        return false
    end

    return false
end


-- 获取ip
function _M:get_req_ip()

    local headers = ngx.req.get_headers()

    local ip = headers["X_real_ip"]

    if not ip then
        ip = headers["X_Forwarded_For"]
    end

    if not ip then
        ip = ngx.var.remote_addr
    end

    if not ip then
        return nil
    end

    return ip
end


-- lock
function _M:tl_ops_worker_lock(key, time)
	local ok, _ = shared:add(key, true, time)
	if not ok then
		if _ == "exists" then
			return nil
		end
		return nil
    end
	
	return true
end



-- 生成 '服务-节点' , '服务' key
function _M:gen_node_key(prefix, node, node_id)
    if not node_id then
        return prefix .. "_" .. node;
    else 
        return prefix .. "_" .. node .. "_" .. node_id;
    end
end




return _M;