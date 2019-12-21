#!/bin/bash
set -e
# Leemos los parametros de entrada
fich_conf_ser=$1

# Comprobamos que el numero de parametros
# es el correcto
if [ $# -ne 1 ]
then
    echo "NUMERO DE PARAMETROS INCORRECTO EN FICHERO EN LLAMADA A SCRIPT PRINCIPAL" >&2
    exit 101
fi

        #Almacenamos el valor original de la variable IFS
 oldIFS=$IFS
 #Cambiamos el valor del IFS para que el delimitardor
 #cambio de linea
 IFS=$'\n'



                                                                
nr_lineas=$(cat $fich_conf_ser | wc -l)
if [[ nr_lineas -ne 2 ]]; then
        echo "Formato de fichero de configuración erroneo xd"
        exit 3
else
    name_disp=$(head --lines=1 $fich_conf_ser)
    #Comprabamos dispositivos
    b=${name_disp:5:3}
    #Comprabamos si esta en el sistema
    existe=$(lsblk -f | grep -w $b | wc -l) 
    if [[ $exite -eq 1 ]]; then
        echo "Dispositivo no esta en nuestro sistema"
        exit 5
    fi
    #Comprobamos si teien formato
    existefs=$(lsblk -f | grep -w $b | grep -w ext4 | wc -w) 
    if [[ $existefs -eq 1 ]]; then
        echo "Damos formato"
        echo s | /sbin/mkfs.ext4 $name_disp
    fi
    #Comprobamos si esta montado
    montado=$(mount | grep -w $b | wc -l) 
    if [[ $montado -eq 1 ]]; then
        echo "Disco montado previamente"
        exit 6
    fi                           

    #Generamos el directorio en caso de que no este donde queremos montar
    pto_montaje=$(head --lines=2 $fich_conf_ser | tail --line=1)
    if [ -d $pto_montaje ];then
            echo "Directorio existe"
    else

            mkdir "$pto_montaje"
            echo "Directorio creado satisfactoriamente"
    fi

    #Intentamos montar dispositivo
    mount -t ext4 $name_disp $pto_montaje &>/dev/bin
    echo "$name_disp        $pto_montaje    ext4    defaults        0       0       " >> /etc/fstab
    echo "Dispositivo montado"

    #Comandos utilies para ver discos duros:
    # sudo lsblk -fm
    # umount -t /dev/nombre_particion_disco
fi