#!/bin/bash

#Numero de parametros
if [ $# -ne 1 ]
then
	echo "NUMERO DE PARAMETROS INCORRECTO EN FICHERO EN LLAMADA A SCRIPT NFS_CLIENT" >&2
	exit 170
fi

#Comprobar que el fichero pasado como parametro existe
if [ ! -f $1 ]
then
	echo "FICHERO $1 NO ECONTRADO" >&2
	exit 171
fi

#Numero de lineas debe ser igual o superior a 1
nLineas=$(wc -l $1 | mawk '{ print $1 }')
if [ $nLineas -lt 1 ] #$(wc -l < $1)
then
	echo "ERROR DE FORMATO DE FICHERO DE CONFIGURACIÓN: $1" >&2
	exit 172
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
	if [ $(echo "$linea" | wc -w ) -ne 3 ]
	then
		echo "FORMATO DE FICHERO ERRONEO EN LINEA: $(($index+1))" >&2
		exit 173
	fi
	servidor=$(echo $linea | mawk '{ print $1 }')
	directorio=$(echo $linea | mawk '{ print $2 }')
	montaje=$(echo $linea | mawk '{ print $3 }')

	#Comprobar si el servidor es alcanzable
	echo "Contactando con el servidor $servidor"
	ping -c 3 $servidor > /dev/null
	if [ $(echo $?) -ne 0 ]
	then
		echo "Servidor $servidor inalcanzable" >&2
		exit 174
	fi

	#Comprobar si el directorio seleccionado se encuentra en la lista de exportacion del servidor
	if [ $(showmount -e $servidor | grep $directorio | wc -l) -eq 0 ]
	then
		echo "El directorio $directorio no se encuentra en la lista de exportacion del servidor $servidor" >&2
		exit 175
	fi

	#Comprobar si el punto de montaje existe y, en caso negativo, crearlo
	if [ ! -d $montaje ]
	then
		echo "Creando el directorio $montaje"
		mkdir $montaje
	fi

	#Montaje
	mount -t nfs $servidor:$directorio $montaje > /dev/null

	#Configurar el fichero fstab para que se realice el montaje en el inicio
	echo "$servidor:$directorio $montaje nfs defaults" >> /etc/fstab

	echo "El directorio $directorio se ha montado en $montaje"

	index=$(($index+1))
done

exit 0
