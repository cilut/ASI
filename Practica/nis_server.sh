#!/bin/bash
set -e
# Leemos los parametros de entrada
fich_conf_ser=$1

# Comprobamos que el numero de parametros
# es el correcto
if [ $# -ne 1 ]
then
	echo "			Numero de parametros incorrecto servicio mount"
	exit 1
fi

	#Almacenamos el valor original de la variable IFS
 oldIFS=$IFS
 #Cambiamos el valor del IFS para que el delimitardor 
 #cambio de linea
 IFS=$'\n'
   
 nr_lineas=$(cat $fich_conf_ser | wc -l)
if [[ $nr_lineas -ne 1 ]]; then
		echo "Formato de fichero de configuración erroneo xd"
		exit 3
else
	echo "nis_server" >  /etc/hostname
	#Porque raya a los chavales, ademas el ticches dijo que era pa parguelas
	#apt-get install -y systemd > /dev/null
	#systemctl disable NetworkManager.service > /dev/null

	nombre_dom=$(head --lines=1 $fich_conf_ser)
	[[ "$nombre_dom" != ?* ]] && echo "Formato de linea erroneo" && exit 1
	#instalamos NIS
	echo "--------------------- INSTALAMOS NIS ---------------------"
	#apt-get -y install debconf-set-selections > /dev/null
	echo "nis nis/domain string $nombre_dom" > /tmp/nisinfo
	debconf-set-selections /tmp/nisinfo
	apt-get -y install nis    

	#Consifiguramos dominio
	echo "----------------- DEFINIMOS DOMINIO NIS ------------------"
	domainname $nombre_dom  
	echo "------------------ MODIFICAMOS FICHERPS -------------------"
	#Especificamos el rol, modificamos el fichero /etc/default/nis
	sed -e 's/NISSERVER=false/NISSERVER=master/; s/NISCLIENT=true/NISCLIENT=false/' /etc/default/nis > /etc/default/nis.temp
	cat /etc/default/nis.temp > /etc/default/nis
	#Para que las contraseñas tambien esten el repositorio
	sed -e 's/MERGE_PASSWD=false/MERGE_PASSWD=true/; s/MERGE_GROUP=false/MERGE_GROUP=true/' /var/yp/Makefile > /var/yp/Makefile.temp
	cat /var/yp/Makefile.temp > /var/yp/Makefile
	#Volcamos el la info d econfiguración al erpositorio
	echo "-------------- VOLVAMOS CONFIGURACION AL REPO ----------"
	echo "#Ctrl+D\n" | /usr/lib/yp/ypinit -m &> /dev/null

	#Arrancamos el servicio
	
	echo "----------------- ARRANCAMOS EL SERVICIO ------------------"
	service nis start
	echo "-----------------------SERV NIS UP------------------------"

fi