# kubernetes之event剖析
本篇文章主要通过示例及部分源码结构解析来，深入的介绍了 Events 对象的实际的作用及其产生流程。


# Event的作用
## Event的概念
先做个简单的示例，来看看 Kubernetes 集群中的 events 是什么。

创建一个新的名叫 event-test 的 namespace ，然后在其中创建一个叫做 nginx-deployment 的 deployment。接下来查看这个 namespace 中的所有 events。
```
[root@node1 ~]# kubectl get event -n event-test --sort-by='{.metadata.creationTimestamp}'
LAST SEEN   TYPE      REASON              OBJECT                                   MESSAGE
2m27s       Normal    Scheduled           pod/nginx-deployment-6b474476c4-2wk4g    Successfully assigned event-test/nginx-deployment-6b474476c4-2wk4g to node1
2m27s       Normal    ScalingReplicaSet   deployment/nginx-deployment              Scaled up replica set nginx-deployment-6b474476c4 to 1
2m27s       Normal    SuccessfulCreate    replicaset/nginx-deployment-6b474476c4   Created pod: nginx-deployment-6b474476c4-2wk4g
30s         Normal    Pulling             pod/nginx-deployment-6b474476c4-2wk4g    Pulling image "nginx:1.14.2"
55s         Warning   Failed              pod/nginx-deployment-6b474476c4-2wk4g    Failed to pull image "nginx:1.14.2": rpc error: code = Unknown desc = Error response from daemon: error parsing HTTP 408 response body: invalid character '<' looking for beginning of value: "<html><body><h1>408 Request Time-out</h1>\nYour browser didn't send a complete request in time.\n</body></html>\n"
55s         Warning   Failed              pod/nginx-deployment-6b474476c4-2wk4g    Error: ErrImagePull
41s         Normal    BackOff             pod/nginx-deployment-6b474476c4-2wk4g    Back-off pulling image "nginx:1.14.2"
41s         Warning   Failed              pod/nginx-deployment-6b474476c4-2wk4g    Error: ImagePullBackOff
```
通过以上的操作，我们可以发现 events 实际上是 Kubernetes 集群中的一种资源。当 Kubernetes 集群中**资源状态**发生变化时，可以产生新的 events。

## 字段含义

以下是字段解析：
```
LAST: 表示事件发生事件。

TYPE: 事件类型，主要是normal（正常）跟warning（警告），一般只需要关注warning。

REASON: 来阐述该事件发生的原因（一般为多个单词驼峰法的拼写。

OBJECT: 事件所关联的资源对象。                           

MESSAGE: 事件描述。
```
## Event的作用
在kubernetes中，我们通常通过 kubectl describe 资源对象 -n namespace 对象名称 通过对其事件分析，从而**判断资源是否正常**。
```
[root@node1 ~]# kubectl describe pod/nginx-deployment-6b474476c4-2wk4g  -n event-test
Name:         nginx-deployment-6b474476c4-2wk4g
Namespace:    event-test
Priority:     0
Node:         node1/10.20.45.176
Start Time:   Mon, 01 Aug 2022 21:27:30 +0800
Labels:       app=nginx
pod-template-hash=6b474476c4
Annotations:  cni.projectcalico.org/podIP: 10.244.38.145/32
cni.projectcalico.org/podIPs: 10.244.38.145/32
Status:       Pending
IP:           10.244.38.145
IPs:
IP:           10.244.38.145
Controlled By:  ReplicaSet/nginx-deployment-6b474476c4
Containers:
nginx:
Container ID:   
Image:          nginx:1.14.2
Image ID:       
Port:           80/TCP
Host Port:      0/TCP
State:          Waiting
Reason:       ImagePullBackOff
Ready:          False
Restart Count:  0
Environment:    <none>
Mounts:
/var/run/secrets/kubernetes.io/serviceaccount from default-token-f67hn (ro)
Conditions:
Type              Status
Initialized       True
Ready             False
ContainersReady   False
PodScheduled      True
Volumes:
default-token-f67hn:
Type:        Secret (a volume populated by a Secret)
SecretName:  default-token-f67hn
Optional:    false
QoS Class:       BestEffort
Node-Selectors:  <none>
Tolerations:     node.kubernetes.io/not-ready:NoExecute for 300s
node.kubernetes.io/unreachable:NoExecute for 300s
Events:
Type     Reason     Age                     From               Message
  ----     ------     ----                    ----               -------
Normal   Scheduled  8m29s                   default-scheduler  Successfully assigned event-test/nginx-deployment-6b474476c4-2wk4g to node1
Warning  Failed     6m57s (x2 over 7m55s)   kubelet            Failed to pull image "nginx:1.14.2": rpc error: code = Unknown desc = Error response from daemon: error parsing HTTP 408 response body: invalid character '<' looking for beginning of value: "<html><body><h1>408 Request Time-out</h1>\nYour browser didn't send a complete request in time.\n</body></html>\n"
Warning  Failed     5m57s                   kubelet            Failed to pull image "nginx:1.14.2": rpc error: code = Unknown desc = error pulling image configuration: Get https://production.cloudflare.docker.com/registry-v2/docker/registry/v2/blobs/sha256/29/295c7be079025306c4f1d65997fcf7adb411c88f139ad1d34b537164aa060369/data?verify=1659363670-TrbkagNHlCm67ThG8K%2F8%2FdKhRL4%3D: dial tcp 104.18.121.25:443: i/o timeout
Normal   Pulling    5m12s (x4 over 8m28s)   kubelet            Pulling image "nginx:1.14.2"
Warning  Failed     5m3s (x4 over 7m55s)    kubelet            Error: ErrImagePull
Warning  Failed     5m3s                    kubelet            Failed to pull image "nginx:1.14.2": rpc error: code = Unknown desc = toomanyrequests: You have reached your pull rate limit. You may increase the limit by authenticating and upgrading: https://www.docker.com/increase-rate-limit
Normal   BackOff    4m38s (x6 over 7m54s)   kubelet            Back-off pulling image "nginx:1.14.2"
Warning  Failed     3m26s (x10 over 7m54s)  kubelet            Error: ImagePullBackOff
```
通过describe指令，我们可以发现 pod/nginx-deployment-6b474476c4-2wk4g 资源对象由于**image下载失败**而启动失败。
# Event源码解析
## Event的产生代码
事件产生代码如下：
```
// 事件广播器
eventBroadcaster := record.NewBroadcaster()
eventBroadcaster.StartRecordingToSink(&v1.EventSinkImpl{Interface: clientSet.CoreV1().Events("")})
// 事件生产者
DefaultEventRecorder = eventBroadcaster.NewRecorder(mgr.GetScheme(), v12.EventSource{Component: "operator"})
DefaultEventRecorder.Event(&v12.Pod{}, v12.EventTypeWarning, "JustTest", "just for test")
```
上述代码可产生如下一个事件：
```
LAST SEEN   TYPE      REASON              OBJECT                               MESSAGE
2m27s       Warning   JustTest           pod/xxx                               just for test
```
## Event的产生整理流程

