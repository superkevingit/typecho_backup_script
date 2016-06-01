#!/bin/bash

################################
# 作用：TE备份脚本。将数据库和usr目录备份打包。
# 版本：1.0, 2016-05-31
# 作者：www.bitbite.cn
# 用法：假如typecho安装在/path/to/yoursite.com/，那么执行“./backup_typecho.sh /path/to/yoursite.com”即可开始备份，
#       备份结果放在$backup_dir/yoursite.com目录下。使用时注意给$backup_dir目录添加写入权限。
################################
backup_dir="/home/pi/Backup/"
function print_help(){
	echo 'Usage: $shell dir_to_typecho'
}

function die(){
	test -z "$1" || echo "$1"
	exit 1
}

function parse_db(){
	config_file=$2
	db_key=$1
	cat "$config_file" | grep -A 6 '$db' | grep '=>' | grep "$db_key" | awk -F "'" '{print $4}'
}


if [ "$#" -lt "1" ] 
then
	print_help
	exit 1
fi
te_dir="$1"
backup_dir="$backup_dir`basename "$te_dir"`"

#判断备份时间是否过频
min_time="43200" #12H
flag="/tmp/last_backup_typecho_`echo $te_dir | md5sum | awk '{print $1}'`"
last_backup="0"
test -f $flag && last_backup="`ls -l --time-style=+%s "$flag" | awk '{print $6}'`"
delta_time=$(expr "`date +%s`" - "$last_backup")

test "$delta_time" -lt "$min_time" && die "Time from last backup is less then $min_time, skip this time"


#初始化变量
te_config="$te_dir/config.inc.php"
#te_usr_dir="$te_dir/usr"
te_usr_dir="$te_dir"

#初始化环境
test -f "$te_config" || die "Can not find config file: $te_config"
test -d "$backup_dir" || mkdir -p "$backup_dir" || die "Can not create backup dir"

db_host=$(parse_db 'host' "$te_config")
db_port=$(parse_db 'port' "$te_config")
db_user=$(parse_db 'user' "$te_config")
db_pass=$(parse_db 'password' "$te_config")
db_name=$(parse_db 'database' "$te_config")

#备份数据库
echo "Found database config: host=$db_host, port=$db_port, user=$db_user, pass=**** and database=$db_name"
echo 'Try to dump database....'
dump_target='/tmp/database.sql';
test -f "$dump_target" && rm "$dump_target"
mysqldump -h"$db_host" -P"$db_port" -u"$db_user" -p"$db_pass" "$db_name" > "$dump_target"
echo 'Dump done.'

#备份usr目录
echo "Try to tar usr dir..."
tar_target="/tmp/user.tar.gz"
test -f "$tar_target" && rm "$tar_target"
tar czvf "$tar_target" "$te_usr_dir"
echo "Tar done."

echo "Try to pack..."
md5sum "$dump_target" > "$dump_target.md5sum"
md5sum "$tar_target" > "$tar_target.md5sum"
backup_file="$backup_dir/`basename "$te_dir"`.`date +%s`.tar.gz"
tar czvf "$backup_file" "$dump_target" "$dump_target.md5sum" "$tar_target" "$tar_target.md5sum"

#清理临时文件
rm $tar_target
rm "$tar_target.md5sum"
rm $dump_target
rm "$dump_target.md5sum"

touch "$flag"
echo "Backup to $backup_file done."
