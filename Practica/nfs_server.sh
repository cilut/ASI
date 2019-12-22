#!/bin/bash

#Numero de parametros
if [ $# -ne 1 ]
then
	echo "NUMERO DE PARAMETROS INCORRECTO EN FICHERO EN LLAMADA A SCRIPT NFS_SERVER" >&2
	exit 160
fi

#Comprobar que el fichero pasado como parametro existe
if [ ! -f $1 ]
then
	echo "FICHERO $1 NO ENCONTRADO" >&2
	exit 161
fi

#Numero de lineas debe ser igual o superior a 1
lineas=$(wc -l $1 | mawk '{ print $1 }')
if [ $lineas -lt 1 ] #$(wc -l < $1)
then
	echo "ERROR DE FORMATO DE FICHERO DE CONFIRACIÓN: $1" >&2
	exit 162
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
		echo "$directorio NO ES UN DIRECTORIO" >&2
		exit 163
	fi

	echo "$directorio *(rw,sync,no_subtree_check)" >> /etc/exports
	echo "Directorio $directorio añadido a la lista de exportaciones"

	index=$(($index+1))
done

echo "Reiniciando servidor..."

exportfs -ra > /dev/null

service nfs-kernel-server restart > /dev/null

echo "Directorio/s exportado/s"

exit 0

