#!/bin/bash
echo -e "\n"

echo -e "Eseguo il down della composizione. \n"

docker compose -f docker-compose.yml down -v

exit 0
