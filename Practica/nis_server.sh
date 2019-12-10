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
for i in $(cat $fich_conf_ser)
do
	if [ $nr_linea -eq 0 ];
	then
		#Comprabos si esta el formato bien
		[[ "$i" != ?* ]] && echo "Formato de linea erroneo" && exit 1
		nr_linea=1

	else
		echo "Error de formato en el fichero de configurccion de mount"
		exit 3
	fi
done
IFS=$oldIFS








