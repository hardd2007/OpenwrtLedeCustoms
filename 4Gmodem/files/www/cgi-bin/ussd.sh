#!/bin/sh
echo "Content-type: text/html"
echo ""
echo "
<html>
<head>
<title>USSD</title>
<meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\" />
<link rel=\"stylesheet\" href=\"../modem.css\" type=\"text/css\" />
</head>
<body>
"
decode_ucs2() {
    local text="$1"

    while [ -n "$text" ]; do
        local code="$((0x${text:0:4}))"

        if [ $code -le 127 ]; then
            echo -en \\x$(printf "%02x" $code)
        elif [ $code -le 2047 ]; then
            echo -en \\x$(printf "%02x" $(((($code >>  6) & 0x1F) | 0xC0)))
            echo -en \\x$(printf "%02x" $(( ($code        & 0x3F) | 0x80)))
        elif [ $code -le 65535 ]; then
            echo -en \\x$(printf "%02x" $(((($code >> 12) & 0x0F) | 0xE0)))
            echo -en \\x$(printf "%02x" $(((($code >>  6) & 0x3F) | 0x80)))
            echo -en \\x$(printf "%02x" $((( $code        & 0x3F) | 0x80)))
        elif [ $code -le 1114111 ]; then
            echo -en \\x$(printf "%02x" $(((($code >> 18) & 0x07) | 0xF0)))
            echo -en \\x$(printf "%02x" $(((($code >> 12) & 0x3F) | 0x80)))
            echo -en \\x$(printf "%02x" $(((($code >>  6) & 0x3F) | 0x80)))
            echo -en \\x$(printf "%02x" $((( $code        & 0x3F) | 0x80)))
        else
            echo -n "?"
        fi

        text="${text:4}"
    done

    echo ""
}




if [ "$REQUEST_METHOD" = POST ]; then
	read -t 3 QUERY_STRING
	eval $(echo "$QUERY_STRING"|awk -F'&' '{for(i=1;i<=NF;i++){print $i}}')
	action=`uhttpd -d $action`
	ussd=`uhttpd -d $ussd`
else
	action="x"
fi
case "$action" in
	send)
A=$(ussd159 -v -p $(uci get modem.@modem[0].device) -t 30 -u "$ussd" | grep "buf=" | cut -f2 -d=)
#sleep 
B=$(decode_ucs2 $A)
echo "Запрос /Query: $ussd<br />"
echo "Ответ / Response:  $B<br />"
		
	;;
esac
echo "
<a href="../4g-index.html"><h3>Главная / Index</h3></a>

<form method=\"post\">
  <input type=\"hidden\" name=\"action\" id=\"action\" value=\"send\">
  <p>Введите ussd запрос / Input query</p>
	<div class=label>USSD:</div><input name=\"ussd\" class=text size=\"100\"><br />
  <input type=\"submit\" name=\"submit\" value=\"Отправить / Send\" text-align=center>
</form>
</div>
</body></html>"
