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
				#Para cada servicio vamos a seguir el siguiente orden:
				#	Copiamos carpeta Practica a maquina destino
				#	Ejecutamos en maquina de destino			
				
				case $n_servicio in
					"mount")	
						echo "		Vamos a montar una el dispositivo";
						scp mount.sh root@$n_maquina:.;
						scp $fich_conf_ser root@$n_maquina:.;
						ssh root@$n_maquina ./mount.sh $fich_conf_ser;
						ssh root@$n_maquina rm mount.sh;
						ssh root@$n_maquina rm $fich_conf_ser;;

						
					"raid")
						echo "		Vamo a hacer un raid to wapo";
						scp raid.sh root@$n_maquina:.;
						scp $fich_conf_ser root@$n_maquina:.;
						scp mdadm-4.1.tar.gz root@$n_maquina:.;
						ssh root@$n_maquina ./raid.sh $fich_conf_ser;;
						
					"lvm")
						echo "		Vamos a hacer algo con LVM jajaja xd";
						scp lvm.sh root@$n_maquina:.;
						scp $fich_conf_ser root@$n_maquina:.;
						ssh root@$n_maquina ./lvm.sh $fich_conf_ser;; 

					"nis_server")
						echo "		Vamos a conf un servidor NIS";
						scp $fich_conf_ser practicas@$n_maquina:.;
						scp nis_server.sh practicas@$n_maquina:.;
						ssh practicas@$n_maquina ./nis_server.sh $fich_conf_ser;;
					"nis_client")
						echo "		Vamos a conf un cliente NIS";
						scp $fich_conf_ser practicas@$n_maquina:.;
						scp nis_client.sh practicas@$n_maquina:.;
						ssh practicas@$n_maquina ./nis_client.sh $fich_conf_ser;;
					"nfs_server")
						echo "		Vamos a conf un servidor NFS";
						scp $fich_conf_ser practicas@$n_maquina:.;
						scp nfs_server.sh practicas@$n_maquina:.;
						ssh practicas@$n_maquina ./nfs_server.sh $fich_conf_ser;;	
					"nis_client")
						echo "		Vamos a conf un cliente NFS";
						scp $fich_conf_ser practicas@$n_maquina:.;
						scp nfs_client.sh practicas@$n_maquina:.;
						ssh practicas@$n_maquina ./nfs_client.sh $fich_conf_ser;;
					"backup_server")
						echo "		Vamos a conf un servidor backup";
						scp $fich_conf_ser practicas@$n_maquina:.;
						scp backup_server.sh practicas@$n_maquina:.;
						ssh practicas@$n_maquina ./backup_server.sh $fich_conf_ser;;	
					"backup_client")
						echo "		Vamos a conf un cliente backup";
						scp $fich_conf_ser practicas@$n_maquina:.;
						scp backup_client.sh practicas@$n_maquina:.;
						ssh practicas@$n_maquina ./backup_client.sh $fich_conf_ser;;
					?*)
						echo "	ESE SERVICIO NO EXISTE PARAGUELAS: " $n_servicio;;
				esac;	
			done
			IFS=$'\n';;

		?* )
			echo "Error formato: "$i;
			exit 2;;
	esac
done
IFS=$oldIFS

