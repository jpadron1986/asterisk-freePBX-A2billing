#!/bin/bash
#
# Implementacion de servidor de llamadas, asterisk somo server sip
# FreePBX + A2billing para la facturacion y la creacion del sistema
# colling card. Fue creado apra la instalacion en el sistema Centos 7
# por Jorge Padron Salas, System admin software libre, 
# otorgar permisos de +x antes de usar.
# jpadron1986@gmail.com, version 1.0
#

if [[ $EUID -ne 0 ]]; then
	echo -e "Sorry, you need to run this as root"
	exit 1
fi

# Define versions
ASTERISK=11.12.1
A2BILLING=2.2.0
LLAME=3.100
LIBMAD=0.15.1b
SoX=14.4.1
SpanDSP=0.0.6
version=v1.0 

clear
echo "                                                                                                                     ";
echo "@@@@@@@@@@   @@@  @@@  @@@       @@@@@@@  @@@   @@@@@@@  @@@  @@@  @@@@@@@    @@@@@@   @@@@@@@   @@@@@@@   @@@  @@@  ";
echo "@@@@@@@@@@@  @@@  @@@  @@@       @@@@@@@  @@@  @@@@@@@@  @@@  @@@  @@@@@@@@  @@@@@@@@  @@@@@@@@  @@@@@@@@  @@@  @@@  ";
echo "@@! @@! @@!  @@!  @@@  @@!         @@!    @@!  !@@       @@!  @@@  @@!  @@@  @@!  @@@  @@!  @@@  @@!  @@@  @@!  !@@  ";
echo "!@! !@! !@!  !@!  @!@  !@!$version !@!    !@!  !@!       !@!  @!@  !@   @!@  !@!  @!@  !@!  @!@  !@   @!@  !@!  @!!  ";
echo "@!! !!@ @!@  @!@  !@!  @!!         @!!    !!@  !@!       @!@  !@!  @!@!@!@   @!@!@!@!  @!@@!@!   @!@!@!@    !@@!@!   ";
echo "!@!   ! !@!  !@!  !!!  !!!         !!!    !!!  !!!       !@!  !!!  !!!@!!!!  !!!@!!!!  !!@!!!    !!!@!!!!    @!!!    ";
echo "!!:     !!:  !!:  !!!  !!:         !!:    !!:  :!!       !!:  !!!  !!:  !!!  !!:  !!!  !!:       !!:  !!!   !: :!!   ";
echo ":!:     :!:  :!:  !:!   :!:        :!:    :!:  :!:       :!:  !:!  :!:  !:!  :!:  !:!  :!:       :!:  !:!  :!:  !:!  ";
echo ":::     ::   ::::: ::   :: ::::     ::     ::   ::: :::  ::::: ::   :: ::::  ::   :::   ::        :: ::::   ::  :::  ";
echo " :      :     : :  :   : :: : :     :     :     :: :: :   : :  :   :: : ::    :   : :   :        :: : ::    :   ::   ";
echo "                                                                                                                     ";
echo "Servidor de llamadas multicuba Jorge Padron jpadron1986@gmail.com"

if [[ $HEADLESS != "y" ]]; then
	echo ""
	echo "Welcome to the asterisk install script."
	echo ""
	echo "What do you want to do?"
	echo "   1) Install Asterisk"
	echo "   2) install A2billing"
	echo "   3) Update the script"
	echo "   4) Install freePBX, EN PROCESO "
	echo "   5) Exit"
	echo ""
	while [[ $OPTION != "1" && $OPTION != "2" && $OPTION != "3" && $OPTION != "4" && $OPTION != "5" ]]; do
		read -rp "Select an option [1-5]: " OPTION
	done
