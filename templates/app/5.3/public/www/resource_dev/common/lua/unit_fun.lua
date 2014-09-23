globalTable = {};

ewp_debug = false;

page_ewp_debug = true;
loadingtag = 3;

tempTable = nil;
reliable_msg_view_Table = {};
reliable_msg_view_vTab={};
reliable_msg_view_setTab = {};
xmppUid_info = {};
xmpp_type = "";
user_login_time = "";
login_user = "";

-- register = 0;
reading = 0;
page_flag = "";
xmppTimerRun_flag="no";
mn = 120;
db = database:open("xmpppubsub");
timerxmpp =nil;
xmpp_flag=nil;
xmpp_flag1=nil;
login_flag="";
timer_channelId="";
timer_trancode="";
timer_flag ="";
isFinished_tab ={};
failNode_tab ={};
failNode = {};
--0 启动xmpp服务 ; 1 为未启动
startService_flag = 1;
--0首次登录 ; 1 未退出程序
first_login = 0;
--注册号码
register_phone ="";
register_password ="";
logined_flag = "no";
--更多功能滑动标志
count_flag = true;
tempcurDate =os.time{year=os.date("%Y"),month=os.date("%m"),day=os.date("%d"),hour=os.date("%H"),min=os.date("%M"),sec=os.date("%S")};
--[[此回调方法中做返回错误json的判断，如果正确则将数据放入全局变量并请求界面进入下个界面]]--
function callback_login(params)
    if params["responseCode"] == 200 then
        local trancode = params["key"];
        globalTable[trancode] = params["responseBody"];
        invoke_page("login/xhtml/unlogin_menu.xhtml",page_callback,nil);
    else
        window:hide(loadingtag);
        window:alert("访问失败!");
        return;
    end;
end;


function change_bg(name,bgImg)
    local ctrl = document:getElementsByName(name);
    if ctrl and #ctrl > 0 then
        ctrl[1]:setStyleByName("background-image",bgImg);
    end;
end;

function getValue(name,msg,require)
    local ctrl = document:getElementsByName(name);
    local ctrl_value;
    if ctrl and #ctrl > 0 then
        ctrl_value = ctrl[1]:getPropertyByName("value");
        if require then
            if ctrl_value ~= nil and ctrl_value~="" then
               return ctrl_value;
            else
                window:alert(msg);
                return -1;
            end;
        else
            return ctrl_value;
        end;
    else
        window:alert( name .. "控件不存在！");
    end;
end;

 function get_platform_info()
        platform = system:getInfo("platform");
        if string.find(platform,"Android") then
            return "android";
        elseif string.find(platform,"iPhone") then
            return "iPhone";
        elseif string.find(platform,"Window") then
            return "wp";
        else
            return "qt";
        end;
end;

--[[
    说明：根据是否为开发模式请求不同数据来源
    如果为开发模式请求接口为test_s/get_page,请求资源为各个channelId文件夹下json文件夹中静态json数据。
    如果为生产模式请求接口为channel_s/run,请求数据资源为业务处理流程中返回json数据。

    参数：
    channelId:
    说明：此业务频道channelId。
    格式：string。
    例子："balance_qry"
    tranCode:
    说明：此业务流程唯一业务标识。
    格式：string。
    例子："MB2010"
    postParams:
    说明：此业务流程请求下个接口所需参数。
    格式：table。
    例子：{tranCode="MB2010",accNo= "62252430987612345"}
    busiCallback:
    说明：post请求的回调方法。
    格式：function 名称。
    例子：funCallback
    callbackParams:
    说明：回调方法所需其他参数。
    格式：table。
    例子：{trancode="mb02",channelId="balance_qry"}

    返回：
    一般回调函数实现为跳转入下个界面。

]]--
function invoke_trancode(channelId, tranCode, postParams, busiCallback, callbackParams)

    --[[保存invoke_trancode()的五个参数到callbackParams，用以传值给all_callback()来进入页面]]--
    local params = {};
    params.channelId = channelId;
    params.tranCode = tranCode;
    params.postParams = postParams;
    params.busiCallback = busiCallback;
    params.callbackParams = callbackParams;
    if ewp_debug then
        -- get sample data for debug
        local path = "name="..utility:escapeURI("channels/"..channelId.."/json/"..tranCode..".json");
        params.app_callback = busiCallback;
        ryt:post(nil, "/test_s/get_page", path, all_callback, params, false);
    else
        -- ryt:post接口的params格式{header, url, data, callback, parameters, synchronous}
        local client_post = to_post_body(postParams);
        params.app_callback = busiCallback;
        if callbackParams.login_auth == "true" then
            ryt:post(nil, "${app}_s/login_filter", client_post, all_callback, params, false);
        else
            ryt:post(nil, "channel_s/run", client_post, all_callback, params, false);
        end;
    end;
