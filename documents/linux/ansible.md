# Inventory 内置参数
ansible_ssh_host	定义 host ssh 地址	ansible_ssh_host=10.1.90.59
ansible_ssh_port	定义 hosts ssh 端口	ansible_ssh_port=22
ansible_ssh_user	定义 hosts ssh 认证用户	ansible_ssh_user=wupx
ansible_ssh_pass	定义 hosts ssh 认证密码	ansible_ssh_pass=123
ansible_sudo	定义 hosts sudo的用户	ansible_sudo=wupx
ansible_sudo_pass	定义 hosts sudo密码	ansible_sudo_pass=123
ansible_sudo_exe	定义 hosts sudo 路径	ansible_sudo_exe=/usr/bin/sudo
ansible_ssh_private_key_file	定义 hosts 私钥	ansible_ssh_private_key_file=/root/key
ansible_shell_type	定义 hosts shell 类型	ansible_shell_type=bash
ansible_python_interpreter	定义 hosts 任务执行 python 的路径	ansible_python_interpreter=/usr/bin/python2.6
ansible_*_interpreter	定义 hosts 其他语言解析器路径	ansible_ruby_interpreter=/usr/bin/ruby

```
ssh-keygen

ssh-copy-id root@ip

ssh root@ip

ansible -u root 165 -a "pwd"
```