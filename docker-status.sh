clear
echo 'Docker Status\n============='
echo '\nImages...'
docker image list

echo '\nVolumes...'
docker volume list

echo '\nNetworks...'
docker network list

echo '\nContainers...'
docker container list -a

echo '\nCompositions...'
docker compose ps -a

#  --- end of file -- #
