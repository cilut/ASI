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

nr_lineas=$(cat fich_conf_ser | wc -l)
if [[ nr_lineas -le 2 ]]; then
		echo "Formato de fichero de configuración erroneo xd"
		exit 3
else
		#Comprabos si esta el formato bien de la primera linea
		n_grupo=$(head --lines=1 $fich_conf_ser)
		[[ "$n_grupo" != ?* ]] && echo "Formato de linea erroneo" && exit 11
		
		#-------------------------------------------------------------------------
		#Pillamos la linea de dispositivos, y si estan disponibles para ser usados
		array_disp=$(head --lines=2 $fich_conf_ser | tail --line=1)
		for j in $array_disp; 
		do
			b=${j:5:3}
			lsblk -f | grep -w $b 
			if [ $? -eq 1 ]; then
				echo "No existe el dispositivo indicado"
				exit 5
			fi
			#Comprabamos dispositivos
			b=${name_disp:5:3}
			#Comprabamos si esta en el sistema
			existe=$(lsblk -f | grep -w $b | wc -l) 
			if [[ $exite -eq 1 ]]; then
			    echo "Dispositivo no esta en nuestro sistema"
			    exit 5
			fi
			#Comprobamos si teien formato
			existefs=$(lsblk -f | grep -w $b | grep -w ext4 | wc -w) 
			if [[ $existefs -eq 1 ]]; then
			    echo "Damos formato"
			    echo s | /sbin/mkfs.ext4 $name_disp
			fi
			#Comprobamos si esta montado
			montado=$(mount | grep -w $b | wc -l) 
			if [[ $montado -eq 1 ]]; then
			    echo "Disco montado previamente"
			    exit 6
			fi        
		done
		salida=$?;
		if [[ $salida -ne  ]]; then
			exit $salida
		fi
		#-------------------------------------------------------------------------
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
		read a a tam_grupo a <<< $(vgdisplay grupo | grep -w "VG Size")  
		
		#-------------------------------------------------------------------------
		#Creamos los volumnes logicos que toquen
		nr_lineas=$(($nr_lineas-2))
		v_logicos=$(tail --linea=nrlienas fich_conf_ser)
		for i in v_logicos 
		do
			[[ "$i" != ?*" "[0-9]*"GB" ]] && echo "Formato de linea erroneo" && exit 1 
			read name_vlogico size_vlogico <<< $i 
			suma_vol=$(($suma_vol+$size_vlogico))
			if [[ $suma_vol -lt $tam_grupo ]]; then
				lvcreate --name $name_vlogico --size $size_vlogico grupo
			fi
		done
fi