end;

----------------返回---------------
function back()
    ryt:back();
end;
--[[
   说明：
         验证登陆成功之后进入验证点之前的页面，在堆栈中取出原页面进行展示，并清理客户端存储中的数据。
]]--

function backward_page()
    local result = history:get(-1);
    location:replace(result);
    tempTable = nil;
end;


--[[
   说明：
         登陆成功之后进入验证点之后的页面，即进入下一页面，需要在客户端存储中读取之前存储的数据向服务器发起请求，请求之后清理客户端存储中数据。
]]--
function forward_page()
    invoke_trancode(tempTable.channelId, tempTable.tranCode, tempTable.postParams, tempTable.busiCallback, tempTable.callbackParams);
    tempTable = nil;
end;

--[[
    说明：请求channel/list接口或者其他非channel_s/run接口
    参数：
    url:
    说明：请求接口
    格式：string
    例子："app_s/list"
    postParams:
    说明：请求接口所需参数列表
    格式：table
    例子：{id="${app}_bkrytong",type=collections}
    busiCallback:
    说明：post请求的回调方法。
    格式：function 名称。
    例子：funCallback
    callbackParams:
    说明：回调方法所需其他参数。
    格式：table。
    例子：{key="login_collection"}
]]--
function req_channel_list(url,postParams,busiCallback,callbackParams)
    local client_post = to_post_body(postParams);
    callbackParams.callbackParams = callbackParams;
    callbackParams.app_callback = busiCallback;
    ryt:post(nil, url, client_post, all_callback, callbackParams, false);
end;
--[[
    说明：组装网络请求参数
    参数：
    params:
    说明：请求下个接口所需参数列表
    格式：table
    例子：{trancode="mb001",accno= "12314"}

    返回：
    根据table组装成post请求参数，如trancode=mb001&accno=12314
]]--

function to_post_body(params)
    local post = "";
    local ret_post;
    if params then
        for key,value in pairs(params) do
            print(key);
            post = post .. key .. "=" ..utility:escapeURI(value) .. "&";
        end;
        ret_post = string.sub(post,1,string.len(post)-1);
    else
        ret_post = "";
    end;
    return ret_post;
end;


