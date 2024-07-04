#!/bin/bash
echo "DolphinDB Module Deploy!"
CURRENTIP=`hostname -I | awk '{ print $1 }'`
echo "当前服务器地址: $CURRENTIP"
read -p "需要部署的文件名: " fileName

read -p "是否执行？(Y/N): " confirm && [[ $confirm == [yY] ]] || exit 1

originPath=./${fileName}.dos
echo "originPath:" $originPath

localPath=/home/dolphindb/server/modules
prePath=/home/dolphindb/server/clusterDemo/data
nodePathArr=(/dnode1/modules /dnode2/modules)
remoteAddressArr=(192.168.56.105 192.168.56.106)
remoteUsername=root
remotePassword=xxxx
for((i=0;i < 4;i++))
  do
    curRemoteAddress=${remoteAddressArr[$i]}
    if [ "$curRemoteAddress" == "$CURRENTIP" ]; then
      echo "目标地址1: ${localPath}"
      echo "目标地址2: ${prePath}${nodePathArr[$i]}"
      `cp $originPath ${localPath} -f`
      `cp $originPath ${prePath}${nodePathArr[$i]} -f`
    else
      expect <<EOF
      spawn scp -r $originPath $remoteUsername@${remoteAddressArr[$i]}:${prePath}${nodePathArr[$i]}
      expect {
        "yes/no" { send "yes\n";exp_continue }
        "password" { send "$remotePassword\n" }
      }
      expect eof
      expect <<EOF
        spawn ssh root@${remoteAddressArr[$i]}
        expect {
        "yes/no" { send "yes\n";exp_continue }
        "password" { send "$remotePassword\n" }
        }
      expect "]#" { send "cd /home/dolphindb/server\n" }
      expect "]#" { send "./dolphindb -remoteHost 127.0.0.1 -remotePort 8902 -uid admin -pwd 123456 -run /home/moduleCacheClean.dos\n"}
      expect "]#" { send "exit\n" }
      expect eof
      EOF
    fi
  done