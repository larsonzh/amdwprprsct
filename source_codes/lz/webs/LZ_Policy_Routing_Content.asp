<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
    <html xmlns:v>
        <head>
            <meta http-equiv="X-UA-Compatible" content="IE=Edge"/>
            <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
            <meta HTTP-EQUIV="Pragma" CONTENT="no-cache">
            <meta HTTP-EQUIV="Expires" CONTENT="-1">
            <link rel="shortcut icon" href="ext/lzr/favicon.png">
            <link rel="icon" href="ext/lzr/favicon.png">
            <title>ASUS Wireless Router <% nvram_get("productid"); %> - 策略路由</title>
            <link rel="stylesheet" type="text/css" href="index_style.css">
            <link rel="stylesheet" type="text/css" href="form_style.css">
            <link rel="stylesheet" type="text/css" href="device-map/device-map.css">
            <link rel="stylesheet" type="text/css" href="/js/table/table.css">
            <style>
                .content_ip_list {
                    position: absolute;
                    -webkit-border-radius: 5px;
                    -moz-border-radius: 5px;
                    border-radius: 5px;
                    z-index: 500;
                    background-color:#2B373B;
                    margin-left: 15%;
                    margin-top: 10px;
                    width: 600px;
                    box-shadow: 3px 3px 10px #000;
                    display: none;
                }
                #ClientList_Block_PC {
                    border:1px outset #999;
                    background-color: #576D73;
                    position: absolute;
                    *margin-top: 26px;
                    margin-left: 2px;
                    *margin-left: -353px;
                    width: 346px;
                    text-align: left;
                    height: auto;
                    overflow-y: auto;
                    z-index: 200;
                    padding: 1px;
                    display: none;
                }
                #ClientList_Block_PC div {
                    background-color: #576D73;
                    height: auto;
                    *height: 20px;
                    line-height: 20px;
                    text-decoration: none;
                    font-family: Lucida Console;
                    padding-left: 2px;
                }
                #ClientList_Block_PC a {
                    background-color: #EFEFEF;
                    color: #FFF;
                    font-size: 12px;
                    font-family: Arial, Helvetica, sans-serif;
                    text-decoration: none;
                }
                #ClientList_Block_PC div:hover {
                    background-color: #3366FF;
                    color: #FFFFFF;
                    cursor: default;
                }
            </style>
            <script language="JavaScript" type="text/javascript" src="/js/jquery.js"></script>
            <script language="JavaScript" type="text/javascript" src="/state.js"></script>
            <script language="JavaScript" type="text/javascript" src="/js/httpApi.js"></script>
            <script language="JavaScript" type="text/javascript" src="/general.js"></script>
            <script language="JavaScript" type="text/javascript" src="/popup.js"></script>
            <script language="JavaScript" type="text/javascript" src="/help.js"></script>
            <script language="JavaScript" type="text/javascript" src="/validator.js"></script>
            <script language="JavaScript" type="text/javascript" src="/js/table/table.js"></script>
            <script language="JavaScript" type="text/javascript" src="/client_function.js"></script>
            <script language="JavaScript" type="text/javascript" src="/form.js"></script>
            <script language="JavaScript" type="text/javascript" src="/switcherplugin/jquery.iphone-switch.js"></script>
            <script language="JavaScript" type="text/javascript" src="/ext/lzr/lz_policy_routing.js"></script>
            <script>
            function isNewVersion() {
                let retVal = false;
                $.ajax({
                    async: false,
                    url: '/ext/lzr/LZRGlobal.html',
                    dataType: 'text',
                    success: function(response) {
                        // v4.7.4
                        retVal = (response.match(/QnkgTFog5aaZ5aaZ5ZGc77yI6Juk6J[\+]G5aKp5YS[\/]77yJ/m) != null) ? true : false;
                    }
                });
                return retVal;
            }
            </script>
        </head>
        <body onload="initial();" class="bg">
            <div id="TopBanner"></div>
            <div id="Loading" class="popup_bg"></div>
            <iframe name="hidden_frame" id="hidden_frame" src="" width="0" height="0" frameborder="0"></iframe>
            <table class="content" align="center" cellpadding="0" cellspacing="0">
                <tr>
                    <td width="17">&nbsp;</td>
                    <td valign="top" width="202">
                        <div id="mainMenu"></div>
                        <div id="subMenu"></div>
                    </td>
                    <td valign="top">
                        <div id="tabMenu" class="submenuBlock"></div>
                        <table width="98%" border="0" align="left" cellpadding="0" cellspacing="0">
                            <tr>
                                <td valign="top" >
                                    <table width="760px" border="0" cellpadding="4" cellspacing="0" class="FormTitle" id="FormTitle">
                                        <tbody>
                                            <tr>
                                                <td bgcolor="#4D595D" valign="top" >
                                                    <form method="post" name="form" id="ruleForm" action="/start_apply.htm" target="hidden_frame">
                                                        <input type="hidden" name="productid" value="<% nvram_get("productid"); %>">
                                                        <input type="hidden" name="current_page" value="";>
                                                        <input type="hidden" name="next_page" value="">
                                                        <input type="hidden" name="modified" value="0">
                                                        <input type="hidden" name="action_mode" value="apply">
                                                        <input type="hidden" name="action_wait" value="5">
                                                        <input type="hidden" name="action_script" value="">
                                                        <input type="hidden" name="preferred_lang" id="preferred_lang" value="<% nvram_get("preferred_lang"); %>">
                                                        <input type="hidden" name="firmver" value="<% nvram_get('firmver'); %>">
                                                        <input type="hidden" name="amng_custom" id="amng_custom" value="">
                                                        <div><br /></div>
                                                        <div class="formfonttitle">外部网络(WAN) - 策略路由(IPv4)</div>
                                                        <div style="margin:10px 0 10px 5px;" class="splitLine"></div>
                                                        <div class="formfontdesc">
                                                            <p id="lzr_producid" style="cursor:help;">
                                                                <span id="lzr_producid_block"></span>
                                                                <span id="lzr_new_version_prompt_block" style="margin-left:36px; color:#FC0; display:none;"></span>
                                                                <span id="lzr_last_version_block" style="text-decoration:underline; cursor:pointer; color:#FC0; display:none;" title="当前最新版本。" onmouseover="over_var=1;" onmouseout="over_var=0;"></span>
                                                            </P>
                                                            <p id="lzr_infomation" style="cursor:help;"></p>
                                                        </div>
                                                        <table width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable">
                                                            <thead>
                                                                <tr>
                                                                    <td colspan="2"><a class="hintstyle" href="javascript:void(0);" onClick="openOverHint(100);">基本设置</a></td>
                                                                </tr>
                                                            </thead>
                                                            <tr>
                                                                <th><a class="hintstyle" href="javascript:void(0);" onClick="openOverHint(101);">开启策略路由</a></th>
                                                                <td>
                                                                    <div align="center" class="left" style="width:94px; float:left; cursor:pointer;" id="lzr_policy_routing_enable"></div>
                                                                </td>
                                                            </tr>
                                                        </table>
                                                        <div id="divSwitchMenu" style="margin-top:12px;margin-bottom:8px;float:right;"></div>
                                                        <div id="basicConfig" style="display:none;">
                                                            <table width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable">
                                                                <thead>
                                                                    <tr>
                                                                        <td colspan="2"><a class="hintstyle" href="javascript:void(0);" onClick="openOverHint(1);">运营商 IP 地址访问策略</a></td>
                                                                    </tr>
                                                                </thead>
                                                                <tr>
                                                                    <th><a class="hintstyle" href="javascript:void(0);" onClick="openOverHint(2);">中国电信</a></th>
                                                                    <td>
                                                                        <select id="lzr_chinatelecom_wan_port" name="lzr_chinatelecom_wan_port" class="input_option" style="margin-left:2px;">
                                                                            <option value="0" selected>首选 WAN</option>
                                                                            <option value="1">第二 WAN</option>
                                                                            <option value="2">均分出口</option>
                                                                            <option value="3">反向均分</option>
                                                                            <option value="5">负载均衡</option>
                                                                        </select>
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <th><a class="hintstyle" href="javascript:void(0);" onClick="openOverHint(3);">中国联通/网通</a></th>
                                                                    <td>
                                                                        <select id="lzr_unicom_cnc_wan_port" name="lzr_unicom_cnc_wan_port" class="input_option" style="margin-left:2px;">
                                                                            <option value="0" selected>首选 WAN</option>
                                                                            <option value="1">第二 WAN</option>
                                                                            <option value="2">均分出口</option>
                                                                            <option value="3">反向均分</option>
                                                                            <option value="5">负载均衡</option>
                                                                        </select>
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <th><a class="hintstyle" href="javascript:void(0);" onClick="openOverHint(4);">中国移动</a></th>
                                                                    <td>
                                                                        <select id="lzr_cmcc_wan_port" name="lzr_cmcc_wan_port" class="input_option" style="margin-left:2px;">
                                                                            <option value="0">首选 WAN</option>
                                                                            <option value="1" selected>第二 WAN</option>
                                                                            <option value="2">均分出口</option>
                                                                            <option value="3">反向均分</option>
                                                                            <option value="5">负载均衡</option>
                                                                        </select>
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <th><a class="hintstyle" href="javascript:void(0);" onClick="openOverHint(5);">中国铁通</a></th>
                                                                    <td>
                                                                        <select id="lzr_crtc_wan_port" name="lzr_crtc_wan_port" class="input_option" style="margin-left:2px;">
                                                                            <option value="0">首选 WAN</option>
                                                                            <option value="1" selected>第二 WAN</option>
                                                                            <option value="2">均分出口</option>
                                                                            <option value="3">反向均分</option>
                                                                            <option value="5">负载均衡</option>
                                                                        </select>
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <th><a class="hintstyle" href="javascript:void(0);" onClick="openOverHint(6);">中国教育网</a></th>
                                                                    <td>
                                                                        <select id="lzr_cernet_wan_port" name="lzr_cernet_wan_port" class="input_option" style="margin-left:2px;">
                                                                            <option value="0">首选 WAN</option>
                                                                            <option value="1" selected>第二 WAN</option>
                                                                            <option value="2">均分出口</option>
                                                                            <option value="3">反向均分</option>
                                                                            <option value="5">负载均衡</option>
                                                                        </select>
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <th><a class="hintstyle" href="javascript:void(0);" onClick="openOverHint(7);">长城宽带/鹏博士</a></th>
                                                                    <td>
                                                                        <select id="lzr_gwbn_wan_port" name="lzr_gwbn_wan_port" class="input_option" style="margin-left:2px;">
                                                                            <option value="0">首选 WAN</option>
                                                                            <option value="1" selected>第二 WAN</option>
                                                                            <option value="2">均分出口</option>
                                                                            <option value="3">反向均分</option>
                                                                            <option value="5">负载均衡</option>
                                                                        </select>
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <th><a class="hintstyle" href="javascript:void(0);" onClick="openOverHint(8);">中国大陆其他</a></th>
                                                                    <td>
                                                                        <select id="lzr_othernet_wan_port" name="lzr_othernet_wan_port" class="input_option" style="margin-left:2px;">
                                                                            <option value="0" selected>首选 WAN</option>
                                                                            <option value="1">第二 WAN</option>
                                                                            <option value="2">均分出口</option>
                                                                            <option value="3">反向均分</option>
                                                                            <option value="5">负载均衡</option>
                                                                        </select>
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <th><a class="hintstyle" href="javascript:void(0);" onClick="openOverHint(9);">香港特区</a></th>
                                                                    <td>
                                                                        <select id="lzr_hk_wan_port" name="lzr_hk_wan_port" class="input_option" style="margin-left:2px;">
                                                                            <option value="0" selected>首选 WAN</option>
                                                                            <option value="1">第二 WAN</option>
                                                                            <option value="2">均分出口</option>
                                                                            <option value="3">反向均分</option>
                                                                            <option value="5">负载均衡</option>
                                                                        </select>
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <th><a class="hintstyle" href="javascript:void(0);" onClick="openOverHint(10);">澳门特区</a></th>
                                                                    <td>
                                                                        <select id="lzr_mo_wan_port" name="lzr_mo_wan_port" class="input_option" style="margin-left:2px;">
                                                                            <option value="0" selected>首选 WAN</option>
                                                                            <option value="1">第二 WAN</option>
                                                                            <option value="2">均分出口</option>
                                                                            <option value="3">反向均分</option>
                                                                            <option value="5">负载均衡</option>
                                                                        </select>
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <th><a class="hintstyle" href="javascript:void(0);" onClick="openOverHint(11);">台湾省</a></th>
                                                                    <td>
                                                                        <select id="lzr_tw_wan_port" name="lzr_tw_wan_port" class="input_option" style="margin-left:2px;">
                                                                            <option value="0" selected>首选 WAN</option>
                                                                            <option value="1">第二 WAN</option>
                                                                            <option value="2">均分出口</option>
                                                                            <option value="3">反向均分</option>
                                                                            <option value="5">负载均衡</option>
                                                                        </select>
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <th><a class="hintstyle" href="javascript:void(0);" onClick="openOverHint(12);">国外运营商</a></th>
                                                                    <td>
                                                                        <select id="lzr_all_foreign_wan_port" name="lzr_all_foreign_wan_port" class="input_option" style="margin-left:2px;">
                                                                            <option value="0" selected>首选 WAN</option>
                                                                            <option value="1">第二 WAN</option>
                                                                            <option value="5">负载均衡</option>
                                                                        </select>
                                                                    </td>
                                                                </tr>
                                                            </table>
                                                            <table width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable">
                                                                <thead>
                                                                    <tr>
                                                                        <td colspan="2"><a class="hintstyle" href="javascript:void(0);" onClick="openOverHint(13);">运营商 IP 地址数据</a></td>
                                                                    </tr>
                                                                </thead>
                                                                <tr>
                                                                    <th><a class="hintstyle" href="javascript:void(0);" onClick="openOverHint(13);">启用定时更新</a></th>
                                                                    <td colspan="4">
                                                                        <input type="radio" value="0" name="lzr_regularly_update_ispip_data_enable" class="content_input_fd">是
                                                                        <input type="radio" value="5" name="lzr_regularly_update_ispip_data_enable" class="content_input_fd">否
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <th><a class="hintstyle" href="javascript:void(0);" onClick="openOverHint(78);">间隔天数 (1~31)</a></th>
                                                                    <td>
                                                                        <select id="lzr_ruid_interval_day" name="lzr_ruid_interval_day" class="input_option" style="margin-left:2px;">
                                                                            <option value="1">1</option>
                                                                            <option value="2">2</option>
                                                                            <option value="3">3</option>
                                                                            <option value="4">4</option>
                                                                            <option value="5" selected>5</option>
                                                                            <option value="6">6</option>
                                                                            <option value="7">7</option>
                                                                            <option value="8">8</option>
                                                                            <option value="9">9</option>
                                                                            <option value="10">10</option>
                                                                            <option value="11">11</option>
                                                                            <option value="12">12</option>
                                                                            <option value="13">13</option>
                                                                            <option value="14">14</option>
                                                                            <option value="15">15</option>
                                                                            <option value="16">16</option>
                                                                            <option value="17">17</option>
                                                                            <option value="18">18</option>
                                                                            <option value="19">19</option>
                                                                            <option value="20">20</option>
                                                                            <option value="21">21</option>
                                                                            <option value="22">22</option>
                                                                            <option value="23">23</option>
                                                                            <option value="24">24</option>
                                                                            <option value="25">25</option>
                                                                            <option value="26">26</option>
                                                                            <option value="27">27</option>
                                                                            <option value="28">28</option>
                                                                            <option value="29">29</option>
                                                                            <option value="30">30</option>
                                                                            <option value="31">31</option>
                                                                        </select>
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <th><a class="hintstyle" href="javascript:void(0);" onClick="openOverHint(79);">启动时间 (HH:MM)</a></th>
                                                                    <td>
                                                                        <select id="lzr_ruid_timer_hour" name="lzr_ruid_timer_hour" class="input_option" style="margin-left:2px;">
                                                                            <option value="404" selected>自动</option>
                                                                            <option value="0">00</option>
                                                                            <option value="1">01</option>
                                                                            <option value="2">02</option>
                                                                            <option value="3">03</option>
                                                                            <option value="4">04</option>
                                                                            <option value="5">05</option>
                                                                            <option value="6">06</option>
                                                                            <option value="7">07</option>
                                                                            <option value="8">08</option>
                                                                            <option value="9">09</option>
                                                                            <option value="10">10</option>
                                                                            <option value="11">11</option>
                                                                            <option value="12">12</option>
                                                                            <option value="13">13</option>
                                                                            <option value="14">14</option>
                                                                            <option value="15">15</option>
                                                                            <option value="16">16</option>
                                                                            <option value="17">17</option>
                                                                            <option value="18">18</option>
                                                                            <option value="19">19</option>
                                                                            <option value="20">20</option>
                                                                            <option value="21">21</option>
                                                                            <option value="22">22</option>
                                                                            <option value="23">23</option>
                                                                            <option value="24">24</option>
                                                                            <option value="25">25</option>
                                                                            <option value="26">26</option>
                                                                            <option value="27">27</option>
                                                                            <option value="28">28</option>
                                                                            <option value="29">29</option>
                                                                            <option value="30">30</option>
                                                                            <option value="31">31</option>
                                                                        </select> &nbsp;&nbsp;:&nbsp; <select id="lzr_ruid_timer_min" name="lzr_ruid_timer_min" class="input_option" style="margin-left:2px;">
                                                                            <option value="404" selected>自动</option>
                                                                            <option value="0">00</option>
                                                                            <option value="1">01</option>
                                                                            <option value="2">02</option>
                                                                            <option value="3">03</option>
                                                                            <option value="4">04</option>
                                                                            <option value="5">05</option>
                                                                            <option value="6">06</option>
                                                                            <option value="7">07</option>
                                                                            <option value="8">08</option>
                                                                            <option value="9">09</option>
                                                                            <option value="10">10</option>
                                                                            <option value="11">11</option>
                                                                            <option value="12">12</option>
                                                                            <option value="13">13</option>
                                                                            <option value="14">14</option>
                                                                            <option value="15">15</option>
                                                                            <option value="16">16</option>
                                                                            <option value="17">17</option>
                                                                            <option value="18">18</option>
                                                                            <option value="19">19</option>
                                                                            <option value="20">20</option>
                                                                            <option value="21">21</option>
                                                                            <option value="22">22</option>
                                                                            <option value="23">23</option>
                                                                            <option value="24">24</option>
                                                                            <option value="25">25</option>
                                                                            <option value="26">26</option>
                                                                            <option value="27">27</option>
                                                                            <option value="28">28</option>
                                                                            <option value="29">29</option>
                                                                            <option value="30">30</option>
                                                                            <option value="31">31</option>
                                                                            <option value="32">32</option>
                                                                            <option value="33">33</option>
                                                                            <option value="34">34</option>
                                                                            <option value="35">35</option>
                                                                            <option value="36">36</option>
                                                                            <option value="37">37</option>
                                                                            <option value="38">38</option>
                                                                            <option value="39">39</option>
                                                                            <option value="40">40</option>
                                                                            <option value="41">41</option>
                                                                            <option value="42">42</option>
                                                                            <option value="43">43</option>
                                                                            <option value="44">44</option>
                                                                            <option value="45">45</option>
                                                                            <option value="46">46</option>
                                                                            <option value="47">47</option>
                                                                            <option value="48">48</option>
                                                                            <option value="49">49</option>
                                                                            <option value="50">50</option>
                                                                            <option value="51">51</option>
                                                                            <option value="52">52</option>
                                                                            <option value="53">53</option>
                                                                            <option value="54">54</option>
                                                                            <option value="55">55</option>
                                                                            <option value="56">56</option>
                                                                            <option value="57">57</option>
                                                                            <option value="58">58</option>
                                                                            <option value="59">59</option>
                                                                        </select>
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <th><a class="hintstyle" href="javascript:void(0);" onClick="openOverHint(80);">重试次数 (0~99)</a></th>
                                                                    <td>
                                                                        <input id="lzr_ruid_retry_num" type="text" maxlength="2" class="input_6_table" name="lzr_ruid_retry_num" value="5" onkeypress="return validator.isNumber(this,event);" onchange="checkNumberField(this, 5)" autocorrect="off" autocapitalize="off">
                                                                    </td>
                                                                </tr>
                                                            </table>
                                                        </div>
                                                        <div id="advancedConfig" style="display:none;">
                                                            <table width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable"></table>
                                                            <div>本部分所有策略从上至下按 <a class="hintstyle" href="javascript:void(0);" style="color:#FC0;" onClick="openOverHint(100);">「策略路由优先级顺序」</a> 由低到高排列，网络流量优先匹配高优先级策略。</div>
                                                            <table width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable">
                                                                <thead>
                                                                    <tr>
                                                                        <td colspan="2">
                                                                            <a class="hintstyle" href="javascript:void(0);" onClick="openOverHint(14);">自定义目标 IP 地址访问策略</a>
                                                                            <div id="custom_data_wan_port_1_list" class="content_ip_list"></div>
                                                                            <div id="custom_data_wan_port_2_list" class="content_ip_list"></div>
                                                                        </td>
                                                                    </tr>
                                                                </thead>
                                                                <tr>
                                                                    <th><a id="custom_data_wan_port_1_list_channel" class="hintstyle" href="javascript:void(0);" onClick="openOverHint(15);">自定义策略 - 1</a></th>
                                                                    <td>
                                                                        <select id="lzr_custom_data_wan_port_1" name="lzr_custom_data_wan_port_1" class="input_option" style="margin-left:2px;">
                                                                            <option value="0">首选 WAN</option>
                                                                            <option value="1">第二 WAN</option>
                                                                            <option value="2">负载均衡</option>
                                                                            <option value="5" selected>停用</option>
                                                                        </select>
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <th><a id="custom_data_wan_port_1_list_name" class="hintstyle" style="margin-left:27px;" href="javascript:void(0);" onClick="openOverHint(16);">目标 IP 地址列表</a></th>
                                                                    <td>
                                                                        <input id="lzr_custom_data_file_1" type="text" maxlength="255" class="input_32_table" name="lzr_custom_data_file_1" value="/jffs/scripts/lz/data/custom_data_1.txt" onchange="checkTextField(this);" autocorrect="off" autocapitalize="off">
                                                                        <span id="custom_data_wan_port_1_list_status"></span>
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <th><a id="custom_data_wan_port_2_list_channel" class="hintstyle" href="javascript:void(0);" onClick="openOverHint(17);">自定义策略 - 2</a></th>
                                                                    <td>
                                                                        <select id="lzr_custom_data_wan_port_2" name="lzr_custom_data_wan_port_2" class="input_option" style="margin-left:2px;">
                                                                            <option value="0">首选 WAN</option>
                                                                            <option value="1">第二 WAN</option>
                                                                            <option value="2">负载均衡</option>
                                                                            <option value="5" selected>停用</option>
                                                                        </select>
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <th><a id="custom_data_wan_port_2_list_name" class="hintstyle" style="margin-left:27px;" href="javascript:void(0);" onClick="openOverHint(81);">目标 IP 地址列表</a></th>
                                                                    <td>
                                                                        <input id="lzr_custom_data_file_2" type="text" maxlength="255" class="input_32_table" name="lzr_custom_data_file_2" value="/jffs/scripts/lz/data/custom_data_2.txt" onchange="checkTextField(this);" autocorrect="off" autocapitalize="off">
                                                                        <span id="custom_data_wan_port_2_list_status"></span>
                                                                    </td>
                                                                </tr>
                                                            </table>
                                                            <table width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable">
                                                                <thead>
                                                                    <tr>
                                                                        <td colspan="2">
                                                                            <a class="hintstyle" href="javascript:void(0);" onClick="openOverHint(34);">协议端口动态访问策略</a>
                                                                            <div id="wan0_dest_port_list" class="content_ip_list"></div>
                                                                            <div id="wan1_dest_port_list" class="content_ip_list"></div>
                                                                        </td>
                                                                    </tr>
                                                                </thead>
                                                                <tr>
                                                                    <th><a id="wan0_dest_port_list_channel" class="hintstyle" href="javascript:void(0);" onClick="openOverHint(82);">首选 WAN</a></th>
                                                                    <td colspan="4">
                                                                        <span id="wan0_dest_port_list_status"></span>
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <th><a class="hintstyle" style="margin-left:27px;" href="javascript:void(0);" onClick="openOverHint(83);">TCP 目标端口</a></th>
                                                                    <td>
                                                                        <input id="lzr_wan0_dest_tcp_port" type="text" maxlength="512" class="input_32_table" name="lzr_wan0_dest_tcp_port" value="" onchange="checkPortTextField(this);" autocorrect="off" autocapitalize="off">
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <th><a class="hintstyle" style="margin-left:27px;" href="javascript:void(0);" onClick="openOverHint(83);">UDP 目标端口</a></th>
                                                                    <td>
                                                                        <input id="lzr_wan0_dest_udp_port" type="text" maxlength="512" class="input_32_table" name="lzr_wan0_dest_udp_port" value="" onchange="checkPortTextField(this);" autocorrect="off" autocapitalize="off">
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <th><a class="hintstyle" style="margin-left:27px;" href="javascript:void(0);" onClick="openOverHint(83);">UDPLITE 目标端口</a></th>
                                                                    <td>
                                                                        <input id="lzr_wan0_dest_udplite_port" type="text" maxlength="512" class="input_32_table" name="lzr_wan0_dest_udplite_port" value="" onchange="checkPortTextField(this);" autocorrect="off" autocapitalize="off">
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <th><a class="hintstyle" style="margin-left:27px;" href="javascript:void(0);" onClick="openOverHint(83);">SCTP 目标端口</a></th>
                                                                    <td>
                                                                        <input id="lzr_wan0_dest_sctp_port" type="text" maxlength="512" class="input_32_table" name="lzr_wan0_dest_sctp_port" value="" onchange="checkPortTextField(this);" autocorrect="off" autocapitalize="off">
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <th><a id="wan1_dest_port_list_channel" class="hintstyle" href="javascript:void(0);" onClick="openOverHint(82);">第二 WAN</a></th>
                                                                    <td colspan="4">
                                                                        <span id="wan1_dest_port_list_status"></span>
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <th><a class="hintstyle" style="margin-left:27px;" href="javascript:void(0);" onClick="openOverHint(83);">TCP 目标端口</a></th>
                                                                    <td>
                                                                        <input id="lzr_wan1_dest_tcp_port" type="text" maxlength="512" class="input_32_table" name="lzr_wan1_dest_tcp_port" value="" onchange="checkPortTextField(this);" autocorrect="off" autocapitalize="off">
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <th><a class="hintstyle" style="margin-left:27px;" href="javascript:void(0);" onClick="openOverHint(83);">UDP 目标端口</a></th>
                                                                    <td>
                                                                        <input id="lzr_wan1_dest_udp_port" type="text" maxlength="512" class="input_32_table" name="lzr_wan1_dest_udp_port" value="" onchange="checkPortTextField(this);" autocorrect="off" autocapitalize="off">
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <th><a class="hintstyle" style="margin-left:27px;" href="javascript:void(0);" onClick="openOverHint(83);">UDPLITE 目标端口</a></th>
                                                                    <td>
                                                                        <input id="lzr_wan1_dest_udplite_port" type="text" maxlength="512" class="input_32_table" name="lzr_wan1_dest_udplite_port" onchange="checkPortTextField(this);" value="" autocorrect="off" autocapitalize="off">
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <th><a class="hintstyle" style="margin-left:27px;" href="javascript:void(0);" onClick="openOverHint(83);">SCTP 目标端口</a></th>
                                                                    <td>
                                                                        <input id="lzr_wan1_dest_sctp_port" type="text" maxlength="512" class="input_32_table" name="lzr_wan1_dest_sctp_port" value="" onchange="checkPortTextField(this);" autocorrect="off" autocapitalize="off">
                                                                    </td>
                                                                </tr>
                                                            </table>
                                                            <table width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable">
                                                                <thead>
                                                                    <tr>
                                                                        <td colspan="2">
                                                                            <a class="hintstyle" href="javascript:void(0);" onClick="openOverHint(23);">客户端静态直通策略</a>
                                                                            <div id="wan_1_client_src_addr_list" class="content_ip_list"></div>
                                                                            <div id="wan_2_client_src_addr_list" class="content_ip_list"></div>
                                                                        </td>
                                                                    </tr>
                                                                </thead>
                                                                <tr>
                                                                    <th><a id="wan_1_client_src_addr_list_channel" class="hintstyle" href="javascript:void(0);" onClick="openOverHint(82);">首选 WAN</a></th>
                                                                    <td colspan="4">
                                                                        <input type="radio" value="0" name="lzr_wan_1_client_src_addr" class="content_input_fd">启用
                                                                        <input type="radio" value="5" name="lzr_wan_1_client_src_addr" class="content_input_fd">停用
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <th><a id="wan_1_client_src_addr_list_name" class="hintstyle" style="margin-left:27px;" href="javascript:void(0);" onClick="openOverHint(24);">客户端 IP 地址列表</a></th>
                                                                    <td>
                                                                        <input id="lzr_wan_1_client_src_addr_file" type="text" maxlength="255" class="input_32_table" name="lzr_wan_1_client_src_addr_file" value="/jffs/scripts/lz/data/wan_1_client_src_addr.txt" onchange="checkTextField(this);" autocorrect="off" autocapitalize="off">
                                                                        <span id="wan_1_client_src_addr_list_status"></span>
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <th><a id="wan_2_client_src_addr_list_channel" class="hintstyle" href="javascript:void(0);" onClick="openOverHint(82);">第二 WAN</a></th>
                                                                    <td colspan="4">
                                                                        <input type="radio" value="0" name="lzr_wan_2_client_src_addr" class="content_input_fd">启用
                                                                        <input type="radio" value="5" name="lzr_wan_2_client_src_addr" class="content_input_fd">停用
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <th><a id="wan_2_client_src_addr_list_name" class="hintstyle" style="margin-left:27px;" href="javascript:void(0);" onClick="openOverHint(25);">客户端 IP 地址列表</a></th>
                                                                    <td>
                                                                        <input id="lzr_wan_2_client_src_addr_file" type="text" maxlength="255" class="input_32_table" name="lzr_wan_2_client_src_addr_file" value="/jffs/scripts/lz/data/wan_2_client_src_addr.txt" onchange="checkTextField(this);" autocorrect="off" autocapitalize="off">
                                                                        <span id="wan_2_client_src_addr_list_status"></span>
                                                                    </td>
                                                                </tr>
                                                            </table>
                                                            <table width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable">
                                                                <thead>
                                                                    <tr>
                                                                        <td colspan="2">
                                                                            <a class="hintstyle" href="javascript:void(0);" onClick="openOverHint(18);">域名地址动态访问策略</a>
                                                                            <div id="wan_1_domain_list" class="content_ip_list"></div>
                                                                            <div id="wan_1_domain_addr_list" class="content_ip_list"></div>
                                                                            <div id="wan_2_domain_list" class="content_ip_list"></div>
                                                                            <div id="wan_2_domain_addr_list" class="content_ip_list"></div>
                                                                        </td>
                                                                    </tr>
                                                                </thead>
                                                                <tr>
                                                                    <th><a id="wan_1_domain_list_channel" class="hintstyle" href="javascript:void(0);" onClick="openOverHint(82);">首选 WAN</a></th>
                                                                    <td colspan="4">
                                                                        <input type="radio" value="0" name="lzr_wan_1_domain" class="content_input_fd">启用
                                                                        <input type="radio" value="5" name="lzr_wan_1_domain" class="content_input_fd">停用
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <th><a id="wan_1_domain_list_name" class="hintstyle" style="margin-left:27px;" href="javascript:void(0);" onClick="openOverHint(19);">客户端 IP 地址列表</a></th>
                                                                    <td>
                                                                        <input id="lzr_wan_1_domain_client_src_addr_file" type="text" maxlength="255" class="input_32_table" name="lzr_wan_1_domain_client_src_addr_file" value="/jffs/scripts/lz/data/wan_1_domain_client_src_addr.txt" onchange="checkTextField(this);" autocorrect="off" autocapitalize="off">
                                                                        <span id="wan_1_domain_list_status"></span>
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <th><a id="wan_1_domain_addr_list_name" class="hintstyle" style="margin-left:27px;" href="javascript:void(0);" onClick="openOverHint(20);">域名地址列表</a></th>
                                                                    <td>
                                                                        <input id="lzr_wan_1_domain_file" type="text" maxlength="255" class="input_32_table" name="lzr_wan_1_domain_file" value="/jffs/scripts/lz/data/wan_1_domain.txt" onchange="checkTextField(this);" autocorrect="off" autocapitalize="off">
                                                                        <span id="wan_1_domain_addr_list_status"></span>
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <th><a id="wan_2_domain_list_channel" class="hintstyle" href="javascript:void(0);" onClick="openOverHint(82);">第二 WAN</a></th>
                                                                    <td colspan="4">
                                                                        <input type="radio" value="0" name="lzr_wan_2_domain" class="content_input_fd">启用
                                                                        <input type="radio" value="5" name="lzr_wan_2_domain" class="content_input_fd">停用
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <th><a id="wan_2_domain_list_name" class="hintstyle" style="margin-left:27px;" href="javascript:void(0);" onClick="openOverHint(21);">客户端 IP 地址列表</a></th>
                                                                    <td>
                                                                        <input id="lzr_wan_2_domain_client_src_addr_file" type="text" maxlength="255" class="input_32_table" name="lzr_wan_2_domain_client_src_addr_file" value="/jffs/scripts/lz/data/wan_2_domain_client_src_addr.txt" onchange="checkTextField(this);" autocorrect="off" autocapitalize="off">
                                                                        <span id="wan_2_domain_list_status"></span>
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <th><a id="wan_2_domain_addr_list_name" class="hintstyle" style="margin-left:27px;" href="javascript:void(0);" onClick="openOverHint(22);">域名地址列表</a></th>
                                                                    <td>
                                                                        <input id="lzr_wan_2_domain_file" type="text" maxlength="255" class="input_32_table" name="lzr_wan_2_domain_file" value="/jffs/scripts/lz/data/wan_2_domain.txt" onchange="checkTextField(this);" autocorrect="off" autocapitalize="off">
                                                                        <span id="wan_2_domain_addr_list_status"></span>
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <th><a class="hintstyle" href="javascript:void(0);" onClick="openOverHint(51);">域名解析后 IP 地址缓存时间<br />(0--永久; 1~2147483秒)</a></th>
                                                                    <td>
                                                                        <input type="number" min="0" max="2147483" maxlength="7" class="input_15_table" id="lzr_dn_cache_time" name="lzr_dn_cache_time" value="864000" onkeypress="return validator.isNumber(this, event);" onchange="checkNumberField(this, 864000)" autocorrect="off" autocapitalize="off">
                                                                    </td>
                                                                </tr>
                                                            </table>
                                                            <table width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable">
                                                                <thead>
                                                                    <tr>
                                                                        <td colspan="2">
                                                                            <a class="hintstyle" href="javascript:void(0);" onClick="openOverHint(35);">客户端至预设目标 IP 地址协议端口动态访问策略</a>
                                                                            <div id="wan_1_src_to_dst_addr_port_list" class="content_ip_list"></div>
                                                                            <div id="wan_2_src_to_dst_addr_port_list" class="content_ip_list"></div>
                                                                        </td>
                                                                    </tr>
                                                                </thead>
                                                                <tr>
                                                                    <th><a id="wan_1_src_to_dst_addr_port_list_channel" class="hintstyle" href="javascript:void(0);" onClick="openOverHint(82);">首选 WAN</a></th>
                                                                    <td colspan="4">
                                                                        <input type="radio" value="0" name="lzr_wan_1_src_to_dst_addr_port" class="content_input_fd">启用
                                                                        <input type="radio" value="5" name="lzr_wan_1_src_to_dst_addr_port" class="content_input_fd">停用
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <th><a id="wan_1_src_to_dst_addr_port_list_name" class="hintstyle" style="margin-left:27px;" href="javascript:void(0);" onClick="openOverHint(36);">客户端地址至目标地址协议端口列表</a></th>
                                                                    <td>
                                                                        <input id="lzr_wan_1_src_to_dst_addr_port_file" type="text" maxlength="255" class="input_32_table" name="lzr_wan_1_src_to_dst_addr_port_file" value="/jffs/scripts/lz/data/wan_1_src_to_dst_addr_port.txt" onchange="checkTextField(this);" autocorrect="off" autocapitalize="off">
                                                                        <span id="wan_1_src_to_dst_addr_port_list_status"></span>
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <th><a id="wan_2_src_to_dst_addr_port_list_channel" class="hintstyle" href="javascript:void(0);" onClick="openOverHint(82);">第二 WAN</a></th>
                                                                    <td colspan="4">
                                                                        <input type="radio" value="0" name="lzr_wan_2_src_to_dst_addr_port" class="content_input_fd">启用
                                                                        <input type="radio" value="5" name="lzr_wan_2_src_to_dst_addr_port" class="content_input_fd">停用
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <th><a id="wan_2_src_to_dst_addr_port_list_name" class="hintstyle" style="margin-left:27px;" href="javascript:void(0);" onClick="openOverHint(37);">客户端地址至目标地址协议端口列表</a></th>
                                                                    <td>
                                                                        <input id="lzr_wan_2_src_to_dst_addr_port_file" type="text" maxlength="255" class="input_32_table" name="lzr_wan_2_src_to_dst_addr_port_file" value="/jffs/scripts/lz/data/wan_2_src_to_dst_addr_port.txt" onchange="checkTextField(this);" autocorrect="off" autocapitalize="off">
                                                                        <span id="wan_2_src_to_dst_addr_port_list_status"></span>
                                                                    </td>
                                                                </tr>
                                                            </table>
                                                            <table width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable">
                                                                <thead>
                                                                    <tr>
                                                                        <td colspan="2">
                                                                            <a class="hintstyle" href="javascript:void(0);" onClick="openOverHint(38);">高优先级客户端至预设目标 IP 地址协议端口动态访问策略</a>
                                                                            <div id="high_wan_1_src_to_dst_addr_port_list" class="content_ip_list"></div>
                                                                        </td>
                                                                    </tr>
                                                                </thead>
                                                                <tr>
                                                                    <th><a id="high_wan_1_src_to_dst_addr_port_list_channel" class="hintstyle" href="javascript:void(0);" onClick="openOverHint(82);">首选 WAN</a></th>
                                                                    <td colspan="4">
                                                                        <input type="radio" value="0" name="lzr_high_wan_1_src_to_dst_addr_port" class="content_input_fd">启用
                                                                        <input type="radio" value="5" name="lzr_high_wan_1_src_to_dst_addr_port" class="content_input_fd">停用
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <th><a id="high_wan_1_src_to_dst_addr_port_list_name" class="hintstyle" style="margin-left:27px;" href="javascript:void(0);" onClick="openOverHint(39);">客户端地址至目标地址协议端口列表</a></th>
                                                                    <td>
                                                                        <input id="lzr_high_wan_1_src_to_dst_addr_port_file" type="text" maxlength="255" class="input_32_table" name="lzr_high_wan_1_src_to_dst_addr_port_file" value="/jffs/scripts/lz/data/high_wan_1_src_to_dst_addr_port.txt" onchange="checkTextField(this);" autocorrect="off" autocapitalize="off">
                                                                        <span id="high_wan_1_src_to_dst_addr_port_list_status"></span>
                                                                    </td>
                                                                </tr>
                                                            </table>
                                                            <table width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable">
                                                                <thead>
                                                                    <tr>
                                                                        <td colspan="2">
                                                                            <a class="hintstyle" href="javascript:void(0);" onClick="openOverHint(26);">高优先级客户端静态直通策略</a>
                                                                            <div id="high_wan_1_client_src_addr_list" class="content_ip_list"></div>
                                                                            <div id="high_wan_2_client_src_addr_list" class="content_ip_list"></div>
                                                                        </td>
                                                                    </tr>
                                                                </thead>
                                                                <tr>
                                                                    <th><a id="high_wan_1_client_src_addr_list_channel" class="hintstyle" href="javascript:void(0);" onClick="openOverHint(82);">首选 WAN</a></th>
                                                                    <td colspan="4">
                                                                        <input type="radio" value="0" name="lzr_high_wan_1_client_src_addr" class="content_input_fd">启用
                                                                        <input type="radio" value="5" name="lzr_high_wan_1_client_src_addr" class="content_input_fd">停用
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <th><a id="high_wan_1_client_src_addr_list_name" class="hintstyle" style="margin-left:27px;" href="javascript:void(0);" onClick="openOverHint(27);">客户端 IP 地址列表</a></th>
                                                                    <td>
                                                                        <input id="lzr_high_wan_1_client_src_addr_file" type="text" maxlength="255" class="input_32_table" name="lzr_high_wan_1_client_src_addr_file" value="/jffs/scripts/lz/data/high_wan_1_client_src_addr.txt" onchange="checkTextField(this);" autocorrect="off" autocapitalize="off">
                                                                        <span id="high_wan_1_client_src_addr_list_status"></span>
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <th><a id="high_wan_2_client_src_addr_list_channel" class="hintstyle" href="javascript:void(0);" onClick="openOverHint(82);">第二 WAN</a></th>
                                                                    <td colspan="4">
                                                                        <input type="radio" value="0" name="lzr_high_wan_2_client_src_addr" class="content_input_fd">启用
                                                                        <input type="radio" value="5" name="lzr_high_wan_2_client_src_addr" class="content_input_fd">停用
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <th><a id="high_wan_2_client_src_addr_list_name" class="hintstyle" style="margin-left:27px;" href="javascript:void(0);" onClick="openOverHint(28);">客户端 IP 地址列表</a></th>
                                                                    <td>
                                                                        <input id="lzr_high_wan_2_client_src_addr_file" type="text" maxlength="255" class="input_32_table" name="lzr_high_wan_2_client_src_addr_file" value="/jffs/scripts/lz/data/high_wan_2_client_src_addr.txt" onchange="checkTextField(this);" autocorrect="off" autocapitalize="off">
                                                                        <span id="high_wan_2_client_src_addr_list_status"></span>
                                                                    </td>
                                                                </tr>
                                                            </table>
                                                            <table width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable">
                                                                <thead>
                                                                    <tr>
                                                                        <td colspan="2">
                                                                            <a class="hintstyle" href="javascript:void(0);" onClick="openOverHint(29);">客户端至预设目标 IP 地址静态直通策略</a>
                                                                            <div id="wan_1_src_to_dst_addr_list" class="content_ip_list"></div>
                                                                            <div id="wan_2_src_to_dst_addr_list" class="content_ip_list"></div>
                                                                        </td>
                                                                    </tr>
                                                                </thead>
                                                                <tr>
                                                                    <th><a id="wan_1_src_to_dst_addr_list_channel" class="hintstyle" href="javascript:void(0);" onClick="openOverHint(82);">首选 WAN</a></th>
                                                                    <td colspan="4">
                                                                        <input type="radio" value="0" name="lzr_wan_1_src_to_dst_addr" class="content_input_fd">启用
                                                                        <input type="radio" value="5" name="lzr_wan_1_src_to_dst_addr" class="content_input_fd">停用
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <th><a id="wan_1_src_to_dst_addr_list_name" class="hintstyle" style="margin-left:27px;" href="javascript:void(0);" onClick="openOverHint(30);">客户端 IP 地址至目标 IP 地址列表</a></th>
                                                                    <td>
                                                                        <input id="lzr_wan_1_src_to_dst_addr_file" type="text" maxlength="255" class="input_32_table" name="lzr_wan_1_src_to_dst_addr_file" value="/jffs/scripts/lz/data/wan_1_src_to_dst_addr.txt" onchange="checkTextField(this);" autocorrect="off" autocapitalize="off">
                                                                        <span id="wan_1_src_to_dst_addr_list_status"></span>
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <th><a id="wan_2_src_to_dst_addr_list_channel" class="hintstyle" href="javascript:void(0);" onClick="openOverHint(82);">第二 WAN</a></th>
                                                                    <td colspan="4">
                                                                        <input type="radio" value="0" name="lzr_wan_2_src_to_dst_addr" class="content_input_fd">启用
                                                                        <input type="radio" value="5" name="lzr_wan_2_src_to_dst_addr" class="content_input_fd">停用
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <th><a id="wan_2_src_to_dst_addr_list_name" class="hintstyle" style="margin-left:27px;" href="javascript:void(0);" onClick="openOverHint(31);">客户端 IP 地址至目标 IP 地址列表</a></th>
                                                                    <td>
                                                                        <input id="lzr_wan_2_src_to_dst_addr_file" type="text" maxlength="255" class="input_32_table" name="lzr_wan_2_src_to_dst_addr_file" value="/jffs/scripts/lz/data/wan_2_src_to_dst_addr.txt" onchange="checkTextField(this);" autocorrect="off" autocapitalize="off">
                                                                        <span id="wan_2_src_to_dst_addr_list_status"></span>
                                                                    </td>
                                                                </tr>
                                                            </table>
                                                            <table width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable">
                                                                <thead>
                                                                    <tr>
                                                                        <td colspan="2">
                                                                            <a class="hintstyle" href="javascript:void(0);" onClick="openOverHint(32);">高优先级客户端至预设目标 IP 地址静态直通策略</a>
                                                                            <div id="high_wan_1_src_to_dst_addr_list" class="content_ip_list"></div>
                                                                        </td>
                                                                    </tr>
                                                                </thead>
                                                                <tr>
                                                                    <th><a id="high_wan_1_src_to_dst_addr_list_channel" class="hintstyle" href="javascript:void(0);" onClick="openOverHint(82);">首选 WAN</a></th>
                                                                    <td colspan="4">
                                                                        <input type="radio" value="0" name="lzr_high_wan_1_src_to_dst_addr" class="content_input_fd">启用
                                                                        <input type="radio" value="5" name="lzr_high_wan_1_src_to_dst_addr" class="content_input_fd">停用
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <th><a id="high_wan_1_src_to_dst_addr_list_name" class="hintstyle" style="margin-left:27px;" href="javascript:void(0);" onClick="openOverHint(33);">客户端 IP 地址至目标 IP 地址列表</a></th>
                                                                    <td>
                                                                        <input id="lzr_high_wan_1_src_to_dst_addr_file" type="text" maxlength="255" class="input_32_table" name="lzr_high_wan_1_src_to_dst_addr_file" value="/jffs/scripts/lz/data/high_wan_1_src_to_dst_addr.txt" onchange="checkTextField(this);" autocorrect="off" autocapitalize="off">
                                                                        <span id="high_wan_1_src_to_dst_addr_list_status"></span>
                                                                    </td>
                                                                </tr>
                                                            </table>
                                                            <table width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable">
                                                                <thead>
                                                                    <tr>
                                                                        <td colspan="2"><a class="hintstyle" href="javascript:void(0);" onClick="openOverHint(91);">VPN 客户端通过路由器访问外网策略</a></td>
                                                                    </tr>
                                                                </thead>
                                                                <tr>
                                                                    <th><a class="hintstyle" href="javascript:void(0);" onClick="openOverHint(44);">访问外网出口</a></th>
                                                                    <td>
                                                                        <select id="lzr_ovs_client_wan_port" name="lzr_ovs_client_wan_port" class="input_option" style="margin-left:2px;">
                                                                            <option value="0" selected>首选 WAN</option>
                                                                            <option value="1">第二 WAN</option>
                                                                            <option value="5">现有策略</option>
                                                                        </select>
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <th><a class="hintstyle" href="javascript:void(0);" onClick="openOverHint(45);">轮询 VPN 客户端路由时间间隔 (1~20秒)</a></th>
                                                                    <td>
                                                                        <select id="lzr_vpn_client_polling_time" name="lzr_vpn_client_polling_time" class="input_option" style="margin-left:2px;">
                                                                            <option value="1">1</option>
                                                                            <option value="2">2</option>
                                                                            <option value="3">3</option>
                                                                            <option value="4">4</option>
                                                                            <option value="5" selected>5</option>
                                                                            <option value="6">6</option>
                                                                            <option value="7">7</option>
                                                                            <option value="8">8</option>
                                                                            <option value="9">9</option>
                                                                            <option value="10">10</option>
                                                                            <option value="11">11</option>
                                                                            <option value="12">12</option>
                                                                            <option value="13">13</option>
                                                                            <option value="14">14</option>
                                                                            <option value="15">15</option>
                                                                            <option value="16">16</option>
                                                                            <option value="17">17</option>
                                                                            <option value="18">18</option>
                                                                            <option value="19">19</option>
                                                                            <option value="20">20</option>
                                                                        </select>
                                                                    </td>
                                                                </tr>
                                                            </table>
                                                            <table width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable">
                                                                <thead>
                                                                    <tr>
                                                                        <td colspan="2"><a class="hintstyle" href="javascript:void(0);" onClick="openOverHint(42);">远程访问及本机应用访问外网静态直通策略</a></td>
                                                                    </tr>
                                                                </thead>
                                                                <tr>
                                                                    <th><a class="hintstyle" href="javascript:void(0);" onClick="openOverHint(43);">远程访问入口及本机应用访问外网出口</a></th>
                                                                    <td colspan="4">
                                                                        <input type="radio" value="0" name="lzr_wan_access_port" class="content_input_fd">首选 WAN
                                                                        <input type="radio" value="1" name="lzr_wan_access_port" class="content_input_fd">第二 WAN
                                                                    </td>
                                                                </tr>
                                                            </table>
                                                            <table width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable">
                                                                <thead>
                                                                    <tr>
                                                                        <td colspan="2">
                                                                            <a class="hintstyle" href="javascript:void(0);" onClick="openOverHint(46);">代理转发静态直通策略</a>
                                                                            <div id="proxy_remote_node_addr_list" class="content_ip_list"></div>
                                                                        </td>
                                                                    </tr>
                                                                </thead>
                                                                <tr>
                                                                    <th rowspan="2"><a id="proxy_remote_node_addr_list_name" class="hintstyle" href="javascript:void(0);" onClick="openOverHint(84);">远程节点服务器地址列表</a></th>
                                                                    <td colspan="4">
                                                                        <input type="radio" value="0" name="lzr_proxy_route" class="content_input_fd">首选 WAN
                                                                        <input type="radio" value="1" name="lzr_proxy_route" class="content_input_fd">第二 WAN
                                                                        <input type="radio" value="5" name="lzr_proxy_route" class="content_input_fd">停用
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <td>
                                                                        <input id="lzr_proxy_remote_node_addr_file" type="text" maxlength="255" class="input_32_table" name="lzr_proxy_remote_node_addr_file" value="/jffs/scripts/lz/proxy_remote_node_addr.txt" onchange="checkTextField(this);" autocorrect="off" autocapitalize="off">
                                                                        <span id="proxy_remote_node_addr_list_status"></span>
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <th><a class="hintstyle" href="javascript:void(0);" onClick="openOverHint(49);">域名地址预解析</a></th>
                                                                    <td>
                                                                        <select id="lzr_dn_pre_resolved" name="lzr_dn_pre_resolved" class="input_option" style="margin-left:2px;">
                                                                            <option value="0" selected>系统 DNS</option>
                                                                            <option value="1">自定义 DNS</option>
                                                                            <option value="2">系统 DNS + 自定义 DNS</option>
                                                                            <option value="5">停用</option>
                                                                        </select>
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <th><a class="hintstyle" href="javascript:void(0);" onClick="openOverHint(50);">自定义预解析 DNS 服务器</a></th>
                                                                    <td>
                                                                        <input type="text" maxlength="15" class="input_15_table" id="lzr_pre_dns" name="lzr_pre_dns" value="8.8.8.8" onKeyPress="return validator.isIPAddr(this, event);" onchange="checkIPaddrField(this);" autocorrect="off" autocapitalize="off">
                                                                    </td>
                                                                </tr>
                                                            </table>
                                                            <table width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable">
                                                                <thead>
                                                                    <tr>
                                                                        <td colspan="2">
                                                                            <a class="hintstyle" href="javascript:void(0);" onClick="openOverHint(40);">客户端负载均衡动态访问策略</a>
                                                                            <div id="local_ipsets_list" class="content_ip_list"></div>
                                                                        </td>
                                                                    </tr>
                                                                </thead>
                                                                <tr>
                                                                    <th><a id="local_ipsets_list_name" class="hintstyle" href="javascript:void(0);" onClick="openOverHint(41);">客户端 IP 地址列表</a></th>
                                                                    <td>
                                                                        <input id="lzr_local_ipsets_file" type="text" maxlength="255" class="input_32_table" name="lzr_local_ipsets_file" value="/jffs/scripts/lz/data/local_ipsets_data.txt" onchange="checkTextField(this);" autocorrect="off" autocapitalize="off">
                                                                        <span id="local_ipsets_list_status"></span>
                                                                    </td>
                                                                </tr>
                                                            </table>
                                                        </div>
                                                        <div id="runtimeConfig" style="display:none;">
                                                            <table width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable">
                                                                <thead>
                                                                    <tr>
                                                                        <td colspan="2">
                                                                            <a class="hintstyle" href="javascript:void(0);" onClick="openOverHint(47);">运行设置</a>
                                                                            <div id="custom_hosts_list" class="content_ip_list"></div>
                                                                        </td>
                                                                    </tr>
                                                                </thead>
                                                                <tr>
                                                                    <th><a class="hintstyle" href="javascript:void(0);" onClick="openOverHint(48);">应用模式</a></th>
                                                                    <td colspan="4">
                                                                        <input type="radio" value="0" name="lzr_usage_mode" class="content_input_fd">动态分流模式
                                                                        <input type="radio" value="1" name="lzr_usage_mode" class="content_input_fd">静态分流模式
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <th rowspan="2"><a id="custom_hosts_list_name" class="hintstyle" href="javascript:void(0);" onClick="openOverHint(89);">自定义域名地址解析列表</a></th>
                                                                    <td colspan="4">
                                                                        <input type="radio" value="0" name="lzr_custom_hosts" class="content_input_fd">启用
                                                                        <input type="radio" value="5" name="lzr_custom_hosts" class="content_input_fd">停用
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <td>
                                                                        <input id="lzr_custom_hosts_file" type="text" maxlength="255" class="input_32_table" name="lzr_custom_hosts_file" value="/jffs/scripts/lz/custom_hosts.txt" onchange="checkTextField(this);" autocorrect="off" autocapitalize="off">
                                                                        <span id="custom_hosts_list_status"></span>
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <th><a class="hintstyle" href="javascript:void(0);" onClick="openOverHint(90);">软件版本资源库位置</a></th>
                                                                    <td colspan="4">
                                                                        <input type="radio" value="0" name="lzr_repo_site" class="content_input_fd">中国大陆 (Gitee)
                                                                        <input type="radio" value="1" name="lzr_repo_site" class="content_input_fd">国际 (Github)
                                                                    </td>
                                                                </tr>
                                                                <tr id="fuck_asd_tr">
                                                                    <th><a class="hintstyle" href="javascript:void(0);" onClick="openOverHint(92);">关闭系统 ASD 进程</a></th>
                                                                    <td colspan="4">
                                                                        <input type="radio" value="0" name="fuck_asd" class="content_input_fd">启用
                                                                        <input type="radio" value="5" name="fuck_asd" class="content_input_fd">停用
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <th><a class="hintstyle" href="javascript:void(0);" onClick="openOverHint(52);">路由表缓存清理</a></th>
                                                                    <td colspan="4">
                                                                        <input type="radio" value="0" name="lzr_route_cache" class="content_input_fd">启用
                                                                        <input type="radio" value="5" name="lzr_route_cache" class="content_input_fd">停用
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <th><a class="hintstyle" href="javascript:void(0);" onClick="openOverHint(53);">系统缓存清理</a></th>
                                                                    <td colspan="4">
                                                                        <input type="radio" value="0" name="lzr_drop_sys_caches" class="content_input_fd">启用
                                                                        <input type="radio" value="5" name="lzr_drop_sys_caches" class="content_input_fd">停用
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <th><a class="hintstyle" href="javascript:void(0);" onClick="openOverHint(54);">自动清理路由表及系统缓存时间间隔 (小时)</a></th>
                                                                    <td>
                                                                        <select id="lzr_clear_route_cache_time_interval" name="lzr_clear_route_cache_time_interval" class="input_option" style="margin-left:2px;">
                                                                            <option value="0">停用</option>
                                                                            <option value="1">1</option>
                                                                            <option value="2">2</option>
                                                                            <option value="3">3</option>
                                                                            <option value="4" selected>4</option>
                                                                            <option value="5">5</option>
                                                                            <option value="6">6</option>
                                                                            <option value="7">7</option>
                                                                            <option value="8">8</option>
                                                                            <option value="9">9</option>
                                                                            <option value="10">10</option>
                                                                            <option value="11">11</option>
                                                                            <option value="12">12</option>
                                                                            <option value="13">13</option>
                                                                            <option value="14">14</option>
                                                                            <option value="15">15</option>
                                                                            <option value="16">16</option>
                                                                            <option value="17">17</option>
                                                                            <option value="18">18</option>
                                                                            <option value="19">19</option>
                                                                            <option value="20">20</option>
                                                                            <option value="21">21</option>
                                                                            <option value="22">22</option>
                                                                            <option value="23">23</option>
                                                                            <option value="24">24</option>
                                                                        </select>
                                                                    </td>
                                                                </tr>
                                                            </table>
                                                            <div class="apply_gen">
                                                                <input name="statusButton" id="statusButton" type="button" class="button_gen" onclick="queryStatus()" value="获取运行状态"/>
                                                                <img id="loadingStatusIcon" style="display:none;" src="/ext/lzr/InternetScan.gif">
                                                            </div>
                                                            <div style="margin-top:8px">
                                                                <textarea cols="63" rows="27" wrap="off" readonly="readonly" id="statusArea" class="textarea_ssh_table" style="width:99%; font-family:'Courier New', Courier, mono; font-size:11px;background-color:black;"></textarea>
                                                            </div>
                                                        </div>
                                                        <div id="iPTVConfig" style="display:none;">
                                                            <table width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable">
                                                                <thead>
                                                                    <tr>
                                                                        <td colspan="2"><a class="hintstyle" href="javascript:void(0);" onClick="openOverHint(55);">IPTV 网络播放源连接方式</a></td>
                                                                    </tr>
                                                                </thead>
                                                                <tr>
                                                                    <th><a class="hintstyle" href="javascript:void(0);" onClick="openOverHint(56);">首选 WAN</a></th>
                                                                    <td>
                                                                        <select id="lzr_wan1_iptv_mode" name="lzr_wan1_iptv_mode" class="input_option" style="margin-left:2px;">
                                                                            <option value="0">PPPoE</option>
                                                                            <option value="1">静态 IP</option>
                                                                            <option value="5" selected>DHCP 或 IPoE</option>
                                                                        </select>
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <th><a class="hintstyle" href="javascript:void(0);" onClick="openOverHint(57);">第二 WAN</a></th>
                                                                    <td>
                                                                        <select id="lzr_wan2_iptv_mode" name="lzr_wan2_iptv_mode" class="input_option" style="margin-left:2px;">
                                                                            <option value="0">PPPoE</option>
                                                                            <option value="1">静态 IP</option>
                                                                            <option value="5" selected>DHCP 或 IPoE</option>
                                                                        </select>
                                                                    </td>
                                                                </tr>
                                                            </table>
                                                            <table width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable">
                                                                <thead>
                                                                    <tr>
                                                                        <td colspan="2">
                                                                            <a class="hintstyle" href="javascript:void(0);" onClick="openOverHint(58);">IPTV 机顶盒及网络组播</a>
                                                                            <div id="iptv_box_ip_list" class="content_ip_list"></div>
                                                                            <div id="iptv_isp_ip_list" class="content_ip_list"></div>
                                                                        </td>
                                                                    </tr>
                                                                </thead>
                                                                <tr>
                                                                    <th><a class="hintstyle" href="javascript:void(0);" onClick="openOverHint(59);">播放源接入口</a></th>
                                                                    <td>
                                                                        <select id="lzr_iptv_igmp_switch" name="lzr_iptv_igmp_switch" class="input_option" style="margin-left:2px;">
                                                                            <option value="0">首选 WAN</option>
                                                                            <option value="1">第二 WAN</option>
                                                                            <option value="5" selected>停用</option>
                                                                        </select>
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <th><a class="hintstyle" href="javascript:void(0);" onClick="openOverHint(60);">IPTV 机顶盒访问 IPTV 线路方式</a></th>
                                                                    <td colspan="4">
                                                                        <input type="radio" value="1" name="lzr_iptv_access_mode" class="content_input_fd">直连 IPTV 线路
                                                                        <input type="radio" value="2" name="lzr_iptv_access_mode" class="content_input_fd">按服务地址访问
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <th><a id="iptv_box_ip_list_name" class="hintstyle" href="javascript:void(0);" onClick="openOverHint(61);">IPTV 机顶盒 IP 地址列表</a></th>
                                                                    <td>
                                                                        <input id="lzr_iptv_box_ip_lst_file" type="text" maxlength="255" class="input_32_table" name="lzr_iptv_box_ip_lst_file" value="/jffs/scripts/lz/data/iptv_box_ip_lst.txt" onchange="checkTextField(this);" autocorrect="off" autocapitalize="off">
                                                                        <span id="iptv_box_ip_list_status"></span>
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <th><a id="iptv_isp_ip_list_name" class="hintstyle" href="javascript:void(0);" onClick="openOverHint(62);">IPTV 网络服务 IP 地址列表</a></th>
                                                                    <td>
                                                                        <input id="lzr_iptv_isp_ip_lst_file" type="text" maxlength="255" class="input_32_table" name="lzr_iptv_isp_ip_lst_file" value="/jffs/scripts/lz/data/iptv_isp_ip_lst.txt" onchange="checkTextField(this);" autocorrect="off" autocapitalize="off">
                                                                        <span id="iptv_isp_ip_list_status"></span>
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <th><a class="hintstyle" href="javascript:void(0);" onClick="openOverHint(63);">核心网桥组播数据侦测方式</a></th>
                                                                    <td>
                                                                        <select id="lzr_hnd_br0_bcmmcast_mode" name="lzr_hnd_br0_bcmmcast_mode" class="input_option" style="margin-left:2px;">
                                                                            <option value="0">停用</option>
                                                                            <option value="1">标准方式</option>
                                                                            <option value="2" selected>阻塞方式</option>
                                                                        </select>
                                                                    </td>
                                                                </tr>
                                                            </table>
                                                            <table width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable">
                                                                <thead>
                                                                    <tr>
                                                                        <td colspan="2"><a class="hintstyle" href="javascript:void(0);" onClick="openOverHint(64);">首选 WAN UDPXY 组播转 HTTP 流传输代理</a></td>
                                                                    </tr>
                                                                </thead>
                                                                <tr>
                                                                    <th><a class="hintstyle" href="javascript:void(0);" onClick="openOverHint(65);">启用代理</a></th>
                                                                    <td colspan="4">
                                                                        <input type="radio" value="0" name="lzr_wan1_udpxy_switch" class="content_input_fd">启用
                                                                        <input type="radio" value="5" name="lzr_wan1_udpxy_switch" class="content_input_fd">停用
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <th><a class="hintstyle" href="javascript:void(0);" onClick="openOverHint(66);">UDPXY 端口号 (1~65535)</a></th>
                                                                    <td>
                                                                        <input type="number" min="1" max="65535" maxlength="5" class="input_6_table" id="lzr_wan1_udpxy_port" name="lzr_wan1_udpxy_port" value="8686" onkeypress="return validator.isNumber(this, event);" onchange="checkNumberField(this, 8686)" autocorrect="off" autocapitalize="off">
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <th><a class="hintstyle" href="javascript:void(0);" onClick="openOverHint(67);">UDPXY 缓冲区 (4096~2097152 bytes)</a></th>
                                                                    <td>
                                                                        <input type="number" min="4096" max="2097152" maxlength="7" class="input_12_table" id="lzr_wan1_udpxy_buffer" name="lzr_wan1_udpxy_buffer" value="65536" onkeypress="return validator.isNumber(this, event);" onchange="checkNumberField(this, 65536)" autocorrect="off" autocapitalize="off">
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <th><a class="hintstyle" href="javascript:void(0);" onClick="openOverHint(68);">UDPXY 客户端数量 (1~5000)</a></th>
                                                                    <td>
                                                                        <input type="number" min="1" max="5000" maxlength="4" class="input_6_table" id="lzr_wan1_udpxy_client_num" name="lzr_wan1_udpxy_client_num" value="10" onkeypress="return validator.isNumber(this, event);" onchange="checkNumberField(this, 10)" autocorrect="off" autocapitalize="off">
                                                                    </td>
                                                                </tr>
                                                            </table>
                                                            <table width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable">
                                                                <thead>
                                                                    <tr>
                                                                        <td colspan="2"><a class="hintstyle" href="javascript:void(0);" onClick="openOverHint(69);">第二 WAN UDPXY 组播转 HTTP 流传输代理</a></td>
                                                                    </tr>
                                                                </thead>
                                                                <tr>
                                                                    <th><a class="hintstyle" href="javascript:void(0);" onClick="openOverHint(70);">启用代理</a></th>
                                                                    <td colspan="4">
                                                                        <input type="radio" value="0" name="lzr_wan2_udpxy_switch" class="content_input_fd">启用
                                                                        <input type="radio" value="5" name="lzr_wan2_udpxy_switch" class="content_input_fd">停用
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <th><a class="hintstyle" href="javascript:void(0);" onClick="openOverHint(71);">UDPXY 端口号 (1~65535)</a></th>
                                                                    <td>
                                                                        <input type="number" min="1" max="65535" maxlength="5" class="input_6_table" id="lzr_wan2_udpxy_port" name="lzr_wan2_udpxy_port" value="8888" onkeypress="return validator.isNumber(this, event);" onchange="checkNumberField(this, 8888)" autocorrect="off" autocapitalize="off">
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <th><a class="hintstyle" href="javascript:void(0);" onClick="openOverHint(72);">UDPXY 缓冲区 (4096~2097152 bytes)</a></th>
                                                                    <td>
                                                                        <input type="number" min="4096" max="2097152" maxlength="7" class="input_12_table" id="lzr_wan2_udpxy_buffer" name="lzr_wan2_udpxy_buffer" value="65536" onkeypress="return validator.isNumber(this, event);" onchange="checkNumberField(this, 65536)" autocorrect="off" autocapitalize="off">
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <th><a class="hintstyle" href="javascript:void(0);" onClick="openOverHint(73);">UDPXY 客户端数量 (1~5000)</a></th>
                                                                    <td>
                                                                        <input type="number" min="1" max="5000" maxlength="4" class="input_6_table" id="lzr_wan2_udpxy_client_num" name="lzr_wan2_udpxy_client_num" value="10" onkeypress="return validator.isNumber(this, event);" onchange="checkNumberField(this, 10)" autocorrect="on" autocapitalize="on">
                                                                    </td>
                                                                </tr>
                                                            </table>
                                                        </div>
                                                        <div id="insertScriptConfig" style="display:none;">
                                                            <table width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable">
                                                                <thead>
                                                                    <tr>
                                                                        <td colspan="2"><a class="hintstyle" href="javascript:void(0);" onClick="openOverHint(74);">外置脚本设置</a></td>
                                                                    </tr>
                                                                </thead>
                                                                <tr>
                                                                    <th rowspan="2"><a class="hintstyle" href="javascript:void(0);" onClick="openOverHint(75);">外置用户自定义清理资源脚本</a></th>
                                                                    <td colspan="4">
                                                                        <input type="radio" value="0" name="lzr_custom_clear_scripts" class="content_input_fd">启用
                                                                        <input type="radio" value="5" name="lzr_custom_clear_scripts" class="content_input_fd">停用
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <td>
                                                                        <input id="lzr_custom_clear_scripts_filename" type="text" maxlength="255" class="input_32_table" name="lzr_custom_clear_scripts_filename" value="/jffs/scripts/lz/custom_clear_scripts.sh" onchange="checkTextField(this);" autocorrect="off" autocapitalize="off">
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <th rowspan="2"><a class="hintstyle" href="javascript:void(0);" onClick="openOverHint(76);">外置用户自定义配置脚本</a></th>
                                                                    <td colspan="4">
                                                                        <input type="radio" value="0" name="lzr_custom_config_scripts" class="content_input_fd">启用
                                                                        <input type="radio" value="5" name="lzr_custom_config_scripts" class="content_input_fd">停用
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <td>
                                                                        <input id="lzr_custom_config_scripts_filename" type="text" maxlength="255" class="input_32_table" name="lzr_custom_config_scripts_filename" value="/jffs/scripts/lz/custom_config.sh" onchange="checkTextField(this);" autocorrect="off" autocapitalize="off">
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <th rowspan="2"><a class="hintstyle" href="javascript:void(0);" onClick="openOverHint(77);">外置用户自定义双线路脚本</a></th>
                                                                    <td colspan="4">
                                                                        <input type="radio" value="0" name="lzr_custom_dualwan_scripts" class="content_input_fd">启用
                                                                        <input type="radio" value="5" name="lzr_custom_dualwan_scripts" class="content_input_fd">停用
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <td>
                                                                        <input id="lzr_custom_dualwan_scripts_filename" type="text" maxlength="255" class="input_32_table" name="lzr_custom_dualwan_scripts_filename" value="/jffs/scripts/lz/custom_dualwan_scripts.sh" onchange="checkTextField(this);" autocorrect="off" autocapitalize="off">
                                                                    </td>
                                                                </tr>
                                                            </table>
                                                        </div>
                                                        <div id="scriptTools" style="display:none;">
                                                            <table width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable">
                                                                <thead>
                                                                    <tr>
                                                                        <td colspan="2"><a class="hintstyle" href="javascript:void(0);" onClick="openOverHint(85);">快捷命令</a></td>
                                                                    </tr>
                                                                </thead>
                                                                <tr>
                                                                    <th><a class="hintstyle" href="javascript:void(0);" onClick="openOverHint(86);">命令</a></th>
                                                                    <td>
                                                                        <select id="cmdMethod" name="cmdMethod" class="input_option" style="margin-left:2px;" onchange="hideCNT(this.value);">
                                                                            <option value="0" selected>查询路由器出口</option>
                                                                            <option value="1">显示系统路由表</option>
                                                                            <option value="2">显示系统路由规则</option>
                                                                            <option value="3">显示系统防火墙规则链</option>
                                                                            <option value="4">显示系统定时任务</option>
                                                                            <option value="5">显示 firewall-start 启动项</option>
                                                                            <option value="6">显示 service-event 服务触发项&nbsp;</option>
                                                                            <option value="7">显示 openvpn-event 事件触发项</option>
                                                                            <option value="8">显示 post-mount 挂载启动项</option>
                                                                            <option value="9">显示 dnsmasq.conf.add 配置项</option>
                                                                            <option value="10">更新运营商 IP 地址数据</option>
                                                                            <option value="11">解除程序运行锁</option>
                                                                            <option value="12">恢复缺省配置参数</option>
                                                                            <option value="13">卸载策略路由</option>
                                                                        </select>
                                                                    </td>
                                                                </tr>
                                                                <tr id="destIPCNT_tr">
                                                                    <th><a class="hintstyle" href="javascript:void(0);" onClick="openOverHint(87);">目标</a></th>
                                                                    <td>
                                                                        <input id="destIP" type="text" maxlength="100" class="input_32_table" name="destIP" onClick="hideClients_Block();" value="" onchange="checkdestIPTextField(this);" placeholder="ex: www.google.com" autocorrect="off" autocapitalize="off">
                                                                        <img id="pull_arrow" height="14px;" src="/ext/lzr/arrow-down.gif" style="position:absolute;*margin-left:-3px;*margin-top:1px;" onclick="pullLANIPList(this);" title="选择互联网服务地址。" onmouseover="over_var=1;" onmouseout="over_var=0;">
                                                                        <div id="ClientList_Block_PC" class="ClientList_Block_PC"></div>
                                                                        <br />
                                                                        <span id="alert_block" style="color:#FC0;display:none;"></span>
                                                                    </td>
                                                                </tr>
                                                                <tr id="dnsIPAddressCNT_tr">
                                                                    <th><a class="hintstyle" href="javascript:void(0);" onClick="openOverHint(88);">DNS 服务器</a></th>
                                                                    <td>
                                                                        <input type="text" maxlength="15" class="input_15_table" id="dnsIPAddress" name="dnsIPAddress" value="" onKeyPress="return validator.isIPAddr(this, event);" onchange="checkDNSIPaddrField(this);" placeholder="ex: 8.8.8.8" autocorrect="off" autocapitalize="off">
                                                                    </td>
                                                                </tr>
                                                            </table>
                                                            <div class="apply_gen">
                                                                <input name="toolsButton" id="toolsButton" type="button" class="button_gen" onclick="toolsCommand()" value="执行命令"/>
                                                                <img id="loadingToolsIcon" style="display:none;" src="/ext/lzr/InternetScan.gif">
                                                            </div>
                                                            <div style="margin-top:8px">
                                                                <textarea cols="63" rows="27" wrap="off" readonly="readonly" id="toolsTextArea" class="textarea_ssh_table" style="width:99%; font-family:'Courier New', Courier, mono; font-size:11px;background-color:black;"></textarea>
                                                            </div>
                                                        </div>
                                                        <div id="Donation" style="display:none;">
                                                            <table width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable"></table>
                                                            <div class="formfontdesc">
                                                                <p align="center">
                                                                    <br /><br />
                                                                    <a class="hintstyle" href="javascript:void(0);" onClick="openOverHint(102);">
                                                                        <img src="/ext/lzr/wechat.png" alt="wechat.png" height="360px" title="攒钱买盒饭。" onmouseover="over_var=1;" onmouseout="over_var=0;">
                                                                    </a>
                                                                    <span style="margin-left:40px;"></span>
                                                                    <a class="hintstyle" href="javascript:void(0);" onClick="openOverHint(103);">
                                                                        <img src="/ext/lzr/alipay.png" alt="alipay.png" height="360px" title="海外孤品，清仓捡漏。" onmouseover="over_var=1;" onmouseout="over_var=0;">
                                                                    </a>
                                                                </p>
                                                                <p style="margin-left:55px;"><br />小众需求，专业品质。开源不易，欢迎投喂！😘<br /><br /></p>
                                                            </div>
                                                        </div>
                                                        <div class="apply_gen" title="启动/重启/保存。" onmouseover="over_var=1;" onmouseout="over_var=0;">
                                                            <input name="button" type="button" class="button_gen" onclick="applyRule()" value="应用本页面设置"/>
                                                        </div>
                                                    </form>
                                                    <form method="post" name="scriptActionsForm" action="/start_apply.htm" target="hidden_frame">
                                                        <input type="hidden" name="current_page" value="">
                                                        <input type="hidden" name="next_page" value="">
                                                        <input type="hidden" name="action_mode" value="apply">
                                                        <input type="hidden" name="action_script" value="">
                                                        <input type="hidden" name="action_wait" value="">
                                                    </form>
                                                </td>
                                            </tr>
                                        </tbody>
                                    </table>
                                </td>
                            </tr>
                        </table>
                    </td>
                    <td width="10" align="center" valign="top">&nbsp;</td>
                </tr>
            </table>
            <div id="footer"></div>
        </body>
    </html>
</html>
