
# 主备集群搭建
## 修改主机

确保双方主机为集群的master及etcd所在节点节点（需要etcd相关信息），并确保双方主机上已安装helm

格式为： ${ip}:${username}/${password}
```
vi host.conf
```

## 准备工作
执行
```
sh prepare.sh
```
来完成**expect**命令安装及**etcd-mirror**镜像的上传

执行完成之后继续 执行

```
sh set.sh
```

如果出现以下类似错误 
```
-bash: /usr/local/bin/expect: No such file or directory
```
说明expect安装过程中有问题，查询expect命令是否存在,执行

```
cat: /usr/local/bin/expect
```
如果结果如下
```
cat: /usr/local/bin/expect: No such file or directory
```
表示命令安装失败，联系对应人员。

如果显示是一堆二进制码，说明命令已经存在，则是PATH没有包含 /usr/local/bin/ ， 执行
```
export PATH=/usr/local/bin/:$PATH
sh set.sh
```

# 取消主备集群之间关系

执行

```
sh reset.sh
```
