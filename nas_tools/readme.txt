
1° construa a image: 
    sudo docker build -t nas-image .

2° crie um container: 
    sudo docker run -it --rm --privileged -p 22:22 -p 21:21 -p 139:139 -p 445:445 nas-image

