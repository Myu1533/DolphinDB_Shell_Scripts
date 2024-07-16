#!/bin/bash
echo "DolphinDB Module Deploy!"
CURRENTIP=`hostname -I | awk '{ print $1 }'`
echo "当前服务器地址: $CURRENTIP"
echo "请选择部署方式:"
echo "1. 本机部署"
echo "2. 本机及远程部署"
read -p "输入选择: " choice

read -p "需要部署的文件名: " fileName

read -p "现在执行？(Y/N): " confirm && [[ $confirm == [yY] ]] || exit 1

originPath=./${fileName}.dos
echo "originPath:" $originPath

localPath=/home/dolphindb/server/modules
prePath=/home/dolphindb/server/clusterDemo/data
nodePathArr=(/dnode1/modules /dnode2/modules)
remoteAddressArr=(192.168.56.105 192.168.56.106)
remoteUsername=root
remotePassword=root@1234

if [ "$choice" == "1" ]; then
# 本机文件复制
echo "本机地址1: ${localPath}"
echo "当前节点列表："
echo "1. dnode1"
echo "2. dnode2"
read -p "请选择本机节点: " nodeIndex
echo "本机地址2: ${prePath}${nodePathArr[$nodeIndex-1]}"
`cp $originPath ${localPath} -f`
`cp $originPath ${prePath}${nodePathArr[$nodeIndex-1]} -f`
cd /home/dolphindb/server/
./dolphindb -remoteHost 127.0.0.1 -remotePort 8902 -uid admin -pwd 123456 -run /home/moduleDeploy/moduleCacheClean.dos
cd /home/moduleTest
else
for((i=0;i < ${#remoteAddressArr[*]};i++))
do
curRemoteAddress=${remoteAddressArr[$i]}
if [ "$curRemoteAddress" == "$CURRENTIP" ]; then
# 本机文件复制
echo "本机地址1: ${localPath}"
echo "本机地址2: ${prePath}${nodePathArr[$i]}"
`cp $originPath ${localPath} -f`
`cp $originPath ${prePath}${nodePathArr[$i]} -f`
cd /home/dolphindb/server/
./dolphindb -remoteHost 127.0.0.1 -remotePort 8902 -uid admin -pwd 123456 -run /home/moduleDeploy/moduleCacheClean.dos
cd /home/moduleDeploy
else
# 远程环境文件复制
# scp Module文件到指定服务器
expect <<EOF
spawn scp -r $originPath $remoteUsername@${remoteAddressArr[$i]}:${prePath}${nodePathArr[$i]}
expect "password" { send "$remotePassword\n" }
expect eof
spawn scp -r $originPath $remoteUsername@${remoteAddressArr[$i]}:${localPath}
expect "password" { send "$remotePassword\n" }
expect eof    
# scp module缓存清理文件到指定服务器  
spawn scp -r ./moduleCacheClean.dos $remoteUsername@${remoteAddressArr[$i]}:/home/moduleDeploy
expect "password" { send "$remotePassword\n" } 
expect eof  
# 登录指定服务器，执行module缓存清理，以便在线更新module文件
spawn ssh ${remoteUsername}@${remoteAddressArr[$i]}
expect "password" { send "$remotePassword\n" }
expect "]#" { send "cd /home/dolphindb/server\n" }
expect "]#" { send "./dolphindb -remoteHost 127.0.0.1 -remotePort 8902 -uid admin -pwd 123456 -run /home/moduleDeploy/moduleCacheClean.dos\n"}
expect "]#" { send "exit\n" }  
expect eof
EOF
fi
done
fi