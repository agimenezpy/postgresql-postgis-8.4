# Instalación de PosgreSQL 8.4 / PostGIS 1.5

## Prerequisitos
Montar la imagen del instalador de arcgis y copiar `ArcSDE Linux 10`

```
$ mount /dev/cdrom /mnt/
$ cp -r /mnt/ArcSDE\ Linux\ 10 ./arcsde/
```

## Crear imagen y contenedor

> PostgreSQL 8.4 for Docker.

```
$ docker build -t postgresql-8.4 .
<snip>

$ docker run -i -p 5432:5432 -v /var/lib/postgresql/:/var/lib/postgresql/ -e POSTGRESQL_USER=sigasu -e POSTGRESQL_PASS=SigMunicipal2016 -e POSTGRESQL_DB=catastro postgresql-8.4 --name sigasu
2014-07-24 21:51:47 UTC LOG:  database system was shut down at 2014-07-24 21:51:47 UTC
2014-07-24 21:51:47 UTC LOG:  autovacuum launcher started
2014-07-24 21:51:47 UTC LOG:  database system is ready to accept connections
```
## Instalar Postgis y SDE 

```
$ docker exec -ti /usr/local/bin/create-postgis
$ docker exec -ti /usr/local/bin/create-sde
```

## Activar SDE

```
$ docker exec -ti /usr/local/bin/install-sde $SDE_LICENCE
```

## Variables de entorno

 - `POSTGRESQL_DB`: Se crea una base de datos. Defecto: `docker`
 - `POSTGRESQL_USER`: Usuario administrador de base de datos especificado en `POSTGRESQL_DB`. Defecto: `docker`
 - `POSTGRESQL_PASS`: La contraseña para `POSTGRESQL_USER`. Defecto: `docker`
 - `SDE_LICENCE`: La licencia de ArcSDE para la instalación. Ejemplo: `arcsdeserver,100,ecp123456789,none,AAABBBCCCDDDEEE11223`
