#header
source ./header.html.sh

#body
echo -n "<h1>CIAO world</h1>"
echo -n "from <b>$(hostname)</b> on <b>$(date +%d-%m-%y"</b>"@"<b>"%H:%M)</b>"
echo -e "\r\n" # end of body
