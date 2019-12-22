#!/bin/bash

#Numero de parametros
if [ $# -ne 1 ]
then
	echo "Numero de parametros incorrecto" >&2
	exit 120
fi

#Comprobar que el fichero pasado como parametro existe
if [ ! -f $1 ]
then
	echo "Fichero $1 no encontrado" >&2
	exit 121
fi

#Numero de lineas debe ser igual a 3
if [ $(wc -l $1 | mawk '{ print $1 }') -ne 3 ] #wc -l < $1
then
	echo "Formato de fichero incorrecto" >&2
	exit 122
fi

#Comprobar nivel de raid
nivel=$(head -n 2 $1| tail -n 1)
if [[ $nivel -gt 5 || $nivel -lt 0 ]] 
then
	echo "Nivel de raid incorrecto" >&2
	exit 123
fi

#Comprobar si existe un raid con ese nombre?

#Comprobar si existe sistema de ficheros en los dispositivos? o en el primero solo?

primerDisp=$(tail -n 1 $1 | mawk '{ print $1 }')

if [ $(mount | grep $primerDisp | wc -l) -ne 0 ]
then
	echo "El dispositivo $primerDisp tiene un sistema de ficheros" >&2
	exit 124
fi

#Comprobar que mdadm esta instalado
if [ $(which mdadm | wc -l) -eq 0 ]
then
	echo "Instalando la herramienta mdadm"
	apt-get -y -q install mdadm > /dev/null
	echo "La herramienta mdadm se ha instalado"
else
	echo "La herramienta mdadm ya se encuentra instalada"
fi

nDispositivos=$(tail -n 1 $1 | wc -w)
nombre=$(head -n 1 $1)
dispositivos=$(tail -n 1 $1)

mdadm --create --level=$nivel --raid-devices=$nDispositivos $nombre $dispositivos > /dev/null
exit 0
