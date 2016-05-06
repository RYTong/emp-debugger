--- ert lua库核心

------------------------
-- ert表，所有ert lua库都基于该table扩展
-- @class table
-- @name  ert
-- @field config 全局配置表
-- @field channel channel库
-- @field dom     dom库
-- @platform      platform库
-- @static        static库
ert = {};

(function()
    local function init()
        ert.gfile = "ert.lua";
        --- Config 表，管理ERT脚本中的全局配置
        -- @class table
        -- @name ert.config
        -- @field ui_debug 控制是否为ui开发模式，该模式为developer帮助的总开关，在生产下需要关闭
        -- @field debug_message 用于控制是否输出ert：debug
        ert.config = {
            ui_debug = false,
            debug_ert = false,
            debug_message = false,
            error_handler = function(err,no_hide,level)
              if not no_hide then
                ert.channel:hide_all();
              end
              if not ert.config.ui_debug then
                window:alert(err)
              end;
              local level = level or 0;
              error(err,level)
            end
        };

        local ert_meta = {};
        setmetatable(ert, ert_meta);

        ert_meta.__call = function(t, arg)
            return ert.query.get(arg);
        end

        local print = print
        local tconcat = table.concat
        local tinsert = table.insert
        local srep = string.rep
        local type = type
        local pairs = pairs
        local tostring = tostring
        local next = next

        --- 树形打印table的方法
        -- @param root 需要输出的table
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
                    elseif type(v)=="string" and cmm_unit_fun.format_lib:stringLength(v)>50 then
                        tinsert(temp,"+" .. key .. " [" .. cmm_unit_fun.format_lib:subString(v,1,50).."...]")
                    else
                        tinsert(temp,"+" .. key .. " [" .. tostring(v).."]")
                    end
                end
                return tconcat(temp,"\n"..space)
            end
            print(_dump(root, "",""))
        end

        function ert:error(...)
            if self.config.error_handler ~=nil then
                self.config.error_handler(...);
            end
            if self.config.debug_message then
                ert:do_debug(...);
            end
        end

        --- 提供给脚本开发人员的日志输出方法，用于输出日志信息，提供 lua文件名和 line 信息
        -- @param ... 符合print格式的lua字符串参数
        function ert:debug(...)
            if self.config.ui_debug and self.config.debug_message then
                ert:do_debug(...);
            end
        end

        --- 提供给ert框架开发人员的日志输出方法，用于输出ert中的日志信息，提供 lua文件名和 line 信息
        -- @param ... 符合print格式的lua字符串参数
        function ert:debug_ert(...)
            if self.config.ui_debug and self.config.debug_ert then
                ert:do_debug(...);
            end
        end

        function ert:do_debug(...)
            local ctx= debug.getinfo(3).source or "";
            local lineno =  debug.getinfo(3).currentline;
            if type(...) =="table" then
                print(ctx.." line: "..lineno.." table content:")
                ert:print_t(...)
            else
                print(ctx.." line: "..lineno.." :".. tostring(...));
            end
        end

        --- 设置ert框架的debug配置项
        -- @param ui_debug  debug总开关,当设置为true时，其他开关才生效
        -- @param channel_page  channel流程中当报文不存在与本地离线资源时，是否实时从ewp获取
        -- @param channel_json  channel流程中是否直接从ewp获取json模拟数据作为借口返回
        -- @param debug_message ert:debug() 是否输出日志
        -- @param debug_ert     ert:debug_ert() 是否输出日志
        function ert:set_debug(ui_debug, channel_page, channel_json, debug_message, ert_message)
            ert.config.ui_debug = ui_debug;
            if ui_debug then
                ert.config.debug_message = debug_message;
                ert.config.debug_ert = ert_message;
                ert.channel:set_debug(channel_page, channel_json);
            end
        end
    end
    if ert.config == nil then
        init();
    end
end)();
---------------------------------------------------------------
-- 一个简单的栈,非递归遍历二叉树的时候需要用一下
-- @class module
-- @name Stack
-- @author liqiang
(function()
    local function init()
        local Stack = {}

        --[[--
        构造一个栈
        @treturn table copy 空栈
        ]]
        function Stack:new(o)
            local o = o or {};
            setmetatable(o, self)
            self.__index = self
            return o
        end

        --[[--
        得到栈内元素数量
        @treturn number size 元素个数
        ]]
        function Stack:size()
            return #self
        end

        --[[--
        栈是否为空
        @treturn boolean b true为空,否则为不空
        ]]
        function Stack:empty()
            return (self:size() == 0)
        end

        --[[--
        根据索引出栈
        @treturn void value 返回删除的元素,空返回nil
        ]]
        function Stack:pop(index)
            if self:size() == index or index == nil then
                local tmp = self:top()
                table.remove(self)
                return tmp
            elseif self:size() > index and 0 < index then
                table.remove(self)
                return self:pop(index)
            else
                return nil
            end
        end

        --[[--
        入栈
        @param void value 入栈的元素
        @treturn number size 入栈后元素个数
        ]]
        function Stack:push(value)
            table.insert(self, value)
            return self:size()
        end

        --[[--
        得到栈顶元素
        @treturn void value 栈顶元素,空返回nil
        ]]
        function Stack:top()
            local size = self:size()
            if size == 0 then
                return nil
            end
            return self[size]
        end

        ert.stack = Stack;
    end
    if ert.stack == nil then
        init();
    end
end)();
--<<<<<<<<<<<./ert.stack.lua
-->>>>>>>>>>>./ert.query.lua
-- ert query 库，封装常见的控件查询和操作方法；
(function()
    local function init()
        local Query = {
            _tags = {false,false,false},
            _show_tags = {},
            _next_tag = 10
        };

        function Query:new(ctrls, selector)
            local o = {};

            if type(selector) == "string" then
              o._selector = selector
            end
            o._ctrls= ctrls;
            o._tag = 1;
            --o._show_tags = {};
            --o._next_tag = 10;
            o._has_ctrl = #ctrls>0;
            setmetatable(o, self);
            self.__index = self;
            return o;
        end

        ---------------------
        -- 读写Query实例中控件列表的value属性
        -- @param  val   optinal，参数存在时为写入value，不存在时为读取value
        -- @return value type:string
        -- @usage ert("#id"):val();
        -- @usage ert(".style"):val("test");

        function Query:val(val)
            return self:attr("value", val);
        end
        ------
        -- 读写Query实例中的控件属性
        -- @param  arg1 当参数为string类型时为读写单个控件attribute，当参数类型为
        -- table（{attr1=val1, attr2=val2}）时，为写入相应的val到指定的控件属性
        -- @param  arg2 optional type(arg1)=string时，如果参数存在则写入value，不存在时读取value
        -- @usage ert(".class"):attr("enable");
        -- @usage ert(".class"):attr("checked","true");
        -- @usage ert(".class"):attr({"enable"="true","checked"="true"});
        function Query:attr(arg1, arg2)
            ert:debug_ert({arg1,arg2});
            if not self._has_ctrl then
                return nil;
            end
            if arg2 ==nil and type(arg1) == "string" then
                return self._ctrls[1]:getPropertyByName(arg1);
            elseif type(arg1) == "string" and type(arg2) == "string" then
                table.foreachi(self._ctrls,
                function(i, ctrl)
                    ctrl:setPropertyByName(arg1, arg2);
                end);
            elseif arg2 == nil and type(arg1)=="table" then
                table.foreachi(self._ctrls,
                function(i, ctrl)
                    for k,v in pairs(arg1) do
                        ctrl:setPropertyByName(k, v);
                    end
                end);
            else
                ert:debug("error");
            end
        end

        ------
        -- 读写Query实例中的控件样式
        -- @param  arg1 当type=string时为读写单个控件style，type=table
        -- ({style1=val1, style2=val2})时，为写入相应的val到指定的控件样式
        -- @param  arg2 optional type(arg1)=string时，如果参数存在则写入value，不存在时读取value
        -- @usage ert(".class"):css("display");
        -- @usage ert(".class"):css("display","none");
        -- @usage ert(".class"):css({"left"=10,"display"="block"});
        function Query:css(arg1, arg2)
            ert:debug_ert({arg1,arg2});
            if not self._has_ctrl then
                return nil;
            end
            if arg2 == nil and type(arg1) =="string" then
                return self._ctrls[1]:getStyleByName(arg1);
            elseif arg2 == nil and type(arg1) == "table" then
                table.foreachi(self.ctrls,
                function(i, ctrl)
                    for k,v in pairs(arg1) do
                        ctrl:setStyleByName(k, v);
                    end
                end);
            elseif type(arg1) == "string" and type(arg2) =="string" then
                table.foreachi(self._ctrls,
                function(i, ctrl)
                    ctrl:setStyleByName(arg1, arg2);
                end);
            else
                ert:debug("error");
            end
        end

        ------
        -- 遍历Query实例中的控件列表，执行参数中的回调函数
        -- @param  callback 每个控件的回调执行函数
        -- @usage#  ert(".class"):each(function(index, ctrl)
        --   print(index);
        --   ert(ctrl):val("test");
        -- end)

        function Query:each(callback)
            for index, ctrl in ipairs(self._ctrls) do
                coutinue = callback(index, ctrl);
            end
        end



        ------
        -- 绑定Query实例中的click事件回调函数
        -- @param  callback Query始终每个控件的click事件回调函数
        -- @usage#  ert(".class"):click(function(ctrl)
        --   ert.channel:back();
        -- end)
        function Query:click(callback)
            for index, ctrl in ipairs(self._ctrls) do
                ctrl:setOnClickListener(callback);
            end
        end

        ------
        -- 绑定Query实例中的blur事件回调函数
        -- @param  callback Query始终每个控件的blur事件回调函数
        -- @usage#  ert(".class"):blur(function(ctrl)
        --   do_param_check();
        -- end)
        function Query:blur(callback)
            for index, ctrl in ipairs(self._ctrls) do
                ctrl:setOnBlurListener(callback);
            end
        end

        ------
        -- 绑定Query实例中的change事件回调函数
        -- @param  callback Query始终每个控件的change事件回调函数
        -- @usage#  ert(".class"):change(function(ctrl)
        --   do_sth();
        -- end)
        function Query:change(callback)
            for index, ctrl in ipairs(self._ctrls) do
                ctrl:setOnChangeListener(callback);
            end
        end

        ------
        -- 绑定Query实例中的focus事件回调函数
        -- @param  callback Query始终每个控件的focus事件回调函数
        -- @usage#  ert(".class"):focus(function(ctrl)
        --   do_sth();
        -- end)
        function Query:focus(callback)
            for index, ctrl in ipairs(self._ctrls) do
                ctrl:setOnFocusListener(callback);
            end
        end

        ------
        -- 在指定控件上绑定的指定事件处理器
        -- @param  event 事件类型
        -- @param  callback 对应事件处理器
        -- @usage#  ert("#id"):on("click", clickHandler);
        function Query:on(event, callback)
          for i, ctrl in ipairs(self._ctrls) do
            if event == "click" then
                ctrl:setOnClickListener(callback);
            elseif event == "focus" then
                ctrl:setOnFocusListener(callback);
            elseif event == "change" then
                ctrl:setOnChangeListener(callback);
            elseif event == "blur" then
                ctrl:setOnBlurListener(callback);
            end
          end
        end

        ------
        -- 移除指定控件上绑定的指定事件处理器
        -- @param  event 事件类型
        -- @param  callback 对应事件处理器
        -- @usage#  ert("#id"):off("click", clickHandler);
        function Query:off(event, callback)
          for i, ctrl in ipairs(self._ctrls) do
            if event == "click" then
                ctrl:removeOnClickListener(callback);
            elseif event == "focus" then
                ctrl:removeOnFocusListener(callback);
            elseif event == "change" then
                ctrl:removeOnChangeListener(callback);
            elseif event == "blur" then
                ctrl:removeOnBlurListener(callback)
            end
          end
        end

        ------
        -- 局部刷新控件内容
        -- @param  content 报文内容
        -- @usage#  ert(".class"):html(content)
        function Query:html(content)
            if not self._has_ctrl then
                return nil;
            end;
            for index, ctrl in ipairs(self._ctrls) do
                ctrl:setInnerHTML(content);
            end
        end;

        -- 生成控件下标
        function Query:select_tag()
            for k,v in pairs(self._tags) do
                if not v then
                    return k;
                end
            end
            local size = #self._tags;
            table.insert(self._tags, size+1);
            return size+1;
        end
        ---------------------
        --- 隐藏调用window:showControl显示控件
        --- 调用者在调用Query show后需要在相应的隐藏event中Query hide。
        function Query:hide()
            --ert:debug_ert("page tag: ".. self._tag);
            --ert:debug_ert(self._tag);
            -- if self._tag > 0 then
            --     window:hide(self._tag);
            --     self._tags[self._tag] =false;
            -- end
            local tag = 1;
            ert:debug(self._show_tags);
            if type(self._selector) == "string" then
                tag = self._show_tags[self._selector] or 1;
            end
            ert:debug_ert("hide tag: ".. tag);
            window:hide(tag);
        end

        ---------
        -- 调用showControl方法show出控件
        ---------
       -- 调用showControl方法show出控件
       -- params:是否模态 modal_flag
       -- 每次只能show获取控件的第一个控件
        function Query:show(modal_flag)
            --for index,ctrl in ipairs(self._ctrls) do
                --local tag = Query:select_tag();
                --ert:debug_ert("page tag: ".. tag);
                --window:showControl(ctrl, tag)
                --self._tags[tag] = true;
                --self._tag = tag;
            --end;
            if type(self._ctrls[1]) == "userdata" then
              local tag = 1;
              if type(self._selector) == "string" then
                tag = self._next_tag;
                self._show_tags[self._selector] = self._next_tag;
                ert.query._next_tag = self._next_tag + 2;
              end
              ert:debug_ert("show tag: ".. tag);
              window:showControl(self._ctrls[1], tag, modal_flag)
            end
        end;

        --------
        -- 获取由选择器指定的DOM元素
        -- index：可选参数，规定获取哪个index元素（通过index编号），默认返回第一个DOM元素
        function Query:get_userdata(index)
            if index then
                return self._ctrls[index];
            else
                return self._ctrls[1];
            end;
        end;
        ------
        -- 封装Query实例并返回，ert()=Query.get(),返回的Query实例包含一个或多个DOM Element
        -- 当对Query实例进行读操作时，通常返回第一个DOM Element的对应属性；
        -- 而当对Query实例进行写操作时，通常会写入所有的DOM Element
        -- @param selector   type=string|userdata
        -- @usage  ert("#id");
        -- @usage  ert(".class");
        -- @usage  ert("input");
        -- @usage  ert(document:getElementById("id")); = ert("#id");
        -- @usage#  当selector type=string时，为三种类型的选择器
        --   1. id选择器("^#([%w%d_]+)$"),'#'开头的字符串，支持字母、数字和'_'；
        --   2. class选择器("^%.([%w%d_]+)$"),'.'开头的字符串，支持字母、数字和'_';
        --   3. tag选择器("^([%w]_+)$"), 支持字母和'_';
        --   type=userdata时，将客户端返回的DOM Element封装为 Query实例
        function Query.get(selector)
            ert:debug_ert(selector);
            local id_selector = "^#([%w%d_]+)$";
            local class_selector = "^%.([%w%d_]+)$";
            local tag_selector = "^([%w]_+)$";
            local select;
            local ret = {};
            if type(selector) =="userdata" then
                ret[1] = selector;
            else
                _,_,select = string.find(selector, id_selector);

                if select ~= nil then
                    local ctrl = document:getElementById(select);
                    ret[1] = ctrl;
                    ert:debug_ert(ret);
                else
                    _,_,select = string.find(selector, class_selector);
                    ert:debug_ert(select);
                    if select ~= nil then
                        ret = document:getElementsByClassName(select);
                        ert:debug_ert(ret);
                    else
                        _,_,select = string.find(selector, tag_selector);
                        if select~=nil then
                            ret = document:getElementsByTagName(select);
                            ert:debug_ert(ret);
                        end
                    end
                end
            end
            return Query:new(ret, selector);
        end


        ert.query = Query;
    end
    if ert.query == nil then
        init();
    end
