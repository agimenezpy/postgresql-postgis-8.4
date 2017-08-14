FROM ubuntu:14.04

RUN sed -i 's/deb-src /#deb-src /g' /etc/apt/sources.list 
RUN apt-get update && apt-get install -y wget 
#&& apt-get install -y software-properties-common
#RUN add-apt-repository ppa:ubuntugis/ubuntugis-unstable

ADD pgdg.list /etc/apt/sources.list.d/pgdg.list
RUN wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -

# Install Postgres
#RUN apt-get -qq update && LC_ALL=en_US.UTF-8 DEBIAN_FRONTEND=noninteractive apt-get install -y -q postgresql-8.4 postgresql-8.4-postgis-2.0
RUN apt-get -qq update && LC_ALL=en_US.UTF-8 DEBIAN_FRONTEND=noninteractive apt-get install -y -q postgresql-8.4 libpq5=8.4.22-1.pgdg14.04+1 libpq-dev=8.4.22-1.pgdg14.04+1 postgresql-server-dev-8.4=8.4.22-1.pgdg14.04+1

# Install Postgis
RUN LC_ALL=en_US.UTF-8 DEBIAN_FRONTEND=noninteractive apt-get install -y -q build-essential libgeos-dev libgeos-c1 libproj-dev libjson-c-dev libxml2-dev libxml2-utils xsltproc docbook-xsl docbook-mathml 

RUN wget http://download.osgeo.org/postgis/source/postgis-1.5.8.tar.gz -P /tmp && tar xfvz /tmp/postgis-1.5.8.tar.gz -C /tmp/
RUN cd /tmp/postgis-1.5.8 && ./configure && make && make install && ldconfig && rm -rf /tmp/postgis*

# Install SDE Deps
RUN LC_ALL=en_US.UTF-8 DEBIAN_FRONTEND=noninteractive apt-get install -y -q libmotif3 libcrypto++9 libssl0.9.8 libxp6 
RUN wget http://old-releases.ubuntu.com/ubuntu/pool/universe/g/gcc-3.4/libg2c0_3.4.6-6ubuntu5_amd64.deb -P /tmp/ && \
    wget http://old-releases.ubuntu.com/ubuntu/pool/universe/g/gcc-3.4/gcc-3.4-base_3.4.6-6ubuntu5_amd64.deb -P /tmp/ && \
   sudo dpkg -i /tmp/libg2c0_3.4.6-6ubuntu5_amd64.deb /tmp/gcc-3.4-base_3.4.6-6ubuntu5_amd64.deb 

## SDE FILES
COPY "arcsde/pg_64/arcsde/02.tar" /tmp/

RUN SDE_BASE_DIR=/opt/arcsde && mkdir -p $SDE_BASE_DIR && \
    tar -xf /tmp/02.tar -C $SDE_BASE_DIR && \
    ln -s /lib/x86_64-linux-gnu/libssl.so.0.9.8  /usr/lib/libssl.so.6 && \
    ln -s /lib/x86_64-linux-gnu/libcrypto.so.0.9.8 /usr/lib/libcrypto.so.6 && \
    ln -s /usr/lib/x86_64-linux-gnu/libldap_r-2.4.so.2.8.3 /usr/lib/libldap_r-2.3.so.0 && \
    cp $SDE_BASE_DIR/sdeexe100/pg841_st_lib/libst_raster_pg.so /usr/lib/postgresql/8.4/lib/ && \
    cp $SDE_BASE_DIR/sdeexe100/pg841_st_lib/st_geometry.so /usr/lib/postgresql/8.4/lib/ && \
    rm -rf /tmp/02.tar

# /etc/ssl/private can't be accessed from within container for some reason
# (@andrewgodwin says it's something AUFS related)
RUN mkdir /etc/ssl/private-copy; mv /etc/ssl/private/* /etc/ssl/private-copy/; rm -r /etc/ssl/private; mv /etc/ssl/private-copy /etc/ssl/private; chmod -R 0700 /etc/ssl/private; chown -R postgres /etc/ssl/private

## Add over config files
ADD postgresql.conf /etc/postgresql/8.4/main/postgresql.conf
ADD pg_hba.conf /etc/postgresql/8.4/main/pg_hba.conf
RUN chown postgres:postgres /etc/postgresql/8.4/main/*.conf
ADD init-postgresql /usr/local/bin/init-postgresql
ADD create-postgis /usr/local/bin/create-postgis
ADD create-sde /usr/local/bin/create-sde
ADD install-sde /usr/local/bin/install-sde
RUN chmod +x /usr/local/bin/init-postgresql /usr/local/bin/create-postgis /usr/local/bin/create-sde /usr/local/bin/install-sde


VOLUME ["/var/lib/postgresql"]
EXPOSE 5432

CMD ["/usr/local/bin/init-postgresql"]
