#!/bin/sh

echo "Content-type: text/html"
echo ""
_hostname=$(cat /proc/sys/kernel/hostname)
echo "
<html>
<head>
<meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\" />
<title>Система:${_hostname}</title>
</head>
<body>
<a href="../index.html"><h4>Главная</h4></a>
"
echo "" 
vnstat -q -i wwan0 >/tmp/stat.html
cat /tmp/stat.html
echo "

</body>
</html>
"
exit 0