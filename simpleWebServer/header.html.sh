#header
echo -ne "HTTP/1.1 200 OK\r\n"
echo -ne "Date: $(date)\r\n"
echo -ne "Content-Type: text/html; charset=UTF-8\r\n"
echo -ne "\r\n" # the end of header
