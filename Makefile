

clean:
	docker rm sigasu 
	docker rmi postgresql-8.4

build:
	docker build -t postgresql-8.4 .

action:
	echo $@
	docker exec sigasu /usr/local/bin/$(action) 

run:
	docker run -i -v /home/agimenez/postgres/:/var/lib/postgresql -p 5432:5432 -e POSTGRESQL_USER=sigasu -e POSTGRESQL_PASS="SigMunicipal2016" -e POSTGRESQL_DB=catastro --name sigasu postgresql-8.4
