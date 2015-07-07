--[[ert ui库核心
---------------------------------------------------------------------------
定义ert ui库的参数配置，提供设置API
定义扩展库所需的基础API，包括
ert:debug(...)
ert:print_t(table)

]]--

ert = {};

ert.gfile = "ert.lua"

ert.config = {
    ui_debug = true,
    debug_message = true
};

local print = print
local tconcat = table.concat
local tinsert = table.insert
local srep = string.rep
local type = type
local pairs = pairs
local tostring = tostring
local next = next


function ert:print_t(root)
	local cache = {  [root] = "." }
	local function _dump(t,space,name)
		local temp = {}
		for k,v in pairs(t) do
			local key = tostring(k)
			if cache[v] then
				tinsert(temp,"+" .. key .. " {" .. cache[v].."}")
			elseif type(v) == "table" then
				local new_key = name .. "." .. key
				cache[v] = new_key
				tinsert(temp,"+" .. key .. _dump(v,space .. (next(t,k) and "|" or " " ).. srep(" ",#key),new_key))
			else
				tinsert(temp,"+" .. key .. " [" .. tostring(v).."]")
			end
		end
		return tconcat(temp,"\n"..space)
	end
	print(_dump(root, "",""))
end

function ert:debug(...)
    if self.config.debug_message then
        local ctx="";
        if ert.channel.id then
            ctx=ert.channel.id .."/".. ert.channel.trancode
        end
        lineno =  debug.getinfo(2).currentline;
        if type(...) =="table" then
            print(ctx.." line "..lineno.." table content:")
            ert:print_t(...)
        else
            print(ctx.."line "..lineno.." :".. ...)
        end
    end
end
--[[ert.platform
---------------------------------------------------------------------------
封装常用方法,比如获取平台，获取屏幕宽高等。
]]--

local platform = {};

--[[
    @doc:获取手机平台
    @return:
    Android：android
    ios:iphone
    WindowPhone:wp
    other:qt
--]]
function platform:os_info()
    local platform = system:getInfo("platform");
    if string.find(platform,"Android") then
        return "android";
    elseif string.find(platform,"iPhone") then
        return "iphone";
    elseif string.find(platform,"Window") then
        return "wp";
    else
        return "qt";
    end;
end;

ert.platform = platform;
--[[ert.channel库
---------------------------------------------------------------------------
封装channel页面跳转的相关的方法，主要提供下列API:
ert.channl:first_page(id, trancode, post_body, options)
ert.channl:next_page(id, trancode, post_body, options)
ert.channl:back()
]]--

local reset_channel = {
    ui_debug = ert.config.ui_debug,
    debug_page = true;          --页面是否从ewp服务获取
    debug_json = true;          --接口数据是否从ewp静态模拟数据获取
    request_table = {},         --请求接口参数
    last_response = {},         --接口返回json数据
    id = nil,
    trancode = nil,
    transiton_type = nil,        -- 页面切换的动画类型
    cache = 0
};

local channel = reset_channel; -- 离线channe库


function channel.reset()
    channel = reset_channel
end


function channel:test()
    if  self.ui_debug then
        window:alert("test")
    end
end


function channel.next_page_callback(params)
    -- 会话超时界面
    ert:debug(params["responseCode"]);
    local next_page = channel.id .. "/xhtml/" .. channel.trancode .. ".xhtml";
    ert:debug("next page = " .. next_page);
    local page =nil;

    local platform_str = platform:os_info();
    local width = screen:width();
    local height = screen:height();

    if params["responseCode"] == 1599 then
        ert:debug("会话超时");
        -- FIXME handle error
    elseif params["responseCode"] == 200 then
        local key = channel.id .. "_" .. channel.trancode;
        channel.last_response[key] = params["responseBody"];
        if channel.ui_debug and channel.debug_page then
            --增加平台和分辨率参数
            local path = "name="..utility:escapeURI("channels/"..next_page).."&platform="..platform_str.."&resolution="..width.."*"..height;
            --XXX winodws phone 不支持同步请求
            page = http:postSyn({}, "test_s/get_page", path);
        else
            page = file:read(next_page, text);
        end

        ert:debug(channel);
        ert.channel.cache = ert.channel.cache + 1;
        history:add(page);
        location:replace(page);
    end
end;

--[[params 参数格式为{trancode="mb001",accno= "12314"}]]--
function channel.to_post_body(params)
    local post = "";
    local ret_post;
    if params then
        for key,value in pairs(params) do
            post = post .. key .. "=" ..utility:escapeURI(value) .. "&";
        end;
        ret_post = string.sub(post,1,string.len(post)-1);
    else
        ret_post = "";
    end;
    return ret_post;
end;

--[[
    说明：根据是否为开发模式请求不同数据来源
    如果为开发模式请求接口为test_s/get_page,请求资源为各个channelId文件夹下json文件夹中静态json数据。
    如果为生产模式请求接口为channel_s/run,请求数据资源为业务处理流程中返回json数据。

    参数：
    id:
    说明：此业务频道channelId。
    格式：string。
    例子："balance_qry"
    tranCode:
    说明：此业务流程唯一业务标识。
    格式：string。
    例子："MB2010"
    post_body:
    说明：此业务流程请求下个接口所需参数。
    格式：table。
    例子：{tranCode="MB2010",accNo= "62252430987612345"}
    options:
    说明：请求可选参数
    格式：table
    例子：{show_loading=true, transition_type=1}


]]--

function channel:first_page(id, trancode, post_body, options)
    self.reset();
    self:next_page(id, trancode, post_body, options);
end

function channel:next_page(id, trancode, post_body, options)

    self.id = id;
    self.trancode = trancode;

    local key = id .. "_" .. trancode;
    channel.request_table[key] = post_body;

    if self.ui_debug and self.debug_json then
        -- get sample data for debug
        local path = "name="..utility:escapeURI("channels/"..id.."/json/"..trancode..".json");
        http:postAsyn({}, "/test_s/get_page", path, self.next_page_callback, nil);
    else
        -- ryt:post接口的params格式{header, url, data, callback, parameters, synchronous}
        local client_post = self.to_post_body(post_body);
        print("request json from ewp")
        ryt:post(nil, "channel_s/run", client_post, self.next_page_callback, nil, false);
    end;
end;

--[[
用于channel流程结束后，跳回进入channel的界面
]]--
function channel:back()
    total_caches = history:length();
    channel_caches = self.cache;
    entrance_page = history:get(total_caches - channel_caches);
    location:replace(entrance_page);
end


ert.channel = channel;
--[[ert.dom
---------------------------------------------------------------------------
封装控件操作库，比如获取控件，修改控件样式，修改控件属性等。
]]--

local dom = {};

--[[
@doc:根据名称获取控件
--]]
function dom:get_ctrl_by_name(name)
    local ctrl = document:getElementsByName(name);
    if ctrl and #ctrl > 0 then
        return ctrl;
    else
        window:alert(name .. "控件不存在！");
    end;
end;

--[[
@doc:根据输入属性获取控件
@params:table,
 example:{name="button",type="submit"}
]]--
-- get方法，根据参数的不同及传入的值
function dom:get_ctrl(...)
	local arg = {...};
	if 1 == #arg then
        if type(arg[1]) == "table" then
            local ctrl = document:getElementsByProperty(arg[1]);
            if ctrl and #ctrl > 0 then
                return ctrl;
            else
                window:alert("所选控件不存在，请检查参数！！");
            end;
        end
    end
end

--[[
@doc:根据名称改变控件样式
@params:
name:控件名称
style:样式名称，比如："height"
value:修改值，需要将控件样式修改的值
@attention:如果界面中有多个此名称控件则这些控件都会被修改。
]]--
function dom:set_style_by_name(name,style,value)
    local ctrl = document:getElementsByName(name);
    if ctrl and #ctrl > 0 then
        for key,ctrl_atom in pairs(ctrl) do
            ctrl_atom:setStyleByName(style,value);
        end;
    else
        window:alert(name .. "控件不存在 ！");
    end;
end;

--[[
@doc:根据名称改变控件属性
@params:
name:控件名称
property:属性，比如："enable"
value:修改值，需要将控件属性修改的值
@attention:如果界面中有多个此名称控件则这些控件都会被修改。
]]--
function dom:set_property_by_name(name,property,value)
    local ctrl = document:getElementsByName(name);
    if ctrl and #ctrl > 0 then
        for key,ctrl_atom in pairs(ctrl) do
            ctrl_atom:setPropertyByName(property,value);
        end;
    else
        window:alert(name .. "控件不存在 ！");
    end;
end;


--[[
@doc:改变一系列控件属性
@params:
tab_name:控件名称列表 {"name1","name2"}
property:属性，比如："enable"
value:修改值，需要将控件属性修改的值
]]--
function dom:set_ctrls_property_by_name(tab_name,property,value)
    for key,ctrlName in pairs(tab_name) do
        local ctrl = document:getElementsByName(ctrlName);
        if ctrl and #ctrl > 0 then
            for key,ctrl_atom in pairs(ctrl) do
                ctrl_atom:setPropertyByName(property,value);
            end;
        else
            window:alert(name .. "控件不存在 ！");
        end;
    end;
end;

--[[
@doc:改变一系列控件样式
@params:
tab_name:控件名称列表
style:属性，比如："height"
value:修改值，需要将控件样式修改的值
]]--
function dom:set_ctrls_style_by_name(tab_name,style,value)
    for key,ctrlName in pairs(tab_name) do
        local ctrl = document:getElementsByName(ctrlName);
        if ctrl and #ctrl > 0 then
            for key,ctrl_atom in pairs(ctrl) do
                ctrl_atom:setStyleByName(style,value);
            end;
        else
            window:alert(name .. "控件不存在 ！");
        end;
    end;
end;


--[[
@doc:根据名称获取控件样式
@params:
name:控件名称
style:样式名称，比如："height"
@attention:如果界面中有多个此名称控件返回值为这些控件样式的集合table。
如果只有一个控件则直接返回样式值。
]]--
function dom:get_style_by_name(name,style)
    local ctrl = document:getElementsByName(name);
    local return_tab = {};
    if ctrl and #ctrl > 0 then
        for key,ctrl_atom in pairs(ctrl) do
            local style = ctrl_atom:getStyleByName(style);
            table.insert(return_tab,style);
        end;
    else
        window:alert(name .. "控件不存在 ！");
    end;
    if #return_tab == 1 then
        return return_tab[1];
    else
        return return_tab;
    end;
end;

--[[
@doc:根据名称获取控件属性
@params：
name:控件名称
property:属性名称，比如:"value"
@attention:如果界面中有多个此名称控件返回值为这些控件属性的集合table
如果只有一个控件则直接返回属性值。
--]]
function dom:get_property_by_name(name,property)
    local ctrl = document:getElementsByName(name);
    local return_tab = {};
    if ctrl and #ctrl > 0 then
        for key,ctrl_atom in pairs(ctrl) do
            local property = ctrl_atom:getPropertyByName(property);
            table.insert(return_tab,property);
        end;
    else
        window:alert(name .. "控件不存在 ！");
    end;
    if #return_tab == 1 then
        return return_tab[1];
    else
        return return_tab;
    end;
end;


--[[
@doc: 根据名称获取控件值
@params:
name: 控件名称
msg: 返回的提示消息
require: 是否验证控件值为空
@attention:默认此名称控件只有一个
]]--
function dom:get_ctrl_value(name,msg,require)
    local ctrl = document:getElementsByName(name);
    local ctrl_value;
    if ctrl and #ctrl > 0 then
        ctrl_value = ctrl[1]:getPropertyByName("value");
        if require then
            if ctrl_value ~= nil and ctrl_value ~= "" then
               return ctrl_value;
            else
                window:alert(msg);
                return -1;
            end;
        else
            return ctrl_value;
        end;
    else
        window:alert( name .. "控件不存在 ！");
    end;
end;


--[[
@doc:根据控件名称获取控件值
@params:控件名称
--]]
function dom:get_ctrl_value_ex(name)
    local ctrl = document:getElementsByName(name);
    local ctrl_value;
    if ctrl and #ctrl > 0 then
        ctrl_value = ctrl[1]:getPropertyByName("value");
        if ctrl_value == nil then
            ctrl_value = "";
        end;
        return ctrl_value;
    else
        window:alert( name .. "控件不存在 ！");
    end;
end;

--[[
@doc:判断控件值是否为空,如果为空则弹出msg,并且返回-1
@params:
value:控件值
msg:为空时弹出信息
@return:
如果参数为空,则返回nil值,如果不为空则直接返回参数值.
--]]
function dom:check_value(value,msg)
    if value == "" or value == nil then
        window:alert(msg);
        return nil;
    else
        return value
    end;
end;

ert.dom = dom;
