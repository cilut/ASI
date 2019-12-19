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
nLineas=$(wc -l $1 | mawk '{ print $1 }')
if [ $nLineas -lt 1 ] #$(wc -l < $1)
then
	echo "Formato de fichero incorrecto" >&2
	exit 2
fi

index=0

#Instalar nfs-common
if [ $(dpkg -l | grep nfs-common | wc -l) -eq 0 ]
then
	echo "Instalando nfs-common"
	apt-get -y -q install nfs-common > /dev/null
	echo "nfs-common se ha instalado"
else
	echo "nfs-common ya se encuentra instalado"
fi

while [ $index -lt $nLineas ]
do
	#Comprobar si la linea tiene tres argumentos
	linea=$(head -n $(($index+1)) $1 | tail -n 1)
	if [ $(wc -w $linea) -ne 3 ]
	then
		echo "Formato de fichero incorrecto en linea $(($index+1))" >&2
		exit 2
	fi
	servidor=$(echo $linea | mawk '{ print $1 }')
	directorio=$(echo $linea | mawk '{ print $2 }')
	montaje=$(echo $linea | mawk '{ print $3 }')

	#Comprobar si el servidor es alcanzable
	ping -c 3 $servidor
	if [ $(echo $?) -ne 0 ]
	then
		echo "Servidor $servidor inalcanzable" >&2
		exit 7
	fi

	#Comprobar si el directorio seleccionado se encuentra en la lista de exportacion del servidor
	if [ $(showmount -e $servidor | grep $directorio | wc -l) -eq 0 ]
	then
		echo "El directorio $directorio no se encuentra en la lista de exportacion del servidor $servidor" >&2
		exit 8
	fi

	#Comprobar si el punto de montaje existe y, en caso negativo, crearlo
	if[ ! -d $directorio ]
	then
		mkdir $directorio
	fi

	#Montaje
	mount -t nfs $servidor:$directorio $montaje > /dev/null

	#Configurar el fichero fstab para que se realice el montaje en el inicio
	echo "$servidor:$directorio montaje nfs defaults" >> /etc/fstab

	echo "El directorio $directorio se ha montado en $montaje"

	index=$(($index+1))
done

exportfs -ra

exit 0