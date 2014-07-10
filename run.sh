# sable
sudo docker.io run --detach --publish 53:53 --publish 53:53/udp --publish 80:80 --publish 3306:3306 --publish 9001:9001 --publish 22 --volume /home/jake/code/sites:/www --name lamp --env IP=192.168.1.4 --env TLD=squeaker github.com/300brand/docker-lampstack
