#!/bin/bash

# Leemos los parametros de entrada
fich_conf_ser=$1

# Comprobamos que el numero de parametros
# es el correcto
if [ $# -ne 1 ]
then
	echo "			Numero de parametros incorrecto"
	exit 1
fi

	#Almacenamos el valor original de la variable IFS
 oldIFS=$IFS
 #Cambiamos el valor del IFS para que el delimitardor 
 #cambio de linea
 IFS=$'\n'
   
 
nr_linea=0;
for i in $(cat $fich_conf_ser)
do
	if [ $nr_linea -eq 0 ];
	then

		nombre_dispositivo_raid=$i
		nr_linea=1

	elif [ $nr_linea -eq 1 ]; 
	then

		nr_raid=$i
		nr_linea=2
	
	elif [ $nr_linea -eq 2 ]; 
	then

		array_disp=$i
		nr_elementos_array=${#array_disp[*]}
		nr_linea=3
	
	else
		echo "Error de formato en el fichero de configurccion de raid"
		exit 4
	fi
done
IFS=$oldIFS
	
	#Generamos el raid
	mdadm --create --level=$nr_raid --raid-devices=$nr_elementos_array $nombre_dispositivo_raid $array_disp;
	#Hacemos permanete la configuración
	mdadm --detail $nombre_dispositivo_raid --brief >> /etc/mdadm/mdadm.conf;