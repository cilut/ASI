#!/bin/bash

#Numero de parametros
if [ $# -ne 1 ]
then
	echo "Numero de parametros incorrecto" >&2
	exit 1
fi

#Comprobar que el fichero pasado como parametro existe
if [ ! -f $1 ]
then
	echo "Fichero $1 no encontrado" >&2
	exit 6
fi

#Numero de lineas debe ser igual o superior a 1
lineas=$(wc -l $1 | mawk '{ print $1 }')
if [ $lineas -lt 1 ] #$(wc -l < $1)
then
	echo "Formato de fichero incorrecto" >&2
	exit 2
fi

index=0

#Instalar nfs-kernel-server

if [ $(dpkg -l | grep nfs-kernel-server | wc -l) -eq 0 ]
then
	echo "Instalando nfs-kernel-server"
	apt-get -y -q install nfs-kernel-server > /dev/null
	echo "nfs-kernel-server se ha instalado"
else
	echo "nfs-kernel-server ya se encuentra instalado"
fi

while [ $index -lt $lineas ]
do
	directorio=$(head -n $(($index+1)) $1 | tail -n 1)
	if [ ! -d $directorio ]
	then
		echo "$directorio no es un directorio" >&2
		exit 3
	fi

	echo "$directorio *(rw,sync)" >> /etc/exports
	echo "Directorio $directorio añadido a la lista de exportaciones"

	index=$(($index+1))
done

exportfs -ra

exit 0

