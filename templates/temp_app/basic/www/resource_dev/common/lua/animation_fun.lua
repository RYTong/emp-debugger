animation_fun = {};

--[[
@doc:模仿iphone手机长按菜单效果实现控件的抖动。
@params：
paramCtrl:需要晃动控件
启动单个控件的晃动timer
TODO:有待优化动画效果，加上高度随机提升0-1.5，增强动画效果。
TODO:同一个控件不能同时做几个动画，客户端也不支持同一个控件排队做动画。
]]--



function animation_fun.shake(paramCtrl)
    local random_angle = 0;
    local timer_obj = nil;
    local shake_index = -1;
    -- 旋转状态 0：开始 1：正在做 2：结束
    local animation_state = 0;
    -- 动画状态0：开始 1：正在做 2：结束
    local timer_state = 0;

    local function get_angle()
        math.randomseed(tonumber(tostring(os.time()):reverse():sub(1,6)));
        local random_test = math.random(0,2*10000);
        local random_index = math.random(0,2*10000);
        return random_index/10000;
    end

    local reset = function(object)
        if shake_index == 0 or shake_index == 2 then
            transition:rotate(object,-random_angle,'z',0.1);
        end;
    end;

    local function rotate_stop_lis(object)
        amimation_state = 2;
        if timer_state == 2 then
            reset(object);
        end;
    end;

    local function timer_callback()
        shake_index = shake_index + 1;
        if shake_index == 0 then
		    random_angle = 6 - get_angle();
		elseif shake_index == 1 then
		    random_angle = 0 - random_angle;
		elseif shake_index == 2 then
		    random_angle = -6 + get_angle();
		elseif shake_index == 3 then
		    random_angle = 0 - random_angle;
		    shake_index = -1;
		end;
		timer_state = 1;
		amimation_state = 1;
		transition:setStopListener(paramCtrl[1],rotate_stop_lis);
	    transition:rotate(paramCtrl[1],random_angle,'z',0.1);
    end

    --记录：当把时间间隔改为0.1时动画效果为持续旋转？？？
    local start = function()
        timer_obj = timer:startTimer(0.2, true, timer_callback);
    end;


    local stop = function()
        timer_state = 2;
        timer:stopTimer(timer_obj);
        -- 动作结束
        if amimation_state == 2 then
            reset(paramCtrl[1]);
        end;
    end;

    return start,stop
end
