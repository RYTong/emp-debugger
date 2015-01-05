![EMP](https://raw.githubusercontent.com/wiki/RYTong/emp-debugger/images/emp.png)
# Emp Debugger Package Change Log

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
