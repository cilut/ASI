#!/bin/bash

# Comprobamos que el numero de parametros
# es el correcto
if [ $# -ne 1 ]
then
    echo "NUMERO DE PARAMETROS INCORRECTO EN FICHERO EN LLAMADA A SCRIPT MOUNT" >&2
    exit 110
fi

#Obtenemos el fichero de configuración que se nos pasa por 
#parametro.
fich_conf_ser=$1

#Obtenemos el numero de lineas del fichero de configuración                                                                
nr_lineas=$(cat $fich_conf_ser | wc -l)
if [[ $nr_lineas -ne 2 ]]; then
        echo "ERROR DE FORMATO DE FICHERO DE CONFIRACIÓN: $fich_conf_ser" >&2
        exit 111
else
    #Comprabamos dispositivos
    name_disp=$(head --lines=1 $fich_conf_ser)
    b=${name_disp:5}
    existe=$(lsblk -f | grep -w $b | wc -l) 
    if [[ $exite -eq 1 ]]; then
        echo "ERROR EN ESPECIFICACION DEL DISPOSITIVO A MONTAR" >&2
        exit 112
    fi
    
    #Comprobamos si el dispositivo tiene sistema de ficheros:
    existefs=$(lsblk -f | grep -w $b | grep -w ext4 | wc -l) 
    if [[ $existefs -ne 1 ]]; then
        echo "DAMOS FORMATO AL DISCO"
        echo s | /sbin/mkfs.ext4 $name_disp &> /dev/bin
    fi

    #Comprobamos si el dispositivo ha sido montado previamente.
    montado=$(mount | grep -w $b | wc -l) 
    if [[ $montado -eq 1 ]]; then
        echo "ERROR: ACCION INECESARIA DISPOSITIVO SE ENCUENTRA MONTADO" >&2
        exit 113
    fi                           

    #Generamos el directorio en caso de que no este donde queremos montar
    pto_montaje=$(head --lines=2 $fich_conf_ser | tail --line=1)
    if [[ ! -d $pto_montaje ]];then
            mkdir "$pto_montaje"
    fi

    #Montamos dispisitivo
    mount -t ext4 $name_disp $pto_montaje 

    echo "$name_disp        $pto_montaje    ext4    defaults        0       0       " >> /etc/fstab
    echo "DISPOSITIVO: $name_disp SE HA MONTADO SATISFACTORIAMENTE"

fi

    #Comandos utilies para ver discos duros:
    # sudo lsblk -fm
    # umount -t /dev/nombre_particion_disco