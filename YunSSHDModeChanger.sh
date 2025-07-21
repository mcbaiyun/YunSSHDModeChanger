#!/bin/sh

# 打印换行符 防止某些情况导致的输出显示问题
echo -e "\n"

# 系统类型检测
if [ -f "/etc/os-release" ]; then
    if grep -q "ID=alpine" /etc/os-release; then
        OS_TYPE="Alpine"
        echo -e "\033[36m检测到系统类型：\033[32m$OS_TYPE\033[0m"
    elif grep -q "ID=ubuntu" /etc/os-release; then
        OS_TYPE="Ubuntu"
        echo -e "\033[36m检测到系统类型：\033[32m$OS_TYPE\033[0m"
    elif grep -q "ID=debian" /etc/os-release; then
        OS_TYPE="Debian"
        echo -e "\033[36m检测到系统类型：\033[32m$OS_TYPE\033[0m"
    else
        OS_TYPE="Other"
        echo -e "\033[36m检测到系统类型：\033[33m$OS_TYPE\033[0m"
    fi
else
    echo -e "\033[31m错误：/etc/os-release 文件不存在\033[0m"
    exit 1
fi

# sudo可用性检测（通用实现）
echo -e "\033[36m正在检测sudo可用性...\033[0m"

# 封装检测逻辑为函数以便重复调用
check_sudo() {
    if [ "$OS_TYPE" = "Alpine" ]; then
        if apk info -e sudo > /dev/null 2>&1; then
            echo -e "\033[32m✓ sudo 已安装并可用\033[0m"
            return 0
        else
            echo -e "\033[33m⚠ 警告：sudo 未安装\033[0m"
            while true; do
                read -p $'\033[36m是否安装sudo? [y/n]: \033[0m' yn
                case $yn in
                    [Yy]* ) 
                        echo -e "\033[36m正在安装sudo...\033[0m"
                        if apk add sudo > /dev/null 2>&1; then
                            echo -e "\033[32m✓ sudo 安装成功\033[0m"
                            return 1
                        else
                            echo -e "\033[31m错误：sudo 安装失败\033[0m"
                            return 2
                        fi
                    ;;
                    [Nn]* ) 
                        echo -e "\033[31m错误：sudo 未安装，脚本退出\033[0m"
                        exit 1
                    ;;
                    * ) 
                        echo -e "\033[33m请输入 y 或 n\033[0m"
                    ;;
                esac
            done
        fi
    elif [ "$OS_TYPE" = "Ubuntu" ] || [ "$OS_TYPE" = "Debian" ]; then
        if dpkg -s sudo > /dev/null 2>&1; then
            echo -e "\033[32m✓ sudo 已安装并可用\033[0m"
            return 0
        else
            echo -e "\033[33m⚠ 警告：sudo 未安装\033[0m"
            while true; do
                read -p $'\033[36m是否安装sudo? [y/n]: \033[0m' yn
                case $yn in
                    [Yy]* ) 
                        echo -e "\033[36m正在安装sudo...\033[0m"
                        if apt install -y sudo > /dev/null 2>&1; then
                            echo -e "\033[32m✓ sudo 安装成功\033[0m"
                            return 1
                        else
                            echo -e "\033[31m错误：sudo 安装失败\033[0m"
                            return 2
                        fi
                    ;;
                    [Nn]* ) 
                        echo -e "\033[31m错误：sudo 未安装，脚本退出\033[0m"
                        exit 1
                    ;;
                    * ) 
                        echo -e "\033[33m请输入 y 或 n\033[0m"
                    ;;
                esac
            done
        fi
    else
        if command -v sudo > /dev/null 2>&1; then
            echo -e "\033[32m✓ sudo 已安装并可用\033[0m"
            return 0
        else
            echo -e "\033[33m⚠ 警告：sudo 未安装\033[0m"
            echo -e "\033[31m错误：无法自动安装sudo，请手动安装后重新运行脚本\033[0m"
            exit 1
        fi
    fi
}

# 执行检测并处理安装逻辑
while true; do
    check_sudo
    case $? in
        0 ) break ;;  # 已安装，退出循环
        1 ) continue ;; # 安装成功，重新检测
        2 ) continue ;; # 安装失败，重新检测
    esac
done

