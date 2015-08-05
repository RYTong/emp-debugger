# 数据传输格式old #

## 版本历史
版本号|日期|作者|描述
---|---|---|---
V1.0|2015.7.18|李浩(li.hao85)|新传输格式约定

<!-- toc -->

## 客户端 -> 服务器 ##

```
EditorMessageStart
#EditorMessage#

EditorContentStart
#EditorContent#
报文内容（全部）
#EditorContent#
EditorContentEnd

EditorScriptStart
#EditorScript#
脚本1名称（外联）#fileName#脚本1内容（外联）
#EditorScript#
EditorScriptEnd
#EditorScript#

EditorScriptStart
#EditorScript#
脚本2名称（外联）#fileName#脚本2内容（外联）
#EditorScript#
EditorScriptEnd
#EditorScript#

#EditorMessage#
EditorMessageEnd
```

## 服务器 -> 客户端 ##

```
s2bContent&$报文
#&#脚本1（外联）名称#fileName#脚本1（外联）内容
#&#脚本2(外联)名称#fileName#脚本2（外联）内容
$&end
```
注：

- 从“报文”的位置取出报文。
- 从“#&#”之后的位置取出外联脚本(可能有多份)。

## 上送日志的格式 ##

```
EditorMessageStart
#EditorMessage#
EditorLogStart
#EditorLog#
Log内容（全部）
#EditorLog#
EditorLogEnd
#EditorMessage#
EditorMessageEnd
```