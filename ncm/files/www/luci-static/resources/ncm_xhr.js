/*
 * xhr.js - XMLHttpRequest helper class
 * (c) 2008-2010 Jo-Philipp Wich
 */

var gothwD = "0";
var gotcarrierD = "0";
var gotsignalD = "0";
var hwrefreshD = "0";
var modemdevD = ""
var driverD = ""

XHR2 = function()
{
	this.reinit = function()
	{
		if (window.XMLHttpRequest) {
			this._xmlHttp = new XMLHttpRequest();
		}
		else if (window.ActiveXObject) {
			this._xmlHttp = new ActiveXObject("Microsoft.XMLHTTP");
		}
		else {
			alert("dongle_xhr.js: XMLHttpRequest is not supported by this browser!");
		}
	}

	this.busy = function() {
		if (!this._xmlHttp)
			return false;

		switch (this._xmlHttp.readyState)
		{
			case 1:
			case 2:
			case 3:
				return true;

			default:
				return false;
		}
	}

	this.abort = function() {
		if (this.busy())
			this._xmlHttp.abort();
	}

	this.get = function(url,data,callback)
	{
		this.reinit();

		var xhr2  = this._xmlHttp;
		var code = this._encode(data);

		url = location.protocol + '//' + location.host + url;

		if (code)
			if (url.substr(url.length-1,1) == '&')
				url += code;
			else
				url += '?' + code;

		xhr2.open('GET', url, true);

		xhr2.onreadystatechange = function()
		{
			if (xhr2.readyState == 4) {
				var json = null;
				if (xhr2.getResponseHeader("Content-Type") == "application/json") {
					try {
						json = eval('(' + xhr2.responseText + ')');
					}
					catch(e) {
						json = null;
					}
				}

				callback(xhr2, json);
			}
		}

		xhr2.send(null);
	}

	this.post = function(url,data,callback)
	{
		this.reinit();

		var xhr2  = this._xmlHttp;
		var code = this._encode(data);

		xhr2.onreadystatechange = function()
		{
			if (xhr2.readyState == 4)
				callback(xhr2);
		}

		xhr2.open('POST', url, true);
		xhr2.setRequestHeader('Content-type', 'application/x-www-form-urlencoded');
		xhr2.setRequestHeader('Content-length', code.length);
		xhr2.setRequestHeader('Connection', 'close');
		xhr2.send(code);
	}

	this.cancel = function()
	{
		this._xmlHttp.onreadystatechange = function(){};
		this._xmlHttp.abort();
	}

	this.send_form = function(form,callback,extra_values)
	{
		var code = '';

		for (var i = 0; i < form.elements.length; i++)
		{
			var e = form.elements[i];

			if (e.options)
			{
				code += (code ? '&' : '') +
					form.elements[i].name + '=' + encodeURIComponent(
						e.options[e.selectedIndex].value
					);
			}
			else if (e.length)
			{
				for (var j = 0; j < e.length; j++)
					if (e[j].name) {
						code += (code ? '&' : '') +
							e[j].name + '=' + encodeURIComponent(e[j].value);
					}
			}
			else
			{
				code += (code ? '&' : '') +
					e.name + '=' + encodeURIComponent(e.value);
			}
		}

		if (typeof extra_values == 'object')
			for (var key in extra_values)
				code += (code ? '&' : '') +
					key + '=' + encodeURIComponent(extra_values[key]);

		return(
			(form.method == 'get')
				? this.get(form.getAttribute('action'), code, callback)
				: this.post(form.getAttribute('action'), code, callback)
		);
	}

	this._encode = function(obj)
	{
		obj = obj ? obj : { };
		obj['gothw'] = gothwD;
		obj['gotcarrier'] = gotcarrierD;
		obj['gotsignal'] = gotsignalD;
		obj['hwrefresh'] = hwrefreshD;
		obj['modemdev'] = modemdevD;
		obj['driver'] = driverD;
		obj['_'] = Math.random();

		if (typeof obj == 'object')
		{
			var code = '';
			var self = this;

			for (var k in obj)
				code += (code ? '&' : '') +
					k + '=' + encodeURIComponent(obj[k]);

			return code;
		}

		return obj;
	}
}

XHR2.get = function(url, data, callback)
{
	(new XHR2()).get(url, data, callback);
}

XHR2.poll = function(interval, url, data, callback)
{
	if (isNaN(interval) || interval < 1)
		interval = 5;

	if (!XHR2._q)
	{
		XHR2._t = 0;
		XHR2._q = [ ];
		XHR2._r = function() {
			for (var i = 0, e = XHR2._q[0]; i < XHR2._q.length; e = XHR2._q[++i])
			{
				if (!(XHR2._t % e.interval) && !e.xhr2.busy())
					e.xhr2.get(e.url, e.data, e.callback);
			}

			XHR2._t++;
		};
	}

	XHR2._q.push({
		interval: interval,
		callback: callback,
		url:      url,
		data:     data,
		xhr2:      new XHR2()
	});

	XHR2.run();
}

XHR2.halt = function()
{
	if (XHR2._i)
	{
		/* show & set poll indicator */
		try {
			document.getElementById('xhr_poll_status').style.display = '';
			document.getElementById('xhr_poll_status_on').style.display = 'none';
			document.getElementById('xhr_poll_status_off').style.display = '';
		} catch(e) { }

		window.clearInterval(XHR2._i);
		XHR2._i = null;
	}
}

XHR2.run = function()
{
	if (XHR2._r && !XHR2._i)
	{
		/* show & set poll indicator */
		try {
			document.getElementById('xhr_poll_status').style.display = '';
			document.getElementById('xhr_poll_status_on').style.display = '';
			document.getElementById('xhr_poll_status_off').style.display = 'none';
		} catch(e) { }

		/* kick first round manually to prevent one second lag when setting up
		 * the poll interval */
		XHR2._r();
		XHR2._i = window.setInterval(XHR2._r, 1000);
	}
}

XHR2.running = function()
{
	return !!(XHR2._r && XHR2._i);
}