end)();
--[[ert.platform
---------------------------------------------------------------------------
封装常用方法,比如获取平台，获取屏幕宽高等。
]]--
(function()
    local function init()
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
    end
    if ert.platform == nil then
        init();
    end
end)();

-- ert dom 库，dom操作库封装
(function()
    local function init()
        local dom = {};

        ---------------------
        -- 根据name获取控件,如果控件存在则返回控件列表table，如果控件不存在则弹出提示框，返回nil。
        -- @param name string 控件名称
        -- @return table 控件列表
        function dom:get_ctrl_by_name(name)
            local ctrl = document:getElementsByName(name);
            if ctrl and #ctrl > 0 then
                return ctrl;
            else
                window:alert(name .. "控件不存在！");
            end;
        end;

        ---------------------
        -- 根据id获取控件，如果控件存在则返回根据id获取的控件，如果id重复也只返回获取的第一个控件，如果控件不存在则弹出提示框，返回nil。
        -- @param id string 控件id
        -- @return userdata 单个控件
        function dom:get_ctrl_by_id(id)
            local ctrl = document:getElementById(id);
            if ctrl then
                return ctrl;
            else
                window:alert(id .. "控件不存在！");
            end;
        end;

        ---------------------
        -- 根据属性列表获取控件，如果控件存在则返回控件列表，如果控件不存在则弹出提示框，返回nil。
        -- @param ... 属性列表，例如{name="button",type="submit"}
        -- @return table 控件列表
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

        ---------------------
        -- 根据名称改变控件样式，如果界面中有多个此名称控件则这些控件都会被修改。
        -- @param name 控件名称
        -- @param style 样式名称，比如："height"
        -- @param value 修改值，需要将控件样式修改的值
        -- @return nil
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

        ---------------------
        -- 根据id改变控件样式，只修改界面中有此id的第一个控件。
        -- @param id 控件Id
        -- @param style 样式名称，比如："height"
        -- @param value 修改值，需要将控件样式修改的值
        -- @return nil
        function dom:set_style_by_id(id,style,value)
            local ctrl = document:getElementById(id);
            if ctrl then
                ctrl:setStyleByName(style,value);
            else
                window:alert(id .. "控件不存在 ！");
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
        @doc:根据ID改变控件属性
        @params:
        name:控件名称
        property:属性，比如："enable"
        value:修改值，需要将控件属性修改的值
        ]]--
        function dom:set_property_by_id(id,property,value)
            local ctrl = document:getElementById(id);
            if ctrl then
                ctrl:setPropertyByName(property,value);
            else
                window:alert(id .. "控件不存在 ！");
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
        @doc:根据id列表改变一系列控件属性
        @params:
        tab_name:控件id列表 {"id1","id2"}
        property:属性，比如："enable"
        value:修改值，需要将控件属性修改的值
        ]]--
        function dom:set_ctrls_property_by_id(tab_id,property,value)
            for key,ctrl_id in pairs(tab_id) do
                local ctrl = document:getElementById(ctrl_id);
                if ctrl then
                    ctrl:setPropertyByName(property,value);
                else
                    window:alert(id .. "控件不存在 ！");
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
        @doc:改变一系列控件样式
        @params:
        tab_id:控件名称列表
        style:属性，比如："height"
        value:修改值，需要将控件样式修改的值
        ]]--
        function dom:set_ctrls_style_by_id(tab_id,style,value)
            for key,ctrl_id in pairs(tab_id) do
                local ctrl = document:getElementById(ctrl_id);
                if ctrl then
                    ctrl:setStyleByName(style,value);
                else
                    window:alert(id .. "控件不存在 ！");
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
        @doc:根据ID获取控件样式
        @params:
        id:控件名称
        style:样式名称，比如："height"
        @attention:如果界面中有多个此名称控件返回值为这些控件样式的集合table。
        如果只有一个控件则直接返回样式值。
        ]]--
        function dom:get_style_by_id(id,style)
            local ctrl = document:getElementById(id);
            if ctrl then
                local style_value = ctrl:getStyleByName(style);
                return style_value;
            else
                window:alert(id .. "控件不存在 ！");
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
        @doc:根据名称获取控件属性
        @params：
        id:控件名称
        property:属性名称，比如:"value"
        @attention:如果界面中有多个此名称控件返回值为这些控件属性的集合table
        如果只有一个控件则直接返回属性值。
        --]]
        function dom:get_property_by_id(id,property)
            local ctrl = document:getElementById(id);
            if ctrl then
                local property = ctrl:getPropertyByName(property);
                return property;
            else
                window:alert(id .. "控件不存在 ！");
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
        function dom:get_ctrl_value_by_name(name,msg,require)
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
        @doc: 根据id获取控件值
        @params:
        name: 控件名称
        msg: 返回的提示消息
        require: 是否验证控件值为空
        @attention:默认此名称控件只有一个
        ]]--
        function dom:get_ctrl_value_by_id(id,msg,require)
            local ctrl = document:getElementById(id);
            local ctrl_value;
            if ctrl then
                ctrl_value = ctrl:getPropertyByName("value");
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
                window:alert( id .. "控件不存在 ！");
            end;
        end;

        --[[
        @doc:根据控件名称获取控件值
        @params:控件名称
        --]]
        function dom:get_ctrl_value_by_name_ex(name)
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
        @doc:根据控件名称获取控件值
        @params:控件名称
        --]]
        function dom:get_ctrl_value_by_id_ex(id)
            local ctrl = document:getElementById(id);
            local ctrl_value;
            if ctrl then
                ctrl_value = ctrl:getPropertyByName("value");
                if ctrl_value == nil then
                    ctrl_value = "";
                end;
                return ctrl_value;
            else
                window:alert( id .. "控件不存在 ！");
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
    end
    if ert.dom == nil then
        init();
    end
