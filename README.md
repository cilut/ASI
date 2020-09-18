# ASI

Este repositorio es para el desarrollo de la practicas de la asignatura Administración de Sistemas.

Configurar clouster es el script principal. Para conseguir que realice la función esperada se procede de la siguiente manera:
•	Se comprueba que el número de argumentos esperados (1) sea el recibido, si no lo es se responde con error código 100.
•	Se comprueba que la maquina deseada es alcanzable y se puede conectar a través de ssh, si no es así, el programa termina con un exit status 101.
•	Se comprueba que el nombre del servicio es correcto, si es erróneo se responde con exit status 102.
•	Se comprueba el formato del fichero de configuración auxiliar, si es erróneo se responde con exit status 103.
•	Se copian ambos ficheros en la máquina remota. 
•	Se ejecuta el servicio y si no es correcta la ejecución se responde con exit status 104.
•	Si el formato es correcto se ejecuta el script asociado a cada línea, si no se responde con exit status 105.
*Si cualquiera de los comandos que termina de forma errónea hace terminar la ejecución del script. Sucederá de forma análoga en los scripts auxiliares asociados a cada servicio.