--[[说明：判断传入数据的格式为json还是xml。
    正则表达式：^%s*%{ 表示以   {开始的字符串。
            ^<%?xml 表示以<?xml 开始的字符串
    参数：
    params_str:
    说明：需要验证字符串
    格式：string
    例子：{"return":{"error":"000000"}}

    返回：
        如果为json返回"json"。
        如果为xml返回"xml"。
        如果不为这两种则返回nil。
]]--
function get_format(paramsStr)
    if string.find(paramsStr,"^%s*%{") ~= nil then
        return "json";
    elseif string.find(paramsStr,"^<%?xml ") ~= nil then
        return "xml"
    else
        return nil;
    end;
end;


function loginCallback(index)
    if index == 0 then
        invoke_page("login/xhtml/unlogin_menu.xhtml",page_callback,nil);
    else
        track:endSession(true);
        window:close();
    end;
end;

--[[说明：将登录验证嵌入到需要验证的流程。
参数： params
说明：客户端回调传回table列表。
格式：table
例子：{["login_auth"] ="true",["landing_page"] = "login/xhtml/login_page.xhtml"}

返回：
如果需要登录验证，则进入登陆界面；
否则，按原来的正常流程走，即不登陆也可正常操作。
]]--
function need_auth(params)
    local ret_data = params["responseBody"];
    local jsonObj = json:objectFromJSON(ret_data);

    --local ret_code = "000000";
    local ret_code = jsonObj["return"]["error_code"];

    params.callbackParams["responseBody"] = params["responseBody"];
    params.callbackParams["responseCode"] = params["responseCode"];

    if params.callbackParams.login_auth == "true" then
         if ret_code == "need_login" then
                --[[把all_callback()传过来的invoke_trancode()的参数保存在全局的tempTable里面，以备forward_page()使用]]--
                tempTable = {};
                tempTable.channelId = params.channelId;
                tempTable.tranCode = params.tranCode;
                tempTable.postParams = params.postParams;
                tempTable.busiCallback = params.busiCallback;
                tempTable.callbackParams = params.callbackParams;
                if logined_flag == "yes" then
                    window:alert("您已登录超时,是否重新登录？","是","否",loginCallback);
                else
                    invoke_page("login/xhtml/unlogin_menu.xhtml",page_callback,nil);
                end;
         else
           params.app_callback(params.callbackParams);
         end;
    else
         params.app_callback(params.callbackParams);
    end;

end;


--[[
    说明：切换页面回调方法
]]--
    function replace_callback(params)
        window:hide(loadingtag);
    end;

--[[
    说明：invoke_trancode中post请求回调方法。
        在此方法中封装错误信息处理方法。
        如果返回responseCode 为1599 则表示会话超时，
        此时返回responseBody为超时界面，后台直接replace即可。
        如果返回responseCode 为200 则表示报文正常返回，
        此时需要判断返回报文为json还是xml数据，如果为xml数据表示在处理过程中出现错误返回，
        将此xml界面直接replace即可弹出错误信息界面。
        在项目中业务流程数据从simulator或者网银app中取回时先进行错误码的判断，如果返回为错误信息，
        则将此业务错误信息throw出来即可。
        返回正常即走正常流程，在xhtml界面报文中只用对正确情况进行处理。
    参数：
    params:
    说明：客户端回调传回table列表。
    格式：table
    例子：{["responseCode"] = 1599,["responseBody"] = "<?xml><content>....</content>"}
    返回：
    如果为会话超时则进入会话超时界面。
    如果为错误信息则会弹出错误信息。
    如果为正常返回则调用正常流程回调方法，此时一般为跳转入下个界面。
]]--
function all_callback(params)

    -- 会话超时界面
    if params["responseCode"] == 1599 then
        location:replace(params["responseBody"],replace_callback,nil);
    elseif params["responseCode"] == 200 then
        local ret_data = params["responseBody"];
        --window:alert(ret_data);
        --返回为xml
        if get_format(ret_data) == "xml" then
            location:replace(ret_data,replace_callback,nil);
        elseif get_format(ret_data) == "json" then
            need_auth(params);
        else
            window:alert("返回数据格式不对，请重新请求!");
        end;
    else
        window:alert("网络请求失败，请重试！");
        return;
    end;
end;

--[[params为请求返回数据，判断返回数据是否错误,临时方法可以去掉]]--
function error_judge(params)
    if params["responseCode"] == 200 then
        local jsonData = params["responseBody"];
        local jsonObj = json:objectFromJSON(jsonData);
        if jsonObj["return"]["error_code"] ~= "000000" then
            local error_msg = jsonObj["return"]["error_msg"];
            return -1,error_msg;
        else
            return 0,"";
        end;
    else
        local error_msg = "网络请求失败，请重试！";
        return -1,error_msg;
    end;
end;

--[[
说明：invoke_trancode方法中post请求通用回调方法
参数：
params：
说明：客户端请求回调方法时传入参数。
格式：table
例子：{["trancode"] = "mb01",["responseCode"] =200}
返回：
请求跳转下个界面方法，进而跳转入下个业务流程界面。
]]--
function callback_channel(params)
    local trancode = params["trancode"];
    globalTable[trancode] = params["responseBody"];
    local channelId = params["channelId"];

    invoke_page(channelId .. "/xhtml/"..channelId.."_"..trancode..".xhtml",page_callback,nil);
end;

--[[
    说明：根据是否为开发模式获取不同界面资源
        如果为开发模式发送请求test_s/get_page获得ewp服务器上静态界面。
        如果为生产模式直接读取客户端本地离线资源界面。
    参数：
    ${app}_file：
    说明：请求界面名称。
    格式：string
    例子：balance_qry/xhtml/balance_qry_mb01.xhtml
    fun_callback:
    说明：post请求回调方法。
    格式：function 名称。
    例子：page_callback
    fun_params:
    说明：请求回调方法时所需参数。
    格式：table
    例子：{trancode="mb01",channelId="balance_qry"}
]]--
function invoke_page(${app}_file,fun_callback,fun_params)
    local page =nil;
    if page_ewp_debug then
        local path = "name="..utility:escapeURI("channels/"..${app}_file);
        --由于winphone暂未支持可靠消息,希望用winphone进入九宫格，请打开下面注释
        --local path = "name="..utility:escapeURI("channels/"..${app}_file).."&platform=qt&resolution=1*1";
        ryt:post(nil, "test_s/get_page", path, fun_callback, fun_params, false)
    else
        local response = {};
        if file:isExist(${app}_file) then
            response["responseCode"] = 200;
            page = file:read(${app}_file, "text");
            response["responseBody"] = page;
        else
             --这个需要商议一下如何定义
            response["responseCode"] = 404
        end;
        fun_callback(response);
    end
end;

--[[
    说明：通用请求获取静态界面回调方法
    参数：
    params：
    说明：客户端post请求回调方法传入参数。
    格式：table
    例子：{["responseCode"] = 200,["responseBody"] = "<?xml><content>..</content>"}
    返回：
    跳转入下个界面，并将此界面加入缓存。
]]--
function page_callback(params)
    if params["responseCode"] == 1599 then
        location:replace(params["responseBody"],replace_callback,nil);
    elseif params["responseCode"] == 200 then
        local page = params["responseBody"];
        history:add(page);
        location:replace(page,replace_callback,nil);
    else
        window:hide(loadingtag);
        window:alert("该离线资源还没有下载完成");
    end
end;

--[[
    说明：点击首页返回主菜单界面
    返回：跳转入首页界面
]]--
function main_page()
    login_flag="";
    count_flag = true;
    invoke_page("login/xhtml/unlogin_menu.xhtml",page_callback, nil);
end;


function main_page_callback()
    invoke_page("login/xhtml/unlogin_menu.xhtml",page_callback, nil);
end;

--[[
    说明：点击返回按钮返回上一界面
    返回：跳转入上一界面
]]--
function back_fun()
    login_flag="";
    local result = history:get(-1);
    location:replace(result);
end;

--[[
    说明：修改控件property方法
    参数：
    name:
    说明：控件名称。
    格式：string
    例子："title_label"
    property:
    说明：属性名称。
    格式：string
    例子："value"
    newValue：
    说明：控件的属性新value。
    格式：string
    例子："1232436"
]]--
function changeProperty(name,property,newValue)
    local ctrl = document:getElementsByName(name);
    if ctrl and #ctrl > 0 then
        ctrl[1]:setPropertyByName(property,newValue);
    end;
end;


--[[变更控件样式]]--
function change_style(name,PX,style)
    local ctrl = document:getElementsByName(name);
    if ctrl and #ctrl > 0 then
        ctrl[1]:setStyleByName(style,PX);
        --如果界面正在生成的时候调用reload就会出问题进不了九宫格：报程序无反应，是否强制关闭
        -- location:reload(true);
    end;
end;

--[[修改控件样式]]--
--[[参数为table，格式{
                    {{"name","sort"},{"style",{{"top","20px"},{"left","200px"}}}},
                    {{"property","class=table1"},{"property",{{"value","test"},{"class","table1"}}}}
                  }
]]--
function change_ctrl_style(ctrlsTable)
    for i,ctrlTable in pairs(ctrlsTable) do
        local ctrl;
        local getClass = ctrlTable[1][1]
        local getValue = ctrlTable[1][2]
        local setClass = ctrlTable[2][1]

        local setValueTable = ctrlTable[2][2]

        if getClass == "name" then
            ctrl = document:getElementsByName(getValue);
        elseif getClass == "property" then
            ctrl = document:getElementsByProperty(getValue);
        elseif getClass == "tag" then
            ctrl = document:getElementsByTagName(getValue)
        else
            window:alert("暂不支持根据此属性获得控件");
            return
        end;

        if ctrl and #ctrl > 0 then
            for i, ctrl in pairs(ctrl) do
                for i,setStyle in pairs(setValueTable) do
                    local styleType = setStyle[1]
                    local styleValue = setStyle[2]
                    if setClass == "style" then
                        ctrl:setStyleByName(styleType,styleValue);
                    elseif setClass == "property" then
                        ctrl:setPropertyByName(styleType,styleValue);
                    else
                        window:alert("暂不支持根据此属性改变控件");
                        return
                    end
                end
            end
        else
            window:alert("控件不存在请修改参数。");
            return
        end;
    end;
end;


--[[获取中文字符串的长度]]--
function length(str)
    --每个汉字占三个byte,都替换为一个''
    local len = #(string.gsub(str,'[\128-\255][\128-\255][\128-\255]',' '));
    return len;
end;

--[[截取中文字符串]]--
function chsize(char)
    if not char then
        return 0
    elseif char >= 0 and char <= 127 then
        return 1
    elseif char >= 128 and char <= 255 then
        return 3
    else
        return 0
    end
end

--[[截取中文字符串]]--
function utf8sub(str, startChar, numChars)
    local startIndex = 1
    --当请求的起始位置大于1时
    -- lua先测试while循环的条件，如果条件为假，那么循环结束
    while startChar > 1 do
        local char = string.byte(str, startIndex)
        startIndex = startIndex + chsize(char)
        startChar = startChar - 1
    end
    local currentIndex = startIndex
    while numChars > 0 and currentIndex <= #str do
        local char = string.byte(str, currentIndex)
        currentIndex = currentIndex + chsize(char)
        numChars = numChars -1
    end
    return str:sub(startIndex, currentIndex-1)
end


--[[截取字符串]]--
function subString(iSummary, startChar, numChars)
    local ret_summary;
    if not(length(iSummary) <= numChars) then
        ret_summary = utf8sub(iSummary,startChar,numChars).."...";
    else
        ret_summary = iSummary;
    end;
    return ret_summary;
end;

--[[数字化--]]
function toNumber(countValue)
    local count;
    --读取表的每一行
    for _, sum in pairs(countValue) do
        --读取表的每一行中的各个列
        for _, num1 in pairs(sum) do
            count=tonumber(num1);
        end;
    end;
    return count;
end;



function callback_channel_second(params)
    -- body
    local trancode = params["key"];
    globalTable["collectionId"] = trancode;
    globalTable[trancode] = params["responseBody"];
    invoke_page("login/xhtml/secondaryMenu.xhtml",page_callback,nil);
end

function back_fun_second(collectionId)
    -- body
    local postParams = {id=collectionId};
    req_channel_list("app_s/list",postParams,callback_channel_second,{key = collectionId});
end

