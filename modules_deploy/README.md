# Module 文件部署脚本

由于需要通过 Java 客户端的对外接口输出计算数据，为了利用 DolphinDB 的计算优势，计算方法都封装在 Module 文件中，涉及多节点的时候，Module 文件的部署就需要多节点去上传，此脚本就自动化处理 Module 文件多节点的分发。

## 使用说明

在不改动的脚本的前提下，在服务器的 home 文件夹下新建 moduleDeploy，将 moduleCacheClean.dos 和 run.sh 放入 moduleDeploy 中执行即可

run.sh 中可能需要手动修改的地方，DolphinDB 的路径，节点名称，其他可不用修改

```shell
localPath=/home/dolphindb/server/modules
prePath=/home/dolphindb/server/clusterDemo/data
nodePathArr=(/dnode1/modules /dnode2/modules)
remoteAddressArr=(192.168.56.105 192.168.56.106)
```

localPath: 脚本所在机器的 Module 地址

pePath：用于拼接节点地址

nodePathArr: 节点的路径

remoteAddressArr: 节点的 IP 地址
