### oducharles Web System

Portfolio website for oducharles:


### Installation and Set Up

1. clone the repo  
	`git clone git@github.com:vendors-point/oducharles.git`

2. cd into your project folder, e.g oducharles  
	`cd oducharles`

3. create the .env file from `.env.example`   
    `cp .env.example .env`

4. proceed to build the docker app image and start the containers   
    `sudo docker compose --profile=dev up -d --build`

5. confirm all docker containers are up and running   
    `sudo docker compose ps`

6. at this point, you should be able to load and access the system on your favorite web browser using   
    `http:://localhost:7058`

7. If you get permission error, run the following command on your host machine   
	`sudo docker compose exec -i ocl-site chown -R www-data:www-data /site/storage /site/bootstrap/cache`  



## Setup the system to run behind a Reverse Proxy

**Pre-requisite:** Importantly, first setup the devops environment using instructions on [this repo](https://github.com/vendors-point/devops) separately, then continue with the steps below. (checkout the on-off-switch branch)

9. Copy the reverse proxy complete configured config file from `docker/.reverse-proxy/` directory

	`cp docker/.reverse-proxy/docker-compose.reverse-proxy.yml docker-compose.yml`

	or optionally, do the steps below: -

	+ back in this project folder (oducharles), open the docker configuration of this project
		`sudo nano docker-compose.yml`

	+ uncomment the following lines under the `networks` directive by removing the preceeding `#`   
	
		```
		networks:
		  oducharles_system_network:
		  # proxy_network:
		  #    name: frontend_network
		  #    external: true
		``` 
		And under `oducharles-nginx` (the Webserver Service), look for and uncomment the line
		`# - proxy_network` 


10. Test the configurations by running the comand.   
	`sudo docker compose config`   
	
	Please NOTE: Ensure proper indentation of the content of the `docker-compose.yml`. The command above will complain if indentation is not right.

11. Restart all container
	```
	sudo docker compose down
	sudo docker compose up -d

	In production server, run this instead
	sudo docker compose -f docker-compose.yml -f compose.prod.yml up -d --build
	```


12. confirm all docker containers are up and running   
	`sudo docker compose ps`


13. If you followed the **pre-requsite devops setup** correctly, you should be able to access the system behind a reverse proxy on your favourite browser using
	`oducharles.local`



### Copyright

This system is copyrighted to [oducharles](https://oducharles.lsmig1936.org.ug).
