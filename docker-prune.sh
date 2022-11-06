clear
echo 'Docker Prune\n============='

echo '\nImages...'
docker image prune -f

echo '\nContainers...'
docker container prune -f

echo '\nVolumes...'
docker volume prune -f

#  --- end of file -- #
