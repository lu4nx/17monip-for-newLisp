17MonIP for newLisp
=====
17Mon（17mon.cn）IP地址库解析代码

Usage
=====

    > (find-ip "8.8.8.8")
    ("GOOGLE" "GOOGLE" "")
    > (find-ip "127.0.0.1")
    ("本机地址" "本机地址" "")
    > (find-ip "test") ; 如果IP地址格式错误或查询失败，返回nil：
    nil

IP库更新
=====
http://tool.17mon.cn/ipdb.html

