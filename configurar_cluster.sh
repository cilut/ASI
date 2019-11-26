#!/bin/bash

# Leemos los parametros de entrada
fichero_configuracion=$1

# Comprobamos que el numero de parametros
# es el correcto
if [ $# -ne 1 ]
then
	echo "Numero de parametros incorrecto o nombre de fichero_configuracion incorrecto"
	exit 1
fi
# Vemos que servicios debemos ejecutar



#Almacenamos el valor original de la variable IFS
 oldIFS=$IFS
 #Cambiamos el valor del IFS para que el delimitardor 
 #cambio de linea
 IFS=$'\n'
   

for i in $(cat $fichero_configuracion)
do

	case $i in
		"#"* )
			echo "	Linea contiene comentario";;
		?*?" "?*?" "?*? )
			IFS=$oldIFS;
			echo "Linea leida:"$i;
			echo $i | while read n_maquina n_servicio fich_conf_ser; 
			do
				echo "	Maquina: " $n_maquina
				echo "	Servicio: " $n_servicio
				echo "	fich_conf_ser: " $fich_conf_ser
			
				#Todos los comandos ./xxxxxx son scripts propios
				case $n_servicio in
					"mount")	
						echo "		Vamos a montar una el dispositivo";
						./mount.sh $n_maquina $fich_conf_ser;;
					"raid")
						echo "		Vamo a hacer un raid to wapo";
						./raid.sh $n_maquina $fich_conf_ser;;
					"lvm")
						echo "		Vamos a hacer algo con LVM jajaja xd";
						./lvm.sh $n_maquina $fich_conf_ser;;
					"nis_server")
						echo "		Vamos a conf un servidor NIS";
						./nis_server.sh $n_maquina $fich_conf_ser;;
					"nis_client")
						echo "		Vamos a conf un cliente NIS";
						./nis_cliente.sh $n_maquina $fich_conf_ser;;
					"nfs_server")
						echo "		Vamos a conf un servidor NFS";
						./nfs_server.sh $n_maquina $fich_conf_ser;;	
					"nis_client")
						echo "		Vamos a conf un cliente NFS";
						./nfs_client.sh $n_maquina $fich_conf_ser;;
					"backup_server")
						echo "		Vamos a conf un servidor backup";
						./backup_server.sh $n_maquina $fich_conf_ser;;	
					"backup_client")
						echo "		Vamos a conf un cliente backup";
						./backup_client.sh $n_maquina $fich_conf_ser;;
					?*)
						echo "	ESE SERVICIO NO EXISTE PARAGUELAS: " $n_servicio
				esac;	
			done
			IFS=$'\n';;

		?* )
			echo "Error formato: a"$i;
			exit 2;;
	esac
done
IFS=$oldIFS

