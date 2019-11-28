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

		n_dispositivo=$i
		nr_linea=1

	elif [ $nr_linea -eq 1 ]; 
	then

		p_montaje=$i
		if [ -d "$p_montaje" ]; then
		  # Take action if $DIR exists. #
		  echo "Es un directorio"
		else 
			mkdir "$p_montaje"
			echo "Directorio creado satisfactoriamente"
		fi

		nr_linea=2
	
	else
		echo "Error de formato en el fichero de configurccion de mount"
		exit 3
	fi
done
IFS=$oldIFS

	#Montamos la unidad indicada
	mount -t ext4 $n_dispositivo $p_montaje
	#Introducimos en el fichero /etc/fstab la linea para que se haga el automontaje
	echo "$n_dispositivo	$p_montaje	ext4	defaults	0	0	" >> /etc/fstab