#/bin/bash

# build headers for response
DATE=$(date +"%a, %d %b %Y %H:%M:%S %Z")
declare -a RESPONSE_HEADERS=( \
    "Date: $DATE" \
    "Expires: $DATE" \
    "Server: simpleWebServer" \
)

add_response_header() {
   RESPONSE_HEADERS+=("$1: $2")
}

declare -a HTTP_RESPONSE=(
   [200]="OK"
   [400]="Bad Request"
   [403]="Forbidden"
   [404]="Not Found"
   [405]="Method Not Allowed"
   [500]="Internal Server Error"
)

# log scrivendolo sullo schermo attraverso stderr
log() { echo "LOG: $@" >&2; }
# scrivi su stderr la stringa ai fini di logging
recv() { echo "< $@" >&2; }
# manda su schermo usando stderr per log e scrive su stdout cosa mandare aggiungendo \r\n 
send() { echo "> $@" >&2; printf '%s\r\n' "$*"; }

send_response() {
   log "SENDING RESPONSE HEADER:"
   local code=$1
   send "HTTP/1.0 $1 ${HTTP_RESPONSE[$1]}"
   for i in "${RESPONSE_HEADERS[@]}"; do
      send "$i"
   done
   send
   log "SENDING BODY RESPONSE:"
   [ -f "$2" ] && cat $2 || cat <<< "$2"
   log "FINISHED SENDING RESPONSE"
#   while read -r line; do
#      send "$line"
#   done
}

send_response_ok_exit() { send_response 200 $1; exit 0; }

fail_with() {
   send_response "$1" <<< "$1 ${HTTP_RESPONSE[$1]}"
   exit 1
}

#
# Ricevi la richiesta ed elabora la risposta
#
#Nella prima linea della richiesta mi aspetto delle informazioni
#Come specificato
# Request-Line HTTP RFC 2616 $5.1
read -r line || fail_with 400

# rimuovi eventuali CR alla fine della stringa
line=${line%%$'\r'}
recv "$line"

# scomponi la riga di richiesta secondo il formato dettato da standard HTTP
read -r REQUEST_METHOD REQUEST_URI REQUEST_HTTP_VERSION <<<"$line"

# verifica tutti gli elementi sono presenti
[ -n "$REQUEST_METHOD" ] && \
[ -n "$REQUEST_URI" ] && \
[ -n "$REQUEST_HTTP_VERSION" ] \
   || fail_with 400

# GET e' l'unico metodo implementato
[ "$REQUEST_METHOD" = "GET" ] || fail_with 405

# Legge e memorizza tutte le righe dell'header della richiesta
declare -a REQUEST_HEADERS

while read -r line; do
   line=${line%%$'\r'}
   recv "$line"

   # la prima riga vuota coincide con la fine del headers, break.
   [ -z "$line" ] && break

   # inserisci la riga appena ricevuta nel header della richiesta
   REQUEST_HEADERS+=("$line")
done

# nel caso siano presenti dei parametri nella richiesta bisogna valutarli
read REQUEST_URI PARAMs <<< "${REQUEST_URI/\?/ }"

serve_file() {
   local file=$1

   CONTENT_TYPE=
   case "$file" in
     *\.css)
       CONTENT_TYPE="text/css"
       ;;
     *\.js)
       CONTENT_TYPE="text/javascript"
       ;;
     *)
       read -r CONTENT_TYPE   < <(file -b --mime-type "$file")
       ;;
   esac

   add_response_header "Content-Type"   "$CONTENT_TYPE";

#   read -r CONTENT_LENGTH < <(stat -c'%s' "$file")         && \
#      add_response_header "Content-Length" "$CONTENT_LENGTH"

   send_response_ok_exit "$file"
}

REQUEST_URI=.$REQUEST_URI
# se la richiesta punta ad una pagina dinamica (che termina con .sh)
if [ -f ${REQUEST_URI}.sh  ]; then
  scriptFile="${REQUEST_URI##*\/}"
  sed 's/"/\\"/g;/^[[:space:]]*<%/!s/^/echo -e "/;/^[[:space:]]*<%/!s/$/"\r\n/;s/<%//g;s/%>//g' ${REQUEST_URI}.sh > /tmp/$scriptFile
  #sed 's/<%/\n<%/g;s/%>/%>\n/g;s/"/\\"/g' ${REQUEST_URI}.sh | \
  #sed '/^$/d' | \
  #sed '/^<%/!s/^/echo -e "/;/^<%/!s/$/"\r\n/;s/<%//g;s/%>//g' > /tmp/$scriptFile
  (log ${PARAMs//&/; }; eval ${PARAMs//&/; }; source /tmp/$scriptFile) > .$scriptFile
  REQUEST_URI=.$scriptFile
# se la richiesta non specifica un file allora assumi che cerchino index.html
elif  [ ! -f $REQUEST_URI ]; then
  REQUEST_URI="${REQUEST_URI%/}/index.html"
fi
serve_file $REQUEST_URI
exit 0
fail_with 500

function response {
      #if  [[ ( "${path: -4}" != "html" ) ]]; then
      if  [ ! -f $path ]; then
        path="${path%/}/index.html"
      fi
      echo SENDING RESPONSE $path 1>&2
  #echo "testing: $path"
      #nel caso in cui il file e' specificato dai priorita' al file.html.sh se esiste
      if [ -e ${path}.sh ]; then
        source ./header.html.sh
        source ./.getParams.sh
	sed 's/^/echo -n "/;s/<%//g;s/%>//g;s/$/"/' $path.sh > .${path##*\/}
        source .${path##*\/}
        echo -e '\r\n'
      #nel caso il file e' specificato e non esiste il file.html.sh ma esiste if file.html
      elif [ "${path: -4}" != "html" ]; then
        source ./header.html.sh
        while read line; do
          echo -n $line
        done < $path
      #se fosse un file di supporto come CSS o un immagine
      elif [ -e $path ]; then
	cat $path
      #nel caso in cui il file richiesto non esiste in nessuna delle sue possibili forme
      else
        echo -e "HTTP/1.1 404 Not Found \r\n"
      fi
      exit
}

#nc -q1 -lp 80 < in   | \
while read key value; do
    # Per poter rilevare il Carriage Return che indica la fine dell'HTTP header
    specialChar="$(echo -ne $key | od -An -c)"
    # echo "$specialChar"

    if [ "$specialChar" = "  \r" ]; then
      echo Request HEADER end Detecetd! 1>&2
      path="${wdir}$path"
      echo serving $path 1>&2
      response 
    fi
   case $key in
      'GET')
        echo "detected $key method" 1>&2
          echo "$value" 1>&2
        method=$key
        read path version <<< "$value"
        echo "$path is requested" 1>&2
        echo "version: $version" 1>&2
          read path value <<< "${path/\?/ }"
        echo "$path is requested" 1>&2
        echo "data: ${value//&/; }" 1>&2
        echo "${value//&/; }" > ./.getParams.sh
        cat ./.getParams.sh
        ;;
      'User-Agent:')
        echo "detected $key" 1>&2
        userAgent="$value"
        ;;
      'Host:')
        echo "detected $key" 1>&2
        host="$value"
        ;;
      *)
        ;;
    esac

done
echo DONE 1>&2
