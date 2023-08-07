## memory profiling主要查看程序当前活动对象内存分配

```

go tool pprof http://localhost:57617/debug/pprof/profile

http://localhost:8082/debug/pprof/ ：获取概况信息，即图一的信息
go tool pprof http://localhost:8082/debug/pprof/allocs : 分析内存分配
go tool pprof http://localhost:8082/debug/pprof/block : 分析堆栈跟踪导致阻塞的同步原语
go tool pprof http://localhost:8082/debug/pprof/cmdline : 分析命令行调用的程序，web下调用报错
go tool pprof http://localhost:8082/debug/pprof/goroutine : 分析当前 goroutine 的堆栈信息
go tool pprof http://localhost:8082/debug/pprof/heap : 分析当前活动对象内存分配
go tool pprof http://localhost:8082/debug/pprof/mutex : 分析堆栈跟踪竞争状态互斥锁的持有者
go tool pprof http://localhost:8082/debug/pprof/profile : 分析一定持续时间内CPU的使用情况
go tool pprof http://localhost:8082/debug/pprof/threadcreate : 分析堆栈跟踪系统新线程的创建
go tool pprof http://localhost:8082/debug/pprof/trace : 分析追踪当前程序的执行状况
```

https://zhuanlan.zhihu.com/p/371713134

go tool pprof -http localhost:3001 /Users/stt/pprof/pprof.app-operator.samples.cpu.004.pb.gz

