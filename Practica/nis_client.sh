#!/bin/bash


# Comprobamos que el numero de parametros
# es el correcto
if [ $# -ne 1 ]
then
	echo "NUMERO DE PARAMETROS INCORRECTO EN FICHERO EN LLAMADA A SCRIPT LVM" >&2
	exit 140
fi

# Leemos los parametros de entrada
fich_conf_ser=$1
   
 
nr_lineas=$(cat $fich_conf_ser | wc -l)
if [[ $nr_lineas -ne 1 ]]; then
		echo "Formato de fichero de configuración erroneo xd"
		exit 3
else
		
		nombre_dom=$(head --lines=1 $fich_conf_ser)
		[[ "$nombre_dom" != ?* ]] && echo "Formato de linea erroneo" && exit 1
		
		#Porque raya a los chavales, ademas el ticches dijo que era pa parguelas
		#apt-get install -y systemd > /dev/null
		#systemctl disable NetworkManager.service > /dev/null
	
		#instalamos NIS
		#Instalacion silencisa, sin interacion: https://juraboy.wordpress.com/2011/08/04/silent-install-of-nis-on-ubuntu/

		echo "--------------------- INSTALAMOS NIS ---------------------"
		#apt-get -y install debconf-set-selections > /dev/null
		echo "nis nis/domain string $nombre_dom" > /tmp/nisinfo
		debconf-set-selections /tmp/nisinfo
		apt-get -y install nis     
		#Consifiguramos dominio
		echo "----------------- DEFINIMOS DOMINIO NIS ------------------"
		domainname $nombre_dom


		#Especificamos el server en /etc/yp.conf
		echo "------------------ ESPECIFICAMOS SERVER -------------------"
		servidor_nis=$(head --lines=2 $fich_conf_ser |tail --lines=1)
		echo "ypserver $nombre_dom server $servidor_nis" >> /etc/yp.conf

		#Configramos las contraseñas
		echo "------------------ MODIFICAMOS FICHEROS -------------------"
		sed -e 's/passwd:         compat/passwd:         compat nis/; s/group:          compat/group:          compat nis/;' /etc/nsswitch.conf > /etc/nsswitch.tmp
		cat /etc/nsswitch.tmp > /etc/nsswitch.conf
		#Arrancamos el servicio
		echo "----------------- ARRANCAMOS EL SERVICIO ------------------"
		service nis start
		echo "-----------------------SERV NIS UP------------------------"
fi
