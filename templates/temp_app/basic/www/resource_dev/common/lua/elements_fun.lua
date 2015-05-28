--[[
    @doc:控件操作共通方法
]]--

elements_fun = {};

--[[
@doc:根据名称改变控件样式
@params:
name:控件名称
style:样式名称，比如："height"
value:修改值，需要将控件样式修改的值
@attention:如果界面中有多个此名称控件则这些控件都会被修改。
]]--
function elements_fun.changeStyle(name,style,value)
    local ctrl = document:getElementsByName(name);
    if ctrl and #ctrl > 0 then
        for key,ctrl_atom in pairs(ctrl) do
            ctrl_atom:setStyleByName(style,value);
        end;
    else
        window:alert("控件不存在！");
    end;
end; --测试我是



--[[
@doc:根据名称改变控件属性
@params:
name:控件名称
property:属性，比如："enable"
value:修改值，需要将控件属性修改的值
@attention:如果界面中有多个此名称控件则这些控件都会被修改。
]]--
function elements_fun.changeProperty(name,property,value)
    local ctrl = document:getElementsByName(name);
    if ctrl and #ctrl > 0 then
        for key,ctrl_atom in pairs(ctrl) do
            ctrl_atom:setPropertyByName(property,value);
        end;
    else
        window:alert("控件不存在！");
    end;
end;


--[[
@doc:改变一系列控件属性
@params:
tab_name:控件名称列表 {"name1","name2"}
property:属性，比如："enable"
value:修改值，需要将控件属性修改的值
]]--
function elements_fun.changeCtrlsProperty(tab_name,property,value)
    for key,ctrlName in pairs(tab_name) do
        local ctrl = document:getElementsByName(ctrlName);
        if ctrl and #ctrl > 0 then
            for key,ctrl_atom in pairs(ctrl) do
                ctrl_atom:setPropertyByName(property,value);
            end;
        else
            window:alert("控件不存在！");
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
function elements_fun.changeCtrlsStyle(tab_name,style,value)
    for key,ctrlName in pairs(tab_name) do
        local ctrl = document:getElementsByName(ctrlName);
        if ctrl and #ctrl > 0 then
            for key,ctrl_atom in pairs(ctrl) do
                ctrl_atom:setStyleByName(style,value);
            end;
        else
            window:alert("控件不存在！");
        end;
    end;
end;

function jc_test3()
    print("this is test3")
end
