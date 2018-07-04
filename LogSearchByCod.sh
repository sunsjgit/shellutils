#!/bin/bash



#定义日志检索的语句条件段的前缀
ComPrefix=""

#定义日志检索的语句条件段的前缀
ComSuffix=""

#定义检索输出文件位置
#targetPath="/home/deploy/data/"
targetPath=""




#定义条件变量池的文件位置，条件变量以行区分
CodPath=""

#参数解释函数
introduction(){
		echo "-p 检索语句前缀 "	
		echo "-s 检索语句后缀 "	
		echo "-t 检索文件存放路径"
		echo "-c 检索语句中条件变量池文件路径，条件以行区分" 
		exit 1
}



#获取参数
while getopts ":p:s:t:c:" opt  
do  
    case $opt in
        p)   
	     ComPrefix="$OPTARG"
        ;;   
        s)   
	     ComSuffix="$OPTARG" 
		;;
        t)  
	     targetPath="$OPTARG"
        ;;
	c)  
	     CodPath="$OPTARG"
        ;;
		?)
		echo "参数错误 请参照以下显示操作"
		introduction
		;;
    esac  
done  





if [ ${#ComPrefix} -lt 1 ];then
	echo "检索前缀不可为空"
	introduction
	exit 1 
elif [ ${#ComSuffix} -lt 1 ];then
	echo "检索后缀不可为空"
	introduction
	exit 1 
elif [ ${#targetPath} -lt 1 ];then
	echo "目标不可为空"
	introduction
	exit 1
elif [ ${#CodPath} -lt 1 ];then
	echo "变量池不可为空"
	introduction
	exit 1
fi



#得到需要查询的ID的总数
CodCount=`sudo cat "$CodPath" | wc -l`


#定义初始位置
i=1



#echo $idcount
#echo $i
#echo $ComPrefix
#echo $ComSuffix



#开始检索
while (($i <= $CodCount))
do
 #获取第i行的ID
 cod=`sudo cat "$CodPath" | awk 'NR=="'$i'"{print $1}'`
 #echo "测试cod >>>>>>>> $cod" 
 #根据检索条件输出结果，并将之存储到指定的csv文件中
 #echo $mycommand
 eval ${ComPrefix} | grep $cod | ${ComSuffix}    >> $targetPath
  let "i++"
done
