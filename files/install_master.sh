sudo apt update
sudo apt install -y mysql-server
sudo mysql < /home/vitorllavor/users.sql
sudo cp -f /home/vitorllavor/mysqld.cnf /etc/mysql/mysql.conf.d/mysqld.cnf
sudo service mysql restart
sleep 20
