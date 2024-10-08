# Docker Compose

## Table of Contents

1. [Requirements](#requirements)
2. [Run the composition - MAGIC WAY](#run-the-composition-magic-way)
3. [Run the composition - LONG WAY](#run-the-composition-long-way)
4. [Configure your system](#configure-your-system)
5. [Insights](#Insights)

## Requirements

In order to execute the run script you need:

* docker-compose

Installation example in Ubuntu:

```
sudo apt install docker-compose
```

For docker-compose you can also [see here](https://docs.docker.com/compose/install/other/).

## Run the composition MAGIC WAY

Enter in `Docker-compose` directory and run `run-docker-compose.sh`:
```bash
cd Docker-compose
./run-docker-compose.sh
```
The script make the directories for local mounts, copy all required files in right directory and start a full demo with test and Service providers

* Satosa-saml2spid is published with nginx frontend on https://localhost
* Mongo Espress is published on http://localhost:8081
* Django SAML2 SP is published on https://localhost:8000
* Spid-samlcheck is published on https://localhost:8443

More details ad start option are avable on [run-docker-compose.sh](../docs/run-docker-compose.sh.md) page

### Run the composition LONG WAY

Enter in `Docker-compose` directory and make required direcotries for local mounts:
```bash
cd Docker-compose
mkdir -p ./mongo/db          # DB Data directory
mkdir -p ./satosa-project    # Satosa-saml2spid data istance
mkdir -p ./djangosaml2_sp    # Service provider directory
mkdir -p ./nginx/html/static # static files for nginx
```

Copy required files
```bash
cp -R ../example/* ./satosa-project
cp -R ../example_sp/djangosaml2_sp/* ./djangosaml2_sp
cp -E ../example/static/* ./nginx/html/static
```

Clean static data from Satosa project
```bash
rm -R ./satosa-project/static
```

Run the compose for a minimal system (nginx and satosa)
```
docker compose up
```

Run the full demo
```bash
docker compose --profile demo up
```

Read the [profiles guide](../docs/docker_compose_profiles.md) for more informations 


### Configure your system
Copy the example env file:
```bash
cp env.example .env
```

Edit and personalize the system from `.env` files. You can still edit all files in detail from their local volumes.
**IMPORTANT all the default password must be changed!**

### Insights

* More details on prodiles read the [Docker Compose Profiles](../docs/docker_compose_profiles.md) page
* More details on run-docker-compose,sh read the [run-docker-compose.sh](../docs/run-docker-compose.sh.md) page