end)();

---ert.page库


(function()
    local function init()

        local next =next ;
        ------------
        -- Page类，每个实例对应Channel的一个界面，保存在所属Channel的pages字段中。Page实例一般会
        -- 被每个界面的lua 脚本引用，通常为this = ert.channel:get_page(id, trancode);
        -- @class table
        -- @name  Page
        -- @field _id             当前流程所对应的channel id
        -- @field _trancode       当前流程所处的channel 步骤代码
        -- @field _content        Page报文，通常为静态html界面
        -- @field _data           Page输入 = ert.channel:get_response(_id, _trancode);
        -- @field _user_input     以kv形式存储Page页面中用户输入的信息，key为页面标签的id
        -- @field _last_page      同一Channel流程中的上一个Page实例，用于Page:replace()时缓存其
        -- 页面上的用户输入
        -- @filed _tags           用于Page:show_content()方法中客户端API所需的index，
        -- 存储在Page的metatable中，所有Pages页面共享，目前从1，2，3开始(TODO,改为1001开始)
        local Page = {
            _tags = {false, false, false}
        };


        function Page:new(id, trancode, content, last_page)
            local o = {};
            o._id= id;
            o._trancode = trancode;
            o._content = content;
            o._tag = 0;
            o._user_input = {};
            o._last_page = last_page;
            setmetatable(o, self);
            self.__index = self;
            ert.channel:get_channel():insert_page(o);
            return o;
        end

        ---------------------
        -- 如果当前Page是用show_content的方式显示，即channel流程中的options中指定了
        -- “replace”=”show_content”，则需要页面开发者将Page:hide()绑定到相应的event用于释放该界面
        function Page:hide()
            ert:debug_ert(self._tag);
            if self._tag > 0 then
                window:hide(self._tag);
                self._tags[self._tag] =false;
            end
        end

        ---------------------
        -- 获取当前Page对应的trancode
        function Page:trancode()
            return self._trancode;
        end

        ---------------------
        -- 当前Page是否有缓存的用户输出
        -- @return boolean
        function Page:has_cache()
            return next(self._user_input)~=nil;
        end

        ---------------------
        -- 获取当前Page所属的Channel ID
        function Page:id()
            return self._id;
        end

        ---------------------
        -- 获取当前Page展现所需的动态数据
        function Page:get_data()
            return ert.channel:get_response(self._id, self._trancode);
        end

        ---------------------
        -- 更新当前Page展现所需的动态数据
        function Page:update_data(response)
            local channel = ert.channel:get_channel(self._id);
            channel.response_table[self._trancode] = response;
        end

        function Page.showContent_callback(page)
            ert.channel:hide_loading(1);        end

        function Page.replace_callback(page)
            local channel = ert.channel:get_channel(page._id);
            channel:push_page(page);
            ert.channel.current_page = page;
            ert.channel:hide_loading();
        end

        function Page.replace_callback_nopush(page)
            local channel = ert.channel:get_channel(page._id);
            ert.channel.current_page = page;
            ert.channel:hide_loading();
        end

        function Page:select_tag()
            for k,v in pairs(self._tags) do
                if not v then
                    return k;
                end
            end
            local size = #self._tags;
            table.insert(self._tags, size*2+1);
            return size*2+1;
        end

        function Page:get_user_input(id)
            return self._user_input[id];
        end
        function Page:cache_user_input()
            local ctrls = document:getElementsByClassName("ert_input_cache");
            for k,ctrl in pairs(ctrls) do
                local tag = ctrl:getPropertyByName("tagName");
                local id = ctrl:getPropertyByName("id");
                local type = ctrl:getPropertyByName("type");
                if tag == "input" and type=="text" and id ~=nil then
                    local value = ctrl:getPropertyByName("value");
                    self._user_input[id] = value;
                elseif tag == "label" and id ~=nil then
                    local value = ctrl:getPropertyByName("value");
                    self._user_input[id] = value;
                elseif tag == "input" and type == "checkbox" and id ~= nil then
                    local checked = ctrl:getPropertyByName("checked");
                    self._user_input[id] = checked;
                elseif tag == "input" and type == "radio" and id ~= nil then
                    local checked = ctrl:getPropertyByName("checked");
                    self._user_input[id] = checked;
                elseif tag == "input" and type == "hidden" and id ~= nil  then
                    local value = ctrl:getPropertyByName("value");
                    self._user_input[id] = value;
                elseif tag == "input" and type == "switch" and id ~= nil  then
                    local checked = ctrl:getPropertyByName("checked");
                    self._user_input[id] = checked;
                end
            end
        end
        function Page:replace(transiton_type,nopush)
            if self._last_page ~= nil then
                self._last_page:cache_user_input();
            end
            if nopush then
                location:replace(self._content,self.replace_callback_nopush,self);
            else
                location:replace(self._content,self.replace_callback,self);
            end
        end

        function Page:show_content()
            --ert.channel:hide_loading();
            local tag = self:select_tag();
            window:showContent(self._content, tag,{callback=self.showContent_callback});
            self._tags[tag] = true;
            self._tag = tag;
        end

        function Page:hide_all()
            ert:debug_ert("----------hide all");
            for k,v in pairs(self._tags) do
                ert:debug_ert(k);
                window:hide(k);
                self._tags[k]=false;
            end
        end
        ert.page=Page;
    end


    if ert.page == nil then
        init();
    end
end)();

