#!/bin/bash
# /usr/bin/mysqld_safe > /dev/null 2>&1 &

RET=1
while [[ RET -ne 0 ]]; do
	echo "=> Waiting for confirmation of MySQL service startup"
	sleep 5
	/usr/bin/mysql -uroot -e "status" > /dev/null 2>&1
	RET=$?
done

/usr/bin/mysql -uroot -e "CREATE USER 'root'@'%' IDENTIFIED BY ''"
/usr/bin/mysql -uroot -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION"
# /usr/bin/mysqladmin -uroot shutdown
