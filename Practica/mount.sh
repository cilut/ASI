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

		name_disp=$i
		lsblk -fm | grep -w $name_disp
		if [ $? -eq 1 ]; then
			echo "No existe el dispositivo indicado"
			exit 5
		fi
		nr_linea=1

	elif [ $nr_linea -eq 1 ]; 
	then

		pto_montaje=$i
		nr_linea=2
	
	else
		echo "Error de formato en el fichero de configurccion de mount"
		exit 3
	fi
done
IFS=$oldIFS
	#Generamos el directorio en caso de que no este donde queremos montar

	if [ -d $pto_montaje ];then
	  	echo "Directorio existe"
	else 
		mkdir "$p_montaje"
		echo "Directorio creado satisfactoriamente"
	fi

	#Intentamos montar dispositivo
	mount -t ext4 $name_disp $pto_montaje &>/dev/bin
	salida=$?
	if [ $salida -eq 0 ];then
		#Introducimos en el fichero /etc/fstab la linea para que se haga el automontaje
		#ya que el montaje se ha realizado correctamente
		echo "$name_disp	$pto_montaje	ext4	defaults	0	0	" >> /etc/fstab
		echo "Dispositivo montado"
	elif [ $salida -eq 32 ]; then
		echo "Dispositivo montado previamente"
	else
		#Le damos formato al disco, la 's' es para que se le de a sí
		#porque si vamos a hace una unica particion
		echo s | /sbin/mkfs.ext4 $name_disp
		mount -t ext4 $name_disp $pto_montaje 
		echo "$name_disp	$pto_montaje	ext4	defaults	0	0	" >> /etc/fstab
		echo "Dispositivo montado"
		
	fi



	#Comandos utilies para ver discos duros:
	# sudo lsblk -fm
	# umount -t /dev/nombre_particion_disco