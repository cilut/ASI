#!/bin/bash

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
   
 
nr_linea=0;
for nombre_dom in $(cat $fich_conf_ser)
do
	if [ $nr_linea -eq 0 ];
	then
		#Comprabos si esta el formato bien
		[[ "$nombre_dom" != ?* ]] && echo "Formato de linea erroneo" && exit 1
		nr_linea=1

	else
		echo "Error de formato en el fichero de configurccion de mount"
		exit 3
	fi
done
IFS=$oldIFS


#instalamos NIS
apt-get -q -y install nis > /dev/null    
#Consifiguramos dominio
echo $nombre_dom > /etc/defaultdomain  

#Especificamos el rol, modificamos el fichero /etc/default/nis

sed -i 's/NISSERVER=false/NISSERVER=master/'  /etc/default/nis 
sed -i 's/NISCLIENT=true/NISCLIENT=true/'  /etc/default/nis 

#Para que las contraseñas tambien esten el repositorio
sed -i 's/MERGE_PASSWD=false/MERGE_PASSWD=true' /var/yp/Makefile
sed -i 's/MERGE_GROUP=false/MERGE_GROUP=true' /var/yp/Makefile

#Volcamos el la info d econfiguración al erpositorio
/usr/lib/ypinit -m > /dev/null

#Arrancamos el servicio
systemctl restart nis

