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
		echo "ERROR DE FORMATO DE FICHERO DE CONFIRACIÓN: $fich_conf_ser" >&2
        exit 151
else
		
		nombre_dom=$(head --lines=1 $fich_conf_ser)
		[[ "$nombre_dom" != ?* ]] &&
		echo "ERROR DE FORMATO DE LINEA DONDE SE ESPECIFICA DOMINIO" >&2
		exit 152
		
		#Realizamos instalacion silenciosa de NIS 
		#apt-get -y install debconf-set-selections > /dev/null
		echo "nis nis/domain string $nombre_dom" > /tmp/nisinfo
		debconf-set-selections /tmp/nisinfo
		apt-get -y install nis     
		
		#Consifiguramos dominio NIS
		domainname $nombre_dom


		#Especificamos el server en /etc/yp.conf
				servidor_nis=$(head --lines=2 $fich_conf_ser |tail --lines=1)
		echo "ypserver $nombre_dom server $servidor_nis" >> /etc/yp.conf

		#Configuramos las contraseñas
		sed -e 's/passwd:         compat/passwd:         compat nis/; s/group:          compat/group:          compat nis/;' /etc/nsswitch.conf > /etc/nsswitch.tmp
		cat /etc/nsswitch.tmp > /etc/nsswitch.conf

		#Arrancamos el servicio
		service nis start
		echo "-----------------------CLIENTE NIS UP------------------------"
fi
