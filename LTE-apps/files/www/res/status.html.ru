<a href="cgi-bin/luci"><h5 align="center" style="margin:0;">Управление и настройки<br>Luci Settings</h5></a>
<a href="index.html"><h5 align="center">Главная<br>Main</h5></a>
<div class="c"><input type="button" class="button" value="Обновить&#x00A;Refresh" onClick="return loadinfo('cgi-bin/lte_modem.sh',0);"></div>
<br />
<span class="l" style="display:{STATUS_SHOW}">Статус:</span><span class="r" style="display:{STATUS_SHOW}">{STATUS}</span>
<span class="l" style="display:{STATUS_SHOW}"><small>Время соединения:</small></span><span class="r" style="display:{STATUS_SHOW}"><small>{CONN_TIME}</small></span>
<span class="l" style="display:{STATUS_SHOW}"><small>Получено:</small></span><span class="r" style="display:{STATUS_SHOW}"><small>{RX}</small></span>
<span class="l" style="display:{STATUS_SHOW}"><small>Отправлено:</small></span><span class="r" style="display:{STATUS_SHOW}"><small>{TX}</small></span>
<span class="l">Оператор:</span><span class="r">{COPS}</span>
<span class="l">Режим сети:</span><span class="r">{MODE}</span>
<span class="l">Уровень сигнала:</span><span class="r"><strong>{CSQ_PER}%</strong></span>
<br />
<div class="c">
<div style="float: none; margin:1% auto;  width:95%; height:20px; border:1px solid #aaaaaa; background-color:#EEEEEE; max-width: 480px; text-align:center; border-radius: 5px;">
 <div style="float:left; background-image: url(res/pmini.png); background-repeat:repeat-y; border-right:1px solid #cccccc; height:20px; width:{CSQ_PER}%; max-width: 480px; border-radius: 5px;">&nbsp;</div>
</div>
</div>
<div class="l" style="display:block;"><input type="button" class="button" value="SMS" onClick="window.location.href='cgi-bin/sms.html'"></div>
<div class="r" style="display:block;"><input type="button" class="button" value="USSD" onClick="window.location.href='cgi-bin/ussd.html'"></div>
<br />
 <span class="l">CSQ:</span><span class="r">{CSQ}</span>
 <span class="l">RSSI:</span><span class="r">{CSQ_RSSI} dBm</span>
 <span class="l">MCC MNC:</span><span class="r">{COPS_MCC} {COPS_MNC}</span>
 <span class="l">LAC:</span><span class="r">{LAC} ({LAC_NUM})</span>
 <span class="l">CID:</span><span class="r">{CID} ({CID_NUM})</span>
 <span class="l">TAC:</span><span class="r">{TAC} ({TAC_NUM})</span>
 <span class="l">RSCP:</span><span class="r">{RSCP} dBm</span>
 <span class="l">Ec/IO:</span><span class="r">{ECIO} dB</span>
 <span class="l">RSRP:</span><span class="r">{RSRP} dBm</span>
 <span class="l">SINR:</span><span class="r">{SINR} dB</span>
 <span class="l">RSRQ:</span><span class="r">{RSRQ} dB</span>
 <span class="l">Device:</span><span class="r">{DEVICE}</span>
<br />
<span class="l" style="display:block"><input type="button" class="button" value="Перезагрузить порт&#x00A;Reset port" onClick="window.location.href='cgi-bin/mode.html?action=rport';"></span>
<span class="r" style="display:block"><input type="button" class="button" value="Перезагрузить модем&#x00A;Reset modem" onClick="window.location.href='cgi-bin/mode.html?action=rmodem';"></span>
<br />
<div class="c" style="display:block">Изменить режим сети / Change mode</div>
<form method="post" action="cgi-bin/mode.html">
  <input type="hidden" name="action" id="action" value="chband">
  <div class="c"><select size="1" name="mode">
   <option value="res" disabled>Выберите режим сети</option>
   <option value="auto_ext">АвтоР Auto Ex.</option>
   <option value="auto_3g">Авто (Auto)</option>
   <option value="4g">Только lte (4G)</option>
   <option value="4g_B1">lte B1 (2100)</option>
   <option value="4g_B3">lte B3 (1800)</option>
   <option value="4g_B7">lte B7 (2600)</option>
   <option value="4g_B8">lte B8 (900)</option>
   <option value="4g_B20">lte B20 (800)</option>
   <option value="3g">Только umts (3G)</option>
   <option value="3g_2100">umts B1 (2100)</option>
   <option value="3g_900">umts B8 (900)</option>
   <option value="2g">Только edge (2G)</option>
   <option value="2g_1800">edge (1800)</option>
   <option value="2g_900">edge (900)</option>
   <option value="2g_850">edge (850)</option>
   <option value="2g_1900">edge (1900)</option>
   <option value="prefer4g">Преобладание lte/umts</option>
   <option value="prefer3g">Преобладание umts/edge</option>
   </select></div>
  </div>
  <div class="c"><input type="submit" name="submit" value="Изменить&#x00A;Do it!" text-align=center"></div>
</form>