#!/bin/bash
# Simple Web Server using netcat (nc) e a few lines of code

thisScript=$$ # memorizza il process ID di questo Script
# ps $thisScript
# aggiungo named pipe che va a fornire nc con la risposta da mandare
mkfifo in
(echo -n; sleep 999) > in & # devo mantenere il pipe aperto
nc -q1 -lp 8080 < in | while read key value; do

  # Per poter rilevare il Carriage Return che indica la fine dell'HTTP header
  specialChar="$(echo -ne $key | od -An -c)" 
  # echo "$specialChar"

  if [ "$specialChar" = "  \r" ]; then 
    echo Request HEADER end Detcetd!
    # mando una risposta al Browser
    #echo -e "HTTP/1.1 200 OK\r\n$(date)\r\n\r\n<h1>hello world from $(hostname) on $(date)</h1>\r\n" > in
    # TODO: inviare la risorsa richiesta
    path=".$path"
    if  [[ ( "${path: -4}" != "html" ) ]]; then
	path="${path%/}/index.html"
    fi
echo "testing: $path"
    if [ -e ${path}.sh ]; then
	source ./header.html.sh > in
	source ./.getParams.sh
	source $path.sh > in
	echo -e '\r\n' > in
    elif [ -e $path ]; then
	source ./header.html.sh > in
	while read line; do
	  echo -n $line
	done < $path > in
	echo -e '\r\n' > in
    else
	echo -e "HTTP/1.1 404 Not Found \r\n" > in
    fi

    # termino la connessione una volta risposto al Browser
    rm -f in
    read father children <<< $(ps --forest -o pid= -g $(ps -o sid= -p $thisScript))
    kill -9 $children # senza eliminare il padre (la shell)
    exit
  fi

  #echo $key | sed l | (read key; read g; read g)
  echo "parsing: $key $value"
  case $key in
    'GET')
	echo "detected $key method"
        echo "$value"
	method=$key
	read path version <<< "$value"
	echo "$path is requested"
	echo "version: $version"
        read path value <<< "${path/\?/ }"
	echo "$path is requested"
	echo "data: ${value//&/; }"
	echo "${value//&/; }" > ./.getParams.sh
	cat ./.getParams.sh
	;;
    'User-Agent:')
	echo "detected $key"
	userAgent="$value"
	;;
    'Host:')
	echo "detected $key"
	host="$value" 
	;;
    *)
	;;
  esac
done


