#!/bin/bash
set -e

#Modificamos IFS para que en lso bucles el delimitador sea
#el cambio de línea no los espacios. Guardando su valor para
#restablecerlo posteriormente.
	oldIFS=$IFS
	IFS=$'\n'


# Comprobamos que el numero de parametros es el correcto.
if [ $# -ne 1 ]
then
	echo "NUMERO DE PARAMETROS INCORRECTO EN FICHERO EN LLAMADA A SCRIPT PRINCIPAL" >&2
	exit 200
fi

#Obtenemos el fichero de configuración que se nos pasa por 
#parametro.
fichero_configuracion=$1

   
#Recorremos el fichero linea por linea, y nos ayudaremos
#nos ayudaremos de los scripts auxiliares para la realización
#de la tarea.
for i in $(cat $fichero_configuracion)
do

	case $i in
		"#"* )
			echo "	Linea contiene comentario";;
		?*" "?*" "?* )
			
			read n_maquina n_servicio fich_conf_ser <<< $i
			#Todos los comandos ./xxxxxx son scripts propios
			#Para cada servicio vamos a seguir el siguiente orden:
			#	Copiamos script y fichero de configuracion a maquina 
			#	destino
			#	Ejecutamos en maquina de destino
			#	Eliminamos script y fichero de configuración de 
			#	maquina destino			
			scp "$n_servicio\.sh" root@$n_maquina:. >> /dev/null;
			scp $fich_conf_ser root@$n_maquina:. >> /dev/null;
			ssh root@$n_maquina ./"$n_servicio\.sh" $fich_conf_ser ;
			ssh root@$n_maquina rm "$n_servicio\.sh";
			ssh root@$n_maquina rm $fich_conf_ser;;
		?* )
			echo "ERROR DE FORMATO DE LINEA EN FICHERO DE CONFIRACIÓN: $i" >&2;
			exit 201;;
	esac
done
IFS=$oldIFS