fi
case $OPTION in
1) # Dependencies
    yum update -y
	yum upgrade -y
    yum install -y libvorbis libvorbis-devel vorbis-tools libogg libogg-devel ntp curl curl-devel libidn-devel \
    gcc ncurses-devel make gcc-c++ mingw64-termcap-static zlib-devel libtool bison-devel bison openssl-devel \
    bzip2-devel wget newt-devel subversion flex gtk2-devel net-tools mariadb mariadb-server mariadb-devel \
    unixODBC unixODBC-devel mysql-connector-odbc libtool-ltdl-devel sqlite sqlite-devel festival festival-devel \
    hispavoces-pal-diphone hispavoces-sfl-diphone libuuid libuuid-devel uuid uuid-devel speex speex-devel wavpack \
    wavpack-devel libtiff libtiff-devel libxml2 libxml2-devel gnutls gnutls-devel gnutls-utils iksemel iksemel-devel \
    compat-openldap openldap openldap-clients openldap-devel openldap-servers net-snmp net-snmp-devel net-snmp-libs \
    net-snmp-utils libical libical-devel neon neon-devel libsrtp libsrtp-devel php php-gd php-mysql php-process httpd\
    mod_ssl php-cli php-soap php-xml php-mcrypt git libass-devel yasm
	
	cd /usr/src || exit 1
	wget https://iweb.dl.sourceforge.net/project/lame/lame/3.100/lame-3.100.tar.gz
    tar -xf lame-3.100.tar.gz
	cd lame-3.100 || exit 1
	./configure --prefix=/usr --libdir=/usr/lib64/
	make
	make install
	
	cd /usr/src || exit 1
	wget http://prdownloads.sourceforge.net/mad/libmad-$LIBMAD.tar.gz
    tar -xf libmad-$LIBMAD.tar.gz
	cd libmad-$LIBMAD || exit 1
	./configure --prefix=/usr --libdir=/usr/lib64/
    sed -i "129s/.*/CFLAGS = -Wall -g -O -fforce-addr -fthread-jumps -fcse-follow-jumps -fcse-skip-blocks -fexpensive-optimizations -fregmove -fschedule-insns2/" "Makefile"
	make
	make install
	
	cd /usr/src || exit 1
	wget http://downloads.sourceforge.net/project/sox/sox/14.4.1/sox-$SoX.tar.gz
    tar -xf sox-$SoX.tar.gz
	cd sox-$SoX || exit 1
	./configure --prefix=/usr --libdir=/usr/lib64/
	make
	make install

	cd /usr/src || exit 1
	wget wget http://www.soft-switch.org/downloads/spandsp/spandsp-0.0.6pre21.tgz
    tar -xf spandsp-0.0.6pre21.tgz
	cd spandsp-$SpanDSP || exit 1
	./configure --prefix=/usr --libdir=/usr/lib64/
	make
	make install
    
	cd /usr/src || exit 1
	wget http://downloads.asterisk.org/pub/telephony/asterisk/old-releases/asterisk-$ASTERISK.tar.gz
    tar -xf asterisk-$ASTERISK.tar.gz
	cd asterisk-$ASTERISK || exit 1
	./configure --libdir=/usr/lib64
    make menuselect
    contrib/scripts/get_mp3_source.sh
	make
	make install
    make samples

	echo -e "[Unit] \
	\nDescription=Asterisk PBX \
	\nDocumentation=man:asterisk(8) \
	\nWants=network-online.target \
	\nAfter=network-online.target \
	\n \
	\n[Service] \
	\nExecStart=/usr/sbin/asterisk -g -f \
	\nExecReload=/usr/sbin/asterisk -rx 'core reload' \
	\nRestart=always \
	\nRestartSec=1 \
	\nWorkingDirectory=/usr/sbin \
	\n \
	\n[Install] \
	\nWantedBy=multi-user.target" >> /usr/lib/systemd/system/asterisk.service
	
    systemctl enable asterisk

    # We're done !
	echo "Asterisk instalado"
	exit
	route -n;;

