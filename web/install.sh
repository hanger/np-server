#!/bin/bash 
#运行 cd /usr/local/web && ./install.sh

#创建www用户和组
user=www  
group=www  
  
#create group if not exists  
egrep "^$group" /etc/group >& /dev/null  
if [ $? -ne 0 ];then  
    groupadd $group  
fi  
  
#create user if not exists  
egrep "^$user" /etc/passwd >& /dev/null  
if [ $? -ne 0 ];then  
    useradd -g $group $user  
fi 

WEB_SERVICE_PATH="/usr/local/web"

#nginx 启动需要寻找libpcre.so.1,64位系统如果找不到，可以设置一个软链到libpcre.so.0.0.1
libpcreFile="/lib64/libpcre.so.1"
libpcreLinkFile="/lib64/libpcre.so.0.0.1"
if [ ! -f "$libpcreFile" ]; then
	if [ ! -f "$libpcreLinkFile" ]; then
		echo "$libpcreLinkFile not exist"
	else
		ln -s  "$libpcreLinkFile" "$libpcreFile"
		echo "linked $libpcreFile"
	fi
fi

#将libmemcached目录设置到环境变量
libmemcachedPath="$WEB_SERVICE_PATH/libmemcached"
if [[ $LD_LIBRARY_PATH =~ "libmemcached" ]]; then
	echo "libmemcached has been added to LD_LIBRARY_PATH nothing to do"
else
	echo "export LD_LIBRARY_PATH=$libmemcachedPath:$LD_LIBRARY_PATH" >> ~/.bash_profile
	source ~/.bash_profile
	echo "new LD_LIBRARY_PATH  :  $LD_LIBRARY_PATH"
fi

#提示启动命令
echo "install success

start php:   "$WEB_SERVICE_PATH"/php/sbin/php-fpm -D -c "$WEB_SERVICE_PATH"/php/etc/php.ini

start nginx : "$WEB_SERVICE_PATH"/nginx/sbin/nginx
"
echo "php-version :  " 
"$WEB_SERVICE_PATH"/php/bin/php -version
"$WEB_SERVICE_PATH"/nginx/sbin/nginx -v