#!/bin/bash
# ss的自动安装脚本,第一次写,写着玩玩
# 

function initEnv
{
        echo "开始更新系统环境..."
        echo "更新软件列表..."
        apt-get update
        echo "升级已有软件..."
        apt-get -y dist-upgrade
        apt-get -y upgrade
        echo "正在移除不需要的软件..."
        apt-get -y autoremove
        echo "正在自动清除不需要的安装包"
        apt-get -y autoclean

}
function mainSetup
{
        echo "正在安装pip和编码包..."
        apt-get -y install python-pip python-m2crypto
        echo "正在升级pip..."
        pip install --upgrade pip
        echo "正在安装setuptools..."
        pip install setuptools
        echo "正在安装shadowsocks主程序..."
        pip install shadowsocks

        echo "开始写ss配置文件..."
        echo -e "{" > /ss.json
        resultVar=$(ifconfig | grep "inet addr" | grep -v "127.0.0.1" | awk '{print $2}' | awk -F ':' '{print $2}')
        echo "获取到的本机ip为:   [$resultVar]"
        echo -e "\t\"server\":\"$resultVar\"," >> /ss.json
        echo -e "\t\"server_port\":8388," >> /ss.json
        echo -e "\t\"local_address\":\"127.0.0.1\"," >> /ss.json
        echo -e "\t\"local_port\":1080," >> /ss.json
        echo -e "\t\"password\":\"FUCKGFW\"," >> /ss.json
        echo -e "\t\"timeout\":300," >> /ss.json
        echo -e "\t\"method\":\"rc4-md5\"" >> /ss.json
        echo -e "}" >> /ss.json
        echo "配置文件编写完毕,启动ssserver..."
        ssserver -c /ss.json -d restart
        echo "设置开机自动启动ssserver...."
        setInitRestart
}

function setInitRestart
{
        if [ -e "/etc/rc.local" ];then
                echo "rc.local已存在..."
                echo "在开机启动项中删除之前的ssserver配置信息..."
                sed -i '/ssserver/'d /etc/rc.local
                echo "查找exit 0的位置..."
                testvar=$(grep -n 'exit 0' /etc/rc.local | grep -v '"exit' | awk -F ':' {'print $1'})
                echo "exit 0 所在位置行数有 : $testvar"
                totalnum=$(echo $testvar | awk '{print NF}')
                echo "exit 0 所在位置共有$totalnum 个"
                linenum=$(echo $testvar | awk "{print \$$totalnum}")
                echo "最后一个exit 0所在位置是第$linenum 行"
                echo "在exit 0之前添加ss启动任务..."
                sed -i "${linenum}c ssserver -c /ss.json -d restart \nexit 0" /etc/rc.local
        else
                echo "rc.local不存在,开始新建rc.local"
                echo -e "#! /bin/bash\nssserver -c /ss.json -d restart\nexit 0" > /etc/rc.local
                chmod 755 /etc/rc.local
        fi
}




echo -e  "\n==============================================================================\n\n 			PPBear SS 自动安装脚本 \n\n==============================================================================\n"
while [ "$answer" != "y" ] && [ "$answer" != "Y" ] && [ "$answer" != "n" ] && [ "$answer" != "N" ]
do

	read -p "本脚本将会在本机上安装ss和其运行需要的部分软件,是否确定需要执行安装?(y/n)   :"  answer
	if [ "$answer" == "y" ] || [ "$answer" == "Y" ];then
		echo -e "\n本脚本将要更新您的系统环境,如果你确定您的系统环境已经足够新,可以选择不更新"
		answer=f
		while [ "$answer" != "y" ] && [ "$answer" != "Y" ] && [ "$answer" != "n" ] && [ "$answer" != "N" ]
		do
			read -p "是否需要更新您的系统环境?(y/n)  :" answer
			if [ "$answer" == "y" ] || [ "$answer" == "Y" ];then
				initEnv
			elif [ "$answer" == "n" ] || [ "$answer" == "N" ];then
				echo "跳过更新系统关紧,直接进入ss相关软件安装..."		
			else
				echo -e "无法识别的命令,请重新输入\n"	
			fi
		done	
                mainSetup
	elif [ "$answer" == "n" ] || [ "$answer" == "N" ];then
		echo "用户选择不安装,脚本退出"
		exit 0
	else 
		echo -e "无法识别的命令,请重新输入 \n"
	fi
	
done

exit 0