Event事件管理机制主要有三部分组成：

**EventBroadcaster**：事件广播器，负责消费EventRecorder产生的事件，然后分发给broadcasterWatcher；

**EventRecorder**：是事件生成者，k8s组件通过调用它的方法来生成事件；

**broadcasterWatcher**：用于定义事件的处理方式，如上报apiserver；

整个事件管理机制的流程大致如图：
![](./images/EventBroadcaster.png)

## 代码部分重要详解

### EventRecorder

#### NewBroadcaster（）
初始化一个Broadcaster对象，初始化一个名叫**incoming**的channel。
```
初始化 EventBroadcaster 对象
eventBroadcaster := record.NewBroadcaster()

func NewBroadcaster() EventBroadcaster {
	return &eventBroadcasterImpl{
		Broadcaster:   watch.NewLongQueueBroadcaster(maxQueuedEvents, watch.DropIfChannelFull),
		sleepDuration: defaultSleepDuration,
	}
}

func NewLongQueueBroadcaster(queueLength int, fullChannelBehavior FullChannelBehavior) *Broadcaster {
	m := &Broadcaster{
		watchers:            map[int64]*broadcasterWatcher{},
		incoming:            make(chan Event, queueLength),
		stopped:             make(chan struct{}),
		watchQueueLength:    queueLength,
		fullChannelBehavior: fullChannelBehavior,
	}
	m.distributing.Add(1)
	//开启loog循环接收所有event
	go m.loop()
	return m
}
```
#### loop()
loop 从 **incoming** 接收对象 并分发给所有的**watchers**。
```
func (m *Broadcaster) loop() {
	// 从incoming不断的拿到event
	for event := range m.incoming {
		if event.Type == internalRunFunctionMarker {
			event.Object.(functionFakeRuntimeObject)()
			continue
		}
		//将event广播给watcher
		m.distribute(event)
	}
	m.closeAll()
	m.distributing.Done()
}

func (m *Broadcaster) distribute(event Event) {
	if m.fullChannelBehavior == DropIfChannelFull {
		for _, w := range m.watchers {
	        //将event放置wather的result中
			select {
			case w.result <- event:
			case <-w.stopped:
			default: // Don't block if the event can't be queued.
			}
		}
	} else {
		for _, w := range m.watchers {
			select {
            //将event放置wather的result中
			case w.result <- event:
			case <-w.stopped:
			}
		}
	}
}

```

总的来说，eventBroadcaster := record.NewBroadcaster()这一步初始化 EventBroadcaster 对象，同时会初始化一个 Broadcaster 对象，并开启一个 **loop** 循环接收**incoming**这个chanel的 events 利用distribute()方法广播给所有的watchers。



