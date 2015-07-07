![EMP](https://raw.githubusercontent.com/wiki/RYTong/emp-debugger/images/emp.png)
# Emp Debugger Package Change Log

## Version 0.8.11
1. 为个界面添加隐藏按键.参见 #68.
2. 添加部分测试用 tag snippets.
3. 修改 bug. (enable view 显示报错问题)


## Version 0.8.9
1. remove Deprecated Api.

## Version 0.8.8
1. 修复 bug #71


## Version 0.8.6
1. 删除 Deprecated API, 支持 atom v0.206 之后的版本

## Version 0.8.2
1. 添加遗漏的前端模板

## Version 0.8.1
1. 删除 Deprecated API
2. 修改工程模板
3. 修改 Col/Cha 编辑时的 bug

## Version 0.7.1
1. 修改重定义的字体类型
2. 修改 按键映射函数错误的 bug

## Version 0.7.0
1. 修改 linux 下 中文显示乱码的问题, 引入字体`思源黑体`.#58.
2. 增加前端工程创建向导. #60.

## Version 0.6.12
1. 修改5.2 emp app 脚本, 重定义外联 lua 引用路径
2. 修改部分插件空间名为英文.

## Version 0.6.11
1. 修改控制台样式, 修复重叠问题

## Version 0.6.10
1. 修改因为超时时间设置引起的报错

## Version 0.6.8
1. 去掉 lua 日志开头标示

## Version 0.6.6
1. 修改 现实可用 lua 文件调用时报错的 bug
2. 限定 log 界面 按键操作范围,使 ctrl-a 局限于 log pane 内(如果当前页面有其他的几面元素,请尽量关闭).
3. 添加文件关联按键. 如果你的模板或者 lua 文件不是通过 atom 创建的.
    但是你也想在调试时关联Debugger 下行报文和文件实体, 那么你可以在上送报文之前在报文中添加文件关联语句.
4. 优化文件关联匹配规则, 现在分为以下几种情况
  * 已添加文件关联语句,并存在对应关联文件,则直接打开文件
  * 已添加文件关联语句,不存在对应关联文件,则查找对应名称文件(若多个则选择)打开
  * 未添加文件关联语句,如果为 lua, 则查找对应名称文件. xhtml 直接打开匿名编辑器


## Version 0.6.5
1. 重构 log 界面, 框体高度可变
2. log 内容可以被本地按键操作

## Version 0.6.5
1. 升级 API 到 API1.0 版本,解决输入框不显示的 bug

## Version 0.6.4
1. 修复bug, 修改多次点击channel wizard时候, channel和col树重复显示
2. 修改编辑Colection 时候的报错
3. 重定义部分按键显示内容
4. 添加 全部打包(资源包)功能

## Version 0.6.3
1. 修复bug, 去掉App 初始化时的`--with-mysql` 参数.
2. 修复bug #31. 为控制面板添加最小宽度.
3. 添加混合语法(html+lua)支持

## Version 0.6.2
修复bug, 去掉无用的`erlc`参数, 避免`Erlang R17`下的报错

## Version 0.6.1
修复bug,去掉无用的引用文件

## Version 0.6.0
### 资源打包
1. 提供普通资源打包功能
2. 提供插件包打包功能

## Version 0.5.0
### App操作
1. 添加远程节点连接,用于支持win32下调试. 通过远程及节点连接,可以同步部分操作.

## Version 0.4.0
#### Channel 操作
1. 添加`channel` 的添加，删除，修改操作
2. 目前`channel` 的 `entry type`只支持 `channel_adapter` 类型，并且可根据配置生成辅助文件
3. 添加`collection` 的添加，删除，修改操作
4. 如果未启动app，则对于`channel`的修改后，需要手动导入`channel.conf `配置
5. 在启动qpp（通过插件启动）的情况下，对于`channel`和`collection`的修改，会即时同步到app中

#### App 操作
1. 添加App 操作功能控制界面
2. 添加App 配置、编译、启动、暂停 以及运行时编译 五项App操作相关功能
3. 添加Channel配置导入功能，导入的文件默认为config/channel.conf
4. 添加运行时交互功能

#### App 创建向导
1. 添加App 创建向导
2. 可以通过控制页面`(ctrl+alt+s)` 下的`Emp App` 选项下 的 `Create A Emp App(Button)` 來打开向导
3. App 创建向导中可以设置 `App Name`， `App Path`， `Ewp Path`
4. 创建App 时，若 `App Path`的base name 是`App Name` 则不单独为App 创建目录，若果不是，则创建名位`App Name`的目录
5. `Ewp Path` 默认为 `/usr/local/lib/ewp`， 建议配置，如果置空则需要手动修改`configure,iewp,yaws.conf` 文件

#### Debugger 优化
1. 在创建channel时，同步创建的模板文件中添加关联标示，通过表示，你在查看下行报文时，您可以把报文关联到文件实体。
2. 同时，您在查看下行的脚本文件时，你也可以把下行脚本关联到文件实体。
3. 如果有多个文件实体可以对应时，会弹出选择框让您选择。

## Version 0.3.0
### 调试服务启动
1. 可以通过`ctrl-alt-s` 来呼出 `Emp Debugger`的中控台，然后可以根据需求来设置对应的服务器
Host 和Port。
在默认情况下，Host 为 `All` 包括`Ip`和`localhost`,Port为7003.

2. 添加上送报文、下行报文展示、下行脚本展示的 界面、按键以及快捷键
3. 添加日志的展现界面，并添加日志的清除、暂停和停止等功能，可以为日志选取不同的颜色:)