2)  # instalar A2billing
    sed -i "878s/.*/date.timezone = America/New_York/" "/etc/php.ini" 
    sed -i "800s/.*/upload_max_filesize = 8M/" "/etc/php.ini"
    sed -i "461s/.*/error_reporting = E_ALL & ~E_NOTICE/" "/etc/php.ini"

	cd /usr/src || exit 1
	wget https://github.com/Star2Billing/a2billing/archive/v2.2.0.tar.gz
    tar -xf v2.2.0.tar.gz
	mv a2billing-2.2.0 a2billing
	cd a2billing || exit 1
	sed -i "11s/.*/    "adodb/adodb-php": "v5.20.0",/" "composer.json"
    sed -i "11s/.*/            "version": "v5.20.0",/" "composer.lock"
	curl -sS https://getcomposer.org/installer | php
	php composer.phar update
	php composer.phar install

	systemctl start mariadb.service
	systemctl enable mariadb.service

	mysql -u root -e create database a2billing;
	mysql -u root -e GRANT ALL PRIVILEGES ON a2billing.* TO 'a2user'@'localhost' IDENTIFIED BY '123456789';
    mysql -u root -e flush privileges;
	cd DataBase/mysql-5.x/
	./install-db.sh
	cd /usr/src/a2billing/addons/sounds/
	./install_a2b_sounds.sh
	cp /usr/src/a2billing/a2billing.conf /etc/
    sed -i "10s/.*/port = 3306/" "/etc/a2billing.conf" 
    sed -i "11s/.*/user = a2user/" "/etc/a2billing.conf"
	sed -i "12s/.*/password = 123456789/" "/etc/a2billing.conf"
	sed -i "13s/.*/dbname = a2billing/" "/etc/a2billing.conf"
	sed -i "15s/.*/dbtype = mysql/" "/etc/a2billing.conf"

	touch /etc/asterisk/additional_a2billing_iax.conf
	touch /etc/asterisk/additional_a2billing_sip.conf
	chown apache:apache /etc/asterisk/additional_a2billing_iax.conf
	chown apache:apache /etc/asterisk/additional_a2billing_sip.conf

	sed -i "24s/.*/enabled=yes/" "/etc/asterisk/manager.conf" 
	sed -i "43s/.*/allowmultiplelogin=yes/" "/etc/asterisk/manager.conf"
	sed -i "46s/.*/dislplayconnects=yes/" "/etc/asterisk/manager.conf"

	echo -e "\n \n[myasterisk] \
	\nsecret=mycode \
	\ndeny=0.0.0.0/0.0.0.0 \
	\npermit=127.0.0.1/255.255.255.255 \
	\nread = system,call,log,verbose,agent,user,config,dtmf,reporting,cdr,dialplan \
	\nwrite = system,call,agent,user,config,command,reporting,originate" >> /etc/asterisk/manager.conf


	cd /usr/src/a2billing/AGI
	ln -s /usr/src/a2billing/AGI/a2billing.php /var/lib/asterisk/agi-bin/a2billing.php
	ln -s /usr/src/a2billing/AGI/a2billing_monitoring.php /var/lib/asterisk/agi-bin/a2billing_monitoring.php
	ln -s /usr/src/a2billing/AGI/lib /var/lib/asterisk/agi-bin/lib
	chmod +x /var/lib/asterisk/agi-bin/a2billing.php
	chmod +x /var/lib/asterisk/agi-bin/a2billing_monitoring.php
	mkdir /var/www/html/a2billing
	mkdir -p /var/lib/a2billing/script
	mkdir -p /var/run/a2billing
	ln -s /usr/src/a2billing/admin/ /var/www/html/a2billing/admin
	ln -s /usr/src/a2billing/agent/ /var/www/html/a2billing/agent
	ln -s /usr/src/a2billing/customer/ /var/www/html/a2billing/customer
	ln -s /usr/src/a2billing/common/ /var/www/html/a2billing/common
	chmod 775 /usr/src/a2billing/admin/templates_c
	chmod 775 /usr/src/a2billing/customer/templates_c
	chmod 775 /usr/src/a2billing/agent/templates_c
	chown -Rf apache:apache /var/www/html
	chown -Rf apache:apache /var/www/html/a2billing/admin/
	chown -Rf apache:apache /var/www/html/a2billing/agent/
	chown -Rf apache:apache /var/www/html/a2billing/customer/
	chown -Rf apache:apache /var/www/html/a2billing/common/
	mkdir /var/log/a2billing
	cd /var/log/a2billing
	touch cront_a2b_alarm.log cront_a2b_autorefill.log cront_a2b_batch_process.log \
	cront_a2b_archive_data.log cront_a2b_bill_diduse.log cront_a2b_subscription_fee.log \
	cront_a2b_currency_update.log cront_a2b_invoice.log cront_a2b_check_account.log \
	a2billing_paypal.log a2billing_epayment.log a2billing_api_ecommerce_request.log \
	a2billing_api_callback_request.log a2billing_api_card.log a2billing_agi.log
	chown apache:apache *

	echo "0 6 * * * php /usr/src/a2billing/Cronjobs/currencies_update_yahoo.php" >> /etc/crontab
	echo "0 6 1 * * php /usr/src/a2billing/Cronjobs/a2billing_subscription_fee.php" >> /etc/crontab
	echo "0 * * * * php /usr/src/a2billing/Cronjobs/a2billing_notify_account.php" >> /etc/crontab
	echo "0 2 * * * php /usr/src/a2billing/Cronjobs/a2billing_bill_diduse.php" >> /etc/crontab
	echo "0 12 * * * php /usr/src/a2billing/Cronjobs/a2billing_batch_process.php" >> /etc/crontab
	echo "0 6 * * * php /usr/src/a2billing/Cronjobs/a2billing_batch_billing.php" >> /etc/crontab
	echo "# */5 * * * * php /usr/src/a2billing/Cronjobs/a2billing_batch_autodialer.php" >> /etc/crontab
	echo "0 * * * * php /usr/src/a2billing/Cronjobs/a2billing_alarm.php" >> /etc/crontab
	echo "0 12 * * * php /usr/src/a2billing/Cronjobs/a2billing_archive_data_cront.php" >> /etc/crontab
	echo "0 6 1 * * php /usr/src/a2billing/Cronjobs/a2billing_autorefill.php" >> /etc/crontab
	systemctl restart crond

	sed -i "1151s/.*/externaddr=207.246.114.220/" " /etc/asterisk/sip.conf"
	sed -i "1152s/.*/externaddr=localnet=172.31.0.0/255.255.0.0/" " /etc/asterisk/sip.conf"

	echo "#include additional_a2billing_iax.conf" >> /etc/asterisk/iax.conf
	mv /etc/asterisk/extensions.conf /etc/asterisk/extensions.conf.old

	echo -e "[general] \nstatic = yes \nwriteprotect = no \nautofallthrough = yes \
	\nextenpatternmatchnew = true \nclearglobalvars = no \nuserscontext=default" >> /etc/asterisk/extensions.conf 
	
	echo -e "[globals] \n; Variables globales" >> /etc/asterisk/extensions.conf 
	echo -e "[a2billing] \nexten => _X.,1,NoOp(A2Billing Start) \nsame => n,Agi(a2billing.php,1) \
	\nsame => n,Hangup \nexten => h,1,Hangup" >> /etc/asterisk/extensions.conf


	sed -i "18s/.*/preload => res_odbc.so/" " /etc/asterisk/modules.conf"
	sed -i "19s/.*/preload => res_config_odbc.so/" " /etc/asterisk/modules.conf"
	sed -i "1151s/.*/externaddr=207.246.114.220/" " /etc/asterisk/modules.conf"
	sed -i "1151s/.*/externaddr=207.246.114.220/" " /etc/asterisk/modules.conf"

	echo -e "\nnoload => pbx_lua.so \nnoload => pbx_ael.so" >> /etc/asterisk/modules.conf 

	mv /etc/odbcinst.ini /etc/odbcinst.old
	echo -e "[MySQL] \nDescription = ODBC for MySQL \nDriver = /usr/lib64/libmyodbc5.so \
	\nSetup = /usr/lib64/libodbcmyS.so \nFileUsage = 1" >> /etc/odbcinst.ini 
	
	echo -e "[a2billing] \
	\nDescription = MySQL a2billing \
	\nDriver = MySQL \
	\nDatabase = a2billing \
	\nServer = localhost \
	\nUser = a2user \
	\nPassword = 123456789
	\nPort = 3306 \
	\nOption = 3" >> /etc/odbc.ini

	sed -i "77s/.*/iaxusers => odbc,a2b,cc_iax_buddies/" " /etc/asterisk/extconfig.conf"
	sed -i "78s/.*/iaxpeers => odbc,a2b,cc_iax_buddies/" " /etc/asterisk/extconfig.conf"
	sed -i "79s/.*/sippeers => odbc,a2b,cc_sip_buddies/" " /etc/asterisk/extconfig.conf"

	echo -e "[a2b] \
	\nenabled => yes \
	\ndsn => a2billing \
	\nusername => a2user \
	\npassword => 123456789 \
	\npre-connect => yes \
	\nsanitysql => select 1 \
	\nidlecheck => 3600 \
	\nconnect_timeout => 10" >> /etc/asterisk/res_odbc.conf

	systemctl restart asterisk
	systemctl enable httpd
	
	# We're done !
	echo "dependencias instaladas."
	exit
route -n;;


5)
break
echo "INSTALACION COMPLETADA CON EXITO QUE TENGA UN BUEN DÍA"
;;
esac
