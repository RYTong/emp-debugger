![EMP](https://github.com/jcrom/emp-debugger/blob/master/images/emp.png)
# emp-debugger package

## EMP 模板实时调试插件

emp-debugger 是一个基于socket协议的简单的协调服务器，它主要用于从Client端 下行报文，以及
从本地文件上行报文。

## Basics
### 启动Debugger 服务

在使用emp-debugger 交互功能之前，需要启动emp-debugger 的socket server , 可以通过
`ctrl-alt-s` 来呼出 debugger的中控台，然后可以根据需求来设置对应的服务器
Host 和Port。

在默认情况下，Host 为 `All` 包括`Ip`和`localhost`,Port为7003.

设置完成直通通过start server 按钮来启动服务。

### 显示可用的下行报文

通过 `ctrl-alt-e` 来调出可用下行报文的面板，选中需要编辑的页面，可以打开并编码页面内容。


### 显示可用的下行脚本

因为页面中有引用`Lua`脚本, 所以在交互时，Client 会发送脚本内容，可以通过`ctrl-alt-u` 來
查看可用的下行脚本。

### 上送编辑报文和脚本

通过 `ctrl-alt-d` 來上送当前编辑页面内的报文，如果上送报文为页面文件，请注意文件后缀需要为`xhtml`，
如果上送报文为脚本文件，请注意文件后缀需要为`lua`,如果是编辑中的下行报文，则可以直接上送。

### 日志显示
我们可以通过在控制面板中打开日志显示界面，来查看交互的日志内容。

## Some Else
### collection
collection-item-panel -> add_collection_view -> collection_child_item_panel