# 主菜单显示部分保持原样
while true; do
    echo -e "\n [YunSSHDModeChanger] 主菜单：\n"
    echo -e "  1. 创建~/.ssh目录并设置权限700"
    echo -e "  2. 检查SSH文件权限"
    echo -e "  3. 检查sshd_config配置"
    echo -e "  4. 切换SSHD配置为允许证书和密码登录"
    echo -e "  5. 切换SSHD配置为仅允许密码登录\033[31m（将禁用密钥认证）\033[0m"
    echo -e "  6. 切换SSHD配置为仅允许证书登录\033[31m（将禁用密码）\033[0m"
    echo -e "  7. 重启sshd服务（支持Alpine,Debain和Ubuntu）\033[31m（建议确保配置无误，并备份重要数据后执行此选项，否则您可能在断开本次会话后无法连接服务器）\033[0m"
    echo -e "  0. 退出脚本\n"
    
    read -p "请输入选项数字 [0-7]: " choice
    
    if [ "$choice" == "1" ]; then
        if [ -d "$HOME/.ssh" ]; then
            echo "错误：目录~/.ssh已存在！"
            continue
        fi
        mkdir -p $HOME/.ssh
        chmod 700 $HOME/.ssh
        echo "目录创建并设置权限成功"
        continue
    elif [ "$choice" == "2" ]; then
        if [ ! -d "$HOME/.ssh" ]; then
            echo "错误：~/.ssh 目录不存在，请先选择选项1创建目录"
            continue
        fi

        # 检查id_rsa文件
        if [ -f "$HOME/.ssh/id_rsa" ]; then
            current_perm=$(stat -c "%a" $HOME/.ssh/id_rsa 2>/dev/null)
            if [ "$current_perm" != "600" ]; then
                chmod 600 $HOME/.ssh/id_rsa
                echo "已修正 ~/.ssh/id_rsa 权限为600"
            else
                echo "~/.ssh/id_rsa 权限正确"
            fi
        else
            echo "错误：~/.ssh/id_rsa 文件不存在"
        fi

        # 检查id_rsa.pub文件
        if [ -f "$HOME/.ssh/id_rsa.pub" ]; then
            current_perm=$(stat -c "%a" $HOME/.ssh/id_rsa.pub 2>/dev/null)
            if [ "$current_perm" != "644" ]; then
                chmod 644 $HOME/.ssh/id_rsa.pub
                echo "已修正 ~/.ssh/id_rsa.pub 权限为644"
            else
                echo "~/.ssh/id_rsa.pub 权限正确"
            fi
        else
            echo "错误：~/.ssh/id_rsa.pub 文件不存在"
        fi

        # 检查authorized_keys文件
        if [ -f "$HOME/.ssh/authorized_keys" ]; then
            current_perm=$(stat -c "%a" $HOME/.ssh/authorized_keys 2>/dev/null)
            if [ "$current_perm" != "600" ]; then
                chmod 600 $HOME/.ssh/authorized_keys
                echo "已修正 ~/.ssh/authorized_keys 权限为600"
            else
                echo "~/.ssh/authorized_keys 权限正确"
            fi
        else
            echo "错误：~/.ssh/authorized_keys 文件不存在"
        fi
        
        echo "文件检查完成"
        continue
    elif [ "$choice" == "3" ]; then
        if [ -f "/etc/ssh/sshd_config" ]; then
            echo "sshd_config文件存在，正在检查配置..."
            grep -E '^(#?PermitRootLogin|#?PubkeyAuthentication|#?AuthorizedKeysFile|#?PasswordAuthentication)' /etc/ssh/sshd_config | while read -r line; do
                echo "$line"
            done
        else
            echo "错误：/etc/ssh/sshd_config 文件不存在"
        fi
        continue
    elif [ "$choice" == "4" ]; then
        if [ ! -f "/etc/ssh/sshd_config" ]; then
            echo "错误：/etc/ssh/sshd_config 文件不存在"
            continue
        fi
        
        echo "正在配置允许证书和密码登录Root..."
        
        # 处理配置PermitRootLogin（如果被注释需要移除注释，且保证值为yes）
        if grep -q '^[[:space:]]*PermitRootLogin' /etc/ssh/sshd_config; then
            # 如果存在且被注释则移除注释
            sudo sed -i 's/^[[:space:]]*#PermitRootLogin/PermitRootLogin/' /etc/ssh/sshd_config
            # 确保值为yes
            sudo sed -i 's/^[[:space:]]*PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config
            echo "PermitRootLogin 已配置为允许"
        else
            echo "警告：未找到PermitRootLogin配置项，建议手动检查配置文件"
        fi
        
        # 处理PasswordAuthentication配置(可以保持被注释，如果没有注释确保值为yes)
        if grep -Eq '^[[:space:]]*#?PasswordAuthentication' /etc/ssh/sshd_config; then
            # 获取当前配置状态
            current_config=$(grep -E '^[[:space:]]*#?PasswordAuthentication' /etc/ssh/sshd_config)
            
            # 处理不同配置情况
            if [[ $current_config == \#* ]]; then
                echo "PasswordAuthentication 被注释，保持注释状态"
            else
                # 检查当前值是否为yes
                if echo "$current_config" | grep -Eq 'PasswordAuthentication\s+yes'; then
                    echo "PasswordAuthentication 已配置为yes"
                else
                    # 修改配置为yes并添加注释说明
                    sudo sed -i 's/^[[:space:]]*#*PasswordAuthentication.*/PasswordAuthentication yes # 由脚本修改/' /etc/ssh/sshd_config
                    echo "PasswordAuthentication 已配置为yes"
                fi
            fi
        else
            echo "警告：未找到PasswordAuthentication配置项，建议手动检查配置文件"
        fi

        # 检查.ssh/authorized_keys是否存在
        AUTHORIZED_KEYS="$HOME/.ssh/authorized_keys"
        if [ ! -f "$AUTHORIZED_KEYS" ]; then
            echo -e "\033[33m警告：authorized_keys文件不存在，将关闭证书登录以确保sshd正常运行...\033[0m"
            
            # 处理PubkeyAuthentication配置（确保被注释且值为yes）
            if grep -Eq '^[[:space:]]*#?PubkeyAuthentication' /etc/ssh/sshd_config; then
                sudo sed -i 's/^[[:space:]]*#*PubkeyAuthentication.*/#PubkeyAuthentication yes # 由脚本修改/' /etc/ssh/sshd_config
                echo -e "\033[33mPubkeyAuthentication 已注释并配置为yes\033[0m"
            else
                echo -e "\033[33m警告：未找到PubkeyAuthentication配置项，建议手动检查配置文件\033[0m"
            fi
            
            # 处理AuthorizedKeysFile配置（确保被注释且值为.ssh/authorized_keys）
            if grep -Eq '^[[:space:]]*#?AuthorizedKeysFile' /etc/ssh/sshd_config; then
                sudo sed -i 's/^[[:space:]]*#*AuthorizedKeysFile.*/#AuthorizedKeysFile .ssh\/authorized_keys # 由脚本修改/' /etc/ssh/sshd_config
                echo -e "\033[33mAuthorizedKeysFile 已注释并配置为默认路径\033[0m"
            else
                echo -e "\033[33m警告：未找到AuthorizedKeysFile配置项\033[0m"
            fi


        else
            # 检查目录权限（确保为700）（这里无需检查目录存在，因为其内部文件都存在那么目录肯定已经存在）
            SSH_DIR="$HOME/.ssh"
            DIR_MODE=$(stat -c "%a" "$SSH_DIR" 2>/dev/null)
            if [ "$DIR_MODE" != "700" ]; then
                echo -e "\033[33m警告：.ssh目录权限不正确（当前权限：$DIR_MODE），正在修正...\033[0m"
                chmod 700 "$SSH_DIR"
                echo -e "\033[32m已修正.ssh目录权限为700\033[0m"
            fi

            # 检查文件权限
            FILE_MODE=$(stat -c "%a" "$AUTHORIZED_KEYS" 2>/dev/null)
            if [ "$FILE_MODE" != "600" ]; then
                echo -e "\033[33m警告：authorized_keys权限不正确（当前权限：$FILE_MODE），正在修正...\033[0m"
                chmod 600 "$AUTHORIZED_KEYS"
                echo -e "\033[32m已修正authorized_keys文件权限为600\033[0m"
            fi

            # 处理PubkeyAuthentication配置（确保没有被注释且值为yes）
            if grep -Eq '^[[:space:]]*#?PubkeyAuthentication' /etc/ssh/sshd_config; then
                sudo sed -i 's/^[[:space:]]*#*PubkeyAuthentication.*/PubkeyAuthentication yes # 由脚本修改/' /etc/ssh/sshd_config
                echo -e "\033[32mPubkeyAuthentication 已配置为yes\033[0m"
            else
                echo -e "\033[33m警告：未找到PubkeyAuthentication配置项，建议手动检查配置文件\033[0m"
            fi
            
            # 处理AuthorizedKeysFile配置（确保没有被注释且值为.ssh/authorized_keys）
            if grep -Eq '^[[:space:]]*#?AuthorizedKeysFile' /etc/ssh/sshd_config; then
                sudo sed -i 's/^[[:space:]]*#*AuthorizedKeysFile.*/AuthorizedKeysFile .ssh\/authorized_keys # 由脚本修改/' /etc/ssh/sshd_config
                echo -e "\033[32mAuthorizedKeysFile 已配置为默认路径\033[0m"
            else
                echo -e "\033[33m警告：未找到AuthorizedKeysFile配置项\033[0m"
            fi
        fi


        
        echo "配置完成，建议重启ssh服务生效"
        continue
    elif [ "$choice" == "5" ]; then
        if [ ! -f "/etc/ssh/sshd_config" ]; then
            echo "错误：/etc/ssh/sshd_config 文件不存在"
            continue
        fi
        
        echo -e "\n\033[36m正在配置仅密码登录模式...\033[0m"
        
        # 处理PermitRootLogin配置（确保没有注释且配置为yes）
        if grep -q '^[[:space:]]*PermitRootLogin' /etc/ssh/sshd_config; then
            sudo sed -i 's/^[[:space:]]*#PermitRootLogin/PermitRootLogin/' /etc/ssh/sshd_config
            sudo sed -i 's/^[[:space:]]*PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config
            echo -e "\033[32mPermitRootLogin 已配置为允许\033[0m"
        else
            echo -e "\033[33m警告：未找到PermitRootLogin配置项，建议手动检查配置文件\033[0m"
        fi
        
        # 处理PasswordAuthentication配置（强制取消注释并设为yes）
        if grep -Eq '^[[:space:]]*#?PasswordAuthentication' /etc/ssh/sshd_config; then
            sudo sed -i 's/^[[:space:]]*#*PasswordAuthentication.*/PasswordAuthentication yes # 由脚本修改/' /etc/ssh/sshd_config
            echo -e "\033[32mPasswordAuthentication 已配置为yes\033[0m"
        else
            echo -e "\033[33m警告：未找到PasswordAuthentication配置项，建议手动检查配置文件\033[0m"
        fi
        
        # 禁用公钥认证（确保被注释且值为no）
        if grep -Eq '^[[:space:]]*#?PubkeyAuthentication' /etc/ssh/sshd_config; then
            sudo sed -i 's/^[[:space:]]*#*PubkeyAuthentication.*/PubkeyAuthentication no/' /etc/ssh/sshd_config
            echo -e "\033[32mPubkeyAuthentication 已禁用\033[0m"
        else
            echo -e "\033[33m警告：未找到PubkeyAuthentication配置项，建议手动检查配置文件\033[0m"
        fi
        
        # 注释AuthorizedKeysFile配置（确保被注释）
        if grep -Eq '^[[:space:]]*AuthorizedKeysFile' /etc/ssh/sshd_config; then
            sudo sed -i 's/^[[:space:]]*AuthorizedKeysFile/#&/' /etc/ssh/sshd_config
            echo -e "\033[32mAuthorizedKeysFile 已注释\033[0m"
        else
            echo -e "\033[33m警告：未找到AuthorizedKeysFile配置项\033[0m"
        fi
        
        echo -e "\033[36m配置完成，建议重启ssh服务生效\033[0m"
        continue
    elif [ "$choice" == "6" ]; then
        echo -e "\n\033[36m正在配置仅证书登录模式...\033[0m"
        
        # 检查authorized_keys文件是否存在且不为空
        AUTHORIZED_KEYS="$HOME/.ssh/authorized_keys"
        if [ ! -f "$AUTHORIZED_KEYS" ]; then
            echo -e "\033[31m错误：authorized_keys文件不存在\033[0m"
            continue
        fi
        
        if [ ! -s "$AUTHORIZED_KEYS" ]; then
            echo -e "\033[31m错误：authorized_keys文件为空\033[0m"
            continue
        fi
        
        # 检查.ssh目录权限
        SSH_DIR="$HOME/.ssh"
        DIR_MODE=$(stat -c "%a" "$SSH_DIR" 2>/dev/null)
        if [ "$DIR_MODE" != "700" ]; then
            echo -e "\033[33m警告：.ssh目录权限不正确（当前权限：$DIR_MODE），正在修正...\033[0m"
            chmod 700 "$SSH_DIR"
            echo -e "\033[32m已修正.ssh目录权限为700\033[0m"
        fi
        
        # 检查文件权限
        FILE_MODE=$(stat -c "%a" "$AUTHORIZED_KEYS" 2>/dev/null)
        if [ "$FILE_MODE" != "600" ]; then
            echo -e "\033[33m警告：authorized_keys权限不正确（当前权限：$FILE_MODE），正在修正...\033[0m"
            chmod 600 "$AUTHORIZED_KEYS"
            echo -e "\033[32m已修正authorized_keys文件权限为600\033[0m"
        fi
        
        # 检查sshd_config是否存在
        if [ ! -f "/etc/ssh/sshd_config" ]; then
            echo -e "\033[31m错误：/etc/ssh/sshd_config 文件不存在\033[0m"
            continue
        fi
        
        # 配置PermitRootLogin
        if grep -q '^[[:space:]]*PermitRootLogin' /etc/ssh/sshd_config; then
            sudo sed -i 's/^[[:space:]]*#PermitRootLogin/PermitRootLogin/' /etc/ssh/sshd_config
            sudo sed -i 's/^[[:space:]]*PermitRootLogin.*/PermitRootLogin prohibit-password/' /etc/ssh/sshd_config
            echo -e "\033[32mPermitRootLogin 已配置为prohibit-password\033[0m"
        else
            echo -e "\033[33m警告：未找到PermitRootLogin配置项，建议手动检查配置文件\033[0m"
        fi
        
        # 配置PubkeyAuthentication
        if grep -Eq '^[[:space:]]*#?PubkeyAuthentication' /etc/ssh/sshd_config; then
            sudo sed -i 's/^[[:space:]]*#*PubkeyAuthentication.*/PubkeyAuthentication yes # 由脚本修改/' /etc/ssh/sshd_config
            echo -e "\033[32mPubkeyAuthentication 已配置为yes\033[0m"
        else
            echo -e "\033[33m警告：未找到PubkeyAuthentication配置项，建议手动检查配置文件\033[0m"
        fi
        
        # 配置AuthorizedKeysFile
        if grep -Eq '^[[:space:]]*#?AuthorizedKeysFile' /etc/ssh/sshd_config; then
            sudo sed -i 's/^[[:space:]]*#*AuthorizedKeysFile.*/AuthorizedKeysFile .ssh\/authorized_keys # 由脚本修改/' /etc/ssh/sshd_config
            echo -e "\033[32mAuthorizedKeysFile 已配置为默认路径\033[0m"
        else
            echo -e "\033[33m警告：未找到AuthorizedKeysFile配置项\033[0m"
        fi
        
        # 配置PasswordAuthentication
        if grep -Eq '^[[:space:]]*#?PasswordAuthentication' /etc/ssh/sshd_config; then
            sudo sed -i 's/^[[:space:]]*#*PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config
            echo -e "\033[32mPasswordAuthentication 已配置为no\033[0m"
        else
            echo -e "\033[33m警告：未找到PasswordAuthentication配置项\033[0m"
        fi
        
        echo -e "\033[36m配置完成，建议重启ssh服务生效\033[0m"
        continue
    elif [ "$choice" == "7" ]; then
        echo -e "\033[36m正在尝试重启sshd服务...\033[0m"
        if [ "$OS_TYPE" = "Alpine" ]; then
            if sudo rc-service sshd restart > /dev/null 2>&1; then
                echo -e "\033[32m✓ sshd服务重启成功\033[0m"
            else
                echo -e "\033[31m错误：sshd服务重启失败\033[0m"
            fi
        elif [ "$OS_TYPE" = "Ubuntu" ] || [ "$OS_TYPE" = "Debian" ]; then
            if sudo systemctl restart ssh > /dev/null 2>&1; then
                echo -e "\033[32m✓ sshd服务重启成功\033[0m"
            else
                echo -e "\033[31m错误：sshd服务重启失败\033[0m"
            fi
        else
            echo -e "\033[33m⚠ 警告：未识别系统类型，无法确定重启方式\033[0m"
            echo -e "\033[33m建议手动执行：\033[37msudo service sshd restart\033[0m"
        fi
        continue
    elif [ "$choice" == "0" ]; then
        echo "退出脚本"
        exit 0
    else
        echo "输入错误！请输入数字0-7"
    fi
done
