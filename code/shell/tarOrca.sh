#!/usr/bin/expect

spawn ssh root@10.20.144.165 uptime

#捕捉是否信任设备
expect "yes/no"
send "yes\n"

#捕捉密码
expect "*assword"
send "1\n"

expect eof






