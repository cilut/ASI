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
tam_grupo=0;
suma_vol=0;
for i in $(cat $fich_conf_ser)
do
	if [ $nr_linea -eq 0 ];
	then
		#Comprabos si esta el formato bien
		
		nr_linea=1

	elif [ $nr_linea -eq 1 ]; 
	then
		#Pillamos la linea de dispositivos y vamos si son dispositivos 
		array_disp=$i
		IFS=$oldIFS;
		echo "Linea leida:"$i;
		for j in $i; 
		do
			lsblk -fm | grep -w $name_disp 
			if [ $? -eq 1 ]; then
				echo "No existe el dispositivo indicado"
				exit 5
			fi
		done
		
		#Comprobamos que estan el programa lvm_tool instalado
		#Inicializamos volumenes fisicos
		pvcreate array_disp
		salida=$?
		if [[ salida -eq 127 ]]; then
			apt-get update > /dev/null
			apt-get -force-yes install lvm2 > /dev/null 

			#Inicializamos volumnes fisicos
			pvcreate array_disp
		fi
		#Creamos grupo de volumnes logicos
		vgcreate grupo array_disp
		vgdisplay grupo | grep -w "VG Size" | while read a a tam a 
			do 
				echo $tam_grupo
		done;
		nr_linea=2
		IFS=$'\n'
	elif [ $nr_linea -eq 2 ]
	then
		[[ "$i" != ?*" "[0-9]*"GB" ]] && echo "Formato de linea erroneo" && exit 1 
		
		#Creamos los volumnes logicos que toquen
		IFS=$oldIFS;
		echo $i | while read name_vlogico size_vlogico; 
			do
			suma_vol=$(($suma_vol+$size_vlogico))
			if [[ $suma_vol -lt $tam_grupo ]]; then
				lvcreate --name $name_vlogico --size $size_vlogico grupo
			fi
			
		done	
		IFS=$'\n'
	else
		echo "Error de formato en el fichero de configurccion de mount"
		exit 3
	fi
done
IFS=$oldIFS








mdadm --create --level=$nr_raid --raid-devices=$nr_elementos_array $nombre_dispositivo_raid $array_disp;	
salida=$?
if [[ salida -eq  127 ]]; then
	apt-get update >/dev/null
	apt-get -q --force-yes install mdadm > /dev/null

	#Generamos el raid
	mdadm --create --level=$nr_raid --raid-devices=$nr_elementos_array $nombre_dispositivo_raid $array_disp;
	salida=$?
	if [ salida -eq 2 ]; then
		echo "Dispositivos indicados para la creacion usados o nombre incorrecto"
		exit $salida
	else
		echo "Array generado satisfactoriamente"
			#Hacemos permanete la configuración
		mdadm --detail $nombre_dispositivo_raid --brief >> /etc/mdadm/mdadm.conf
	fi
else
	echo "Array generado satisfactoriamente"
	#Hacemos permanete la configuración
	mdadm --detail $nombre_dispositivo_raid --brief >> /etc/mdadm/mdadm.conf
fi

