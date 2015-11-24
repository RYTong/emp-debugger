# 数据传输格式new #

## 版本历史

版本号|日期|作者|描述
---|---|---|---
V1.0|2015.7.18|李浩(li.hao85)|新传输格式约定
V1.1|2015.7.22|李浩(li.hao85)|增加对外联样式的支持，添加了一些注释
V1.2|2015.8.23|李浩(li.hao85)|增加一种数据传输格式，服务器要求客户端执行Lua语句时使用这个格式
V1.3|2015.10.8|李浩(li.hao85)|日志中增加Lua类型

<!-- toc -->

新版的数据传输使用json来实现，value部分进行了BASE64加密。

下文的#s#代表报文开始，#e#代表报文结束。

## 客户端 -> 服务器 ##

```
#s#{
    "originMessage": {
        "staticContent": "报文内容(经过Base64编码)",
        "css": [
            {
                "name": "外联样式1名称",
                "content": "外联样式1内容(经过Base64编码)"
            },
            {
                "name": "外联样式2名称",
                "content": "外联样式2内容(经过Base64编码)"
            }
        ],
        "script": [
            {
                "name": "外联脚本1名称",
                "content": "外联脚本1内容(经过Base64编码)"
            },
            {
                "name": "外联脚本2名称",
                "content": "外联脚本2内容(经过Base64编码)"
            }
        ]
    },
    "expandedMessage": {
        "staticContent": "报文内容(经过Base64编码)",
        "css": [
            {
                "name": "外联样式1名称",
                "content": "外联样式1内容(经过Base64编码)"
            },
            {
                "name": "外联样式2名称",
                "content": "外联样式2内容(经过Base64编码)"
            }
        ],
        "script": [
            {
                "name": "外联脚本1名称",
                "content": "外联脚本1内容(经过Base64编码)"
            },
            {
                "name": "外联脚本2名称",
                "content": "外联脚本2内容(经过Base64编码)"
            }
        ]
    }
}#e#
```

注：

- 外联样式和外联脚本可能会有多个，因此用数组来存放。
- originMessage中的内容是slt转换之前的页面内容，expandedMessage中的内容是经过slt转换之后的。
- 当页面不含slt脚本的时候，originMessage和expandedMessage中的内容是一样的。

## 服务器 -> 客户端 ##

```
#s#{
    "staticContent": "报文内容(经过Base64编码)",
    "css": [
        {
            "name": "外联样式1名称",
            "content": "外联样式1内容(经过Base64编码)"
        },
        {
            "name": "外联样式2名称",
            "content": "外联样式2内容(经过Base64编码)"
        }
    ],
    "script": [
        {
            "name": "外联脚本1名称",
            "content": "外联脚本1内容(经过Base64编码)"
        },
        {
            "name": "外联脚本2名称",
            "content": "外联脚本2内容(经过Base64编码)"
        }
    ]
}#e#
```

## 上送日志的格式 ##

```
#s#{
    "level": "日志类型",
    "message": "日志内容(经过Base64编码)"
}#e#
```

其中日志类型如下：

- Lua：用“lua”表示。
- 普通：用“i”表示。
- 警告：用“w”表示。
- 异常：用“e”表示。

## 服务器要求客户端执行Lua语句 ##

```
#s#{
    "lua_console": "lua source code(经过Base64编码)"
}#e#
```
