#!/bin/bash

#Numero de parametros
if [ $# -ne 1 ]
then
	echo "NUMERO DE PARAMETROS INCORRECTO EN FICHERO EN LLAMADA A SCRIPT RAID" >&2
	exit 120
fi

nr_lineas=$(cat $1 | wc -l)
#Numero de lineas debe ser igual a 3
if [ $nr_lineas -ne 3 ] 
then
	echo "ERROR DE FORMATO DE FICHERO DE CONFIRACIÓN: $1" >&2
	exit 122
fi

#Comprobar nivel de raid
nivel=$(head -n 2 $1| tail -n 1)
if [[ $nivel -gt 5 || $nivel -lt 0 || $nivel -eq 2 || $nivel -eq 3 ]] 
then
	echo "ERROR EN ESPECIFICACION DE NIVEL DE RAID" >&2
	exit 123
fi

#Comprobar si existe sistema de ficheros en los dispositivos

primerDisp=$(tail -n 1 $1 | mawk '{ print $1 }')

if [ $(mount | grep $primerDisp | wc -l) -ne 0 ]
then
	echo "ERROR: DISPOSITIVO SE ENCUENTRA MONTADO NO PUEDE SER UTILIZADO" >&2
	exit 124
fi

#Comprobar que mdadm esta instalado
if [ $(which mdadm | wc -l) -eq 0 ]
then
	echo "Instalando la herramienta mdadm"
	apt-get -y -q install mdadm &> /dev/null
	echo "La herramienta mdadm se ha instalado"
else
	echo "La herramienta mdadm ya se encuentra instalada"
fi

nDispositivos=$(tail -n 1 $1 | wc -w)
nombre=$(head -n 1 $1)
dispositivos=$(tail -n 1 $1)

echo yes | mdadm --create --level=$nivel --raid-devices=$nDispositivos $nombre $dispositivos &> /dev/null
echo "RAID: $nombre SE HA CREADO SATISFACTORIAMENTE"
