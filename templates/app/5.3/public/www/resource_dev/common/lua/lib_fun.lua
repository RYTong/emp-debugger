--[[
方法说明：生成UUID
方法实现流程：
 返回：UUID
参数：无
Dec:十进制
Hex:十六进制
BMAnd:两个十六进制数据与运算
BMOr:两个十六进制或运算
Dec2Hex:十进制转换为十六进制
Hex2Dec:十六进制转换为十进制
--]]
function UUID()
    local chars = {"0","1","2","3","4","5","6","7","8","9","A","B","C","D","E","F"}
    local uuid = {[9]="-",[14]="-",[15]="4",[19]="-",[24]="-"}
    local r, index
    for i = 1,36 do
        if(uuid[i]==nil)then
            r = math.random (16)
            if(i == 20 and BinDecHex)then
                index = tonumber(Hex2Dec(BMOr(BMAnd(Dec2Hex(r), Dec2Hex(3)), Dec2Hex(8))))
                if(index < 1 or index > 16)then
                    print("WARNING Index-19:",index)
                    return UUID() -- should never happen - just try again if it does ;-)
                end;
            else
                index = r
            end;
            uuid[i] = chars[index]
        end;
    end;
    return table.concat(uuid)
end;