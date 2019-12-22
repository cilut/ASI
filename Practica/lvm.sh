#!/bin/bash

# Comprobamos que el numero de parametros
# es el correcto
if [ $# -ne 1 ]
then
	echo "NUMERO DE PARAMETROS INCORRECTO EN FICHERO EN LLAMADA A SCRIPT LVM" >&2
	exit 130
fi

#Obtenemos el fichero de configuración que se nos pasa por 
#parametro.
fich_conf_ser=$1

 

nr_lineas=$(cat $fich_conf_ser | wc -l)
if [[ $nr_lineas -le 2 ]]; then
		echo "ERROR DE FORMATO DE FICHERO DE CONFIRACIÓN: $fich_conf_ser" >&2
        exit 131
else
	#Comprobamos formato de la primea linea
	n_grupo=$(head --lines=1 $fich_conf_ser)
	if [[ "$n_grupo" != ?* ]]; then
		echo "ERROR DE FORMATO DE LINEA DONDE SE ESPECIFICA NOMBRE DE GRUPO: $n_grupo" >&2
		exit 132
	fi
	
	#Comprobamos cada dispositivo para ver si se puede usar
	array_disp=$(head --lines=2 $fich_conf_ser | tail --line=1)
	for j in $array_disp; 
	do
		#Comprabamos dispositivos
		b=${j:5}
		#Comprabamos si esta en el sistema
		existe=$(lsblk -f | grep -w $b | wc -l) 
		if [[ $exite -eq 1 ]]; then
		    echo "ERROR EN ESPECIFICACION DEL DISPOSITIVO A UTILIZAR PARA CREAR GRUPO LOGICO" >&2
    		exit 133
		fi
		pertenece_vlogico=$(lsblk -f | grep -w "$b" | grep -w "LVM2_member" | wc -w) 
		if [[ $pertenece_vlogico -eq 1 ]]; then
		    echo "ERROR YA QUE EL DISPOSITIVO: \"$j\" YA PERTENECE A UN VOLUMEN LOGICO " >&2
			exit 134    
		fi
		#Comprobamos si teien formato
		
		existefs=$(lsblk -f | grep -w "$b" | grep -w "ext4" | wc -w) 
		if [[ $existefs -eq 0 ]]; then
		    echo s | /sbin/mkfs.ext4 $j &>/dev/null

		fi
		#Comprobamos si esta montado
		montado=$(mount | grep -w $b | wc -l) 
		if [[ $montado -eq 1 ]]; then
		    echo "ERROR: NO PODEMOS USER DISPOSITIVO SE ENCUENTRA MONTADO" >&2
    		exit 135
		fi        
	done

	#En caso de que nos hayamos salido del bucle por un error lo notificaremos
	#al scrip principal
	salida = $?;	
	if[[ $salida -ne 0 ]]; then
		exit $salida
	fi

	#Comprobamos que estan el programa lvm_tool instalado
	#intentando inicializar los volumenes fisicos
	pvcreate $array_disp

	if [[ $? -eq 127 ]]; then
		apt-get update > /dev/null
		apt-get -q --force-yes install lvm2 > /dev/null 

		#Inicializamos volumnes fisicos
		pvcreate $array_disp
	fi
	#Creamos grupo de volumnes logicos
	vgcreate $n_grupo $array_disp
	read a a tam_grupo a <<< $(vgdisplay $n_grupo | grep -w "VG Size")  
	
	#Creamos los volumnes logicos que toquen
	tam_grupo=${tam_grupo:0:-3} 
	nr_lineas=$(($nr_lineas-2))

	#Var auxiliar para llevar la cuenta espacio usado
	suma_vol=0
	
	while [[ $nr_lineas -gt 0 ]]; do

		#Obtenemos la linea que corresponda	
		v_logicos=$(tail --lines=$nr_lineas $fich_conf_ser | head --lines=1)
		
		#Comprobamos el formato de la linea
		[[ "$v_logicos" != ?*" "[0-9]*"GB" ]] && 
		echo "ERROR DE FORMATO DE LINEA EN FICHERO DE CONFIRACIÓN: $i" >&2 && 
		exit 136 
		
		read name_vlogico size_vlogico <<< $v_logicos 
		size_vlogico=${size_vlogico:0:-2} 
		suma_vol=$(($suma_vol+$size_vlogico))
		
		#Creamos el volumen logico
		if [[ $suma_vol -lt $tam_grupo ]]; then
			lvcreate --name $name_vlogico --size $size_vlogico $n_grupo
		else
			echo "ERROR: ESPACIO INSUFICIENTE EN DISCOS PARA ATENDER SOLICITUD"
			exit 137
		fi
		nr_lineas=$(($nr_lineas-1))
	done
	#En caso de que nos hayamos salido del bucle por un error lo notificaremos
	#al scrip principal
	if[[ $? -ne 0 ]]; then
		exit $salida
	fi
	
fi
	##Para eliminar volumnes logicos:
	#lvremove /dev/nombre_grupo_vol/software /dev/nombre_grupo_vol/user
	#vgremove nombre_grupo_vol
	#pvremove /dev/sdb /dev/sdc
