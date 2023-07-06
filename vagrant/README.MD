
## 使用说明

本脚本适用于vagrant搭建多个虚拟机：
- 至少1个server
- 至少1个node


## 功能如下

- 根据server和node的数量，IP自动顺延往后创建
- 把所有的server和node加/etc/hosts配置
- vagrant 默认的nat的网络（"forwarded_port"）， 把IP固定下来
