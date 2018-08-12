<p align="center"><a href="http://antenna.on.kg/"><img src="img/logo.png" width="300" height="54"><br><h2 align="center">Антенны для улучшения сигнала мобильного интерента</h2></a></p>
<br />
<br />
<span class="l">Оператор:</span><span class="r">{COPS}</span>
<span class="l">Режим сети:</span><span class="r">{MODE}</span>
<span class="l">Уровень сигнала:</span><span class="r"><strong>{CSQ_PER}%</strong></span>
<div style="float:left; margin:1%; width:98%; height:20px; border:1px solid #000000; background-color:transparent;">
 <div style="float:left; background-color:{CSQ_COL}; border-right:1px solid #000000; height:100%; width:{CSQ_PER}%">&nbsp;</div>
</div>
<div class="c"><input type="button" class="button" value="Обновить" onClick="return loadinfo('cgi-bin/4gmodem.sh',0);"></div>
<br />
<div id='details' style="display:inline;">
 <span class="l">CSQ:</span><span class="r">{CSQ}</span>
 <span class="l">RSSI:</span><span class="r">{CSQ_RSSI} dBm</span>
 <span class="l" style="display:{QOS_SHOW}">UMTS QoS Profile:</span><span class="r" style="display:{QOS_SHOW}">{DOWN} kbps DOWN | {UP} kbps UP</span>
 <span class="l">MCC MNC:</span><span class="r">{COPS_MCC} {COPS_MNC}</span>
 <span class="l">LAC:</span><span class="r">{LAC} ({LAC_NUM})</span>
 <span class="l" style="display:{LCID_SHOW}">LCID:</span><span class="r" style="display:{LCID_SHOW}">{LCID} ({LCID_NUM})</span>
 <span class="l" style="display:{LCID_SHOW}">RNC:</span><span class="r" style="display:{LCID_SHOW}">{RNC} ({RNC_NUM})</span>
 <span class="l">CID:</span><span class="r">{CID} ({CID_NUM})</span>
 <span class="l">&nbsp;</span><small><span class="r">{BTSINFO}</small>
 <span class="l">Device:</span><span class="r">{DEVICE}</span>
</div>

