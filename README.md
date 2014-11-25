![EMP](https://raw.githubusercontent.com/wiki/RYTong/emp-debugger/images/emp.png)
# Emp Debugger Package

## Debugger
### New Emp Debugger Wizard (`Linux` `Mac` `Win32`)
通过 `ctrl+alt+s` 呼出`Emp Debugger` 向导界面 .向导界面中包括调试工具以及Emp App操作工具
向导界面中主要包含页面及脚本调试过程中需要的操作。

![Debugger Panel](https://raw.githubusercontent.com/wiki/RYTong/emp-debugger/images/feature_1.png)

                                  图 1-1

### Debugger 服务
`Emp Debugger` 是一个基于socket协议的简单的协调服务器，它主要用于从Client端 下行报文，以及
从本地文件上行报文。
我们通过调试服务來与客户端之间进行 调试页面的实时互传，在使用`Emp Debugger` 与客户端交互功能之前，需要启动`emp-debugger` 的`socket server` , 可以通过`ctrl-alt-s` 来呼出 `Emp Debugger`的中控台，然后可以根据需求来设置对应的服务器
Host 和Port。

在默认情况下，Host 为 `All` 包括`Ip`和`localhost`,Port为7003.

设置完成直通通过`Start Server `按钮来启动服务。如上图。

![Debugger State Panel](https://raw.githubusercontent.com/wiki/RYTong/emp-debugger/images/feature_5.png)

                                  图 1-2

### 上送编辑报文和脚本

如果当前的Editor 中是需要调试的页面，那么你可以通过`Live Preview` 按键，或者 `ctrl-alt-d` 快捷键來上送当前编辑页面内的报文，如果上送报文为页面文件，请注意文件后缀需要为`xhtml`，
如果上送报文为脚本文件，请注意文件后缀需要为`lua`,如果是编辑中的下行报文，则可以直接上送。
如下图

![Debugger State Panel](https://raw.githubusercontent.com/wiki/RYTong/emp-debugger/images/feature_51.png)

                                  图 1-3

### 显示可用的下行报文
在页面调试过程中，你可以通过调试界面中的 `Enable Views` 按钮，或者 `ctrl-alt-e` 快捷键，来调出可用下行报文的面板，选中需要编辑的页面，可以打开并编码页面内容。对于通过 `Emp Debugger` 插件创建的模板，可以再显示时，显示文件名称。如果不是通过 `Debugger` 插件创建的模板，只会按照显示的顺序编号。如下图：

![Debugger State Panel](https://raw.githubusercontent.com/wiki/RYTong/emp-debugger/images/feature_11.png)

                                  图 1-4


如果有多个同名文件，则会进一步显示选择界面：

![Debugger State Panel](https://raw.githubusercontent.com/wiki/RYTong/emp-debugger/images/feature_12.png)

                                  图 1-5

### 显示可用的下行脚本

因为页面中有引用`Lua`脚本, 所以在交互时，Client 会发送脚本内容，可以通过 `Enable Lua` 按键，或者`ctrl-alt-u` 快捷键 來
查看可用的下行脚本。同上述的页面相同，如果有多个同名 的脚本文件，则在选择之后，会进一步提示选择指定文件。

![Debugger State Panel](https://raw.githubusercontent.com/wiki/RYTong/emp-debugger/images/feature_13.png)

                                  图 1-6

### 日志显示
对于页面调试过程中的Lua 脚本打印（例如 `print("This is a lua log~")`）,我们可以通过打开调试工具的日志面板来查看。
我们可以通过`Show Log` 按键， 或者`ctrl+alt+l` 来打开日志界面。
还提供如下功能：
* 交互日志清除
* 暂停日志打印
* 关闭日志输出
* 日志输出颜色选择


![Debugger State Panel](https://raw.githubusercontent.com/wiki/RYTong/emp-debugger/images/feature_14.png)

                                  图 1-7

## App Management
### App 操作管理
#### 本地App 操作 (`Linux` `Mac` )
在 Debugger 向导界面中，添加App管理界面。添加如下功能：
* App 配置
* App 编译
* App 启动
* App 暂停
* App运行时操作：
   * Channel 导入
   * 运行时编译App
   * 运行时Erl 交互
同时，在 `Emp App` 启动时，进行的`Channel/Collection` 操作，会同步到App中。

![Emp App Management Panel](https://raw.githubusercontent.com/wiki/RYTong/emp-debugger/images/feature_3.png)

                                  图 1-8 未启动本地App时

![Start Emp App](https://raw.githubusercontent.com/wiki/RYTong/emp-debugger/images/feature_7.png)

                                  图 1-9 启动本地App时

#### 远程Emp 节点连接(`Linux` `Mac` `win32` )
对于`Win32` 系统来说，无法像类`Linux`系统一样，启动本地的App， 所以我们提供类似Eclipse 插件的方案，通过`Erl Node` 來连接远程启动的`Emp App` 节点，通过节点连接來同步。同时提供如下功能：
* Channel 导入
* 运行时编译App
* 运行时Erl 交互

同时，在连接 `Emp App` 节点的过程中时，进行的`Channel/Collection` 操作，会同步到远程节点的App中。

![Connect Remote Emp Node Panel](https://raw.githubusercontent.com/wiki/RYTong/emp-debugger/images/feature_4.png)

                                  图 1-10 未连接远程App节点

![Connect Remote Emp Node](https://raw.githubusercontent.com/wiki/RYTong/emp-debugger/images/feature_6.png)

                                  图 1-11 连接远程App节点

### App 创建向导 (`Linux` `Mac` `Win32`)
在App管理界面中，通过 `Create A Emp App` 來呼出App创建向导，通过向导，可以容易的创建一个标准V5.3 版本的`Emp App`.

![New Emp App Wizard](https://raw.githubusercontent.com/wiki/RYTong/emp-debugger/images/feature_8.png)

                                  图 1-12 创建App 向导


### Channel 管理向导 (`Linux` `Mac` `Win32`)
在App管理界面中，通过 `Show Channel` 來呼出`Channel` 管理向导，该想到提供的功能点：
* `Channel`和`Collection`的展示, 如 图 1-13
* `Channel`的添加、编辑、删除, 如 图 1-14
* `Collection`的添加、编辑、删除, 如 图 1-15
* `Channel` 操作时的辅助代码生成，包括`Erlang文件`、`页面模板`、`Conf文件中的配置`、`模拟数据模板`

![Channel Management](https://raw.githubusercontent.com/wiki/RYTong/emp-debugger/images/emp_channel_0.png)

                                  图 1-13 Channel 管理界面

![Channel Management](https://raw.githubusercontent.com/wiki/RYTong/emp-debugger/images/feature_9.png)

                                  图 1-14 Channel 添加

![Channel Management](https://raw.githubusercontent.com/wiki/RYTong/emp-debugger/images/feature_10.png)

                                  图 1-15 Collection 添加

## Else
### 将要添加的一些功能
* 下行报文的自动匹配保存
* win32 环境下，实现通过节点与Emp App 操作
* 帮助文档及操作手册添加规划
To Be Continue ...
