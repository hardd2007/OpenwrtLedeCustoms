#!/bin/sh
modemport=$(uci -q get modem.@modem[0].device)
echo "Content-type: text/html"
echo ""
echo "
<html>
<link rel=\"stylesheet\" href=\"../modem.css\" type=\"text/css\" />
<head>
<title>SMS</title>
<meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\" />
</head>
<body>
<a href="../4g-index.html"><h3>Главная / Index</h3></a>
"
if [ "$REQUEST_METHOD" = POST ]; then
	read -t 3 QUERY_STRING
	eval $(echo "$QUERY_STRING"|awk -F'&' '{for(i=1;i<=NF;i++){print $i}}')
	action=`uhttpd -d $action 2>/dev/null`
	tel=`uhttpd -d $msisdn 2>/dev/null`
	msg=`uhttpd -d $msg 2>/dev/null`
	id=`uhttpd -d $id 2>/dev/null`
else
	action="x"
fi

case "$action" in
	send)
		sms_tool -D $modemport -b 115200 send $tel "$msg" >/dev/null
		R=$?
		if [ $R -eq 0 ]; then
			echo "Сообщение отправлено на номер $tel!<br /> Message sent to $tel!<br />"
		else
			echo "<font color=red><strong>Проблемы при отправке! / Error! </strong></font><br />"
		fi
		echo $tel": "$msg >> /tmp/sms.txt
		;;
	delete)
		sms_tool -D $modemport -b 115200 delete $id 2>/dev/null
		;;
esac

echo "
<form method=\"post\">
  <input type=\"hidden\" name=\"action\" id=\"action\" value=\"send\">
  <div class=label>Номер телефона в формате<br /> Phone number <br /><small>7xxxyyyyyyy</small><br /></div><input name=\"msisdn\" class=text SIZE=\"40\"><br />
  <div class=label>Текст сообщения: <br /> Message:</div><textarea name=\"msg\" class=text SIZE=\"160\"></textarea><br />
  <small>Utf8 пока не поддерживается (no utf8) </small>
  <br />
  <input type=\"submit\" name=\"submit\" value=\"Отправить / Send\" text-align=center>
</form>
"
echo  "<p>Сообщния на сим-карте: / Messages on sim card:</p>"
echo "<p>"
sms_tool -D $modemport -b 115200 recv 2>/dev/null | \
sed -e ' \
s/\([0-9]*\)\.\sMSG/<hr \/><form style="text-align: left;" method="post"><input type="hidden" name="action" id="action" value="delete"><input type="hidden" name="id" id="id" value="\1">Сообщение №: \1<input type="submit" name="submit" value="Удалить \/ Delete"><\/form> /g; \
s/^From:/<br \/>Отправитель: /g; s/^Date\/Time:/<br>Дата-Время: /g; \
s/^Text:/<br \/>Текст: /g '

echo "
</p>
</div>
</body></html>"