(function()
    local function init()

        --------------------------
        -- ert.channel=channel_factory 用于存储和所有Channel实例，提供Channel运行所需要的方法
        -- @class table
        -- @name channel_factory
        -- @field ui_debug 是否打开ui 开发者模式，默认值为ert.config.ui_debug
        -- @field debug_page 打开离线资源的开发者模式，通过网络接口从ewp服务上获取离线资源
        -- @field debug_json 打开网络接口的开发者模式，即从ewp服务上的静态文件中模拟接口报文返回
        -- @field loading_tag 用于在channel切换过程中loading界面调用windows:show()/hide()的index，默认为999
        -- @field channels    以kv形式存储正在运行的Channel实例，key为Channel ID
        -- @field channel_stack  一个ert.stack栈实例，用于存放Channel实例的运行顺序
        -- @field wap_entran H5集成入口channelId
        -- @field wap_entran_page H5集成入口page_code
        local channel_factory = {
            debug_page = false,
            debug_json = false,
            wap_debug_json = false,
            loadingtag = 999;
            is_loading = 0;
            wap_entran = "common";
            wap_entran_page = "NCM0015";
            channel_stack = ert.stack:new(),
            channels = {}
        };

        -- 导出channel_stack和page_stack方便使用
        channel_stack = channel_factory.channel_stack;
        page_stack = {};

        function channel_factory:set_debug(debug_page, debug_json)
            self.debug_page = debug_page;
            self.debug_json = debug_json;
            self.wap_debug_json = false;
        end

        ------------
        -- Channel类，每个实例对应一个正在运行的Channel，并保存在channel_factory的channels字段中
        -- @class table
        -- @name  Channel
        -- @field request_table  存储channel请求的上送参数,以 trancode为key
        -- @field response_table 存储channel请求的返回报文,以 id_trancode为key
        -- @field id             Channel id
        -- @field trancode       当前流程所处的channel 步骤代码
        -- @field pages          以kv形式存储已经创建的Page实例，key为trancode
        -- @field page_stack     用erl.stack栈实例存储Page的执行顺序
        local Channel = {
        };


        function Channel:new(o)
            local o = o or {};
            o.page_stack = ert.stack:new();
            --使用外部变量，方便访问
            page_stack = o.page_stack;
            o.options_table = {};
            o.request_table = {};
            o.response_table = {};
            o.pages = {};
            setmetatable(o, self);
            self.__index = self;
            return o;
        end

        function Channel:response(trancode)
            local trancode = trancode or self.trancode
            return self.response_table[trancode];
        end

        function Channel:get_page(trancode)
            if trancode ~= nil then
              return self.pages[trancode] or self.pages[self.page_stack:top()];
            else
              return self.pages[self.page_stack:top()];
            end
        end

        function Channel:insert_request(request,options)
            self.request_table[self.trancode] = request;
            self.options_table[self.trancode] = options;
        end

        function Channel:request(trancode)
            local trancode = trancode or self.trancode
            return self.request_table[trancode];
        end

        function Channel:insert_response(response)
            self.response_table[self.trancode]= response;
        end


        function Channel:push_page(page)
            -- 如果报文无body则界面不入斩
            if string.find(page._content,"<body.*>") ~= nil then
                self.page_stack:push(page:trancode());
            end
        end

        function Channel:pop_page()
            if self.page_stack:size() > 0 then
              return self.pages[self.page_stack:pop()];
            else
              return nil;
            end
        end

        function Channel:insert_page(page)
            self.pages[page:trancode()] = page;
        end

        function Channel:last_page()
            return ert.channel.current_page;
        end

        function channel_factory.fail(response)
          channel_factory:hide_loading();
          if response["responseCode"] == "1599" or response["responseCode"] == 1599 then
            window:alert("很抱歉，会话超时，为保障您的交易安全，请重新打开。","重新打开","退出",
              function(index)
                if index == 1 then
                  window:close();
                else
                  location:replace(file:read("main.xml", "text"));
                end
              end);
          else
            window:alert("服务器处理异常！")
          end
        end

        function channel_factory:hide_loading()
            if self.is_loading == 1 then
                window:hide(self.loadingtag);
            end
            -- is_loading 大于1则自减1，否则置为0
            self.is_loading = self.is_loading > 1 and self.is_loading -1 or 0;
        end

        function channel_factory:hide_all()
            self.is_loading = 0;
            window:hide(self.loadingtag);
        end

        function channel_factory:show_loading()
            if self.is_loading==0 then
                ert:debug_ert("----------show loading");
                window:showContent("local:FullSLoading1.xml", self.loadingtag);
            end
            -- 每次调用，自增1
            self.is_loading = self.is_loading + 1;
        end


        function channel_factory.success(response)
            --local id = channel_factory:get_id();
            local channel = channel_factory:get_channel();
            channel:insert_response(response["responseBody"]);
            local request_callback = channel.options["request_callback"];
            if "function" == type(request_callback) then
              --定制只请求不换页的方法
              request_callback(response)
              if channel.options.show_loading then
                  channel_factory:hide_loading()
              end
            else
              --读取页面刷新页面
              channel_factory:request_callback(response);
            end
        end

        function channel_factory:request_callback(response)
            local id = channel_factory:get_id();
            local channel = channel_factory:get_channel();
            local context = response.context;
            local page_content = channel_factory:get_file(id,channel.trancode);
            local last_page = channel:last_page();
            local page = ert.page:new(channel.id,channel.trancode, page_content, last_page);
            page.context = context;
            local replace = channel.options["replace"];
            if type(replace) == "function" then
                replace(page);
            elseif replace =="show_content" then
                ert:debug_ert("-----------show content")
                page:show_content(page);
            else
                page:replace(channel.options.transiton_type,response.nopush);
            end;
        end
        -- 根据文件路径获取文件
        -- @param file_path 文件路径
        -- 如果为插件资源则为完整文件路径 channel_id/xhtml/***.xhtml
        -- 如果为普通资源则为文件名称 ***.div
        function channel_factory:read_file(file_path)
            local platform_str = ert.platform:os_info();
            local width = screen:width();
            local height = screen:height();
            local page_content =nil;
            if channel_factory.debug_page then
                --增加平台和分辨率参数
                local path = "name="..utility:escapeURI("channels/"..file_path).."&platform="..platform_str.."&resolution="..width.."*"..height;
                --XXX winodws phone 不支持同步请求
                page_content = http:postSyn({}, "test_s/get_page", path);
            else
                page_content = file:read(file_path, "text");
            end
            return page_content;
        end;

        -- 获取文件路径
        function channel_factory:get_file_path(id,trancode)
            local channel = channel_factory:get_channel();
            local option_path = channel.options.option_path;
            local next_page = id .. "/xhtml/" .. trancode .. ".xhtml";
            if option_path ~= nil then
                next_page = option_path..id .. "/xhtml/" .. trancode .. ".xhtml";
            end;
            if string.find(trancode,"%.") ~= nil then
                if option_path ~= nil then
                    next_page = option_path .. id .. "/xhtml/" .. trancode;
                else
                    next_page = id .. "/xhtml/" .. trancode;
                end;
            end;
            return next_page;
        end;
        -- 获取文件
        function channel_factory:get_file(id,trancode)
            local next_page = channel_factory:get_file_path(id,trancode);
            local page_content = channel_factory:read_file(next_page);
            return page_content;
        end;

        function channel_factory.callback(response)
            -- 会话超时界面
            local success_flag = channel_factory.is_response_success(response);
            local id = channel_factory.current_id;
            local channel = channel_factory:get_channel(id);
            if  response["responseCode"] == 200 then
                if success_flag == "xml" then
                    -- 如果返回为xml文件则直接replace
                    local last_page = channel:last_page();
                    local page_content = response["responseBody"];
                    local trancode = os.date("%H%M%S");
                    trancode = channel.trancode .. "_" .. trancode;
                    local page = ert.page:new(channel.id,trancode,page_content, last_page);
                    page:replace(channel.options.transiton_type,response.nopush);
                elseif success_flag then
                    channel.options.success(response);
                else
                    if channel.options.replace == "show_content" then
                        channel_factory:hide_loading(1);
                    else
                        channel_factory:hide_loading();
                    end
                end
            else
                channel.options.fail(response);
            end
        end;

        function channel_factory.is_response_success(response)
            return response["responseCode"] == 200;
        end

        function channel_factory:set_hooks(table)
            if type(table["is_response_success"]) == "function" then
                ert:debug_ert("set hook is_response_success");
                channel_factory.is_response_success = table["is_response_success"];
            end;
        end

        --[[params 参数格式为{trancode="mb001",accno= "12314"}]]--
        function channel_factory.to_post_body(params)
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


        ---------------------
        -- Channel执行界面（Page）切换时的option参数表
        -- @class table
        -- @name options
        -- @field replace  "show_content"|function 页面replace的方式，如果为show_content,则
        -- 会调用window:showContent()遮盖在当前页面之上，使用此方式的页面跳转应注意对应界面脚本中
        -- 保存Page对象的全局变量不能重名
        -- @field show_loading 是否在网络请求过程中加载loading界面
        -- @field transiton_type 界面向下跳转的动画类型
        -- @field back_transiton_type 界面返回的动画类型
        -- @field success_callback 网络请求成功时的回调函数
        -- @field fail_callback   网络请求异常时的回调函数
        local ChannelOptions = {
            context = {};
            show_loading = true;
            transiton_type = transitionType.flipFromLeft;
            back_trasiton_type = transitionType.flipFromLeft;
            success = channel_factory.success;
            fail = channel_factory.fail;
            replace = nil;
        }

        function ChannelOptions:new(o)
            local o = o or {};
            setmetatable(o, self);
            self.__index = self;
            return o;
        end

        function channel_factory:push_channel(channel)
            self.channel_stack:push(channel.id);
            local channels_by_id = self.channels[channel.id] or ert.stack:new();
            channels_by_id:push(channel);
            self.channels[channel.id]=channels_by_id;
            self.current_id=channel.id;
        end

        function channel_factory:pop_channel()
            local id = self.channel_stack:pop();
            self.current_id = self.channel_stack:top();
            local channels_by_id = self.channels[id];
            if channels_by_id ~= nil then
                channels_by_id:pop();
            end;

            local channel = self:get_channel();
            --出栈时重新改变外部指针
            page_stack = {};
            if channel ~= nil then
                page_stack = channel.page_stack;
            end;

            --出栈后，新栈顶页面栈为空时，继续出栈（为避免死循环，最后一层channel栈不会递归出栈）
            -- if #page_stack == 0 and self.channel_stack:size() > 0  then
            --   channel_factory:pop_channel()
            -- end
        end

        ---------------------
        -- 跳转到channel的首个页面，初始化一个Channel实例，存储channel_factory,然后调用channel：next_page()
        -- @see channel:next_page
        function channel_factory:first_page(id, trancode, post_body, options)
            local channel = Channel:new{id = id, trancode = trancode};
            self:push_channel(channel);
            self:next_page(id, trancode, post_body, options);
        end

        -- post_body {id=channel_id,tranCode = tranCode}
        function channel_factory:wap_first_page(c_id,c_trancode,post_body,options)
            local id = ert.channel.wap_entran;
            local trancode = ert.channel.wap_entran_page;
            post_body.longitude = ert.static:get("longitude");
            post_body.latitude = ert.static:get("latitude");
            if options ~= nil then
                local push = options["push"];
                if push == false then
                    ert.channel:pop_channel();
                end;
            end;
            local current_channel = self:get_channel();
            local current_page_code = current_channel.trancode;
            local channel = Channel:new{id = id, trancode = trancode};
            self:push_channel(channel);
            post_body["pre_page_code"] = current_page_code;
            self:next_page(id, trancode, post_body, options);
        end;
        -----------------------------------
        -- 跳转到channel下个界面
        -- @param id 跳转channel ID
        -- @param trancode 跳转channel trancode
        -- @param post_body 当前请求的上送参数，格式为table
        -- @param options 当前请求的配置选项，格式为table
        -- @see options
        function channel_factory:next_page(id, trancode, post_body, options)
            local channel = self:get_channel(id);
            channel.trancode = trancode;
            self.current_id=id;
            channel:insert_request(post_body,options);
            channel.options = ChannelOptions:new(options);
            if channel.options.show_loading then
                self:show_loading();
            end
            if channel.options.just_page == nil then
              if self.debug_json then
                  if channel.options.option_path ~= nil then
                      local option_path = channel.options.option_path;
                      local path = "name="..utility:escapeURI("channels/"..option_path..id.."/json/"..trancode..".json");
                      http:postAsyn({}, "/test_s/get_page", path, self.callback, options);
                  else
                      -- get sample data for debug
                      local path = "name="..utility:escapeURI("channels/"..id.."/json/"..trancode..".json");
                      http:postAsyn({}, "/test_s/get_page", path, self.callback, options);
                  end;
              else
                  -- http:postAsyn接口的params格式{header, url, data, callback, parameters}
                  local client_post = self.to_post_body(post_body);
                  ert:debug_ert("request json from ewp");
                  http:postAsyn({}, "channel_s/run", client_post, self.callback, options);
              end;
            else
              channel:insert_response(channel.options["responseBody"]);
              channel_factory:request_callback(channel.options);
            end;
        end;

        function channel_factory:wap_next_page(id, trancode, post_body, options)
            local channel = self:get_channel(id);
            channel.trancode = trancode;
            self.current_id=id;
            channel:insert_request(post_body,options);
            channel.options = ChannelOptions:new(options);
            if channel.options.show_loading then
                self:show_loading();
            end
            if channel.options.just_page == nil then
              if self.wap_debug_json then
                  -- get sample data for debug
                  local path = "name="..utility:escapeURI("channels/"..id.."/json/"..trancode..".json");
                  http:postAsyn({}, "/test_s/get_page", path, self.callback, options);
              else
                  -- http:postAsyn接口的params格式{header, url, data, callback, parameters}
                  local client_post = self.to_post_body(post_body);
                  http:postAsyn({}, "channel_s/run", client_post, self.callback, options);
              end;
            else
              channel:insert_response(channel.options["responseBody"]);
              channel_factory:request_callback(channel.options);
            end;
        end;
        -- ----------------------------------
        -- -- 跳转到内嵌Html5功能
        -- -- @param page_code 跳转页面页面码，为H5页面页面码
        -- -- 请求common channel中公共webview入口界面
        -- -- 根据page_code获取页面跳转锚点，将锚点传入webview中
        -- function channel_factory:first_page_wap(page_code)
        --     local entra_channel = "common";
        --     local entra_page_code = "NCM0014";
        --     ert.channel:wap_first_page(id, code, {id=id,tranCode=code,page_code=code});
        --     if self.debug_json then
        --         -- get sample data for debug
        --         local path = "name="..utility:escapeURI("channels/"..entra_channel.."/json/"..entra_page_code..".json");
        --         http:postAsyn({}, "/test_s/get_page", path, self.wap_callback, options);
        --     else
        --         -- http:postAsyn接口的params格式{header, url, data, callback, parameters}
        --         local client_post = self.to_post_body({page_code = page_code});
        --         ert:debug_ert("request json from ewp");
        --         http:postAsyn({}, "ebank_s/page_anchor", client_post, self.wap_callback, options);
        --     end;
        -- end;
        -----------------------------------
        -- 获取指定Channel、指定交易步骤（trancode）的上送报文（post_body)
        -- @param id Channel ID
        -- @param trancode 交易步骤码
        function channel_factory:get_request(id, trancode)
            local channel = self:get_channel(id);
            if channel == nil then
                return nil;
            end
            return channel:request(trancode);
        end

        -----------------------------------
        -- 获取指定Channel、指定交易步骤（trancode）的Page实例
        -- @param id Channel ID
        -- @param trancode 交易步骤码
        -- @see Page
        function channel_factory:get_page(id,trancode)
            ert:debug_ert("id: "..id.." trancode :"..trancode);
            local channel = self:get_channel(id);
            --ert:debug_ert(channel.pages[trancode]);
            if channel ~= nil then
                return channel.pages[trancode];
            else
                return nil;
            end
        end

        -----------------------------------
        -- 获取指定Channel、指定交易步骤（trancode）的返回报文
        -- @param id Channel ID
        -- @param trancode 交易步骤码
        function channel_factory:get_response(id, trancode)
            local channel = self:get_channel(id);
            if channel == nil then
                return nil;
            end
            return channel:response(trancode);
        end

        -----------------------------------
        -- 返回当前运行channel的id
        function channel_factory:get_id()
            return self.current_id;
        end

        -----------------------------------
        -- 按照id返回channel对象，如果id为nil则返回当前运行的channel
        -- @param id Channel ID
        function channel_factory:get_channel(id)
            local id = id or self.current_id;
            local channels_by_id = self.channels[id];
            local channel;
            if channels_by_id ~= nil then
                channel = channels_by_id:top();
            end;
            return channel;
        end

        -----------------------------------
        -- 重新加载当前页面
        function channel_factory:reload_current_page()
            local channel = self:get_channel();
            local current_page = self.current_page;
            ert:debug("just reload current_page");
            current_page:replace(channel.options.transiton_type,true)
        end

        ---------------------------------
        -- 根据指定trancode、page_content直接执行加载页面流程,并将页面入栈到当前channel中
        -- @param trancode 生成page对象的id
        -- @parma page_content 页面加载需要的报文
        function channel_factory:replace(trancode,page_content,slt_params)
            local channel = self:get_channel();
            local page = ert.page:new(channel.id,trancode, page_content, channel:last_page());
            page_content = slt2.loadstring(page_content);
            page_content = slt2.render(page_content,slt_params);
            page._content = page_content;
            page:replace(channel.options.transiton_type);
        end

        --------------------------
        -- 根据channel和page参数做返回操作
        --@param channel 需要返回的channel对象
        --@param page    需要返回的page对象
        --@param re_request 是否重新请求数据的的标志
        function channel_factory.do_back(channel,page,re_request)
            if not re_request then
                ert.channel:show_loading();
                page:replace(channel.options.back_trasiton_type,true);
            else
                local options = channel.options_table[page._trancode] or {};
                options.nopush = true;
                ert.channel:next_page(page._id,page._trancode,channel.request_table[page._trancode],options);
            end;
        end;

        function channel_factory.before_back(channel,page,re_request)
            --do nothing here, do rewrite for need
            channel_factory.do_back(channel,page,re_request);
        end;

        -----------------------------------
        -- 根据指定的channelId与trancode返回栈内最近的指定页面，如果没有则返回栈内最近的页面
        --@param channelId 频道id,和trancode有一个为空则不起作用
        --@param trancode 交易码，和channelId有一个为空则不起作用
        --@params re_request 是否重新请求数据的的标志
        --@return 返回page对象
        function channel_factory:back(channelId,trancode,re_request)
            local channel = self:get_channel();
            if channel~= nil then
                local pop_page = channel:pop_page();
                if pop_page ~= nil then
                  local page = channel:get_page();

                  if page ~= nil then
                      --如果指定channelId和trancode，则需要判断是否是指定的页面，不是就继续执行返回；如果没有指定，就直接返回
                      if channelId == page._id and trancode == page._trancode then
                          channel_factory.do_back(channel,page,re_request);
                      elseif  channelId == nil or trancode == nil then
                          channel_factory.before_back(channel,page,re_request);
                      else
                          self:back(channelId,trancode,re_request);
                      end
                  else
                      -- 说明当前page_stack 已经空了。需要进入上一个channel
                      channel:push_page(pop_page);  --为防止当前page为最后一页
                      self:finish(channelId,trancode,re_request);
                  end
                else
                    --当前channel是空栈,因为当前页肯定为上一个非空channel栈的top页，所以出栈后重新操作
                    self:pop_channel();
                    self:back(channelId,trancode,re_request);
                end
            else
                self:finish(channelId,trancode,re_request);
            end
        end

        -----------------------------------
        --退出当前channel，返回进入上一个channel的界面
        --@param channelId 频道id,和trancode有一个为空则不起作用
        --@param trancode 交易码，和channelId有一个为空则不起作用
        --@params re_request 是否重新请求数据的的标志
        --@return 返回page对象
        function channel_factory:finish(channelId,trancode,re_request)
            if self.channel_stack:size() > 1 then
                self:pop_channel();
                local id=self.channel_stack:top();
                self.current_id =id;
                local channel = self:get_channel(id);
                local page = channel:get_page();
                if page ~= nil then
                    --如果指定channelId和trancode，则需要判断是否是指定的页面，不是就继续执行返回；如果没有指定，就直接返回
                    if channelId == page._id and trancode == page._trancode then
                        channel_factory.do_back(channel,page,re_request);
                    elseif  channelId == nil or trancode == nil then
                        channel_factory.before_back(channel,page,re_request);
                    else
                        self:back(channelId,trancode,re_request);
                    end
                else
                  -- page 为nil 说明当前channel没有页面，需要再一次出栈
                    self:finish(channelId,trancode,re_request);
                end
            else
                window:alert("是否退出客户端","退出","取消",
                function(index)
                    if index == 0 then
                        window:close();
                    end
                end);
            end
        end

        ert.channel = channel_factory;
    end
    if ert.channel == nil then
        print("init channel_factory;");
        init();
    end
end)();

---------------------------------------------------------------
-- exception 处理对象
(function()
    local function init()
        local Exception = {}

        --[[--
        构造一个Exception对象
        @treturn table new exception()
        ]]
        function Exception:new(o)
            local o = o or {};
            setmetatable(o, self)
            self.__index = self
            return o
        end

        function Exception:need_login(error_msg)
            window:alert("未登录");
        end;

        function Exception:timeout(error_msg)
            window:alert("很抱歉，登录超时，为保障您的交易安全，请重新打开。","重新打开","退出",
            function(index)
              if index == 1 then
                window:close();
              else
                location:replace(file:read("main.xml", "text"));
              end
            end);
        end;

        function Exception:alert(error_msg,error_code)
            window:alert(error_code.."\n"..error_msg);
        end;

        function Exception:catch_handler(error_code,error_msg,error_codes)
            local server_num = ert.static:get("server_num");
            local error_code = error_code or "";
            local error_codes = error_codes or "";
            local error_code_num = "";
            if error_codes == "" then
                error_code_num = error_code .. "_" .. server_num;
            else
                error_code_num = error_codes .. "_" .. server_num;
            end
            local channel = ert.channel:get_channel();
            local id = channel.id;
            local tranCode = channel.trancode;
            local page_name = channel.request_table[tranCode].page_name;
            if "function" == type(self[error_code]) then
                self[error_code](self,error_msg);
            elseif string.find(tranCode,"^T...[D]+") ~= nil then
                cmm_unit_fun.skip_lib:show_fail(page_name,error_code_num,error_msg);
            else
                self:alert(error_msg,error_code_num);
            end;
        end

        ert.exception = Exception;
    end
    if ert.exception == nil then
        init();
    end
end)();


--------------------------------------------------------------
-- 文件处理对象
(function()
    local function init()
        local Ert_file = {}

        --[[--
        构造一个Ert_file对象
        @treturn table new ert_file()
        ]]
        function Ert_file:new(o)
            local o = o or {};
            setmetatable(o, self)
            self.__index = self
            return o
        end

        -- 返回界面中公共部分代码
        -- path:string,文件路径,完整文件路径，包括文件名。
        -- slt_params,table 对界面进行slt时需要传入的参数。
        -- 返回界面字符串
        function Ert_file:include_page(path,slt_params)
            local page_content = ert.channel:read_file(path);
            page_content = slt2.loadstring(page_content);
            page_content = slt2.render(page_content,slt_params);
            return page_content;
        end;

        -- 返回公共界面代码，不主动调用slt
        function Ert_file:include_page_noslt(path)
            local page_content = ert.channel:read_file(path);
            return page_content;
        end;

        ert.ert_file = Ert_file;
    end
    if ert.ert_file == nil then
        init();
    end
end)();

-------------------------------------------------------------
-- 全局变量get和set方法
(function()
    local function init()
        local Ert_static = {};
        local static_table = {};

        --[[--
        构造一个Ert_static对象
        @treturn table new Ert_static()
        ]]
        function Ert_static:new(o)
            local o = o or {};
            setmetatable(o, self)
            self.__index = self
            return o
        end

        -- 设置全局变量
        -- key：变量的key值。
        -- value: 变量的value值。
        function Ert_static:set(key,value)
            static_table[key] = value;
        end;

        -- 返回全局变量值
        function Ert_static:get(key)
            local value = static_table[key];
            return value;
        end;

        ert.static = Ert_static;
    end
    if ert.static == nil then
        init();
    end
end)();
