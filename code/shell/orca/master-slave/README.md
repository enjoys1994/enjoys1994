
# 主备集群搭建
## 修改主机
```
vi host.conf
```

## 准备工作
执行
```
sh prepare.sh
```
执行完成之后继续 执行

```
sh set.sh
```

出现类似错误 -bash: /usr/local/bin/expect: No such file or directory

执行

```
export PATH=/usr/local/bin/:$PATH
sh set.sh
```

# 取消主备集群之间关系

执行

```
sh reset.sh
```
