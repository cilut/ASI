#!/bin/bash


# Comprobamos que el numero de parametros
# es el correcto
if [ $# -ne 1 ]
then
	echo "NUMERO DE PARAMETROS INCORRECTO EN FICHERO EN LLAMADA A SCRIPT NIS_SERVER" >&2
	exit 140
fi

#Obtenemos el fichero de configuración que se nos pasa por 
#parametro.
fich_conf_ser=$1

   
nr_lineas=$(cat $fich_conf_ser | wc -l)
if [[ $nr_lineas -ne 1 ]]; then
		echo "ERROR DE FORMATO DE FICHERO DE CONFIRACIÓN: $fich_conf_ser" >&2
        exit 141
else
	
	#Obtenemos el nombre del dominio y comprobamos formato
	nombre_dom=$(head --lines=1 $fich_conf_ser)
	[[ "$nombre_dom" != ?* ]] && 
	echo "ERROR DE FORMATO DE LINEA DONDE SE ESPECIFICA DOMINIO" >&2
	exit 142

	#Realizamos instalacion silenciosa de NIS 
	#apt-get -y install debconf-set-selections > /dev/null
	echo "nis nis/domain string $nombre_dom" > /tmp/nisinfo
	debconf-set-selections /tmp/nisinfo
	apt-get -y install nis    

	#Configuramos dominio de NIS
	domainname $nombre_dom  
	
	#Especificamos el rol de server, modificamos el fichero /etc/default/nis
	sed -e 's/NISSERVER=false/NISSERVER=master/; s/NISCLIENT=true/NISCLIENT=false/' /etc/default/nis > /etc/default/nis.temp
	cat /etc/default/nis.temp > /etc/default/nis
	
	#Modificamos fichero Makefile para que las contraseñas tambien esten en el repositorio
	sed -e 's/MERGE_PASSWD=false/MERGE_PASSWD=true/; s/MERGE_GROUP=false/MERGE_GROUP=true/' /var/yp/Makefile > /var/yp/Makefile.temp
	cat /var/yp/Makefile.temp > /var/yp/Makefile
	
	#Volcamos el la info de configuración al repositorio
	echo "#Ctrl+D\n" | /usr/lib/yp/ypinit -m &> /dev/null

	#Arrancamos el servicio
	service nis start
	echo "-----------------------SERVER NIS UP------------------------"

fi