
1.应用部署相关问题

https://iknow.hs.net/portal/docView/home/58534


2.mysql缺少lib库 


https://iknow.hs.net/console/teamManage/knowledgeBase/18/docManage/library/1645/document/50452

3.监控节点访问控制台地址说明


https://iknow.hs.net/console/teamManage/knowledgeBase/18/docManage/library/770/document/58674


4.监视器函数说明


https://iknow.hs.net/console/teamManage/knowledgeBase/18/docManage/library/770/document/21922


5.influxdb磁盘清理

https://iknow.hs.net/portal/qaView/home/59462

6.see初始密码
```
4dff4ea340f0a823f15d3f4f01ab62eae0e5da579ccb851f8db9dfe84c58b2b37b89903a740e1ee172da793a6e79d560e5f7f9bd058a12a280433ed6fa46510a
```

7.获取数据库密码
```
 $SEE20_INSTALL_HOME/seectl/bin/seectl passwd -d $($SEE20_INSTALL_HOME/seectl/bin/seectl props -f $SEE20_INSTALL_HOME/tomcat/webapps/acm/WEB-INF/conf/jdbc.properties -k jdbc.password -m get) 


```


191017739@qq.com
591.Sh9410

启动 chronograf 

```
brew services start chronograf
```

●  什么版本，最好截图下
● 是公司的环境还是客户的环境
●  是生产还是测试
●  如果是公司环境，直接私聊我发下环境地址和网页账号密码；如果是现场环境，能否远程(优先最好使用向日葵或者teamviewer等专业远程工具)
● 如果是客户环境，说明下是哪个客户
● 有服务器账号，可以的话私聊发下我
● 简单描述下最近做过什么操作
● 获取日志
监控节点日志（/home/see/workspace/SystemEagleEyes/server/logs/{sys.log,node.log}）
web控制台日志(see/tomcat/logs/{monitor.log,app.log}）


资管天鉴（MP）质保群：32567877

UFW质保群：35933318

中间件质保群：31029178

操作员中心质保群①：32407439（非部署问题）

操作员中心质保群②：33159500

HSIAR/服务治理质保群①：23183142

HSIAR/服务治理质保群②： 34102575  （非部署问题）

任务调度质保群：31969363（非部署问题）