### StartRecordingToSink()
启动了一个**eventWatcher** 这个**eventWathcer**是专门用来上报event给apiserver的。
```
eventBroadcaster.StartRecordingToSink(&v1.EventSinkImpl{Interface: clientSet.CoreV1().Events("")})
func (e *eventBroadcasterImpl) StartRecordingToSink(sink EventSink) watch.Interface {
	eventCorrelator := NewEventCorrelatorWithOptions(e.options)
	return e.StartEventWatcher(
		func(event *v1.Event) {
			recordToSink(sink, event, eventCorrelator, e.sleepDuration)
		})
}
```
#### recordToSink（）
根据event对应的 InvolvedObject 对象进行聚合，过滤（防止大量事件的产生对etcd造成冲击），再调用recordEvent，将结果上报至apiserver。
```
func recordToSink(sink EventSink, event *v1.Event, eventCorrelator *EventCorrelator, sleepDuration time.Duration) {
	// Make a copy before modification, because there could be multiple listeners.
	// Events are safe to copy like this.
	eventCopy := *event
	event = &eventCopy
	//进行聚合，过滤
	result, err := eventCorrelator.EventCorrelate(event)
	if err != nil {
		utilruntime.HandleError(err)
	}
	if result.Skip {
		return
	}
	tries := 0
	for {
	    //调用sink方法 上报apiserver
		if recordEvent(sink, result.Event, result.Patch, result.Event.Count > 1, eventCorrelator) {
			break
		}
		...//上报错误之后的重试策略 省略
	}
}
```
#### recordEvent（）
判断events是否创建，调用**path（）**或者**create（）**接口上报apiserver。
```
func recordEvent(sink EventSink, event *v1.Event, patch []byte, updateExistingEvent bool, eventCorrelator *EventCorrelator) bool {
	var newEvent *v1.Event
	var err error
	if updateExistingEvent {
	// 如果事件已经存在 调用path接口
		newEvent, err = sink.Patch(event, patch)
	}
	if !updateExistingEvent || (updateExistingEvent && util.IsKeyNotFoundError(err)) {
		event.ResourceVersion = ""
		//事件不存在，调用create接口
		newEvent, err = sink.Create(event)
	}
	if err == nil {
		// we need to update our event correlator with the server returned state to handle name/resourceversion
		eventCorrelator.UpdateState(newEvent)
		return true
	}
    //... 上报失败之后的重试。忽略
	return false
}
```

总的来说，**StartRecordingToSink **封装的 StartEventWatcher 方法里面会将所有的 events 广播给每一个 watcher，并调用 **recordToSink** 方法对收到 events 后会进行**缓存、过滤、聚合**而后发送到 apiserver，apiserver 会将 events 保存到 etcd 中。



### EventRecorder(recorderImpl)

```
DefaultEventRecorder = eventBroadcaster.NewRecorder(mgr.GetScheme(), v12.EventSource{Component: "operator"})
DefaultEventRecorder.Event(&v12.Pod{}, v12.EventTypeWarning, "JustTest", "just for test")

func (recorder *recorderImpl) Event(object runtime.Object, eventtype, reason, message string) {
	recorder.generateEvent(object, nil, eventtype, reason, message)
}
```
#### generateEvent（）
生成event对象 调用ActionOrDrop（）
```
func (recorder *recorderImpl) generateEvent(object runtime.Object, annotations map[string]string, eventtype, reason, message string) {
	ref, err := ref.GetReference(recorder.scheme, object)
	if err != nil {
		klog.Errorf("Could not construct reference to: '%#v' due to: '%v'. Will not report event: '%v' '%v' '%v'", object, err, eventtype, reason, message)
		return
	}
	if !util.ValidateEventType(eventtype) {
		klog.Errorf("Unsupported event type: '%v'", eventtype)
		return
	}
    //创建出一个event对象 简单的赋值操作
	event := recorder.makeEvent(ref, annotations, eventtype, reason, message)
	event.Source = recorder.source
	//发送event
	if sent := recorder.ActionOrDrop(watch.Added, event); !sent {
		klog.Errorf("unable to record event: too many queued events, dropped event %#v", event)
	}
}
```
#### ActionOrDrop（）
将event发送至名叫**incoming**的channel中
```
func (m *Broadcaster) ActionOrDrop(action EventType, obj runtime.Object) bool {
	select {
	//将event发送到incoming 中
	case m.incoming <- Event{action, obj}:
		return true
	default:
		return false
	}
}

```
总的来说，EventRecorder 对象会生成 events 并通过**Action ()** **将event发送至**incoming**这个chanel中，这个chanel是被**EventBroadcaste**r监听的。



至此，整个event从产生到最后发送到ApiServer的流程已经完成。
