#! /bin/bash

username="deploy"  # 用户名
ip="127.0.0.1" # IP地址
port="22"	# 端口号
n=5   # times 
b=20  # b M size
my_times=1; # 循环条件
seconds=0;  # 总时间
speed=0;	# 上传速度


#获取参数
while getopts ":m:i:p:n:b:" opt  
do  
    case $opt in
        m)   
	     username="$OPTARG"
        ;;   
        i)   
	echo $OPTARG|grep "^[0-2]\?[0-9]\?[0-9]\{1\}\.[0-2]\?[0-9]\?[0-9]\{1\}\.[0-2]\?[0-9]\?[0-9]\{1\}\.[0-2]\?[0-9]\?[0-9]\{1\}$" > /dev/null
	if [ $? -eq 1 ];then 
             echo error ip,please enter correct
	     exit 1
	else
	     ip="$OPTARG"
	fi
        ;;  
        p)  
	echo $OPTARG|grep "^[0-9]\{1,5\}$" > /dev/null
	if [ $? -eq 1 ];then 
             echo error port,please enter correct
	     exit 1
	elif [ $OPTARG -gt 65535 ];then
	     echo error port,please enter correct
	     exit 1
	else
	     port="$OPTARG"
	fi
        ;;  
        n)   
	echo $OPTARG|grep "^[0-9]\+$" > /dev/null
	if [ $? -eq 1 ];then 
             echo error times,please enter correct
	     exit 1
	else
	     n="$OPTARG"
	fi
        ;;
	b)
	echo $OPTARG|grep "^[0-9]\+$" > /dev/null
	if [ $? -eq 1 ];then 
             echo error size,please enter correct
	     exit 1
	else
	     b="$OPTARG"
	fi
	;;
	?)
	echo "参数错误 请参照以下显示操作"
	printf;
	echo "-m 输入用户名(默认为deploy)"	
	echo "-i 输入IP地址(默认为127.0.0.1)"
	echo "-p 输入端口号(默认为22)" 
	echo "-n 输入发送次数(默认为5)" 
	echo "-b 输入发送文件大小(默认为20M)"
	exit 1;;
   
    esac  
done  

#创建需要跨域复制的测试文件
`dd if=/dev/zero of=/tmp/zerofile bs=1M count="$b"`
#循环复制 并进行时间计算
while (( $my_times <= $n ))
do
echo "第$my_times次上传测试中..."

(time scp -P "$port" /tmp/zerofile  "$username"@"$ip":/tmp/) 2> /tmp/a.txt
second=$(cat /tmp/a.txt | grep "real"|tail -n 1|awk '{print $2}' | awk 'BEGIN{FS="."}{print $1}' | awk 'BEGIN{FS="m"}{print $1*60+$2}')  
sleep 1
let "seconds+=second"
let "my_times++"
done
#echo $b  $n $seconds
#计算上传速度
if [ $seconds -eq 0 ];then
	echo "上传速度过快,所用时间为小于1ms 无法计算"
	exit 1
else
	speed=$(printf "%.2f" `echo "scale=2; $b*$n/$seconds" | bc`)
	#speed=$(echo $b $n $seconds | awk '{ printf "%0.2f\n" ,$1*$2/$3}')
fi

echo Spped is $speed"MB/s"

#删除本地创建的测试文件
`rm /tmp/zerofile`
