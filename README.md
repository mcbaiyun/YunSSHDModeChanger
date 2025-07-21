# YunSSHDModeChanger
本脚本用于Alpine、Debain等系统的SSHD认证方式的辅助配置，可以检查并切换SSHD的认证方式，但你需要自己生成证书
## 菜单选项
```text
-------------------------------
  [YunSSHDModeChanger] 主菜单
------------------------------
  1. 创建~/.ssh目录并设置权限700
  2. 检查SSH文件权限
  3. 检查sshd_config配置
  4. 切换SSHD配置为允许证书和密码登录
  5. 切换SSHD配置为仅允许密码登录（将禁用密钥认证）
  6. 切换SSHD配置为仅允许证书登录（将禁用密码）
  7. 重启sshd服务（支持Alpine,Debain和Ubuntu）（建议确保配置无误，并备份重要数据后执行此选项，否则您可能在断开本次会话后无法连接服务器）
  0. 退出脚本
```
## 下载使用
### Github 直连
只使用一次(curl与wget二选一)
```shell
bash <(curl https://raw.githubusercontent.com/mcbaiyun/YunSSHDModeChanger/refs/heads/main/YunSSHDModeChanger.sh) || ash <(curl https://raw.githubusercontent.com/mcbaiyun/YunSSHDModeChanger/refs/heads/main/YunSSHDModeChanger.sh)
```
```shell
bash <(wget -q -O - https://raw.githubusercontent.com/mcbaiyun/YunSSHDModeChanger/refs/heads/main/YunSSHDModeChanger.sh) || ash <(wget -q -O - https://raw.githubusercontent.com/mcbaiyun/YunSSHDModeChanger/refs/heads/main/YunSSHDModeChanger.sh)
```
保存并执行(curl与wget二选一)
```shell
curl -O https://raw.githubusercontent.com/mcbaiyun/YunSSHDModeChanger/refs/heads/main/YunSSHDModeChanger.sh && bash YunSSHDModeChanger.sh || ash YunSSHDModeChanger.sh
```
```shell
wget https://raw.githubusercontent.com/mcbaiyun/YunSSHDModeChanger/refs/heads/main/YunSSHDModeChanger.sh && bash YunSSHDModeChanger.sh || ash YunSSHDModeChanger.sh
```
> 后续执行直接使用
```shell
bash YunSSHDModeChanger.sh || ash YunSSHDModeChanger.sh
```
### ghproxy.net 镜像
只使用一次(curl与wget二选一)
```shell
bash <(curl https://ghproxy.net/https://raw.githubusercontent.com/mcbaiyun/YunSSHDModeChanger/refs/heads/main/YunSSHDModeChanger.sh) || ash <(curl https://ghproxy.net/https://raw.githubusercontent.com/mcbaiyun/YunSSHDModeChanger/refs/heads/main/YunSSHDModeChanger.sh)
```
```shell
bash <(wget -q -O - https://ghproxy.net/https://raw.githubusercontent.com/mcbaiyun/YunSSHDModeChanger/refs/heads/main/YunSSHDModeChanger.sh) || ash <(wget -q -O - https://ghproxy.net/https://raw.githubusercontent.com/mcbaiyun/YunSSHDModeChanger/refs/heads/main/YunSSHDModeChanger.sh)
```
保存并执行(curl与wget二选一)
```shell
curl -O https://ghproxy.net/https://raw.githubusercontent.com/mcbaiyun/YunSSHDModeChanger/refs/heads/main/YunSSHDModeChanger.sh && bash YunSSHDModeChanger.sh || ash YunSSHDModeChanger.sh
```
```shell
wget https://ghproxy.net/https://raw.githubusercontent.com/mcbaiyun/YunSSHDModeChanger/refs/heads/main/YunSSHDModeChanger.sh && bash YunSSHDModeChanger.sh || ash YunSSHDModeChanger.sh
```
> 后续执行直接使用
```shell
bash YunSSHDModeChanger.sh || ash YunSSHDModeChanger.sh
```
