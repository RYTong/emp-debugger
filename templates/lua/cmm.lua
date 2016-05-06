
cmm_unit_fun = {};

--定义项目公共方法
(function()
    local function init()
        --字符串格式化公共方法
        local format_lib = {};

        --判断闰年平年
        local function judge_year(year)
            if tonumber(year)%400 == 0 then
                flag = "闰年";
            elseif tonumber(year)%100 ~= 0 and tonumber(year)%4 == 0 then
                flag = "闰年";
            else
                flag = "平年";
            end
            return flag;
        end

        --判断年月
        local function judge_mouth(flag,mouth)
            if flag == "闰年" then
                if tonumber(mouth) == 2 then
                    days = "29";
                elseif tonumber(mouth) == 4 or tonumber(mouth) == 6 or tonumber(mouth) == 9 or tonumber(mouth) == 11 then
                    days = "30";
                else
                    days = "31";
                end
            else
                if tonumber(mouth) == 2 then
                    days = "28";
                elseif tonumber(mouth) == 4 or tonumber(mouth) == 6 or tonumber(mouth) == 9 or tonumber(mouth) == 11 then
                    days = "30";
                else
                    days = "31";
                end
            end
            return days;
        end

        --推算月份
        function format_lib:get_before_mouth_data(date,mouths)
            local year = string.sub(date,1,4);
            local mouth = string.sub(date,5,6);
            local day = string.sub(date,7,8);
            --当前年月
            local flag1 = judge_year(year);
            local day1 = judge_mouth(flag1,mouth);
            --判断月份是否跨年
            local year_nums = tonumber(mouths)/12;
            local year_num = tonumber(string.format("%d",year_nums));
            local mouth_num = mouths%12;
            --推后的月份
            local mouth1 = mouth + mouth_num;
            --判断是否跨年
            if tonumber(mouth1) > 12 then
                --又跨年
                year1 = year+1+year_num;
                mouth2 = tonumber(mouth1) - 12;
                local flag = judge_year(year1);
                local days = judge_mouth(flag,mouth2);
            else
                --不跨年
                year1 = year+year_num;
                mouth2 = mouth1;
                local flag = judge_year(year1);
                local days = judge_mouth(flag,mouth2);
            end
            --大数减小数
            if days > day1 then
                num_days = days -day1;
            else
                num_days = day1 - days;
            end
            --判断是否为月末
            local day_number = day1 - day;
            if day == day1 then
                T_day = days;
            elseif day1>days and day_number <= num_days then
                T_day = days;
            else
                T_day = day;
            end
            --判断月份是否大于10
            if mouth2 < 10 then
                mouth3 = "0"..mouth2;
            else
                mouth3 = mouth2;
            end
            -- 返回推算后时间
            local calculate_time = year1..mouth3..T_day;
            return calculate_time;
        end
        --在设置卡片别名判断别名中是否含有特殊字符，别名只能是数字，字母，汉字。
        --第一行是去除首尾空格。
        --第二行中0-9表示可以输数字，a-z表示小写字母，A-Z表示大写字母，\128-\254表示可以输汉字。
        function format_lib:judge_card_alias(card_alias)
            local card_alias = string.gsub(card_alias, "^%s*(.-)%s*$", "%1");
            local new_alias = string.match(card_alias,"[0-9a-zA-Z\128-\254]+");
            if new_alias ==nil and card_alias ~= nil then
               ert:error("请输入汉字，字母或数字");
            end;
            if string.len(card_alias) ~= string.len(new_alias) then
                ert:error("请输入汉字，字母或数字");
            end;
        end;


        -- 对于卡片设置过别名的，优先展示别名，并展示卡号后4位
        -- 若卡片没有设置过别名，则展示卡号前6位和后4位，中间隐去
        function format_lib:format_card_alias(card_no,card_alias)
            if card_alias ~= nil and card_alias ~= "" then
              --   local num = 0;
              --   if string.len(card_alias) > 18 then
              --     for i=1,18 do
              --         if string.match(string.sub(card_alias,i,i),"[\128-\254]+") == nil then
              --             num = num + 1;
              --         end
              --     end
              --     card_alias = string.sub(card_alias,1,18+num%3).."...";
              -- end
                return string.format("%s(*%s)",
                        card_alias,
                        string.sub(card_no,string.len(card_no)-3,string.len(card_no)))
            else
                return string.format("%s****%s",
                    string.sub(card_no,1,6),
                    string.sub(card_no,string.len(card_no)-3,string.len(card_no)))
            end;
        end;

        --[[
       @desc  检查字符串是否为合法的身份证号码
       @param {string} s - 字符串
       @returns {boolean} 是否为合法身份证号码
       @example local id = '430421197710177894';
       cmm_unit_fun.format_lib:check_IDnumber(id); //true;
       ]]--
        function format_lib:check_IDnumber(s)
          --检查长度是否合法
          local ID_length= #s;
          if ID_length ~=15 and ID_length~=18 then
            window:alert("请输入正确的证件号码！");
            return false;
          else
            --检查是否为数字
            local testInt;
             if ID_length ==15 then
                testInt = tonumber(s);
             else
                testInt = tonumber(string.sub(s,1,17));
             end;
            if(testInt==nil) then
               window:alert("请输入正确的证件号码！");
              return false;
            end;

             --检查区域代码是否合法
            local areaCode = string.sub(s,1,2);
            if(cmm_dict.area_code[areaCode]==nil) then
               window:alert("请输入正确的证件号码！");
              return false;
            end;

             --检查出生日期是否合法
            local year_old,month_old,day_old;
             if ID_length ==15 then
                year_old = "19" + string.sub(s,7,8);
                month_old = string.sub(s,9,10);
                day_old = string.sub(s,11,12);
             else
               year_old = string.sub(s,7,10);
               month_old = string.sub(s,11,12);
               day_old = string.sub(s,13,14);
             end;
             local time_number = os.time{year =year_old,month=month_old,day=day_old};
             local year_new = tostring(os.date("*t",time_number).year);
             local month_new = tostring(os.date("*t",time_number).month);
             if #month_new== 1 then
               month_new = "0"..month_new;
             end;
             local day_new = tostring(os.date("*t",time_number).day);
             if #day_new== 1 then
               day_new = "0"..day_new;
             end;
             if year_old ~= year_new or month_old ~= month_new or day_old ~= day_new then
               window:alert("请输入正确的证件号码！");
               return false;
             end;

             --检查校验位是否合法
            if(ID_length == 18) then
              local testNumber = (tonumber(string.sub(s,1,1)) + tonumber(string.sub(s,11,11))) * 7
                + (tonumber(string.sub(s,2,2)) + tonumber(string.sub(s,12,12))) * 9 + (tonumber(string.sub(s,3,3))
                + tonumber(string.sub(s,13,13))) * 10 + (tonumber(string.sub(s,4,4)) + tonumber(string.sub(s,14,14))) * 5
                 + (tonumber(string.sub(s,5,5)) + tonumber(string.sub(s,15,15))) * 8 + (tonumber(string.sub(s,6,6))
                 + tonumber(string.sub(s,16,16))) * 4 + (tonumber(string.sub(s,7,7)) + tonumber(string.sub(s,17,17))) * 2
                  + tonumber(string.sub(s,8,8)) * 1 + tonumber(string.sub(s,9,9)) * 6 + tonumber(string.sub(s,10,10)) * 3;
              if(string.sub(s,18,18) ~= string.sub("10X98765432",(testNumber % 11)+1,(testNumber % 11)+1)) then
                 window:alert("请输入正确的证件号码！");
                return false;
              end;
            end;
          end;
          return true;
        end;

        -- 显示手机号尾数4位
        function format_lib:format_phone(phone_num)
            return string.format("****%s", string.sub(phone_num,8,11));
        end;

        --将时间转换为秒
        -- @params:date_param 日期，格式为yyyyMMdd
        function format_lib:format_date_mins(date_param)
            local now_date;
            if date_param == nil then
               now_date = os.date("%Y%m%d");
            else
               now_date = date_param;
            end;
            now_date = tostring(now_date);
            local Y = string.sub(now_date,1,4);
            local M = string.sub(now_date,5,6);
            local D = string.sub(now_date,7,8);
            now_date = os.time{year=Y, month=M, day=D};
            return now_date;
        end;
        --  转换日期时间格式
        --  dates为要转换的参数
        --  sign为要添加的符号
        function format_lib:date_time(dates,sign)
            local sign = sign or "";
            local payDate = "";
            local filg = string.len(dates);
            if filg == 10 then
                  payDate = string.sub(dates,1,4) .. sign ..
                            string.sub(dates,6,7) .. sign ..
                            string.sub(dates,9,10);
            elseif filg == 8 then
                  payDate = string.sub(dates,1,4) .. sign ..
                            string.sub(dates,5,6) .. sign ..
                            string.sub(dates,7,8);
            elseif filg == 14 then
                  --截取时间为年-月-日 时：分：秒
                  payDate = string.sub(dates,1,4) .. sign ..
                            string.sub(dates,5,6) .. sign ..
                            string.sub(dates,7,8) .. " " ..
                            string.sub(dates,9,10) .. ":" ..
                            string.sub(dates,11,12) .. ":" ..
                            string.sub(dates,13,14);
            elseif filg == 6 then
                  payDate = string.sub(dates,1,2) .. sign ..
                            string.sub(dates,3,4) .. sign ..
                            string.sub(dates,5,6);
            else
                  window:alert("日期格式有误！")
            end
            return payDate;
        end;

        -- 分割字符串
        -- @params: str 字符串
        -- @ delimiter:分隔符
        -- @ return: 返回分割后的table
        function format_lib:split_str(str,delimiter)
            if str==nil or str=='' or delimiter==nil then
        		return nil
        	end;
            local result = {}
            for match in (str..delimiter):gmatch("(.-)"..delimiter) do
                table.insert(result, match)
            end
            return result
        end;

        -- 转换金额格式
        -- @params：金额，格式 字符串
        -- 判断金额输入格式是否正确，判断整数位不能超过12位。
        -- 返回两位小数金额，如果为整数则添加.00；
        function format_lib:format_money(money_str)
            if money_str ~= "" and money_str ~= nil then
                local num = tonumber(money_str);
                if num ~= nil then
                    if num < 0 then
                        window:alert("金额不支持负数，请重新输入！");
                        return 0;
                    else
                        return string.format("%0.2f",num);
                    end
                else
                    window:alert("请输入正确格式的金额！");
                    return 0;
                end
            end
        end

        --校验输入框只能输入数字字母或者汉字
        --value 用户输入的数据
        --msg 弹框提示
        --num  1-只可输入数字 2-只可输入数字字母 3-只可输入数字字母汉字
        function format_lib:limit_input(num,value,msg)
          local uesr_names = string.gsub(value, "^%s*(.-)%s*$", "%1");
          local new_uesr_name = "";
          if tonumber(num) == 1 then
              new_uesr_name = string.match(uesr_names,"[0-9]+");
          elseif  tonumber(num) == 2 then
              new_uesr_name = string.match(uesr_names,"[0-9a-zA-Z]+");
          elseif  tonumber(num) == 3 then
              new_uesr_name = string.match(uesr_names,"[0-9a-zA-Z\128-\254]+");
          else
              new_uesr_name = string.match(uesr_names,"[0-9a-zA-Z\128-\254]+");
          end;
          if new_uesr_name == nil and uesr_names ~= nil then
              ert:error(msg);
          elseif string.len(new_uesr_name) ~= string.len(uesr_names) then
              ert:error(msg);
              --window:alert(msg);
          end;
        end;

        --[[
            说明:将数字转换成money格式
            输入：货币种类money_type,数字number
            params:
                money_type:转换金额后需要加的符合，比如 ￥，$
                number:需要转换的金额
            @useage：
            cmm_unit_fun.format_lib:number_to_money("",102);    -->102.00
            cmm_unit_fun.format_lib:number_to_money("",102123); --> 102,123.00
            cmm_unit_fun.format_lib:number_to_money("$",102123); --> $102,123.00
          ]]--
        function format_lib:number_to_money(money_type,number)
            local deal_str = number;
            if deal_str == nil or deal_str == "" or deal_str == "null"  then
                return ""
            end


            --判断传入参数是否为数字
            if type(deal_str) == "string" and string.find(deal_str,",") then
                return money_type .. deal_str;
            end
            if type(deal_str) == "string" then
                deal_str = tonumber(deal_str);
            end
            deal_str = string.format("%.2f", deal_str);
            while true do
                deal_str, k = string.gsub(deal_str, "^(-?%d+)(%d%d%d)","%1,%2")
                if k == 0 then
                    break
                end
            end
            return money_type..deal_str
        end;

        -- 判断输入金额格式
        -- @params:金额 字符串
        -- 判断金额不能输入超过两位小数
        function format_lib:judg_amount(amount_str)
            if amount_str ~= "" or amount_str ~= nil then
                local num = tonumber(amount_str);
                if num ~= nil then
                    --返回金额的整数部分和小数部分
                    local int_part, fractional_part = math.modf(num);
                    cmm_unit_fun.get_lib:raise_when_false(fractional_part,"小数位为两位!",
                        function(arg)
                            return not (string.len(tostring(fractional_part)) > 4)
                        end);
                else
                    window:alert("请输入正确格式的金额！");
                end
            end
        end;
        -- 四舍五入
        -- @params:
        -- num：需要转换数据
        -- n : 四舍五入位数，>0表示小数点前多少位，< 0 表示小数后多少位
        -- 函数会取n前面的一位进行四舍五入
        -- useage：
        -- round_off(10806,2) = 10810
        -- round_off(10806,3) = 10800
        -- round_off(10896,3) = 10900
        -- round_off(108.06,-1) = 108.1
        -- round_off(108.06,-2) = 108.06
        -- round_off(108.06879,-3) = 108.069
        -- round_off(108.06879,-2) = 108.07
        function format_lib:round_off(num,n)
            if n > 0  then
                local scale = math.pow(10,n-1);
                return math.floor(num/scale+0.5)*scale;
            elseif n < 0 then
                local scale = math.pow(10,n);
                return math.floor(num/scale+0.5)*scale;
            elseif n == 0 then
                return num
            end;
        end;

        --使用key对table排序
        local function sort_fun(a,b)
            if tostring(a) < tostring(b) then
                return true;
            end;
        end;

        -- 由于lua table循环为hash循环，改为使用字母顺序排序
        -- @usage
        function format_lib:pairs_by_keys(t)
            local a={};
            for n in pairs(t) do
                table.insert(a,n)
            end;
            table.sort(a,sort_fun)
            local i = 0;
            local iter =
                function()
                    i = i + 1;
                    if a[i] == nil then
                        return nil
                    else
                        return a[i],t[a[i]]
                    end;
                end;
            return iter;
        end;

        -- 增加字符串截取函数
        --[[
          内部函数
        ]]--
        local function chsize(char)
          if not char then
            return 0;
          elseif char >= 0 and char <= 127 then
            return 1;
          elseif char >= 128 and char <= 255 then
            return 3;
          else
            return 0;
          end;
        end;

        --[[
        内部函数
        ]]--
        local function utf8sub(str, startChar, numChars)
          local startIndex = 1;
          --当请求的起始位置大于1时
          -- lua先测试while循环的条件，如果条件为假，那么循环结束
          while startChar > 1 do
            local char = string.byte(str, startIndex);
            startIndex = startIndex + chsize(char);
            startChar = startChar - 1;
          end

          local currentIndex = startIndex;

          while numChars > 0 and currentIndex <= #str do
            local char = string.byte(str, currentIndex);
            currentIndex = currentIndex + chsize(char);
            numChars = numChars -1;
          end

          return str:sub(startIndex, currentIndex-1);
        end;

        -- 计算字符串长度
        function format_lib:stringLength(str)
          --每个汉字占三个byte,都替换为一个''
          if str == nil then
            return 0
          end
          local len = #(string.gsub(str,'[\128-\255][\128-\255][\128-\255]',' '));
          return len;
        end;

        --[[截取字符串]]--
        function format_lib:subString(iSummary, startChar, numChars)
          local ret_summary;
          if not(format_lib:stringLength(iSummary) <= numChars) then
              ret_summary = utf8sub(iSummary,startChar,numChars);
          else
              ret_summary = iSummary;
          end;
          return ret_summary;
        end;


        -- show界面公共方法
        local skip_lib = {};

        -- 生成公共channel下xhtml中文件路径
        -- params:
        -- name:文件名称
        -- return:如果文件名称包含后缀，则直接返回common/xhtml/name，如果不包含后缀，则返回common/xhtml/name.xhtml
        function skip_lib.get_page_path(name)
            local path = "common/xhtml/" .. name ..".xhtml";
            if string.find(name,"%.") ~= nil then
                path = "common/xhtml/" .. name;
            end;
            return path;
        end;

        --关联交易
        function skip_lib:show_relevance(ctrl_id,relTranList,flag)
            ert:debug(relTranList);
            local file_path = skip_lib.get_page_path("P_relevance_show.div");
            local relevance_content = ert.ert_file:include_page(file_path,{relTranList = relTranList,flag = flag});
            local ctrl_id = "#" .. ctrl_id;
            ert(ctrl_id):html(relevance_content);
            ert(".relevance_onclick"):click(relevance_onclick);
            binding_physical_back();
	          location:reload();
        end;

        -- 请求关联交易回调
        local function get_relevance_callback(response)
            local response_body = response["responseBody"];
            local table_data = json:objectFromJSON(response_body);
            ert:debug(table_data);
            local relTranList = table_data["RSP_BODY"]["relTranList"];
            ert:debug(relTranList);
            local ctrl_id = response["context"]["ctrl_id"];
            local flag = response["context"]["flag"];
            skip_lib:show_relevance(ctrl_id,relTranList,flag);
        end;
        -- 请求关联交易接口
        function skip_lib:get_relevance_mode(ctrl_id,pageCode,flag)
            local channel = "common";
            local trancode = "SY0100";
            local current_channel =  ert.channel:get_channel();
            local current_id = current_channel.id;
            local context = {ctrl_id = ctrl_id,flag =flag};
            local post_body = {id = "common",tranCode = "SY0100",pageCode_1 = pageCode};
            ert:debug(ctrl_id..pageCode);
            ert.channel:next_page(current_id,"SY0100",post_body,{request_callback=get_relevance_callback,context=context});
        end;

        --展示选卡界面
        -- slt参数包括：
        -- acc_list: 账户列表
        -- flag_balance：是否展示余额
        -- select_key: 当前选择卡列表中下标
        function skip_lib:show_card(acc_list,flag_balance,select_key,flag_all,flag_add)
            local file_path = skip_lib.get_page_path("NCM0001");
            local page_content = ert.ert_file:include_page(file_path,{acc_list = acc_list,
                                                                      flag_balance = flag_balance,
                                                                      select_key = select_key,
                                                                    flag_all = flag_all,
                                                                  flag_add = flag_add});
            ert.channel:hide_loading();
            window:showContent(page_content, ert.channel.loadingtag)
        end;

        -- 请求安全工具列表回调
        local function get_auth_callback(response)
            local response_body = response["responseBody"];
            local table_data = json:objectFromJSON(response_body);
            local header = table_data.header or table_data.RSP_HEAD;
            local error_code = header.error_code or header.ERROR_CODE;
            if error_code == "EBMB0040" or error_code == "MOBS0004SO0301" then
            window:alert("确定领用安全工具！","取消","确定",
              function(index)
                if index==0 then
                  return;
                else
                   ert.channel:first_page("safety_tool","TSL1A02",{id = "safety_tool",tranCode = "TSL1A02",pagecode="TSL1A02"});
                end
              end);
            else
              local phone_num = "";
              local auth_mode = table_data["RSP_BODY"];
              local channel_name = response["context"]["channel_name"];
              local select_key = response["context"]["select_key"];
              skip_lib:show_auth(auth_mode,channel_name,phone_num,select_key);
          end;
        end;
        -- 请求安全工具列表方法二回调
        local function get_auth_callback2(response)
          local response_body = response["responseBody"];
          local table_data = json:objectFromJSON(response_body);
          local mobileNo = table_data["RSP_BODY"]["mobileNo"];
          local authList = response["context"]["authList"];
          local select_key = response["context"]["select_key"];
          local auth_type = response["context"]["auth_type"];
          local file_path = skip_lib.get_page_path("TCM0B02");
          local page_content = ert.ert_file:include_page_noslt(file_path);
          -- local page_content = ert.ert_file:include_page(file_path,{authList=authList,                                                                    select_key=select_key});
          -- ert.channel:hide_loading();
          -- window:showContent(page_content, ert.channel.loadingtag);
          local slt_params = {authList=authList,select_key=select_key,auth_type=auth_type,mobileNo=mobileNo};
          ert.channel:replace("TCM0B02",page_content,slt_params);
        end;
        --安全工具鉴权方法2
        function skip_lib:show_auth2(authList,select_key,auth_type)
          local channel = "common";
          local trancode = "TCM0B02";
          local current_channel =  ert.channel:get_channel();
          local current_id = current_channel.id;
          local current_trancode = current_channel.trancode;
          ert:debug("current_id = " .. current_id .. "trancode = " .. current_trancode);
          local post_body = {id = channel,tranCode = trancode};
          local context = {authList = authList,select_key=select_key,auth_type=auth_type};
          ert.channel:next_page(current_id,"TCM0B02",post_body,{context=context,request_callback=get_auth_callback2});
        end;
        -- 请求安全工具列表
        function skip_lib:get_auth_mode(channel_name,select_key,pagecode)
            local channel = "common";
            local trancode = "TCM0B01";
            local pagecode = pagecode or "SO0103";
            local current_channel =  ert.channel:get_channel();
            local current_id = current_channel.id;
            local current_trancode = current_channel.trancode;
            ert:debug("current_id = " .. current_id .. "trancode = " .. current_trancode);
            local post_body = {id = channel,tranCode = trancode,pagecode=pagecode};
            local context = {channel_name = channel_name,select_key=select_key};
            ert.channel:next_page(current_id,"TCM0B01",post_body,{context=context,request_callback=get_auth_callback});
        end;
        -- show选择安全工具界面
        -- slt参数包括：
        -- auth_mode: 安全工具列表
        -- channel_name: 页面名称
        -- phone_num : 用户电话号码
        -- select_key:当前选择安全工具列表中下标
        function skip_lib:show_auth(auth_mode,channel_name,phone_num,select_key)
            local file_path = skip_lib.get_page_path("TCM0B01");
            local page_content = ert.ert_file:include_page_noslt(file_path);
            local slt_params = {auth_mode = auth_mode,channel_name = channel_name,
                                 phone_num = phone_num,select_key = select_key};
            ert.channel:replace("TCM0B01",page_content,slt_params);
        end;

        -- show选择安全工具界面
        -- slt参数包括：
        -- auth_mode: 安全工具列表
        -- auth_mode: 分行div_id名称

        local function bank_branch_select_authmode(ctrl)
          this.auth_key = tonumber(ert(ctrl):attr("click_params"));
          this.auth_code = this.auth_mode["authList"][this.auth_key]["code"];
          --local params_tab = cmm_unit_fun.format_lib:split_str(click_params,"|");
          --0: 短信动态密码验证
          --1: 手机魔卡验证
          --2: 可视卡
          --3: 智慧网盾-USBKEY
          --4: 智慧网盾-动态令牌
          --6：二代KEY证书认证
        end
        --分行请求安全工具列表回调
        local function bank_branch_back_auth()
            this.query_auth_code(this.auth_code);
        end
        --使用鉴权列表局刷分行上传div
        local function bank_branch_show_auth(auth_mode,div_id)
            this.auth_mode = auth_mode;
            skip_lib:refresh(div_id,"common","TCM0B01_1.html");
            --设置默认code
            this.auth_code = this.auth_mode["authList"][1]["code"];
            location:reload();
            ert(".next_step_bank"):click(bank_branch_back_auth);
            ert(".bank_branch_select_authmode"):click(bank_branch_select_authmode);
        end
        -- 分行请求安全工具列表回调
        local function bank_branch_get_auth_callback(response)
            local response_body = response["responseBody"];
            local table_data = json:objectFromJSON(response_body);
            local header = table_data.header or table_data.RSP_HEAD;
            local error_code = header.error_code or header.ERROR_CODE;
            if error_code == "EBMB0040" then
            window:alert("确定领用安全工具！","取消","确定",
              function(index)
                if index==0 then
                  return;
                else
                   ert.channel:first_page("safety_tool","TSL1A02",{id = "safety_tool",tranCode = "TSL1A02",pagecode="TSL1A02"});
                end
              end);
            else
              local phone_num = "";
              local auth_mode = table_data["RSP_BODY"];
              local div_id = response["context"]["div_id"];
              bank_branch_show_auth(auth_mode,div_id);
          end;
        end;
        -- 分行请求安全工具列表
        function skip_lib:bank_branch_get_auth_mode(div_id,pagecode)
            local channel = "common";
            local trancode = "TCM0B01";
            local pagecode = pagecode or "SO0103";
            local current_channel =  ert.channel:get_channel();
            local current_id = current_channel.id;
            local current_trancode = current_channel.trancode;
            -- ert:debug("current_id = " .. current_id .. "trancode = " .. current_trancode);
            local post_body = {id = channel,tranCode = trancode,pagecode=pagecode};
            local context = {div_id = div_id};
            ert.channel:next_page(current_id,"TCM0B01",post_body,{context=context,request_callback=bank_branch_get_auth_callback});
        end;

        --show出透明蒙板界面
        function skip_lib:show_alpha0()
            local file_path = skip_lib.get_page_path("CM_alpha0");
            local page_content = ert.ert_file:include_page(file_path);
            ert.channel:hide_loading();
            window:showContent(page_content, ert.channel.loadingtag);
        end;

        --隐藏多功能菜单和透明蒙板
        function skip_lib:hide_more_menu()
            ert("#cmm_ui_more_menu"):hide();
            if unread_msg_num>0 then
              ert("#msg_bubble_up"):css("display","block");
            end
            ert.static:set("show_flag",true);
            window:hide(ert.channel.loadingtag);
        end;

        --弹窗模块公共部分
        --需要传入的参数:
        --  params:弹窗里需要显示的信息
        --例如 消息中心、首页
        function skip_lib:multifunctional_alert(slt_params)
            local file_path = skip_lib.get_page_path("multifunctional_alert.div");
            local alert_content = ert.ert_file:include_page(file_path,{slt_params=slt_params});
            return alert_content;
        end;

        --短信密码公共部分
        --需要传入的参数:
        function skip_lib:send_msg(slt_params)
            local file_path = skip_lib.get_page_path("T_password.div");
            local alert_content = ert.ert_file:include_page(file_path,slt_params);
            return alert_content;
        end;

        --返回到首页
        function skip_lib:back_to_home_page()
            --改变板块index全局变量，初始化第一个板块
            ert.static:set("panel_index",1);
            ert.channel:back("home_page","NHP0001",nil);
        end;

        -- 普通页面header公共部分
        -- 包含返回按钮，功能为返回上一页
        -- more按钮，功能为弹出其他菜单。
        -- 需要传入的参数为：
        --  page_name:界面名称
        function skip_lib:include_header_com(slt_params)
            local file_path = skip_lib.get_page_path("P_header_com.div");
            local header_content = ert.ert_file:include_page(file_path,slt_params);

            return header_content;
        end;

        --信用卡的有效期选择年和月
        function skip_lib:enable_date()
            local file_path = skip_lib.get_page_path("choice_date.div");
            local enable_date_content = ert.ert_file:include_page(file_path);
            return enable_date_content;
        end;


        -- 普通页面header公共部分
        -- 包含返回按钮，功能为返回上一页
        -- 需要传入的参数为：
        --  page_name:界面名称
        function skip_lib:include_header_nomore(slt_params)
            local file_path = skip_lib.get_page_path("P_header_nomore.div");
            local header_content = ert.ert_file:include_page(file_path,slt_params);
            return header_content;
        end;

        -- 公共页面header公共部分
        -- 包含返回按钮，功能为隐藏当前界面
        -- 需要传入的参数为：
        --  page_name:界面名称
        -- back_fun:返回的方法
        function skip_lib:include_header_show(slt_params)
            local file_path = skip_lib.get_page_path("P_header_show.div");
            local header_content = ert.ert_file:include_page(file_path,slt_params);
            return header_content;
        end;

        -- 成功界面header公共部分
        -- 包含安全退出按钮，功能为退出登录状态，同时进入首页
        -- 需要传入的参数为：
        --  page_name:界面名称
        function skip_lib:include_header_result(slt_params)
            local file_path = skip_lib.get_page_path("P_header_result.div");
            local header_content = ert.ert_file:include_page(file_path,slt_params);
            return header_content;
        end;

        local nav = {};
        local class = ".ert_nav_back";
        --返回按钮方法
        local function nav_back_fun(ctrl)
            local channel_id;
            local page_code;
            local click_params = ert(ctrl):attr("click_params");
            if click_params ~= nil and click_params ~= "" then
                if click_params == "true" then
                    ert.channel:back(nil,nil,true);
                else
                    local click_tab = cmm_unit_fun.format_lib:split_str(click_params,"|");
                    channel_id = click_tab[1];
                    page_code = click_tab[2];
                    re_quest = click_tab[3];
                    ert.channel:back(channel_id,page_code,re_quest)
                end;
            else
                ert.channel:back();
            end;
        end;

        function binding_physical_back()
            window:setPhysicalkeyListener("backspace",
            function()
               cmm_unit_fun.skip_lib:back_stop_timer();
               if this.timer_1 ~= nil then
                 timer:stopTimer(this.timer_1);
                 this.timer_1=nil;
               end;
                if ert(class)._has_ctrl == false  then
                     ert.channel:back();
                else
                    local ctrl = ert(class):get_userdata();
                    nav_back_fun(ctrl);
                end;
            end);
        end

        -- 根据控件id局部刷新控件内容
        -- @params: ctrl_id,控件id
        -- @params: channel_id channel id
        -- @params：file_path 文件路径，如果为当前channel的xhtml文件夹下文件则直接传入文件名称，
        --          如果不为.xhtml结尾则需要带入文件后缀。
        function skip_lib:refresh(ctrl_id,channel_id,file_name)
            local ctrl_id = "#" .. ctrl_id;
            local content = ert.channel:get_file(channel_id,file_name);
            ert(ctrl_id):html(content);
            local show_content_flag = ert.static:get("show_content_flag");
            if show_content_flag ~= 1 then
                binding_physical_back();
            else
                ert.static:set("show_content_flag",0);
            end
        end;

        -- 下拉选择框改为跳转界面选择
        -- @params:
        -- 需要传入的参数为：
        -- item_list:界面数据
        -- select_key:所选择项的下标
        -- ctrl_id:选择后需要修改的控件ID
        -- select_type:为true是需要回调本地方法（刷新数据），不需要时为空
        function skip_lib:show_select(item_list,select_key,ctrl_id,select_type)
            local file_path = skip_lib.get_page_path("CM_select");
            local page_content = "";
            if select_type == true then
              page_content = ert.ert_file:include_page(file_path,{item_list = item_list,
                                                                      select_key = select_key,
                                                                      ctrl_id = ctrl_id});
            else
              page_content = ert.ert_file:include_page(file_path,{item_list = item_list,
                                                                      select_key = select_key,
                                                                      ctrl_id = ctrl_id,
                                                                      select_type = select_type});
            end
            ert.channel:hide_loading();
            window:showContent(page_content, ert.channel.loadingtag);
        end;

        -- 交易失败跳转入失败界面
        -- @params:需要传入参数
        -- page_name:页面标题
        -- fail_msg:交易失败信息
        -- error_code：错误代码
        -- error_msg: 错误信息
        function skip_lib:show_fail(page_name,error_code,error_msg)
            local file_path = skip_lib.get_page_path("TCM0D01");
            local page_content = ert.ert_file:include_page(file_path,{page_name = page_name,
                                                                      error_code = error_code,
                                                                      error_msg = error_msg
                                                                     });
            ert.channel:replace("TCM0D01",page_content);
        end;

        -- 点击安全退出公共方法
        -- TODO 全局变量提取公共get set方法。
        function skip_lib:exit_page()
            is_login = 0;
            local user_id = database:getData("clientContractNo");
            if user_id == nil then
                user_id = "";
            end;
            local device_id = system:getInfo("deviceID");
            if device_id == nil then
                device_id = "";
            end;
            local weak_login_state = database:getData("weak_login_state");
            if weak_login_state == nil then
                weak_login_state = "";
            end;
            local post_body = "id=common&tranCode=Exit&clientContractNo="..tostring(user_id).."&device_id="..tostring(user_id).."&weak_login_state="..tostring(weak_login_state);
            http:postSyn({}, "channel_s/run",post_body);
            --清空栈内容
            ert.channel.channel_stack = ert.stack:new();
            channel_stack = ert.channel.channel_stack;
            ert.channel.channels = {}
            local channelId = "home_page";
            local tranCode = "NHP0001";
            local city = database:getData("slt_city");
            local post_body = {id = channelId,tranCode = tranCode,page_code=tranCode,city=city};
            --改变板块index全局变量，回到第一个板块页
            ert.static:set("panel_index",1);
            ert.channel:first_page(channelId, tranCode, post_body);
        end

        --确认安全退出
        local function safe_exit_callback(index)
            if index == 1 then
                skip_lib:exit_page();
            else
                return;
            end;
        end

        -- 点击安全退出按钮
        function skip_lib:safe_exit()
          window:alert("您即将退出手机银行","取消","确定",safe_exit_callback);
        end

        -- 返回channel中最近的导航页和交易第一页
        local function return_nav_trade(page_stack)
            for i = 1,#page_stack do
                local j = i + 1;
                if j > #page_stack then
                    local page_code = page_stack[1];
                    return page_code,page_code;
                else
                    local page_code = page_stack[i];
                    local next_page_code = page_stack[j];
                    if string.find(next_page_code,"^T.*") and string.find(page_code,"^N.*") then
                        if j < #page_stack then
                            return next_page_code , page_code;
                        else
                            return page_code , page_code;
                        end;
                    end;
                end;
            end;
        end;

        -- 跳转到对应页面
        local function skip_page(page_code)
            local current_channel = ert.channel:get_channel();
            local channelId = current_channel.id;
            if page_code == "NHP0011" then
               channelId = "home_page";
            end;
            ert.channel:back(channelId,page_code);
        end;

        -- 再试一次
        -- 返回离导航页最近的交易页面
        function skip_lib:one_more()
            local current_channel = ert.channel:get_channel();
            local page_stack = current_channel.page_stack;
            local page_code, _ = return_nav_trade(page_stack);
            skip_page(page_code);
        end;

        -- 下次再说
        -- 返回最近的导航页
        function skip_lib:next_time_try()
            local current_channel = ert.channel:get_channel();
            local page_stack = current_channel.page_stack;
            local _, page_code = return_nav_trade(page_stack);
            if page_code == "TPM1A01" then
               page_code = "NHP0011";
            end;
            skip_page(page_code);
        end;

        --选择城市
        function skip_lib:select_city(ctrl)
            --是否有回调函数
            local call_back = ctrl:getPropertyByName("click_params");
            ert.channel:first_page("common","NCM0002",{id="common",tranCode="empty",page_code="NCM0002"},{replace="show_content",context=call_back});
        end;

        local dynCodeSeq;
        --短信密码请求回调函数
        local function my_send_msg(response)
          local data = response["responseBody"];
          local table_data = json:objectFromJSON(data);
          local msg_list = table_data["RSP_BODY"];
          dynCodeSeq = msg_list["dynCodeSeq"];
          --自动写入短信中收到的验证码
          skip_lib:get_msg_verify_code("msg_password",dynCodeSeq,"1");
          ert("#msg_codeseq"):attr("value",dynCodeSeq);
          location:reload();
        end

        --重新发送短信密码请求回调函数
        local function my_resend_msg(response)
          local data = response["responseBody"];
          local table_data = json:objectFromJSON(data);
          local msg_list = table_data["RSP_BODY"];
          dynCodeSeq = msg_list["dynCodeSeq"];
          --自动写入短信中收到的验证码
          skip_lib:get_msg_verify_code("msg_password",dynCodeSeq,"2");
          ert("#msg_codeseq"):attr("value",dynCodeSeq);
          location:reload();
        end

        local send_msg_timer_my;
        --短信密码请求接口
        function skip_lib:send_msg_password(ctrl)
            local delay_times;
            ert("#send_msg"):attr("enable","false");
            delay_times = tonumber(ert("#send_msg"):attr("delay"));
                local function TimerRun()
                    if delay_times > 0 then
                        delay_times = delay_times - 1;
                        print(delay_times);
                        if delay_times == 0 then
                          ert("#send_msg"):attr("value","重发");
                          ert("#send_msg"):attr("enable","true");
                        else
                          ert("#send_msg"):attr("value",tostring(delay_times).."秒");
                        end
                    else
                        timer:stopTimer(send_msg_timer_my);
                        send_msg_timer_my = nil;
                    end
                end
                send_msg_timer_my= timer:startTimer(1,1,TimerRun);
                local click_params = ert(ctrl):attr("click_params");
                local params_tab = cmm_unit_fun.format_lib:split_str(click_params,"|");
                local channelId = "common";

                local current_channel =  ert.channel:get_channel();
                local current_id = current_channel.id;


                if ert("#send_msg"):attr("value")== "发送" then
                    local tranCode = "ST0202";
                    local post_body ={id =channelId ,
                                      tranCode = tranCode,
                                      targetCode = params_tab[2],
                                      teleNo = params_tab[3],
                                      page_code =params_tab[1]};
                    ert.channel:next_page(current_id,tranCode,post_body,
                                                         {show_loading=false,request_callback=my_send_msg});
                elseif ert("#send_msg"):attr("value")== "重发" then
                    local tranCode = "ST0203";
                    local post_body ={id =channelId ,
                                      tranCode = tranCode,dynCodeSeq=dynCodeSeq,
                                      page_code =params_tab[1]};
                    ert.channel:next_page(current_id,tranCode,post_body,
                                                         {show_loading=false,request_callback=my_resend_msg});
                end;
        end;
        --短信密码请求停止计时器
        function skip_lib:back_stop_timer()
            if send_msg_timer_my ~= nil then
              timer:stopTimer(send_msg_timer_my);
              send_msg_timer_my = nil;
            end
        end;

        --[[
        @doc:动态获取短信中的验证码并自动填入输入框
        @params:
        id 输入框的id
        ]]--
        --短信验证码输入框id
        local verify_code_id;
        function smsCodeBack(errorCode,result)
            if errorCode == "0" then
                ert("#"..verify_code_id):attr("value","");
                ert("#"..verify_code_id):attr("value",result);
            end
        end;

        --dynCodeSeq:短信序号，No:发送（1）重发（2）
        function skip_lib:get_msg_verify_code(id,dynCodeSeq,No)
            verify_code_id = id;
            if ert.platform:os_info() == "android" then
                if No == "1" then
                    --luaSmsCode:getVerifiedCode("95559","smsCodeBack");
					luaSmsCode:getVerifiedCode("95559",dynCodeSeq,"smsCodeBack");
                else
                    --luaSmsCode:getVerifiedCode("106980095559","smsCodeBack");
					luaSmsCode:getVerifiedCode("106980095559",dynCodeSeq,"smsCodeBack");
                end
            end
        end;

        --获取数据公共方法
        local get_lib = {};
        --获取人民币对应的账户余额
        --balance_list:货币类型列表
        function get_lib:get_balance_value(balance_list)
            local balance_sum;
            if balance_list ~= nil then
                for key,list in pairs(balance_list) do
                    if list["currency"] == "CNY" then
                        if list["accBalance"] == nil or list["accBalance"] == "" then
                            if list["value"] == nil then
                              balance_sum = list["accBalanceC"];
                            else
                              balance_sum = list["value"];
                            end
                        else
                            balance_sum = list["accBalance"];
                        end
                    elseif list["currency"]=="" or list["currency"] == nil then
                        if list["value"] == "" or list["value"] ==nil then
                            balance_sum = "0";
                        end
                    end
                end
                return balance_sum;
            else
                return "";
            end;
        end;

        --通过卡号和卡列表获取该卡人民币对应的账户余额
        --account:卡号
        --account_list:卡列表
        function get_lib:get_balance_value_by_account(account,account_list)
            local balance_sum;
            if account_list ~= nil then
                for key,lists in pairs(account_list) do
                    if account == lists["account"] then
                        for key,list in pairs(lists["balance_list"]) do
                            if list["currency"] == "CNY" then
                                if list["accBalance"] == nil or list["accBalance"] == "" then
                                    if list["value"] == nil then
                                      balance_sum = list["accBalanceC"];
                                    else
                                      balance_sum = list["value"];
                                    end
                                else
                                    balance_sum = list["accBalance"];
                                end
                            elseif list["currency"]=="" or list["currency"] == nil then
                                if list["value"] == "" or list["value"] ==nil then
                                    balance_sum = "0";
                                end
                            end
                        end
                    end
                end
                return balance_sum;
            else
                return "";
            end;
        end;

        --通过卡号和卡列表获取该卡的卡别名
        --account:卡号
        --account_list:卡列表
        function get_lib:get_alias_by_account(account,account_list)
            local alias;
            if account_list ~= nil then
                for key,lists in pairs(account_list) do
                    if account == lists["account"] then
                        alias = lists["alias"];
                    end
                end
                return alias;
            else
                return "";
            end;
        end;

        --获取默认卡在卡列表中的位置
        --bind_card:默认卡
        --account_list:卡列表
        function get_lib:get_key_by_bind_card(bind_card,account_list)
            local key;
            if account_list ~= nil then
                for i,lists in pairs(account_list) do
                    if bind_card == lists["account"] then
                        key = i;
                    end
                end
                return key;
            else
                return "";
            end;
        end;

        --[[
        @doc: 通过指定或者默认的函数f处理参数arg，如果结果返回false或者nil，则中断函数，并且弹框提示msg
        @params:
        arg: 需要校验的参数
        msg：校验返回false或者nil时，弹框提示的错误信息。
        f：执行校验过程的函数，可以不传，不传则默认判断arg是否非空
        no_hide：执行校验报错后，不hide show出的页面或者loading（多用于show出页面的输入参数校验）
        useage:
        local amount = ert("#amount"):attr("value");
        cmm_unit_fun.get_lib:raise_when_false(amount,"转账金额不能为空！")
        cmm_unit_fun.get_lib:raise_when_false(amount,"转账金额不能大于20000",
            function(arg)
                return not (tonumber(arg) > 2000)
            end)

        ]]--
        function get_lib:raise_when_false(arg,msg,f,no_hide)
          if "function" == type(f) then
            if not f(arg) then
              ert:error(msg,no_hide)
            end
          else
            if (not arg) or arg=="" then
              ert:error(msg,no_hide)
            end
          end
      end;

        --[[
          交易密码校验
          @password_id：交易密码键盘的id
          @password_msg:密码名称，用作提示语
          例子：cmm_unit_fun.get_lib:judge_password("cmm_ui_div_password_text","交易密码");
          例子：cmm_unit_fun.get_lib:judge_password("cmm_ui_div_password_text","新交易密码");
       ]]--
       function get_lib:judge_password(password_id,password_msg)
           local password = ert("#"..password_id):val();
           local c_password = ert("#"..password_id):get_userdata();
           get_lib:raise_when_false(password,password_msg.."不能为空")
           local passLen = ert("#"..password_id):attr("passlen");
           get_lib:raise_when_false(passLen,password_msg.."位数错误!",
             function(arg)
                 if not (tonumber(arg) == 6) then
                      passEncrypt:clearText(c_password,"1");
                      ert("#"..password_id):val("");
                 end;
                 return (tonumber(arg) == 6)
             end)
       end;

        -- select控件绑定公共方法
        function get_lib:select_bind(ctrl)
            ert.channel:show_loading();
            local click_params = ert(ctrl):attr("click_params");
            local params_tab = cmm_unit_fun.format_lib:split_str(click_params,"|");
            local ctrl_id = params_tab[1];
            local select_type = params_tab[2];
            if select_type == nil or select_type == "" then
                cmm_unit_fun.skip_lib:show_select(this[ctrl_id].item_list,this[ctrl_id].select_key,ctrl_id);
            else
                cmm_unit_fun.skip_lib:show_select(this[ctrl_id].item_list,this[ctrl_id].select_key,ctrl_id,select_type);
            end
        end;
        --[[
        @doc:获取当前时间，格式：年.月.日. 小时：分钟
        @usage: return 2015.10.24 07:39
        --]]
        function get_lib:get_current_time()
            local date = os.date("%Y.%m.%d %H:%M");
            return date;
        end

        --[[
        @doc:根据当前日期和间隔获取截止日期
        @params:
        day: 间隔天数
        @return:
        final_date: 截止日期，格式为："年.月.日"
        @useage：cmm_unit_fun.get_lib:get_end_date(10); --> 2015.11.03
        ]]--
        function get_lib:get_end_date(day)
            local current_time = os.time();
            local interval = 24*60*60*day;
            local temp_time = current_time + interval;
            local final_date = os.date("%Y.%m.%d",temp_time);
            return final_date;
        end

        --获取当前时间的前一月日期
        -- cmm_unit_fun.get_lib:get_before_date(); --> 2015.09.24
        function get_lib:get_before_date()
            local current_time = os.time();
            local current_year=os.date("%Y");
            local current_month=os.date("%m");
            local interval = 0;
            local flag="";
            if tonumber(current_year)%400==0 then
                flag="闰年";
            elseif tonumber(current_year)%100 ~= 0 and tonumber(current_year)%4 == 0 then
                flag="闰年";
            else
                flag="平年";
            end
            if flag=="闰年" then
                if tonumber(current_month)==3 then
                    interval=29*24*60*60;
                end
            else
                if tonumber(current_month)==3 then
                    interval=28*24*60*60;
                end
            end
            if  tonumber(current_month)==5 or tonumber(current_month)==7
                or tonumber(current_month)==10 or tonumber(current_month)==12 then
                interval=30*24*60*60;
            elseif tonumber(current_month)==1 or
                tonumber(current_month)==2  or tonumber(current_month)==4 or tonumber(current_month)==6 or tonumber(current_month)==8
                or tonumber(current_month)==9 or tonumber(current_month)==11 then
                interval=31*24*60*60;
            end
            local temp_time = current_time - interval;
            local start_date = os.date("%Y.%m.%d",temp_time);
            return start_date;
        end;

        --获取交易密码键盘
        --页面有多个密码键盘时，第一个键盘的flag传true，其他键盘都传false
        --id即为键盘id
        --str为hold提示语
        --class为自定义样式，可不传
        function get_lib:get_input_password(flag,id,str,class)
            local class = class and (","..class) or "";
            if flag then
                passEncrypt:buildDigitRule();
                passEncrypt:getEncryRNS();
            end;
            local input_password = [[
                <label class="cmm_ui_w8"></label>
                <input id="]]..id..[[" class="cmm_ui_div_password_text]]..class..[[" type="digitpassword" encryptMode="01" passlen="" style="-wap-input-format:'N'" maxleng="6" hold="]]..str..[[" value="" border="0"/>
            ]]
            return input_password;
        end

        --获取卡校验码键盘
        function get_lib:get_checkCode_password(id,str,class)
            local class = class and (","..class) or "";
            passEncrypt:buildDigitRule();
            passEncrypt:getEncryRNS();
            local checkCode_password = [[
                <input id="]]..id..[[" class="cmm_ui_div_password_text]]..class..[[" type="digitpassword" encryptMode="01" passlen="" style="-wap-input-format:'N'" maxleng="3" hold="]]..str..[[" value="" border="0"/>
            ]]
            return checkCode_password;
        end

         --获取div的实际高度
         --在宽度是320px情况下,除了其他控件以外的高度
         --local height = cmm_unit_fun.get_lib:get_div_height(239);
         function get_lib:get_div_height(ctrl)
             --计算上一个div的显示高度
             local top_div_height = screen:width()/320*ctrl;
             --获得下一个div的高度
             local div_height = screen:clientHeight() - top_div_height;
             local p = screen:width() / 320;
             div_height = div_height / p;
             return div_height;
         end;

         --分页实现方式显示样式
         --lastPage_flag:接口返回是否最后一页状态
         --page:接口返回当前页码
         function get_lib:implement_paging(lastPage_flag,page)
             local page_style = [[]];
             if lastPage_flag == "T" then
                 --当前页码为最后一页
                 if page == 1 or page == "1" then
                     --当前页为尾页
                     page_style = [[]]
                 else
                     --当前页不是首页
                     page_style = [[
                     <div class="cmm_ui_div_h50" valign="middle" align="center" border="0">
                        <div class="cmm_ui_rbtn_w160_h50_f14b,cmm_ui_inline" valign="middle" border="0">
                            <input type="button" class="cmm_ui_btn_w116_h30_f15w_radiuss,cmm_ui_l30,last_page" border="1" enable="true" value="上一页"/>
                        </div>
                        <div class="cmm_ui_rbtn_w160_h50_f14b,cmm_ui_inline" align="center" valign="middle" border="0">
                            <input type="button" class="cmm_ui_btn_w116_h30_f15w_radiuss,cmm_ui_r30,next_page" border="1" enable="false" value="下一页"/>
                        </div>
                     </div>
                     ]]
                 end
             else
                 --当前页码不是最后一页
                 if page == 1 or page == "1" then
                     --当前页为首页
                     page_style = [[
                     <div class="cmm_ui_div_h50" valign="middle" align="center" border="0">
                        <div class="cmm_ui_rbtn_w160_h50_f14b,cmm_ui_inline" valign="middle" border="0">
                            <input type="button" class="cmm_ui_btn_w116_h30_f15w_radiuss,cmm_ui_l30,last_page" border="1" enable="false" value="上一页"/>
                        </div>
                        <div class="cmm_ui_rbtn_w160_h50_f14b,cmm_ui_inline" align="center" valign="middle" border="0">
                            <input type="button" class="cmm_ui_btn_w116_h30_f15w_radiuss,cmm_ui_r30,next_page" border="1" enable="true" value="下一页"/>
                        </div>
                     </div>
                     ]]
                 else
                     --当前页不是首页
                     page_style = [[
                     <div class="cmm_ui_div_h50" valign="middle" align="center" border="0">
                        <div class="cmm_ui_rbtn_w160_h50_f14b,cmm_ui_inline" valign="middle" border="0">
                            <input type="button" class="cmm_ui_btn_w116_h30_f15w_radiuss,cmm_ui_l30,last_page" border="1" enable="true" value="上一页"/>
                        </div>
                        <div class="cmm_ui_rbtn_w160_h50_f14b,cmm_ui_inline" align="center" valign="middle" border="0">
                            <input type="button" class="cmm_ui_btn_w116_h30_f15w_radiuss,cmm_ui_r30,next_page" border="1" enable="true" value="下一页"/>
                        </div>
                     </div>
                     ]]
                 end
             end
             return page_style;
          end

        --实现URL中增加其他参数
        -- anthor:锚点，mobs-web/main.html?app=yes#agreement/agreement/agreement
        -- 参数： page_code=NDM0001&target_page_code=MTM0001
        -- return: mobs-web/main.html?app=yes&page_code=NDM0001&target_page_code=MTM0001#agreement/agreement/agreement
        function get_lib:format_url(anthor,params)
            local find_res =  string.find(anthor,"#");
            local ret_anthor;
            if find_res > 0 then
                local before = string.sub(anthor,1,find_res-1);
                local tail = string.sub(anthor,find_res,string.len(anthor));
                ret_anthor = before .. "&" .. params .. tail;
            end;
            return ret_anthor;
        end;

        cmm_unit_fun.get_lib = get_lib;
        cmm_unit_fun.skip_lib = skip_lib;
        cmm_unit_fun.format_lib = format_lib;
    end;

    if cmm_unit_fun.get_lib == nil then
        init();
    end;

    if cmm_unit_fun.skip_lib == nil then
        init();
    end;

    if cmm_unit_fun.format_lib == nil then
        init();
    end;
end)();
