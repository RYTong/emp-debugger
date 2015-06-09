如何不依赖后端，独立地进行前端业务频道开发
=====================================

1. 运行`simulator`脚本，启动挡板服务。

2. 创建业务频道页面。在`www/resource_dev/common/channels`目录下创建${Channel}文件夹，
   并相应创建${Trancode}.xhtml页面。

3. 定义菜单及模拟数据。在`menu`目录下创建菜单(collection/channel)层次目录及模拟数据文件。
   例如：
    menu
    ├── ebank_virtual_root
    └── ebank_ipad_virtual_root
        └── level1
            └── level2
                └── $transfer
                    ├── MB001.json
                    ├── MB003.json
                    └── MB008.json

   可以看到，我们创建了两个虚拟root节点分别用来管理不同的菜单集。同时，我们在ipad菜单下
   添加了名为level1的一级菜单，并为其添加了名为level2的二级菜单。最后，我们在level2下
   添加了名为transfer的业务频道，并为其创建了MB001, MB003及MB008的交易码模拟数据文件。
   模拟数据的内容可以为任意JSON格式的数据：
{
    "return": {
        "error_code": "000000",
        "error_msg": "",
        "message": "hello"
    }
}


自定义设置
=========
simulator默认使用4000的应用端口及4002的管理后台端口，默认APP名称为ebank。
可以通过添加配置文件进行设置:
  - 在当前目录添加名为`.port`的文件，并输入ebank端口号用来设置ebank端口号。
  - 在当前目录添加名为`.aport`的文件，并输入管理后台端口号用来设置管理后台端口号。
  - 在当前目录添加名为`.app`的文件，并输入启用的后台app名称用来设置对外开放的指定app服务。



注意事项
=======
1. 菜单和频道的名字要符合erlang标示符命名规范。
2. 频道的名字前需要添加一个'$'来区分。
3. 模拟数据文件必须是json格式，且文件名为相应交易码。

