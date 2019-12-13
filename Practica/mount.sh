#!/bin/bash

# Leemos los parametros de entrada
fich_conf_ser=$1

# Comprobamos que el numero de parametros
# es el correcto
if [ $# -ne 1 ]
then
        echo "                  Numero de parametros incorrecto servicio mount"
        exit 1
fi

        #Almacenamos el valor original de la variable IFS
 oldIFS=$IFS
 #Cambiamos el valor del IFS para que el delimitardor
 #cambio de linea
 IFS=$'\n'


nr_linea=0
pto_montaje=0 
name_disp=0
salida=0
for i in $(cat $fich_conf_ser)
do
    if [ $nr_linea -eq 0 ];
    then
        name_disp=$i
        nr_linea=1
    elif [ $nr_linea -eq 1 ];
    then
        pto_montaje=$i
        nr_linea=2

    else
        echo "Error de formato en el fichero de configurccion de mount"
        exit 3
    fi
done


#Comprobamos si el fichero de configuración tine el formato correcto
if [[ $nr_linea -ne 2 ]]; then                                                                    
    echo "Error de formato en el fichero de configurccion de mount"                           
    exit 3                                                                            
fi                                                                  

#Comprabamos dispositivos
b=${name_disp:5:3}
#Comprabamos si esta en el sistema
existe=$(lsblk -f | grep -w $b | wc -w) 
if [[ $exite -eq 1 ]]; then
    echo "Dispositivo no esta en nuestro sistema"
    exit 5
fi
#Comprobamos si teien formato
existefs=$(lsblk -f | grep -w ext4 | wc -w) 
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
IFS=$oldIFS
        #Generamos el directorio en caso de que no este donde queremos montar

        if [ -d $pto_montaje ];then
                echo "Directorio existe"
        else

                mkdir "$pto_montaje"
                echo "Directorio creado satisfactoriamente"
        fi

        #Intentamos montar dispositivo
        mount -t ext4 $name_disp $pto_montaje &>/dev/bin
        salida=$?
        if [ $salida -eq 0 ];then
                #Introducimos en el fichero /etc/fstab la linea para que se haga el automo$     
                #ya que el montaje se ha realizado correctamente

                echo "$name_disp        $pto_montaje    ext4    defaults        0       0       " >> /etc/fstab
                echo "Dispositivo montado"
        else
                #Le damos formato al disco, la 's' es para que se le de a sí
                #porque si vamos a hace una unica particion
                mount -t ext4 $name_disp $pto_montaje
                echo "$name_disp        $pto_montaje    ext4    defaults        0       0       " >> /etc/fstab
                echo "Dispositivo montado"

        fi



        #Comandos utilies para ver discos duros:
        # sudo lsblk -fm
        # umount -t /dev/nombre_particion_disco
