# typecho_backup

typecho数据库和usr目录备份及上传云盘脚本

## 使用方式

### 自定义参数

* $backup_dir参数在backup_typecho.sh文件中设置

* backup_cron.sh 脚本文件路径

* cronwork 脚本文件路径

### 运行方式

>直接执行脚本
 
假如typecho安装在/path/to/yoursite.com/，那么执行“./backup_typecho.sh /path/to/yoursite.com”即可开始备份，

备份结果放在$backup_dir/yoursite.com目录下。使用时注意给$backup_dir目录添加写入权限。


> 使用cronwork定时执行