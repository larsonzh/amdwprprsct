<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<html xmlns:v>
<head>
<meta http-equiv="X-UA-Compatible" content="IE=Edge"/>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<meta HTTP-EQUIV="Pragma" CONTENT="no-cache">
<meta HTTP-EQUIV="Expires" CONTENT="-1">
<link rel="shortcut icon" href="images/favicon.png">
<link rel="icon" href="images/favicon.png">
<title>LZ - Policy Routing</title>
<link rel="stylesheet" type="text/css" href="index_style.css">
<link rel="stylesheet" type="text/css" href="form_style.css">
<link rel="stylesheet" type="text/css" href="device-map/device-map.css">
<script language="JavaScript" type="text/javascript" src="/state.js"></script>
<script type="text/javascript" language="JavaScript" src="/help.js"></script>
<script language="JavaScript" type="text/javascript" src="/general.js"></script>
<script language="JavaScript" type="text/javascript" src="/popup.js"></script>
<script language="JavaScript" type="text/javascript" src="/client_function.js"></script>
<script language="JavaScript" type="text/javascript" src="/validator.js"></script>
<script language="JavaScript" type="text/javascript" src="/form.js"></script>
<script type="text/javascript" language="JavaScript" src="/js/jquery.js"></script>
<script type="text/javascript" src="/js/httpApi.js"></script>
<script type="text/javascript" src="/switcherplugin/jquery.iphone-switch.js"></script>

<script>

let policySettingsArray = {};
let divLabelArray = { "Basic" : [ "基础", "0", "0", "basicConfig" ], "Advanced" : [ "高级", "1", "0", "advancedConfig" ], "Runtime" : [ "运行", "2", "0", "runtimeConfig" ], "IPTV" : [ "IPTV", "3", "0", "iPTVConfig" ], "InsertScript" : [ "外置脚本", "4", "0", "insertScriptConfig" ] };
let customSettings;

function setPolicyRoutingPage() {
    document.form.current_page.value = window.location.pathname.substring(1);
    document.form.next_page.value = window.location.pathname.substring(1);
}

function getVersion() {
    policySettingsArray["version"] = "";
    $.ajax({
        async: false,
        url: '/ext/lzr/LZRVersion.html',
        dataType: 'text',
        error: function(xhr) {
            if (xhr.status != 404)
                setTimeout(getVersion, 1000);
        },
        success: function(result) {
            let buf = result.match(/^[ \t]*LZ_VERSION[=][\w\.]*/m);
            if (buf != null) policySettingsArray.version = (buf.length > 0) ? buf[0].replace(/^.*[=]/, "") : "";
        }
    });
}

function showProduct() {
    getVersion();
    let currentProductId = document.form.productid.value;
    (currentProductId == "undefined" || currentProductId == null || currentProductId == "") && (currentProductId = '<% nvram_get("odmpid"); %>');
    (currentProductId == "") && (currentProductId = '<% nvram_get("model"); %>');
    (currentProductId != "") && (currentProductId = " for " + currentProductId);
    if (policySettingsArray.hasOwnProperty("version") && policySettingsArray.version != "")
        $("#lzr_producid").html(`LZ RULE ${policySettingsArray.version} ${currentProductId} by 妙妙呜&#8482;`);
    else $("#lzr_producid").html(`LZ RULE ${currentProductId} by 妙妙呜&#8482;`);
}

function getPolicyState() {
    policySettingsArray["policyEnable"] = false;
    $.ajax({
        async: false,
        url: '/ext/lzr/LZRState.html',
        dataType: 'text',
        error: function(xhr) {
            if (xhr.status != 404)
                setTimeout(getPolicyState, 1000);
        },
        success: function(result) {
            policySettingsArray.policyEnable = result.match(/^[ \t]*[\w\/]+lz_rule[\.]sh[ \t]*([#].*){0,1}$/m) != null;
        }
    });
    return policySettingsArray.policyEnable;
}

function initPolicyEnableCtrl() {
    $('#lzr_policy_routing_enable').iphoneSwitch(getPolicyState(),
        function() {policySettingsArray["policyEnable"] = true;},
        function() {policySettingsArray["policyEnable"] = false;}
    );
}

function loadCustomSettings() {
    customSettings = '<% get_custom_settings(); %>';
    if (typeof customSettings == "string" && /^[ \t]*[\{]([ \t]*[\"][^\"]+[\"][ \t]*[\:][ \t]*[\"][^\"]*[\"][ \t][,])*[ \t]*[\"][^\"]+[\"][ \t]*[:][ \t]*[\"][^\"]*[\"][ \t][\}][ \t]*$|^[ \t]*[\{]([ \t]*[\"][^\"]+[\"][ \t]*[:][ \t]*[\"][^\"]*[\"][ \t]){0,1}[\}][ \t]*$/.test(customSettings)) {
        customSettings = JSON.parse(customSettings);
        for (let prop in customSettings) {
            if (Object.prototype.hasOwnProperty.call(customSettings, prop))
                if (prop.indexOf("lz_rule_") != -1)
                    eval("delete customSettings." + prop);
        }
    } else customSettings = undefined;
}

function isNewVersion() {
    let retVal = false;
    $.ajax({
        async: false,
        url: '/ext/lzr/LZRGlobal.html',
        dataType: 'text',
        error: function(xhr) {
            if (xhr.status != 404)
                setTimeout(isNewVersion, 1000);
        },
        success: function(result) {
            retVal = (result.match(/QnkgTFog5aaZ5aaZ5ZGc77yI6Juk6J[\+]G5aKp5YS[\/]77yJ/m) != null) ? true : false;
        }
    });
    return retVal;
}

function loadPolicySettings(flag) {
    let retVal = false;
    let fileUrl = '/ext/lzr/LZRConfig.html';
    if (flag != undefined)
        fileUrl = '/ext/lzr/LZRBKData.html';
    $.ajax({
        async: false,
        url: fileUrl,
        dataType: 'text',
        error: function(xhr) {
            if (xhr.status != 404)
                setTimeout(loadPolicySettings, 1000);
        },
        success: function(result) {
            let buf = result.match(/^[ \t]*[\w]+[=].*$/gm);
            if (buf == null) return;
            while (buf.length > 0) {
                buf[0] = buf[0].replace(/^[ \t]+|[# \t].*$|[\'\"]/g, "").split('=');
                buf[0][0] = "lzr_" + buf[0][0].replace(/^lz_config_/, "");
                (buf[0][1] == null) && (buf[0][1] = "");
                if (buf[0][1] == "true" || buf[0][1] == "false")
                    policySettingsArray[buf[0][0]] = JSON.parse(buf[0][1]);
                else if ((!isNaN(parseFloat(buf[0][1])) && isFinite(buf[0][1])))
                    policySettingsArray[buf[0][0]] = Number(buf[0][1]);
                else
                    policySettingsArray[buf[0][0]] = String(buf[0][1]);
                buf.splice(0, 1);
            }
            retVal = true;
        }
    });
    return retVal;
}

function initParseInt(value, min, max, defaultVal) {
    let patt = /^number$|^boolean$|^string$|^bigint$/;
    value = parseInt(patt.test(typeof value) ? value : 0);
    min = parseInt(patt.test(typeof min) ? min : 0);
    max = parseInt(patt.test(typeof max) ? max : 0);
    defaultVal = parseInt(patt.test(typeof defaultVal) ? defaultVal : 0);
    isNaN(value) && (value = 0);
    isNaN(min) && (min = 0);
    isNaN(max) && (max = 0);
    isNaN(defaultVal) && (defaultVal = 0);
    (value < min || value > max) && (value = defaultVal);
    return value;
}

function initCheckRadio(name, min, max, defaultVal) {
    if (!policySettingsArray.hasOwnProperty(name)) return;
    let value = initParseInt(policySettingsArray[name], min, max, defaultVal);
    let radioArray = document.getElementsByName(name);
    for (let i = 0; i < radioArray.length; i++) {
        if (radioArray[i].value == value)
            radioArray[i].checked = "checked";
        else
            radioArray[i].checked = "";
    }
}

function initListBox(name, min, max, defaultVal) {
    if (policySettingsArray.hasOwnProperty(name))
        $("#" + name).val(initParseInt(policySettingsArray[name], min, max, defaultVal));
}

function initNumberEdit(name, min, max, defaultVal) {
    if (policySettingsArray.hasOwnProperty(name))
        $("#" + name).val(initParseInt(policySettingsArray[name], min, max, defaultVal));
}

function initTextEdit(name) {
    if (policySettingsArray.hasOwnProperty(name))
        $("#" + name).val(policySettingsArray[name]);
}

function initControls() {
    initListBox("lzr_chinatelecom_wan_port", 0, 3, 5);
    initListBox("lzr_unicom_cnc_wan_port", 0, 3, 5);
    initListBox("lzr_cmcc_wan_port", 0, 3, 5);
    initListBox("lzr_crtc_wan_port", 0, 3, 5);
    initListBox("lzr_cernet_wan_port", 0, 3, 5);
    initListBox("lzr_gwbn_wan_port", 0, 3, 5);
    initListBox("lzr_othernet_wan_port", 0, 3, 5);
    initListBox("lzr_hk_wan_port", 0, 3, 5);
    initListBox("lzr_mo_wan_port", 0, 3, 5);
    initListBox("lzr_tw_wan_port", 0, 3, 5);
    initListBox("lzr_all_foreign_wan_port", 0, 1, 5);
    initCheckRadio("lzr_regularly_update_ispip_data_enable", 0, 0, 5);
    initListBox("lzr_ruid_interval_day", 1, 31, 5);
    initListBox("lzr_ruid_timer_hour", 0, 23, 404);
    initListBox("lzr_ruid_timer_min", 0, 59, 404);
    initNumberEdit("lzr_ruid_retry_num", 0, 99, 5);
    initListBox("lzr_custom_data_wan_port_1", 0, 2, 5);
    initTextEdit("lzr_custom_data_file_1");
    initListBox("lzr_custom_data_wan_port_2", 0, 2, 5);
    initTextEdit("lzr_custom_data_file_2");
    initCheckRadio("lzr_wan_1_domain", 0, 0, 5);
    initTextEdit("lzr_wan_1_domain_client_src_addr_file");
    initTextEdit("lzr_wan_1_domain_file");
    initCheckRadio("lzr_wan_2_domain", 0, 0, 5);
    initTextEdit("lzr_wan_2_domain_client_src_addr_file");
    initTextEdit("lzr_wan_2_domain_file");
    initCheckRadio("lzr_wan_1_client_src_addr", 0, 0, 5);
    initTextEdit("lzr_wan_1_client_src_addr_file");
    initCheckRadio("lzr_wan_2_client_src_addr", 0, 0, 5);
    initTextEdit("lzr_wan_2_client_src_addr_file");
    initCheckRadio("lzr_high_wan_1_client_src_addr", 0, 0, 5);
    initTextEdit("lzr_high_wan_1_client_src_addr_file");
    initCheckRadio("lzr_high_wan_2_client_src_addr", 0, 0, 5);
    initTextEdit("lzr_high_wan_2_client_src_addr_file");
    initCheckRadio("lzr_wan_1_src_to_dst_addr", 0, 0, 5);
    initTextEdit("lzr_wan_1_src_to_dst_addr_file");
    initCheckRadio("lzr_wan_2_src_to_dst_addr", 0, 0, 5);
    initTextEdit("lzr_wan_2_src_to_dst_addr_file");
    initCheckRadio("lzr_high_wan_1_src_to_dst_addr", 0, 0, 5);
    initTextEdit("lzr_high_wan_1_src_to_dst_addr_file");
    initTextEdit("lzr_wan0_dest_tcp_port");
    initTextEdit("lzr_wan0_dest_udp_port");
    initTextEdit("lzr_wan0_dest_udplite_port");
    initTextEdit("lzr_wan0_dest_sctp_port");
    initTextEdit("lzr_wan1_dest_tcp_port");
    initTextEdit("lzr_wan1_dest_udp_port");
    initTextEdit("lzr_wan1_dest_udplite_port");
    initTextEdit("lzr_wan1_dest_sctp_port");
    initCheckRadio("lzr_wan_1_src_to_dst_addr_port", 0, 0, 5);
    initTextEdit("lzr_wan_1_src_to_dst_addr_port_file");
    initCheckRadio("lzr_wan_2_src_to_dst_addr_port", 0, 0, 5);
    initTextEdit("lzr_wan_2_src_to_dst_addr_port_file");
    initCheckRadio("lzr_high_wan_1_src_to_dst_addr_port", 0, 0, 5);
    initTextEdit("lzr_high_wan_1_src_to_dst_addr_port_file");
    initTextEdit("lzr_local_ipsets_file");
    initCheckRadio("lzr_wan_access_port", 0, 1, 0);
    initListBox("lzr_ovs_client_wan_port", 0, 1, 5);
    initListBox("lzr_vpn_client_polling_time", 1, 20, 5);
    initCheckRadio("lzr_fancyss_support", 0, 0, 5);
    initCheckRadio("lzr_usage_mode", 0, 1, 0);
    initListBox("lzr_dn_pre_resolved", 0, 2, 5);
    initTextEdit("lzr_pre_dns");
    initNumberEdit("lzr_dn_cache_time", 0, 2147483, 864000);
    initCheckRadio("lzr_route_cache", 0, 0, 5);
    initCheckRadio("lzr_drop_sys_caches", 0, 0, 5);
    initListBox("lzr_clear_route_cache_time_interval", 0, 24, 4);
    initListBox("lzr_wan1_iptv_mode", 0, 1, 5);
    initListBox("lzr_wan2_iptv_mode", 0, 1, 5);
    initListBox("lzr_iptv_igmp_switch", 0, 1, 5);
    initCheckRadio("lzr_iptv_access_mode", 1, 2, 1);
    initTextEdit("lzr_iptv_box_ip_lst_file");
    initTextEdit("lzr_iptv_isp_ip_lst_file");
    initListBox("lzr_hnd_br0_bcmmcast_mode", 0, 2, 2);
    initCheckRadio("lzr_wan1_udpxy_switch", 0, 0, 5);
    initNumberEdit("lzr_wan1_udpxy_port", 1, 65535, 8686);
    initNumberEdit("lzr_wan1_udpxy_buffer", 4096, 2097152, 65536);
    initNumberEdit("lzr_wan1_udpxy_client_num", 1, 5000, 10);
    initCheckRadio("lzr_wan2_udpxy_switch", 0, 0, 5);
    initNumberEdit("lzr_wan2_udpxy_port", 1, 65535, 8888);
    initNumberEdit("lzr_wan2_udpxy_buffer", 4096, 2097152, 65536);
    initNumberEdit("lzr_wan2_udpxy_client_num", 1, 5000, 10);
    initCheckRadio("lzr_custom_clear_scripts", 0, 0, 5);
    initTextEdit("lzr_custom_clear_scripts_filename");
    initCheckRadio("lzr_custom_config_scripts", 0, 0, 5);
    initTextEdit("lzr_custom_config_scripts_filename");
    initCheckRadio("lzr_custom_dualwan_scripts", 0, 0, 5);
    initTextEdit("lzr_custom_dualwan_scripts_filename");
}

function checkNumberField(ptr) {
    if (ptr.value == "" && policySettingsArray.hasOwnProperty(ptr.id))
        ptr.value = policySettingsArray[ptr.id];
    else {
        if (ptr.max != "" && ptr.value > ptr.max)
            ptr.value = ptr.max;
        else if (ptr.min != "" && ptr.value < ptr.min)
            ptr.value = ptr.min;
        else if (policySettingsArray.hasOwnProperty(ptr.id))
            ptr.value = policySettingsArray[ptr.id];
    }
}

function checkTextField(ptr) {
    let str = ptr.value.replace(/[^\w\/\.\-]+/g, "").replace(/[\/][\/]+/g, "\/").replace(/[\.][\.]+/g, "\.");
    if (str == "" && policySettingsArray.hasOwnProperty(ptr.id)) ptr.value = policySettingsArray[ptr.id];
    else if (str != ptr.value) ptr.value = str;
}

function checkPortTextField(ptr) {
    let str = ptr.value.replace(/[^\d\:\,]+/g, "").replace(/[\,][\,]+/g, "\,").replace(/[\:][\:]+/g, "\:").replace(/[^\d][^\d]+/g, "\,").replace(/([\:][\d]+)([\:][\d]+)+/g, "$1").replace(/^[^\d]*(([\d]+([\:][\d]+)*[\,]){15}).*$/, "$1").replace(/^[^\d]+|[^\d]+$/g, "");
    if (str != ptr.value) ptr.value = str;
}

function checkIPaddrField(ptr) {
    let patt = /^[0]*([\d]+[\.])[0]*([\d]+[\.])[0]*([\d]+[\.])[0]*([\d]+$)/;
    let val = ptr.value.replace(patt,"$1$2$3$4");
    if (val != ptr.value) ptr.value = val;
    patt = /^((?:(?:[2][5][0-5]|[2][0-4][\d]|[01]?[\d]?[\d])[\.]){3}(?:[2][5][0-5]|[2][0-4][\d]|[01]?[\d]?[\d]))$/;
    if (!patt.test(val)) ptr.value = "8.8.8.8";
}

function inithideDivPage() {
    for (let key in divLabelArray) {
        if (divLabelArray.hasOwnProperty(key)) {
            $("#" + divLabelArray[key][3]).hide();
            divLabelArray[key][2] = "0";
        }
    }
}

function hideDivPage() {
    for (let key in divLabelArray) {
        if (divLabelArray.hasOwnProperty(key)) {
            if (divLabelArray[key][2] != "0") {
                $("#" + divLabelArray[key][3]).hide();
                divLabelArray[key][2] = "0";
            }
        }
    }
}

function genSwitchMenu(_arrayList, _currentItem) {
    let getLength = function(obj) {
        let i = 0, key;
        for (key in obj) {
            if (obj.hasOwnProperty(key))
                i++;
        }
        return i;
    };
    let code = "";
    let array_list_num = getLength(_arrayList);
    if(array_list_num > 1) {
        let left_css = "border-top-left-radius:8px;border-bottom-left-radius:8px;";
        let right_css = "border-top-right-radius:8px;border-bottom-right-radius:8px;";
        let gen_pressed_content = function(_itemArray, _cssMode) {
            let pressed_code = "";
            pressed_code += "<div style='width:110px;height:30px;float:left;" + _cssMode + "' class='block_filter_pressed'>";
            pressed_code += "<div style='text-align:center;padding-top:5px;font-size:14px'>" + _itemArray[0] + "</div>";
            pressed_code += "</div>";
            return pressed_code;
        };
        let gen_not_pressed_content = function(_itemArray, _cssMode) {
            let not_pressed_code = "";
            not_pressed_code += "<div style='cursor:pointer;width:110px;height:30px;float:left;" + _cssMode + "' onclick='switchDivPage(" + _itemArray[1] + ");' class='block_filter'>";
            not_pressed_code += "<div class='block_filter_name'>" + _itemArray[0] + "</div>";
            not_pressed_code += "</div>";
            return not_pressed_code;
        };
        let loop_idx_end = array_list_num;
        let loop_idx = 1;
        for (let key in _arrayList) {
            if (_arrayList.hasOwnProperty(key)) {
                let cssMode = "";
                if(loop_idx == 1)
                    cssMode = left_css;
                else if(loop_idx == loop_idx_end)
                    cssMode = right_css;
                if(_currentItem == key)
                    code += gen_pressed_content(_arrayList[key], cssMode);
                else
                    code += gen_not_pressed_content(_arrayList[key], cssMode);
                loop_idx++;
            }
        }
        return code;
    }
}

function switchDivPage(index) {
    let getKey = function(obj, index) {
        for (let key in obj) {
            if (obj.hasOwnProperty(key))
                if (parseInt(obj[key][1]) == index) return key;
        }
        return "";
    };
    let key = getKey(divLabelArray, index);
    if (key == "") return;
    $('#divSwitchMenu').html(genSwitchMenu(divLabelArray, key));
    hideDivPage();
    $("#" + divLabelArray[key][3]).show();
    divLabelArray[key][2] = "1";
}

function initSwitchDivPage() {
    $('#divSwitchMenu').html(genSwitchMenu(divLabelArray, "Basic"));
    switchDivPage(divLabelArray["Basic"][1]);
}

function setMouseOut(num) {
    if (num == undefined || (num !== 0 && num !== 1)) return;
    var tag_name = document.getElementsByTagName('a');
    for (let i = 0; i < tag_name.length; i++)
            tag_name[i].onmouseout = (num == 0) ? nd : null;
}

function openOverHint(itemNum) {
    if (itemNum == undefined || itemNum == "" || isNaN(itemNum)) return;
    let content = "", caption = "", mode = 0;
    if (itemNum == 1) {
        content = "<div>互联网所有 IP 地址分属不同机构和运营商管理，本策略以中国区用户使用为基础，将 IP 地址划分为 11 个运营区段，按管理范围分配全球互联网流量出口，选项包括："
        content += "<ul>";
        content += "<li>首选 WAN</li>";
        content += "<li>第二 WAN</li>";
        content += "<li>出口均分</li>";
        content += "<li>反向均分</li>";
        content += "<li>负载均衡</li>";
        content += "</ul>";
        content += "<b>出口均分</b>：将所选<b>运营商 IP 地址</b>条目数据平均划分为两部分，前一部分匹配<b>首选 WAN</b>，后一部分匹配<b>第二 WAN</b>。<br />";
        content += "<br /><b>反向均分</b>：将<b>出口均分</b>的流量出口匹配方式倒置。<br />";
        content += "<br /><b>负载均衡</b>：由系统采用链路负载均衡技术自动分配流量出口，但容易导致网络访问不正常。<br />";
        content += "<br /><b>策略执行优先级</b>：详见<b>基本设置&nbsp;-&nbsp;策略路由优先级</b></div>";
    } else if (itemNum == 2) {
        content = "<div><b>中国电信</b>流量出口选项："
        content += "<ul>";
        content += "<li>首选 WAN (缺省)</li>";
        content += "<li>第二 WAN</li>";
        content += "<li>出口均分</li>";
        content += "<li>反向均分</li>";
        content += "<li>负载均衡</li>";
        content += "</ul>";
        content += "<b>出口均分</b>：将<b>中国电信 IP 地址</b>条目数据平均划分为两部分，前一部分匹配<b>首选 WAN</b>，后一部分匹配<b>第二 WAN</b>。<br />";
        content += "<br /><b>反向均分</b>：将<b>出口均分</b>的流量出口匹配方式倒置。<br />";
        content += "<br /><b>负载均衡</b>：由系统采用链路负载均衡技术自动分配流量出口，但容易导致网络访问不正常。<br />";
        content += "<br /><b>策略执行优先级</b>：详见<b>基本设置&nbsp;-&nbsp;策略路由优先级</b></div>";
    } else if (itemNum == 3) {
        content = "<div><b>中国联通/网通</b>流量出口选项："
        content += "<ul>";
        content += "<li>首选 WAN (缺省)</li>";
        content += "<li>第二 WAN</li>";
        content += "<li>出口均分</li>";
        content += "<li>反向均分</li>";
        content += "<li>负载均衡</li>";
        content += "</ul>";
        content += "<b>出口均分</b>：将<b>中国联通/网通 IP 地址</b>条目数据平均划分为两部分，前一部分匹配<b>首选 WAN</b>，后一部分匹配<b>第二 WAN</b>。<br />";
        content += "<br /><b>反向均分</b>：将<b>出口均分</b>的流量出口匹配方式倒置。<br />";
        content += "<br /><b>负载均衡</b>：由系统采用链路负载均衡技术自动分配流量出口，但容易导致网络访问不正常。<br />";
        content += "<br /><b>策略执行优先级</b>：详见<b>基本设置&nbsp;-&nbsp;策略路由优先级</b></div>";
    } else if (itemNum == 4) {
        content = "<div><b>中国移动</b>流量出口选项："
        content += "<ul>";
        content += "<li>首选 WAN</li>";
        content += "<li>第二 WAN (缺省)</li>";
        content += "<li>出口均分</li>";
        content += "<li>反向均分</li>";
        content += "<li>负载均衡</li>";
        content += "</ul>";
        content += "<b>出口均分</b>：将<b>中国移动 IP 地址</b>条目数据平均划分为两部分，前一部分匹配<b>首选 WAN</b>，后一部分匹配<b>第二 WAN</b>。<br />";
        content += "<br /><b>反向均分</b>：将<b>出口均分</b>的流量出口匹配方式倒置。<br />";
        content += "<br /><b>负载均衡</b>：由系统采用链路负载均衡技术自动分配流量出口，但容易导致网络访问不正常。<br />";
        content += "<br /><b>策略执行优先级</b>：详见<b>基本设置&nbsp;-&nbsp;策略路由优先级</b></div>";
    } else if (itemNum == 5) {
        content = "<div><b>中国铁通</b>流量出口选项："
        content += "<ul>";
        content += "<li>首选 WAN</li>";
        content += "<li>第二 WAN (缺省)</li>";
        content += "<li>出口均分</li>";
        content += "<li>反向均分</li>";
        content += "<li>负载均衡</li>";
        content += "</ul>";
        content += "<b>出口均分</b>：将<b>中国铁通 IP 地址</b>条目数据平均划分为两部分，前一部分匹配<b>首选 WAN</b>，后一部分匹配<b>第二 WAN</b>。<br />";
        content += "<br /><b>反向均分</b>：将<b>出口均分</b>的流量出口匹配方式倒置。<br />";
        content += "<br /><b>负载均衡</b>：由系统采用链路负载均衡技术自动分配流量出口，但容易导致网络访问不正常。<br />";
        content += "<br /><b>策略执行优先级</b>：详见<b>基本设置&nbsp;-&nbsp;策略路由优先级</b></div>";
    } else if (itemNum == 6) {
        content = "<div><b>中国教育网</b>流量出口选项："
        content += "<ul>";
        content += "<li>首选 WAN</li>";
        content += "<li>第二 WAN (缺省)</li>";
        content += "<li>出口均分</li>";
        content += "<li>反向均分</li>";
        content += "<li>负载均衡</li>";
        content += "</ul>";
        content += "<b>出口均分</b>：将<b>中国教育网 IP 地址</b>条目数据平均划分为两部分，前一部分匹配<b>首选 WAN</b>，后一部分匹配<b>第二 WAN</b>。<br />";
        content += "<br /><b>反向均分</b>：将<b>出口均分</b>的流量出口匹配方式倒置。<br />";
        content += "<br /><b>负载均衡</b>：由系统采用链路负载均衡技术自动分配流量出口，但容易导致网络访问不正常。<br />";
        content += "<br /><b>策略执行优先级</b>：详见<b>基本设置&nbsp;-&nbsp;策略路由优先级</b></div>";
    } else if (itemNum == 7) {
        content = "<div><b>长城宽带/鹏博士</b>流量出口选项："
        content += "<ul>";
        content += "<li>首选 WAN</li>";
        content += "<li>第二 WAN (缺省)</li>";
        content += "<li>出口均分</li>";
        content += "<li>反向均分</li>";
        content += "<li>负载均衡</li>";
        content += "</ul>";
        content += "<b>出口均分</b>：将<b>长城宽带/鹏博士 IP 地址</b>条目数据平均划分为两部分，前一部分匹配<b>首选 WAN</b>，后一部分匹配<b>第二 WAN</b>。<br />";
        content += "<br /><b>反向均分</b>：将<b>出口均分</b>的流量出口匹配方式倒置。<br />";
        content += "<br /><b>负载均衡</b>：由系统采用链路负载均衡技术自动分配流量出口，但容易导致网络访问不正常。<br />";
        content += "<br /><b>策略执行优先级</b>：详见<b>基本设置&nbsp;-&nbsp;策略路由优先级</b></div>";
    } else if (itemNum == 8) {
        content = "<div><b>中国大陆其他</b>运营商流量出口选项："
        content += "<ul>";
        content += "<li>首选 WAN (缺省)</li>";
        content += "<li>第二 WAN</li>";
        content += "<li>出口均分</li>";
        content += "<li>反向均分</li>";
        content += "<li>负载均衡</li>";
        content += "</ul>";
        content += "<b>出口均分</b>：将<b>中国大陆其他运营商 IP 地址</b>条目数据平均划分为两部分，前一部分匹配<b>首选 WAN</b>，后一部分匹配<b>第二 WAN</b>。<br />";
        content += "<br /><b>反向均分</b>：将<b>出口均分</b>的流量出口匹配方式倒置。<br />";
        content += "<br /><b>负载均衡</b>：由系统采用链路负载均衡技术自动分配流量出口，但容易导致网络访问不正常。<br />";
        content += "<br /><b>策略执行优先级</b>：详见<b>基本设置&nbsp;-&nbsp;策略路由优先级</b></div>";
    } else if (itemNum == 9) {
        content = "<div><b>香港特区</b>运营商流量出口选项："
        content += "<ul>";
        content += "<li>首选 WAN (缺省)</li>";
        content += "<li>第二 WAN</li>";
        content += "<li>出口均分</li>";
        content += "<li>反向均分</li>";
        content += "<li>负载均衡</li>";
        content += "</ul>";
        content += "<b>出口均分</b>：将<b>香港特区运营商 IP 地址</b>条目数据平均划分为两部分，前一部分匹配<b>首选 WAN</b>，后一部分匹配<b>第二 WAN</b>。<br />";
        content += "<br /><b>反向均分</b>：将<b>出口均分</b>的流量出口匹配方式倒置。<br />";
        content += "<br /><b>负载均衡</b>：由系统采用链路负载均衡技术自动分配流量出口，但容易导致网络访问不正常。<br />";
        content += "<br /><b>策略执行优先级</b>：详见<b>基本设置&nbsp;-&nbsp;策略路由优先级</b></div>";
    } else if (itemNum == 10) {
        content = "<div><b>澳门特区</b>运营商流量出口选项："
        content += "<ul>";
        content += "<li>首选 WAN (缺省)</li>";
        content += "<li>第二 WAN</li>";
        content += "<li>出口均分</li>";
        content += "<li>反向均分</li>";
        content += "<li>负载均衡</li>";
        content += "</ul>";
        content += "<b>出口均分</b>：将<b>澳门特区运营商 IP 地址</b>条目数据平均划分为两部分，前一部分匹配<b>首选 WAN</b>，后一部分匹配<b>第二 WAN</b>。<br />";
        content += "<br /><b>反向均分</b>：将<b>出口均分</b>的流量出口匹配方式倒置。<br />";
        content += "<br /><b>负载均衡</b>：由系统采用链路负载均衡技术自动分配流量出口，但容易导致网络访问不正常。<br />";
        content += "<br /><b>策略执行优先级</b>：详见<b>基本设置&nbsp;-&nbsp;策略路由优先级</b></div>";
    } else if (itemNum == 11) {
        content = "<div><b>台湾省</b>运营商流量出口选项："
        content += "<ul>";
        content += "<li>首选 WAN (缺省)</li>";
        content += "<li>第二 WAN</li>";
        content += "<li>出口均分</li>";
        content += "<li>反向均分</li>";
        content += "<li>负载均衡</li>";
        content += "</ul>";
        content += "<b>出口均分</b>：将<b>台湾省运营商 IP 地址</b>条目数据平均划分为两部分，前一部分匹配<b>首选 WAN</b>，后一部分匹配<b>第二 WAN</b>。<br />";
        content += "<br /><b>反向均分</b>：将<b>出口均分</b>的流量出口匹配方式倒置。<br />";
        content += "<br /><b>负载均衡</b>：由系统采用链路负载均衡技术自动分配流量出口，但容易导致网络访问不正常。<br />";
        content += "<br /><b>策略执行优先级</b>：详见<b>基本设置&nbsp;-&nbsp;策略路由优先级</b></div>";
    } else if (itemNum == 12) {
        content = "<div><b>国外运营商</b>流量出口选项："
        content += "<ul>";
        content += "<li>首选 WAN (缺省)</li>";
        content += "<li>第二 WAN</li>";
        content += "<li>负载均衡</li>";
        content += "</ul>";
        content += "<b>负载均衡</b>：由系统采用链路负载均衡技术自动分配流量出口，但容易导致网络访问不正常。<br />";
        content += "<br /><b>策略执行优先级</b>：详见<b>基本设置&nbsp;-&nbsp;策略路由优先级</b></div>";
    } else if (itemNum == 13) {
        content = "<div><b>运营商 IP 地址数据</b>经常发生变化，建议<b>启用定时更新</b>。</div>";
    } else if (itemNum == 14) {
        content = "<div><b>动态分流模式</b>时自动与同一出口的运营商 IP 地址数据合集，采用同一条限定优先级的动态路由策略。<br />";
        content += "<br /><b>静态分流模式</b>时采用专属的自定义目标 IP 地址静态路由策略。<br />";
        content += "<br /><b>策略执行优先级</b>：详见<b>基本设置&nbsp;-&nbsp;策略路由优先级</b></div>";
    } else if (itemNum == 15) {
        content = "<div><b>自定义策略 - 1</b> 流量出口选项："
        content += "<ul>";
        content += "<li>首选 WAN</li>";
        content += "<li>第二 WAN</li>";
        content += "<li>负载均衡</li>";
        content += "<li>停用 (缺省)</li>";
        content += "</ul>";
        content += "<b>负载均衡</b>：由系统采用链路负载均衡技术自动分配流量出口，但容易导致网络访问不正常。<br />";
        content += "<br /><b>策略执行优先级</b>：详见<b>基本设置&nbsp;-&nbsp;策略路由优先级</b></div>";
    } else if (itemNum == 16) {
        content = "<div>缺省文件名为 <b>/jffs/scripts/lz/data/custom_data_1.txt</b>，无有效数据条目。<br />";
        content += "<br />文件路径、名称可自定义和修改，文件路径及名称不得为空。<br />";
        content += "<br />文本格式：一个网址/网段一行，为一个条目，可多行多个条目。<br />";
        content += "<br />此文件中 <b>0.0.0.0/0</b> 为无效地址。<br />";
        content += "<br />为避免软件升级更新或重新安装导致配置重置为缺省状态，建议更改文件名或文件存储路径。</div>";
    } else if (itemNum == 17) {
        content = "<div><b>自定义策略 - 2</b> 流量出口选项："
        content += "<ul>";
        content += "<li>首选 WAN</li>";
        content += "<li>第二 WAN</li>";
        content += "<li>负载均衡</li>";
        content += "<li>停用 (缺省)</li>";
        content += "</ul>";
        content += "<b>负载均衡</b>：由系统采用链路负载均衡技术自动分配流量出口，但容易导致网络访问不正常。<br />";
        content += "<br /><b>策略执行优先级</b>：详见<b>基本设置&nbsp;-&nbsp;策略路由优先级</b></div>";
    } else if (itemNum == 18) {
        content = "<div>为<b>客户端 IP 地址列表</b>中所有访问预设域名地址的设备设定流量出口。<br />";
        content += "<br />功能优先级高于<b>客户端静态直通策略</b>，低于<b>客户端至预设目标 IP 地址静态直通策略</b>、<b>高优先级客户端静态直通策略</b>和<b>客户端至预设目标 IP 地址静态直通策略</b>。<br />";
        content += "<br /><b>策略执行优先级</b>：详见<b>基本设置&nbsp;-&nbsp;策略路由优先级</b></div>";
    } else if (itemNum == 19) {
        content = "<div>文件中具体定义所有使用<b>首选 WAN 口域名地址动态访问策略</b>的客户端在本地网络中的 IP 地址。<br />";
        content += "<br />缺省文件名为 <b>/jffs/scripts/lz/data/wan_1_domain_client_src_addr.txt</b>，无有效数据条目。<br />";
        content += "<br />文件路径、名称可自定义和修改，文件路径及名称不得为空。<br />";
        content += "<br />文本格式：一个网址/网段一行，为一个条目，可多行多个条目。<br />";
        content += "<br />可以用 <b>0.0.0.0/0</b> 表示所有客户端。<br />";
        content += "<br />为避免软件升级更新或重新安装导致配置重置为缺省状态，建议更改文件名或文件存储路径。</div>";
    } else if (itemNum == 20) {
        content = "<div>文件中具体定义所有使用<b>首选 WAN</b> 口作为流量出口的预设域名地址。<br />";
        content += "<br />缺省文件名为 <b>/jffs/scripts/lz/data/wan_1_domain.txt</b>，无有效数据条目。<br />";
        content += "<br />文件路径、名称可自定义和修改，文件路径及名称不得为空。<br />";
        content += "<br />文本格式：一个域名地址一行，为一个条目，可多行多个条目。<br />";
        content += "<br />为避免软件升级更新或重新安装导致配置重置为缺省状态，建议更改文件名或文件存储路径。</div>";
    } else if (itemNum == 21) {
        content = "<div>文件中具体定义所有使用<b>第二 WAN 口域名地址动态访问策略</b>的客户端在本地网络中的 IP 地址。<br />";
        content += "<br />缺省文件名为 <b>/jffs/scripts/lz/data/wan_2_domain_client_src_addr.txt</b>，无有效数据条目。<br />";
        content += "<br />文件路径、名称可自定义和修改，文件路径及名称不得为空。<br />";
        content += "<br />文本格式：一个网址/网段一行，为一个条目，可多行多个条目。<br />";
        content += "<br />可以用 <b>0.0.0.0/0</b> 表示所有客户端。<br />";
        content += "<br />为避免软件升级更新或重新安装导致配置重置为缺省状态，建议更改文件名或文件存储路径。</div>";
    } else if (itemNum == 22) {
        content = "<div>文件中具体定义所有使用<b>第二 WAN</b> 口作为流量出口的预设域名地址。<br />";
        content += "<br />缺省文件名为 <b>/jffs/scripts/lz/data/wan_2_domain.txt</b>，无有效数据条目。<br />";
        content += "<br />文件路径、名称可自定义和修改，文件路径及名称不得为空。<br />";
        content += "<br />文本格式：一个域名地址一行，为一个条目，可多行多个条目。<br />";
        content += "<br />为避免软件升级更新或重新安装导致配置重置为缺省状态，建议更改文件名或文件存储路径。</div>";
    } else if (itemNum == 23) {
        content = "<div>为<b>客户端 IP 地址列表</b>中所有使用固定出口的设备绑定流量出口。<br />";
        content += "<br /><b>策略执行优先级</b>：详见<b>基本设置&nbsp;-&nbsp;策略路由优先级</b></div>";
    } else if (itemNum == 24) {
        content = "<div>文件中具体定义所有使用<b>首选 WAN 口客户端静态直通策略</b>的客户端在本地网络中的 IP 地址。<br />";
        content += "<br />缺省文件名为 <b>/jffs/scripts/lz/data/wan_1_client_src_addr.txt</b>，无有效数据条目。<br />";
        content += "<br />文件路径、名称可自定义和修改，文件路径及名称不得为空。<br />";
        content += "<br />文本格式：一个网址/网段一行，为一个条目，可多行多个条目。<br />";
        content += "<br />可以用 <b>0.0.0.0/0</b> 表示所有客户端。<br />";
        content += "<br />为避免软件升级更新或重新安装导致配置重置为缺省状态，建议更改文件名或文件存储路径。</div>";
    } else if (itemNum == 25) {
        content = "<div>文件中具体定义所有使用<b>第二 WAN 口客户端静态直通策略</b>的客户端在本地网络中的 IP 地址。<br />";
        content += "<br />缺省文件名为 <b>/jffs/scripts/lz/data/wan_2_client_src_addr.txt</b>，无有效数据条目。<br />";
        content += "<br />文件路径、名称可自定义和修改，文件路径及名称不得为空。<br />";
        content += "<br />文本格式：一个网址/网段一行，为一个条目，可多行多个条目。<br />";
        content += "<br />可以用 <b>0.0.0.0/0</b> 表示所有客户端。<br />";
        content += "<br />为避免软件升级更新或重新安装导致配置重置为缺省状态，建议更改文件名或文件存储路径。</div>";
    } else if (itemNum == 26) {
        content = "<div>为<b>客户端 IP 地址列表</b>中所有使用固定出口的设备以高优先级方式绑定流量出口。<br />";
        content += "<br /><b>策略执行优先级</b>：详见<b>基本设置&nbsp;-&nbsp;策略路由优先级</b></div>";
    } else if (itemNum == 27) {
        content = "<div>文件中具体定义所有使用<b>首选 WAN 口高优先级客户端静态直通策略</b>的客户端在本地网络中的 IP 地址。<br />";
        content += "<br />缺省文件名为 <b>/jffs/scripts/lz/data/high_wan_1_client_src_addr.txt</b>，无有效数据条目。<br />";
        content += "<br />文件路径、名称可自定义和修改，文件路径及名称不得为空。<br />";
        content += "<br />文本格式：一个网址/网段一行，为一个条目，可多行多个条目。<br />";
        content += "<br />可以用 <b>0.0.0.0/0</b> 表示所有客户端。<br />";
        content += "<br />为避免软件升级更新或重新安装导致配置重置为缺省状态，建议更改文件名或文件存储路径。</div>";
    } else if (itemNum == 28) {
        content = "<div>文件中具体定义所有使用<b>第二 WAN 口高优先级客户端静态直通策略</b>的客户端在本地网络中的 IP 地址。<br />";
        content += "<br />缺省文件名为 <b>/jffs/scripts/lz/data/high_wan_2_client_src_addr.txt</b>，无有效数据条目。<br />";
        content += "<br />文件路径、名称可自定义和修改，文件路径及名称不得为空。<br />";
        content += "<br />文本格式：一个网址/网段一行，为一个条目，可多行多个条目。<br />";
        content += "<br />可以用 <b>0.0.0.0/0</b> 表示所有客户端。<br />";
        content += "<br />为避免软件升级更新或重新安装导致配置重置为缺省状态，建议更改文件名或文件存储路径。</div>";
    } else if (itemNum == 29) {
        content = "<div>指定客户端以静态路由方式访问预设目标 IP 地址时使用的流量出口。<br />";
        content += "<br /><b>策略执行优先级</b>：详见<b>基本设置&nbsp;-&nbsp;策略路由优先级</b></div>";
    } else if (itemNum == 30) {
        content = "<div>文件中具体定义使用<b>首选 WAN 口客户端至预设目标 IP 地址静态直通策略</b>的客户端 IP 地址和目标 IP 地址。<br />";
        content += "<br />缺省文件名为 <b>/jffs/scripts/lz/data/wan_1_src_to_dst_addr.txt</b>，无有效数据条目。<br />";
        content += "<br />文件路径、名称可自定义和修改，文件路径及名称不得为空。<br />";
        content += "<br />文本格式：每行的源地址和目标地址之间按顺序用空格隔开，一个条目一行，可多行多个条目。<br />";
        content += "<br />例如：<br />";
        content += "192.168.50.101&nbsp;103.10.4.108<br />";
        content += "0.0.0.0/0&nbsp;202.89.233.100<br />";
        content += "<br />可以用 <b>0.0.0.0/0</b> 表示所有未知IP地址。<br />";
        content += "<br />建议列表条目数量不要多于512条，否则易导致软件启动时系统策略路由库加载数据时间过长。<br />";
        content += "<br />为避免软件升级更新或重新安装导致配置重置为缺省状态，建议更改文件名或文件存储路径。</div>";
    } else if (itemNum == 31) {
        content = "<div>文件中具体定义使用<b>第二 WAN 口客户端至预设目标 IP 地址静态直通策略</b>的客户端 IP 地址和目标 IP 地址。<br />";
        content += "<br />缺省文件名为 <b>/jffs/scripts/lz/data/wan_2_src_to_dst_addr.txt</b>，无有效数据条目。<br />";
        content += "<br />文件路径、名称可自定义和修改，文件路径及名称不得为空。<br />";
        content += "<br />文本格式：每行的源地址和目标地址之间按顺序用空格隔开，一个条目一行，可多行多个条目。<br />";
        content += "<br />例如：<br />";
        content += "192.168.50.102&nbsp;210.74.0.0/16<br />";
        content += "<br />可以用 <b>0.0.0.0/0</b> 表示所有未知IP地址。<br />";
        content += "<br />建议列表条目数量不要多于512条，否则易导致软件启动时系统策略路由库加载数据时间过长。<br />";
        content += "<br />为避免软件升级更新或重新安装导致配置重置为缺省状态，建议更改文件名或文件存储路径。</div>";
    } else if (itemNum == 32) {
        content = "<div>指定客户端以高优先级的静态路由方式访问预设目标 IP 地址时使用的流量出口。<br />";
        content += "<br /><b>策略执行优先级</b>：详见<b>基本设置&nbsp;-&nbsp;策略路由优先级</b></div>";
    } else if (itemNum == 33) {
        content = "<div>文件中具体定义使用<b>首选 WAN 口高优先级客户端至预设目标 IP 地址静态直通策略</b>的客户端 IP 地址和目标 IP 地址。<br />";
        content += "<br />缺省文件名为 <b>/jffs/scripts/lz/data/high_wan_1_src_to_dst_addr.txt</b>，无有效数据条目。<br />";
        content += "<br />文件路径、名称可自定义和修改，文件路径及名称不得为空。<br />";
        content += "<br />文本格式：每行的源地址和目标地址之间按顺序用空格隔开，一个条目一行，可多行多个条目。<br />";
        content += "<br />例如：<br />";
        content += "192.168.50.0/27&nbsp;0.0.0.0/0<br />";
        content += "<br />可以用 <b>0.0.0.0/0</b> 表示所有未知IP地址。<br />";
        content += "<br />建议列表条目数量不要多于512条，否则易导致软件启动时系统策略路由库加载数据时间过长。<br />";
        content += "<br />为避免软件升级更新或重新安装导致配置重置为缺省状态，建议更改文件名或文件存储路径。</div>";
    } else if (itemNum == 34) {
        content = "<div>按照目标地址的协议端口设定流量出口。<br />";
        content += "<br />每个协议端口最多可设置 15 个不连续的目标访问端口号埠，仅针对 TCP、UDP、UDPLITE、SCTP 四类协议端口。<br />";
        content += "<br />输入框内容为空时表示对应的协议端口<b>停用</b>。<br />";
        content += "<br />例如：<br />";
        content += "TCP协议端口：80,443,6881:6889,25671<br />";
        content += "<br />其中：6881:6889 表示 6881~6889 的连续端口号，不连续的端口号埠之间用英文半角 <b>,</b> 逗号相隔，不要有多余空格。<br />";
        content += "<br />功能优先级低于<b>客户端静态直通策略</b>，高于<b>运营商 IP 地址访问策略</b>和<b>自定义目标 IP 地址访问策略</b><br />";
        content += "<br /><b>策略执行优先级</b>：详见<b>基本设置&nbsp;-&nbsp;策略路由优先级</b></div>";
    } else if (itemNum == 35) {
        content = "<div>定义客户端使用指定流量出口访问预设地址的协议端口，可一次性的同时实现多种灵活、精准的流量策略。<br />";
        content += "<br />仅用于 TCP、UDP、UDPLITE、SCTP 四类协议端口。<br />";
        content += "<br />功能优先级高于<b>域名地址动态访问策略</b>和<b>客户端静态直通策略</b>，低于<b>高优先级客户端静态直通策略</b>和<b>客户端至预设目标 IP 地址静态直通策略</b>。<br />";
        content += "<br /><b>策略执行优先级</b>：详见<b>基本设置&nbsp;-&nbsp;策略路由优先级</b></div>";
    } else if (itemNum == 36) {
        mode = 1;
        caption = " 客户端地址至目标地址协议端口列表";
        content = "<div>文件中具体定义客户端使用<b>首选 WAN</b> 口作为流量出口访问预设地址协议端口的客户端 IP 地址和目标 IP 地址的协议端口。<br />";
        content += "<br />缺省文件名为 <b>/jffs/scripts/lz/data/wan_1_src_to_dst_addr_port.txt</b>，无有效数据条目。<br />";
        content += "<br />文件路径、名称可自定义和修改，文件路径及名称不得为空。<br />";
        content += "<br />文本格式：每行各字段之间用空格隔开，一个条目一行，可多行多个条目。<br />";
        content += "<br />客户端地址&nbsp;目标地址&nbsp;通讯协议&nbsp;目标端口号<br />";
        content += "<br />例如：<br />";
        content += "192.168.50.101&nbsp;123.123.123.121&nbsp;tcp&nbsp;80,443,6881:6889,25671<br />";
        content += "192.168.50.0/27&nbsp;123.123.123.0/24&nbsp;udp&nbsp;4334<br />";
        content += "0.0.0.0/0&nbsp;123.123.123.123&nbsp;udplite&nbsp;12345<br />";
        content += "192.168.50.102&nbsp;0.0.0.0/0&nbsp;sctp<br />";
        content += "0.0.0.0/0&nbsp;0.0.0.0/0<br />";
        content += "<br />可以用 <b>0.0.0.0/0</b> 表示所有未知IP地址。<br />";
        content += "<br /><b>客户端地址</b>和<b>目标地址</b>为必选项。<br />";
        content += "<br /><b>通讯协议</b>及<b>目标端口号</b>为可选项。选择<b>目标端口号</b>时，<b>通讯协议</b>则为必选项。<br />";
        content += "<br />每个条目只能使用一个端口通讯协议，只能是 TCP、UDP、UDPLITE、SCTP 四种协议中的一个，字母英文大小写均可。<br />";
        content += "<br />连续端口号中间用英文半角 <b>:</b> 冒号相隔，如：6881:6889 表示 6881~6889 的连续端口号。<br />";
        content += "<br />每个条目最多可设置 15 个不连续的目标访问端口号埠，不连续的端口号埠之间用英文半角 <b>,</b> 逗号相隔，不要有空格。<br />";
        content += "<br />为避免软件升级更新或重新安装导致配置重置为缺省状态，建议更改文件名或文件存储路径。</div>";
    } else if (itemNum == 37) {
        mode = 1;
        caption = " 客户端地址至目标地址协议端口列表";
        content = "<div>文件中具体定义客户端使用<b>第二 WAN</b> 口作为流量出口访问预设地址协议端口的客户端 IP 地址和目标 IP 地址的协议端口。<br />";
        content += "<br />缺省文件名为 <b>/jffs/scripts/lz/data/wan_2_src_to_dst_addr_port.txt</b>，无有效数据条目。<br />";
        content += "<br />文件路径、名称可自定义和修改，文件路径及名称不得为空。<br />";
        content += "<br />文本格式：每行各字段之间用空格隔开，一个条目一行，可多行多个条目。<br />";
        content += "<br />客户端地址&nbsp;目标地址&nbsp;通讯协议&nbsp;目标端口号<br />";
        content += "<br />例如：<br />";
        content += "192.168.50.101&nbsp;123.123.123.121&nbsp;tcp&nbsp;80,443,6881:6889,25671<br />";
        content += "192.168.50.0/27&nbsp;123.123.123.0/24&nbsp;udp&nbsp;4334<br />";
        content += "0.0.0.0/0&nbsp;123.123.123.123&nbsp;udplite&nbsp;12345<br />";
        content += "192.168.50.102&nbsp;0.0.0.0/0&nbsp;sctp<br />";
        content += "0.0.0.0/0&nbsp;0.0.0.0/0<br />";
        content += "<br />可以用 <b>0.0.0.0/0</b> 表示所有未知IP地址。<br />";
        content += "<br /><b>客户端地址</b>和<b>目标地址</b>为必选项。<br />";
        content += "<br /><b>通讯协议</b>及<b>目标端口号</b>为可选项。选择<b>目标端口号</b>时，<b>通讯协议</b>则为必选项。<br />";
        content += "<br />每个条目只能使用一个端口通讯协议，只能是 TCP、UDP、UDPLITE、SCTP 四种协议中的一个，字母英文大小写均可。<br />";
        content += "<br />连续端口号中间用英文半角 <b>:</b> 冒号相隔，如：6881:6889 表示 6881~6889 的连续端口号。<br />";
        content += "<br />每个条目最多可设置 15 个不连续的目标访问端口号埠，不连续的端口号埠之间用英文半角 <b>,</b> 逗号相隔，不要有空格。<br />";
        content += "<br />为避免软件升级更新或重新安装导致配置重置为缺省状态，建议更改文件名或文件存储路径。</div>";
    } else if (itemNum == 38) {
        content = "<div>定义客户端高优先级方式使用指定流量出口访问预设地址的协议端口，可一次性的同时实现多种灵活、精准的流量策略。<br />";
        content += "<br />仅用于 TCP、UDP、UDPLITE、SCTP 四类协议端口。<br />";
        content += "<br />功能优先级高于<b>域名地址动态访问策略</b>和<b>客户端静态直通策略</b>，低于<b>高优先级客户端静态直通策略</b>和<b>客户端至预设目标 IP 地址静态直通策略</b>。<br />";
        content += "<br /><b>策略执行优先级</b>：详见<b>基本设置&nbsp;-&nbsp;策略路由优先级</b></div>";
} else if (itemNum == 39) {
        mode = 1;
        caption = " 客户端地址至目标地址协议端口列表";
        content = "<div>文件中具体定义客户端使用<b>首选 WAN</b> 口作为流量出口高优先级访问预设地址协议端口的客户端 IP 地址和目标 IP 地址的协议端口。<br />";
        content += "<br />缺省文件名为 <b>/jffs/scripts/lz/data/high_wan_1_src_to_dst_addr_port.txt</b>，无有效数据条目。<br />";
        content += "<br />文件路径、名称可自定义和修改，文件路径及名称不得为空。<br />";
        content += "<br />文本格式：每行各字段之间用空格隔开，一个条目一行，可多行多个条目。<br />";
        content += "<br />客户端地址&nbsp;目标地址&nbsp;通讯协议&nbsp;目标端口号<br />";
        content += "<br />例如：<br />";
        content += "192.168.50.101&nbsp;123.123.123.121&nbsp;tcp&nbsp;80,443,6881:6889,25671<br />";
        content += "192.168.50.0/27&nbsp;123.123.123.0/24&nbsp;udp&nbsp;4334<br />";
        content += "0.0.0.0/0&nbsp;123.123.123.123&nbsp;udplite&nbsp;12345<br />";
        content += "192.168.50.102&nbsp;0.0.0.0/0&nbsp;sctp<br />";
        content += "0.0.0.0/0&nbsp;0.0.0.0/0<br />";
        content += "<br />可以用 <b>0.0.0.0/0</b> 表示所有未知IP地址。<br />";
        content += "<br /><b>客户端地址</b>和<b>目标地址</b>为必选项。<br />";
        content += "<br /><b>通讯协议</b>及<b>目标端口号</b>为可选项。选择<b>目标端口号</b>时，<b>通讯协议</b>则为必选项。<br />";
        content += "<br />每个条目只能使用一个端口通讯协议，只能是 TCP、UDP、UDPLITE、SCTP 四种协议中的一个，字母英文大小写均可。<br />";
        content += "<br />连续端口号中间用英文半角 <b>:</b> 冒号相隔，如：6881:6889 表示 6881~6889 的连续端口号。<br />";
        content += "<br />每个条目最多可设置 15 个不连续的目标访问端口号埠，不连续的端口号埠之间用英文半角 <b>,</b> 逗号相隔，不要有空格。<br />";
        content += "<br />为避免软件升级更新或重新安装导致配置重置为缺省状态，建议更改文件名或文件存储路径。</div>";
    } else if (itemNum == 40) {
        content = "<div>列入本策略<b>客户端 IP 地址列表</b>中的设备访问外网时不受其他路由策略影响，仅由路由器系统本身的链路负载均衡功能自动分配流量出口，可实现一些特殊用途的应用 (如带速叠加下载，但外部影响因素较多，不保证能实现)。<br />";
        content += "<br /><b>策略执行优先级</b>：详见<b>基本设置&nbsp;-&nbsp;策略路由优先级</b></div>";
    } else if (itemNum == 41) {
        content = "<div>缺省文件名为 <b>/jffs/scripts/lz/data/local_ipsets_data.txt</b>，无有效数据条目。<br />";
        content += "<br />文件路径、名称可自定义和修改，文件路径及名称不得为空。<br />";
        content += "<br />文文本格式：一个网址/网段一行，为一个条目，可多行多个条目。<br />";
        content += "<br />此文件中 <b>0.0.0.0/0</b> 为无效地址。<br />";
        content += "<br />为避免软件升级更新或重新安装导致配置重置为缺省状态，建议更改文件名或文件存储路径。</div>";
    } else if (itemNum == 42) {
        content = "<div>本策略用于从外部网络远程连接访问路由器及其内部的网络设备。<br />";
        content += "<br /><b>策略执行优先级</b>：详见<b>基本设置&nbsp;-&nbsp;策略路由优先级</b></div>";
    } else if (itemNum == 43) {
        content = "<div>该端口用于外网访问路由器 Asuswrt 管理界面及内网设备，正常应与 DDNS 出口保持一致，一般为<b>首选 WAN</b>。<br />";
        content += "<br />部分版本的固件系统，已内部将 DDNS 绑定至<b>首选 WAN</b>，更改或可导致访问失败。<br />";
        content += "<br /><b>策略执行优先级</b>：详见<b>基本设置&nbsp;-&nbsp;策略路由优先级</b></div>";
    } else if (itemNum == 44) {
        content = "<div>用于双线路负载均衡模式下使用路由器主机内置的 OpenVPN、PPTP、IPSec 和 WireGuard 虚拟专用网络服务器。<br />"
        content += "<br />当双线路负载均衡模式下远程接入成功后，远程客户端可通过本策略经由路由器其他流量出口访问外部网络。<br />";
        content += "<br />流量出口选项：<br />";
        content += "<ul>";
        content += "<li>首选 WAN (缺省)</li>";
        content += "<li>第二 WAN</li>";
        content += "<li>现有策略</li>";
        content += "</ul>";
        content += "<b>现有策略</b>：已在路由器上运行的其他策略。<br />";
        content += "<br />对于 OpenVPN Server，仅支持网络层的 TUN 虚拟设备接口类型，可收发第三层数据报文包，无法对采用链路层 TAP 接口类型的第二层数据报文包进行路由控制。<br />";
        content += "<br /><b>策略执行优先级</b>：详见<b>基本设置&nbsp;-&nbsp;策略路由优先级</b></div>";
    } else if (itemNum == 45) {
        content = "<div>缺省为 <b>5</b> 秒。<br />";
        content += "<br />用于双线路负载均衡模式下路由器内置的 PPTP、IPSec  和WireGuard 虚拟专用网络服务器，对 OpenVPN 虚拟专用网络服务器无效。<br />";
        content += "<br />能够在设定的时间间隔内通过后台守护进程，轮询检测和监控 PPTP、IPSec  和WireGuard 服务器和客户端的启停及远程接入状态，适时调整和更新路由器内相关的路由规则和工作方式。<br />";
        content += "<br />时间间隔越短，客户端路由连接可尽早建立，接入越快。但过短的时间间隔有可能早造成路由器资源争抢。对于 GT-AX6000 类硬件平台的路由器，可设置为1~3秒。对于性能较弱，或版本老旧的路由器，可根据路由器 CPU 资源占用的实测结果和应用体验合理调整该参数。</div>";
    } else if (itemNum == 46) {
        content = "<div>不可描述。</div>";
    } else if (itemNum == 47) {
        content = "<div>路由策略运行时参数配置。</div>";
    } else if (itemNum == 48) {
        mode = 1;
        caption = "应用模式";
        content = "<div>缺省为<b>动态分流模式</b> (推荐)。<br />";
        content += "<br /><b>动态路由</b>：<br />";
        content += "采用基于连接跟踪的报文数据包地址匹配标记导流的数据路由传输技术，能通过算法动态生成数据经由路径，较少占用系统策略路由库静态资源。<br />";
        content += "<br /><b>静态路由</b>：<br />";
        content += "采用按数据来源和目标地址通过经由路径规则直接映射网络出口的数据路由传输技术，当经由路径规则条目数很多时会大量占用系统策略路由库的静态资源，若硬件平台性能有限，会出现数据库启动加载时间过长的现象。<br />";
        content += "<br /><b>动态分流模式</b>：<br />";
        content += "国内及国外运营商目标 IP 地址流量采用<b>动态路由</b>技术，其他功能中混合使用<b>静态路由</b>技术，适用于绝大部分功能。<br />";
        content += "路由器主机内应用的流量出口由设备系统内部自动分配，不受用户定义的流量策略控制，用户规则只作用于路由器内网终端访问外网时的流量。<br />";
        content += "<br /><b>静态分流模式</b>：<br />";
        content += "国内及国外运营商目标 IP 地址流量采用<b>静态路由</b>技术。一个通道采用逐条匹配用户策略的方式传输流量，之外的流量则不再逐条匹配，而是采取整体推送的方式传输至另一通道，从而节省设备系统资源，提高传输效率。<br />";
        content += "路由器主机内部应用的流量出口按用户所定义的流量策略分配。<br />";
        content += "<br />本工具提供两种应用模式 (<b>动态分流模式</b>、<b>静态路由</b>)，将<b>动态路由</b>、<b>静态路由</b>两种作用于路由器 WAN 口通道的基础网络数据路由传输技术，组合形成策略路由服务的多种运行模式，并在此基础上结合运营商 IP 地址数据及出口参数配置等场景因素进行更高层的应用级封装，对软件运行时参数进行自动化配置，从而最大限度的降低用户配置参数的复杂度和难度。</div>";
    } else if (itemNum == 49) {
        content = "<div>缺省使用<b>系统 DNS </b>。<br />";
        content += "<br />在<b>域名地址动态访问策略</b>第一次启动时，提前对域名地址列表中的域名地址进行 IPv4 地址解析，能提高系统后续的路由策略执行效率，降低 DNS 污染对网络访问的影响。<br />";
        content += "<br /><b>系统 DNS</b>：使用路由器的 DNS 设置，一个域名解析一个地址，效率高，但不能同时获取域名的多个地址。<br />";
        content += "<br /><b>自定义 DNS</b>：能一次获取域名的多个地址，速度慢，但可提高后续的路由策略执行效率。<br />";
        content += "<br /><b>系统 DNS + 自定义 DNS</b>：建议在 DNS 污染严重时采用。当域名地址条目较多，或网络不好时，会降低软件启动速度。<br />";
        content += "<br />域名地址预解析仅在软件启动时进行，之后的网络访问的域名地址解析按照路由器系统或用户终端的 DNS 设置进行。</div>";
    } else if (itemNum == 50) {
        content = "<div>缺省为 <b>8.8.8.8</b>。<br />";
        content += "<br />建议采用高效、可靠和权威的 DNS 服务器。若经常访问国外站点，最好选用国外的 DNS 服务器。</div>";
    } else if (itemNum == 51) {
        content = "<div>缺省为 <b>864000</b> 秒 (<b>10</b> 天)。</div>";
    } else if (itemNum == 52) {
        content = "<div>缺省为<b>启用</b>。</div>";
    } else if (itemNum == 53) {
        content = "<div>缺省为<b>启用</b>。<br />";
        content += "<br />在软件执行结束时执行一次，同时会在<b>自动清理路由表及系统缓存时间间隔 (小时)</b> 的定时任务中进行。</div>";
    } else if (itemNum == 54) {
        content = "<div>缺省为每 <b>4</b> 小时清理一次。</div>";
    } else if (itemNum == 55) {
        content = "<div>缺省为 <b>DHCP 或 IPoE</b> 方式获取网络播放源地址，此连接方式也是地址获取方式/寻址方式。<br />";
        content += "<br />若不接入网络直播源，保持缺省即可。</div>";
    } else if (itemNum == 56) {
        content = "<div>缺省为 <b>DHCP 或 IPoE</b> 方式获取网络播放源地址，此连接方式也是地址获取方式/寻址方式。<br />";
        content += "<br /><b>首选 WAN</b> 选项：<br />";
        content += "<ul>";
        content += "<li>PPPoE&nbsp;(虚拟拨号端口&nbsp;ppp0)</li>";
        content += "<li>静态&nbsp;IP&nbsp;(以太网口)</li>";
        content += "<li>DHCP&nbsp;或&nbsp;IPoE&nbsp;(以太网口)</li>";
        content += "</ul>";
        content += "若不接入网络直播源，保持缺省即可。</div>";
    } else if (itemNum == 57) {
        content = "<div>缺省为 <b>DHCP 或 IPoE</b> 方式获取网络播放源地址，此连接方式也是地址获取方式/寻址方式。<br />";
        content += "<br /><b>第二 WAN</b> 选项：<br />";
        content += "<ul>";
        content += "<li>PPPoE&nbsp;(虚拟拨号端口&nbsp;ppp1)</li>";
        content += "<li>静态&nbsp;IP&nbsp;(以太网口)</li>";
        content += "<li>DHCP&nbsp;或&nbsp;IPoE&nbsp;(以太网口)</li>";
        content += "</ul>";
        content += "若不接入网络直播源，保持缺省即可。</div>";
    } else if (itemNum == 58) {
        content = "<div><b>IPTV 机顶盒</b>与<b>网络组播</b>均使用来自同一个流量出口的直播源，机顶盒也是网络组播的使用者。</div>";
    } else if (itemNum == 59) {
        content = "<div>用于指定 IPTV 机顶盒播放源接入口或网络 IGMP 组播数据转内网传输代理接入口，可将网络组播数据从路由器 WAN 出口外的组播源地址/接口转入本地内网供播放设备使用，并确保IPTV 机顶盒可全功能完整使用。<br />";
        content += "<br /><b>播放源接入口</b>选项：<br />";
        content += "<ul>";
        content += "<li>首选 WAN</li>";
        content += "<li>第二 WAN</li>";
        content += "<li>停用 (缺省)</li>";
        content += "</ul>";
        content += "当接入的两条线路都有播放源时，连接到路由器上的所有 IPTV 机顶盒和网络组播 (多播) 播放终端只能同时使用选定的一路接入，使用 UDPXY 的 HTTP 网络串流 (单播) 播放终端除外。<br />";
        content += "<br /><b>注意</b>：在路由器后台的IPTV设置界面内将<b>启动组播路由</b>项设置为<b>启用</b>状态后，本功能项才可正常使用。</div>";
    } else if (itemNum == 60) {
        content = "<div>缺省为<b>直连 IPTV 线路</b>。<br />";
        content += "<br /><b>直连 IPTV 线路</b>是在路由器内部通过网络映射关系，将机顶盒直接绑定到 IPTV 线路接口，与路由器上的其它网络隔离，使机顶盒无法通过宽带访问互联网。优点是传输效率高，机顶盒功能完整，不会被运营商 IPTV 网络服务地址调整影响使用。<br />";
        content += "<br /><b>按服务地址访问</b>则是让机顶盒根据<b>IPTV 网络服务 IP 地址列表</b>中的 IP 地址直接访问运营商的 IPTV 服务系统，实现完整的 IPTV 功能，同时还可通过路由器上的运营商宽带网络访问互联网，适用于既能使用运营商 IPTV 功能，又有互联网应用的多功能网络盒子类终端设备。该功能使用的前提是需要用户自己提前获取到运营商的<b>IPTV 网络服务 IP 地址</b></div>";
        content += "<br /><b>策略执行优先级</b>：详见<b>基本设置&nbsp;-&nbsp;策略路由优先级</b></div>";
    } else if (itemNum == 61) {
        content = "<div>IPTV 机顶盒使用的<b>必选项</b>。<br />";
        content += "<br />缺省文件名为 <b>/jffs/scripts/lz/data/iptv_box_ip_lst.txt</b>，无有效数据条目。<br />";
        content += "<br />文件路径、名称可自定义和修改，文件路径及名称不得为空。<br />";
        content += "<br />文本格式，一个机顶盒地址一行，可逐行填入多个机顶盒地址。<br />";
        content += "<br />此文件中 <b>0.0.0.0/0</b> 为无效地址。<br />";
        content += "<br />为避免软件升级更新或重新安装导致配置重置为缺省状态，建议更改文件名或文件存储路径。</div>";
    } else if (itemNum == 62) {
        content = "<div>仅在<b>IPTV 机顶盒访问 IPTV 线路方式</b>为<b>按服务地址访问</b>时使用。<br />";
        content += "<br />这些不是 IPTV 节目播放源地址，而是运营商的 IPTV 后台网络服务地址，需要用户自己获取和填写，如果地址不全或错误，机顶盒将无法通过路由器正确接入 IPTV 线路。若填入的地址覆盖了用户使用的互联网访问地址，会导致机顶盒无法通过该地址访问互联网。<br />";
        content += "<br />缺省文件名为 <b>/jffs/scripts/lz/data/iptv_isp_ip_lst.txt</b>，无有效数据条目。<br />";
        content += "<br />文件路径、名称可自定义和修改，文件路径及名称不得为空。<br />";
        content += "<br />文本格式，一个机顶盒地址一行，可逐行填入多个机顶盒地址。<br />";
        content += "<br />此文件中 <b>0.0.0.0/0</b> 为无效地址。<br />";
        content += "<br />为避免软件升级更新或重新安装导致配置重置为缺省状态，建议更改文件名或文件存储路径。</div>";
    } else if (itemNum == 63) {
        content = "<div><b>核心网桥组播数据侦测方式</b>选项：<br />";
        content += "<ul>";
        content += "<li>停用</li>";
        content += "<li>标准方式</li>";
        content += "<li>阻塞方式 (缺省)</li>";
        content += "</ul>";
        content += "此参数仅对 hnd/axhnd/axhnd.675x 等后续平台机型路由器有效，IPTV 机顶盒或组播不能正常播放节目时可尝试调整此参数。</div>";
    } else if (itemNum == 64) {
        content = "<div>可将来自<b>首选 WAN</b> 的网络组播数据转为 HTTP 数据流供内网客户端进行流式播放，能同时支持多个播放器，避免内网广播风暴。<br />";
        content += "<br /><b>注意</b>：若网络串流播放终端无法播放某些播放源的媒体数据，在设备没有故障的情况下，可能是系统内未启用相关的 <b>RTP/RTSP</b> 实时传输协议等原因所致，在路由器后台的 IPTV 设置界面内将<b>启动组播路由</b>项设置为<b>启用</b>状态，相关功能或可正常。</div>";
    } else if (itemNum == 65) {
        content = "<div>缺省为<b>停用</b>。</div>";
    } else if (itemNum == 66) {
        content = "<div>缺省为 <b>8686</b>。</div>";
    } else if (itemNum == 67) {
        content = "<div>缺省为 <b>65536</b>。</div>";
    } else if (itemNum == 68) {
        content = "<div>缺省为 <b>10</b>。</div>";
    } else if (itemNum == 69) {
        content = "<div>可将来自<b>第二 WAN</b> 的网络组播数据转为 HTTP 数据流供内网客户端进行流式播放，能同时支持多个播放器，避免内网广播风暴。<br />";
        content += "<br /><b>注意</b>：若网络串流播放终端无法播放某些播放源的媒体数据，在设备没有故障的情况下，可能是系统内未启用相关的 <b>RTP/RTSP</b> 实时传输协议等原因所致，在路由器后台的 IPTV 设置界面内将<b>启动组播路由</b>项设置为<b>启用</b>状态，相关功能或可正常。</div>";
    } else if (itemNum == 70) {
        content = "<div>缺省为<b>停用</b>。</div>";
    } else if (itemNum == 71) {
        content = "<div>缺省为 <b>8888</b>。</div>";
    } else if (itemNum == 72) {
        content = "<div>缺省为 <b>65536</b>。</div>";
    } else if (itemNum == 73) {
        content = "<div>缺省为 <b>10</b>。</div>";
    } else if (itemNum == 74) {
        content = "<div>本功能用于在路由器上联动运行用户自定义功能的 Linux Shell 脚本。<br />";
        content += "<br />使用中注意不要过多占用本软件的运行时间，避免产生功能冲突。</div>";
    } else if (itemNum == 75) {
        content = "<div><b>Linux Shell 脚本</b>。<br />";
        content += "<br /><b>启用</b>后随软件最开始时执行，用于清理用户之前创建或调用的各种系统资源。<br />";
        content += "<br />缺省文件名为 <b>/jffs/scripts/lz/custom_dualwan_scripts.sh</b>，实体文件不存在，使用时由用户创建。<br />";
        content += "<br />文件路径、名称可自定义和修改，文件路径及名称不得为空。<br />";
        content += "<br />该文件由用户创建，文件编码格式为 UTF-8 (LF)，首行代码顶齐第一个字符开始必须为：<b>#!bin/sh</b><br />";
        content += "<br />该脚本先于<b>外置用户自定义配置脚本</b>执行。</div>";
    } else if (itemNum == 76) {
        content = "<div><b>Linux Shell 脚本</b>。<br />";
        content += "<br /><b>启用</b>后随软件初始化时启动执行。<br />";
        content += "<br />缺省文件名为 <b>/jffs/scripts/lz/custom_config.sh</b>，实体文件不存在，使用时由用户创建。<br />";
        content += "<br />文件路径、名称可自定义和修改，文件路径及名称不得为空。<br />";
        content += "<br />该文件由用户创建，文件编码格式为 UTF-8 (LF)，首行代码顶齐第一个字符开始必须为：<b>#!bin/sh</b><br />";
        content += "<br />可在其中加入自定义全局变量并初始化，也可加入随系统启动自动执行的其他自定义脚本代码。<br />";
        content += "<br />该脚本晚于<b>外置用户自定义清理资源脚本</b>，早于<b>外置用户自定义双线路脚本</b>执行。</div>";
    } else if (itemNum == 77) {
        content = "<div><b>Linux Shell 脚本</b>。<br />";
        content += "<br /><b>启用</b>后仅在双线路同时接通 WAN 口网络条件下执行。<br />";
        content += "<br />缺省文件名为 <b>/jffs/scripts/lz/custom_dualwan_scripts.sh</b>，实体文件不存在，使用时由用户创建。<br />";
        content += "<br />文件路径、名称可自定义和修改，文件路径及名称不得为空。<br />";
        content += "<br />该文件由用户创建，文件编码格式为 UTF-8 (LF)，首行代码顶齐第一个字符开始必须为：<b>#!bin/sh</b><br />";
        content += "<br />该脚本晚于<b>外置用户自定义配置脚本</b>执行。</div>";
    } else if (itemNum == 78) {
        content = "<div>缺省为 <b>5</b> 天。</div>";
    } else if (itemNum == 79) {
        content = "<div>缺省为<b>自动</b>安排启动时间。</div>";
    } else if (itemNum == 80) {
        content = "<div>缺省为 <b>5</b> 次。</div>";
    } else if (itemNum == 81) {
        content = "<div>缺省文件名为 <b>/jffs/scripts/lz/data/custom_data_2.txt</b>，无有效数据条目。<br />";
        content += "<br />文件路径、名称可自定义和修改，文件路径及名称不得为空。<br />";
        content += "<br />文本格式：一个网址/网段一行，为一个条目，可多行多个条目。<br />";
        content += "<br />此文件中 <b>0.0.0.0/0</b> 为无效地址。<br />";
        content += "<br />为避免软件升级更新或重新安装导致配置重置为缺省状态，建议更改文件名或文件存储路径。</div>";
    } else if (itemNum == 82) {
        content = "<div>缺省为<b>停用</b>。<br />";
        content += "<br /><b>策略执行优先级</b>：详见<b>基本设置&nbsp;-&nbsp;策略路由优先级</b></div>";
    } else if (itemNum == 83) {
        content = "<div>最多可设置 15 个不连续的目标访问端口号埠。<br />";
        content += "<br />输入框内容为空时表示该协议端口<b>停用</b>。<br />";
        content += "<br />例如：<br />";
        content += "80,443,6881:6889,25671<br />";
        content += "<br />其中：6881:6889 表示 6881~6889 的连续端口号，不连续的端口号埠之间用英文半角 <b>,</b> 逗号相隔，不要有多余空格。<br />";
        content += "<br /><b>策略执行优先级</b>：详见<b>基本设置&nbsp;-&nbsp;策略路由优先级</b></div>";
    } else if (itemNum == 84) {
        content = "<div>缺省为<b>否</b>。</div>";
    } else if (itemNum == 100) {
        mode = 1;
        caption = "基本设置 - 策略路由优先级";
        content = "<div>策略路由优先级顺序：由高到低排列，系统抢先执行高优先级策略。<br />";
        content += "<ol>";
        content += "<li>负载均衡</li>";
        content += "<li>IPTV 机顶盒</li>";
        content += "<li>远程连接策略</li>";
        content += "<li>VPN 客户端通过路由器访问外网策略</li>";
        content += "<li>首选 WAN 高优先级客户端至预设目标 IP 地址静态直通策略</li>";
        content += "<li>第二 WAN 客户端至预设目标 IP 地址静态直通策略</li>";
        content += "<li>首选 WAN 客户端至预设目标 IP 地址静态直通策略</li>";
        content += "<li>第二 WAN 高优先级客户端静态直通策略</li>";
        content += "<li>首选 WAN 高优先级客户端静态直通策略</li>";
        content += "<li>首选 WAN 高优先级客户端至预设目标 IP 地址协议端口动态访问策略</li>";
        content += "<li>第二 WAN 客户端至预设目标 IP 地址协议端口动态访问策略</li>";
        content += "<li>首选 WAN 客户端至预设目标 IP 地址协议端口动态访问策略</li>";
        content += "<li>第二 WAN 域名地址动态访问策略</li>";
        content += "<li>首选 WAN 域名地址动态访问策略</li>";
        content += "<li>第二 WAN 客户端静态直通策略</li>";
        content += "<li>首选 WAN 客户端静态直通策略</li>";
        content += "<li>第二 WAN 协议端口动态访问策略</li>";
        content += "<li>首选 WAN 协议端口动态访问策略</li>";
        content += "<li>自定义目标 IP 地址访问策略 - 2 (静态分流模式时)</li>";
        content += "<li>自定义目标 IP 地址访问策略 - 1 (静态分流模式时)</li>";
        content += "<li>第二 WAN 运营商 IP 地址访问策略 (静态分流模式时)</li>";
        content += "<li>首选 WAN 运营商 IP 地址访问策略 (静态分流模式时)</li>";
        content += "<li>第二 WAN 国内运营商 IP 地址访问策略和自定义目标 IP 地址访问策略 (动态分流模式时)</li>";
        content += "<li>首选 WAN 国内运营商 IP 地址访问策略和自定义目标 IP 地址访问策略 (动态分流模式时)</li>";
        content += "<li>国外运营商 IP 地址访问策略 (动态分流模式时)</li>";
        content += "</ol>";
        content += "前往<b>系统记录 - 一般记录文件</b>查询<b>策略路由</b>打开/关闭过程中的工作状态信息。<br />";
        content += "<br /></div>";
    } else if (itemNum == 101) {
        content = "<div>前往<b>系统记录 - 一般记录文件</b>查询<b>策略路由</b>打开/关闭过程中的工作状态信息。</div>";
    }
    if (content != "") {
        if (mode != 0) {
            setMouseOut(1);
            return overlib(content, OFFSETX, -160, LEFT, DELAY, 400, WIDTH, 600, STICKY, CAPTION, caption);
        } else {
            setMouseOut(0);
            return overlib(content, HAUTO, VAUTO);
        }
    }
}

$.fn.serializeObject = function() {
    let o = (customSettings === undefined) ? {} : customSettings;
    let a = this.serializeArray();
    $.each(a, function() {
        if (o[this.name] !== undefined && this.name.indexOf("lzr_") != -1) {
            if (!o[this.name].push)
                o[this.name] = [o[this.name]];
            o[this.name].push(this.value || "");
        } else if (this.name.indexOf("lzr_") != -1)
            o[this.name] = this.value || "";
    });
    return o;
};

function getPolicyChangedItem(_dataArray) {
    for (let key in _dataArray) {
        if (policySettingsArray.hasOwnProperty(key)) {
            if (_dataArray[key] == String(policySettingsArray[key]))
                delete _dataArray[key];
        }
    }
    return _dataArray;
}

function applyRule() {
    $("[name*=lzr_]").prop("disabled", false);
    $("#amng_custom").val(JSON.stringify(getPolicyChangedItem($("#ruleForm").serializeObject())).replace(/\"lzr_/g, "\"lz_rule_"));
    document.form.action_script.value = (policySettingsArray.hasOwnProperty("policyEnable")) ? policySettingsArray.policyEnable ? "start_LZRule" : "stop_LZRule" : "";
    document.form.action_wait.value = 10;
    showLoading();
    document.form.submit();
}

function initial() {
    let restart = false;
    setPolicyRoutingPage();
    showProduct();
    initPolicyEnableCtrl();
    loadCustomSettings();
    if (isNewVersion()) {
        if (!loadPolicySettings(1))
            loadPolicySettings();
        restart = true;
    } else if(!loadPolicySettings())
        loadPolicySettings(1);
    show_menu();
    initControls();
    inithideDivPage();
    initSwitchDivPage();
    if (restart) applyRule();
}

$(document).ready(function() {
    $("#lzr_producid").click(function() {
        if ($("#lzr_infomation").html() == "")
            $("#lzr_infomation").html('华硕梅林路由器双线路策略路由服务配置工具&#169;<br />项目地址:&nbsp;<a href="https://github.com/larsonzh/amdwprprsct.git" target="_blank" style="font-family:Lucida Console;text-decoration:underline;">https://github.com/larsonzh/amdwprprsct</a> &nbsp; 国内镜像:&nbsp;<a href="https://gitee.com/larsonzh/amdwprprsct.git" target="_blank" style="font-family:Lucida Console;text-decoration:underline;">https://gitee.com/larsonzh/amdwprprsct</a>').show();
        else
            $("#lzr_infomation").html("").hide();
    });
    $("#lzr_infomation").click(function() {$("#lzr_infomation").html("").hide();});
});

</script>

</head>

<body onload="initial();" class="bg">

<div id="TopBanner"></div>
<div id="Loading" class="popup_bg"></div>

<iframe name="hidden_frame" id="hidden_frame" src="" width="0" height="0" frameborder="0"></iframe>

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
<div>&nbsp;</div>

<div class="formfonttitle">
外部网络(WAN) - 策略路由(IPv4)
</div>

<div style="margin:10px 0 10px 5px;" class="splitLine"></div>

<div class="formfontdesc">
<p id="lzr_producid" style="cursor:help;"></p>
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

<div id="basicConfig">
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
<td colspan="2"><a class="hintstyle" href="javascript:void(0);" onClick="openOverHint(13);">运营商 IP 地址数据维护</a></td>
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
<input id="lzr_ruid_retry_num" type="text" maxlength="2" class="input_6_table" name="lzr_ruid_retry_num" value="5" onkeypress="return validator.isNumber(this,event);" onchange="checkNumberField(this)" autocorrect="off" autocapitalize="off">
</td>
</tr>
</table>

</div>

<div id="advancedConfig">
<table width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable">
<thead>
<tr>
<td colspan="2"><a class="hintstyle" href="javascript:void(0);" onClick="openOverHint(14);">自定义目标 IP 地址访问策略</a></td>
</tr>
</thead>
<tr>
<th><a class="hintstyle" href="javascript:void(0);" onClick="openOverHint(15);">自定义策略 - 1</a></th>
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
<th>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<a class="hintstyle" href="javascript:void(0);" onClick="openOverHint(16);">目标 IP 地址列表</a></th>
<td>
<input id="lzr_custom_data_file_1" type="text" maxlength="255" class="input_32_table" name="lzr_custom_data_file_1" value="/jffs/scripts/lz/data/custom_data_1.txt" onchange="checkTextField(this)" autocorrect="off" autocapitalize="off">
</td>
</tr>
<tr>
<th><a class="hintstyle" href="javascript:void(0);" onClick="openOverHint(17);">自定义策略 - 2</a></th>
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
<th>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<a class="hintstyle" href="javascript:void(0);" onClick="openOverHint(81);">目标 IP 地址列表</a></th>
<td>
<input id="lzr_custom_data_file_2" type="text" maxlength="255" class="input_32_table" name="lzr_custom_data_file_2" value="/jffs/scripts/lz/data/custom_data_2.txt" onchange="checkTextField(this)" autocorrect="off" autocapitalize="off">
</td>
</tr>
</table>

<table width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable">
<thead>
<tr>
<td colspan="2"><a class="hintstyle" href="javascript:void(0);" onClick="openOverHint(18);">域名地址动态访问策略</a></td>
</tr>
</thead>
<tr>
<th><a class="hintstyle" href="javascript:void(0);" onClick="openOverHint(82);">首选 WAN</a></th>
<td colspan="4">
<input type="radio" value="0" name="lzr_wan_1_domain" class="content_input_fd">启用
<input type="radio" value="5" name="lzr_wan_1_domain" class="content_input_fd">停用
</td>
</tr>
<tr>
<th>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<a class="hintstyle" href="javascript:void(0);" onClick="openOverHint(19);">客户端 IP 地址列表</a></th>
<td>
<input id="lzr_wan_1_domain_client_src_addr_file" type="text" maxlength="255" class="input_32_table" name="lzr_wan_1_domain_client_src_addr_file" value="/jffs/scripts/lz/data/wan_1_domain_client_src_addr.txt" onchange="checkTextField(this)" autocorrect="off" autocapitalize="off">
</td>
</tr>
<tr>
<th>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<a class="hintstyle" href="javascript:void(0);" onClick="openOverHint(20);">域名地址列表</a></th>
<td>
<input id="lzr_wan_1_domain_file" type="text" maxlength="255" class="input_32_table" name="lzr_wan_1_domain_file" value="/jffs/scripts/lz/data/wan_1_domain.txt" onchange="checkTextField(this)" autocorrect="off" autocapitalize="off">
</td>
</tr>
<tr>
<th><a class="hintstyle" href="javascript:void(0);" onClick="openOverHint(82);">第二 WAN</a></th>
<td colspan="4">
<input type="radio" value="0" name="lzr_wan_2_domain" class="content_input_fd">启用
<input type="radio" value="5" name="lzr_wan_2_domain" class="content_input_fd">停用
</td>
</tr>
<tr>
<th>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<a class="hintstyle" href="javascript:void(0);" onClick="openOverHint(21);">客户端 IP 地址列表</a></th>
<td>
<input id="lzr_wan_2_domain_client_src_addr_file" type="text" maxlength="255" class="input_32_table" name="lzr_wan_2_domain_client_src_addr_file" value="/jffs/scripts/lz/data/wan_2_domain_client_src_addr.txt" onchange="checkTextField(this)" autocorrect="off" autocapitalize="off">
</td>
</tr>
<tr>
<th>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<a class="hintstyle" href="javascript:void(0);" onClick="openOverHint(22);">域名地址列表</a></th>
<td>
<input id="lzr_wan_2_domain_file" type="text" maxlength="255" class="input_32_table" name="lzr_wan_2_domain_file" value="/jffs/scripts/lz/data/wan_2_domain.txt" onchange="checkTextField(this)" autocorrect="off" autocapitalize="off">
</td>
</tr>
</table>

<table width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable">
<thead>
<tr>
<td colspan="2"><a class="hintstyle" href="javascript:void(0);" onClick="openOverHint(23);">客户端静态直通策略</a></td>
</tr>
</thead>
<tr>
<th><a class="hintstyle" href="javascript:void(0);" onClick="openOverHint(82);">首选 WAN</a></th>
<td colspan="4">
<input type="radio" value="0" name="lzr_wan_1_client_src_addr" class="content_input_fd">启用
<input type="radio" value="5" name="lzr_wan_1_client_src_addr" class="content_input_fd">停用
</td>
</tr>
<tr>
<th>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<a class="hintstyle" href="javascript:void(0);" onClick="openOverHint(24);">客户端 IP 地址列表</a></th>
<td>
<input id="lzr_wan_1_client_src_addr_file" type="text" maxlength="255" class="input_32_table" name="lzr_wan_1_client_src_addr_file" value="/jffs/scripts/lz/data/wan_1_client_src_addr.txt" onchange="checkTextField(this)" autocorrect="off" autocapitalize="off">
</td>
</tr>
<tr>
<th><a class="hintstyle" href="javascript:void(0);" onClick="openOverHint(82);">第二 WAN</a></th>
<td colspan="4">
<input type="radio" value="0" name="lzr_wan_2_client_src_addr" class="content_input_fd">启用
<input type="radio" value="5" name="lzr_wan_2_client_src_addr" class="content_input_fd">停用
</td>
</tr>
<tr>
<th>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<a class="hintstyle" href="javascript:void(0);" onClick="openOverHint(25);">客户端 IP 地址列表</a></th>
<td>
<input id="lzr_wan_2_client_src_addr_file" type="text" maxlength="255" class="input_32_table" name="lzr_wan_2_client_src_addr_file" value="/jffs/scripts/lz/data/wan_2_client_src_addr.txt" onchange="checkTextField(this)" autocorrect="off" autocapitalize="off">
</td>
</tr>
</table>

<table width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable">
<thead>
<tr>
<td colspan="2"><a class="hintstyle" href="javascript:void(0);" onClick="openOverHint(26);">高优先级客户端静态直通策略</a></td>
</tr>
</thead>
<tr>
<th><a class="hintstyle" href="javascript:void(0);" onClick="openOverHint(82);">首选 WAN</a></th>
<td colspan="4">
<input type="radio" value="0" name="lzr_high_wan_1_client_src_addr" class="content_input_fd">启用
<input type="radio" value="5" name="lzr_high_wan_1_client_src_addr" class="content_input_fd">停用
</td>
</tr>
<tr>
<th>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<a class="hintstyle" href="javascript:void(0);" onClick="openOverHint(27);">客户端 IP 地址列表</a></th>
<td>
<input id="lzr_high_wan_1_client_src_addr_file" type="text" maxlength="255" class="input_32_table" name="lzr_high_wan_1_client_src_addr_file" value="/jffs/scripts/lz/data/high_wan_1_client_src_addr.txt" onchange="checkTextField(this)" autocorrect="off" autocapitalize="off">
</td>
</tr>
<tr>
<th><a class="hintstyle" href="javascript:void(0);" onClick="openOverHint(82);">第二 WAN</a></th>
<td colspan="4">
<input type="radio" value="0" name="lzr_high_wan_2_client_src_addr" class="content_input_fd">启用
<input type="radio" value="5" name="lzr_high_wan_2_client_src_addr" class="content_input_fd">停用
</td>
</tr>
<tr>
<th>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<a class="hintstyle" href="javascript:void(0);" onClick="openOverHint(28);">客户端 IP 地址列表</a></th>
<td>
<input id="lzr_high_wan_2_client_src_addr_file" type="text" maxlength="255" class="input_32_table" name="lzr_high_wan_2_client_src_addr_file" value="/jffs/scripts/lz/data/high_wan_2_client_src_addr.txt" onchange="checkTextField(this)" autocorrect="off" autocapitalize="off">
</td>
</tr>
</table>

<table width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable">
<thead>
<tr>
<td colspan="2"><a class="hintstyle" href="javascript:void(0);" onClick="openOverHint(29);">客户端至预设目标 IP 地址静态直通策略</a></td>
</tr>
</thead>
<tr>
<th><a class="hintstyle" href="javascript:void(0);" onClick="openOverHint(82);">首选 WAN</a></th>
<td colspan="4">
<input type="radio" value="0" name="lzr_wan_1_src_to_dst_addr" class="content_input_fd">启用
<input type="radio" value="5" name="lzr_wan_1_src_to_dst_addr" class="content_input_fd">停用
</td>
</tr>
<tr>
<th>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<a class="hintstyle" href="javascript:void(0);" onClick="openOverHint(30);">客户端 IP 地址至目标 IP 地址列表</a></th>
<td>
<input id="lzr_wan_1_src_to_dst_addr_file" type="text" maxlength="255" class="input_32_table" name="lzr_wan_1_src_to_dst_addr_file" value="/jffs/scripts/lz/data/wan_1_src_to_dst_addr.txt" onchange="checkTextField(this)" autocorrect="off" autocapitalize="off">
</td>
</tr>
<tr>
<th><a class="hintstyle" href="javascript:void(0);" onClick="openOverHint(82);">第二 WAN</a></th>
<td colspan="4">
<input type="radio" value="0" name="lzr_wan_2_src_to_dst_addr" class="content_input_fd">启用
<input type="radio" value="5" name="lzr_wan_2_src_to_dst_addr" class="content_input_fd">停用
</td>
</tr>
<tr>
<th>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<a class="hintstyle" href="javascript:void(0);" onClick="openOverHint(31);">客户端 IP 地址至目标 IP 地址列表</a></th>
<td>
<input id="lzr_wan_2_src_to_dst_addr_file" type="text" maxlength="255" class="input_32_table" name="lzr_wan_2_src_to_dst_addr_file" value="/jffs/scripts/lz/data/wan_2_src_to_dst_addr.txt" onchange="checkTextField(this)" autocorrect="off" autocapitalize="off">
</td>
</tr>
</table>

<table width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable">
<thead>
<tr>
<td colspan="2"><a class="hintstyle" href="javascript:void(0);" onClick="openOverHint(32);">高优先级客户端至预设目标 IP 地址静态直通策略</a></td>
</tr>
</thead>
<tr>
<th><a class="hintstyle" href="javascript:void(0);" onClick="openOverHint(82);">首选 WAN</a></th>
<td colspan="4">
<input type="radio" value="0" name="lzr_high_wan_1_src_to_dst_addr" class="content_input_fd">启用
<input type="radio" value="5" name="lzr_high_wan_1_src_to_dst_addr" class="content_input_fd">停用
</td>
</tr>
<tr>
<th>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<a class="hintstyle" href="javascript:void(0);" onClick="openOverHint(33);">客户端 IP 地址至目标 IP 地址列表</a></th>
<td>
<input id="lzr_high_wan_1_src_to_dst_addr_file" type="text" maxlength="255" class="input_32_table" name="lzr_high_wan_1_src_to_dst_addr_file" value="/jffs/scripts/lz/data/high_wan_1_src_to_dst_addr.txt" onchange="checkTextField(this)" autocorrect="off" autocapitalize="off">
</td>
</tr>
</table>

<table width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable">
<thead>
<tr>
<td colspan="2"><a class="hintstyle" href="javascript:void(0);" onClick="openOverHint(34);">协议端口动态访问策略</a></td>
</tr>
</thead>
<tr>
<th><a class="hintstyle" href="javascript:void(0);" onClick="openOverHint(82);">首选 WAN</a></th>
<td colspan="4">
</td>
</tr>
<tr>
<th>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<a class="hintstyle" href="javascript:void(0);" onClick="openOverHint(83);">TCP 目标端口</a></th>
<td>
<input id="lzr_wan0_dest_tcp_port" type="text" maxlength="512" class="input_32_table" name="lzr_wan0_dest_tcp_port" value="" onchange="checkPortTextField(this)" autocorrect="off" autocapitalize="off">
</td>
</tr>
<tr>
<th>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<a class="hintstyle" href="javascript:void(0);" onClick="openOverHint(83);">UDP 目标端口</a></th>
<td>
<input id="lzr_wan0_dest_udp_port" type="text" maxlength="512" class="input_32_table" name="lzr_wan0_dest_udp_port" value="" onchange="checkPortTextField(this)" autocorrect="off" autocapitalize="off">
</td>
</tr>
<tr>
<th>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<a class="hintstyle" href="javascript:void(0);" onClick="openOverHint(83);">UDPLITE 目标端口</a></th>
<td>
<input id="lzr_wan0_dest_udplite_port" type="text" maxlength="512" class="input_32_table" name="lzr_wan0_dest_udplite_port" value="" onchange="checkPortTextField(this)" autocorrect="off" autocapitalize="off">
</td>
</tr>
<tr>
<th>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<a class="hintstyle" href="javascript:void(0);" onClick="openOverHint(83);">SCTP 目标端口</a></th>
<td>
<input id="lzr_wan0_dest_sctp_port" type="text" maxlength="512" class="input_32_table" name="lzr_wan0_dest_sctp_port" value="" onchange="checkPortTextField(this)" autocorrect="off" autocapitalize="off">
</td>
</tr>
<tr>
<th><a class="hintstyle" href="javascript:void(0);" onClick="openOverHint(82);">第二 WAN</a></th>
<td colspan="4">
</td>
</tr>
<tr>
<th>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<a class="hintstyle" href="javascript:void(0);" onClick="openOverHint(83);">TCP 目标端口</a></th>
<td>
<input id="lzr_wan1_dest_tcp_port" type="text" maxlength="512" class="input_32_table" name="lzr_wan1_dest_tcp_port" value="" onchange="checkPortTextField(this)" autocorrect="off" autocapitalize="off">
</td>
</tr>
<tr>
<th>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<a class="hintstyle" href="javascript:void(0);" onClick="openOverHint(83);">UDP 目标端口</a></th>
<td>
<input id="lzr_wan1_dest_udp_port" type="text" maxlength="512" class="input_32_table" name="lzr_wan1_dest_udp_port" value="" onchange="checkPortTextField(this)" autocorrect="off" autocapitalize="off">
</td>
</tr>
<tr>
<th>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<a class="hintstyle" href="javascript:void(0);" onClick="openOverHint(83);">UDPLITE 目标端口</a></th>
<td>
<input id="lzr_wan1_dest_udplite_port" type="text" maxlength="512" class="input_32_table" name="lzr_wan1_dest_udplite_port" onchange="checkPortTextField(this)" value="" autocorrect="off" autocapitalize="off">
</td>
</tr>
<tr>
<th>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<a class="hintstyle" href="javascript:void(0);" onClick="openOverHint(83);">SCTP 目标端口</a></th>
<td>
<input id="lzr_wan1_dest_sctp_port" type="text" maxlength="512" class="input_32_table" name="lzr_wan1_dest_sctp_port" value="" onchange="checkPortTextField(this)" autocorrect="off" autocapitalize="off">
</td>
</tr>
</table>

<table width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable">
<thead>
<tr>
<td colspan="2"><a class="hintstyle" href="javascript:void(0);" onClick="openOverHint(35);">客户端至预设目标 IP 地址协议端口动态访问策略</a></td>
</tr>
</thead>
<tr>
<th><a class="hintstyle" href="javascript:void(0);" onClick="openOverHint(82);">首选 WAN</a></th>
<td colspan="4">
<input type="radio" value="0" name="lzr_wan_1_src_to_dst_addr_port" class="content_input_fd">启用
<input type="radio" value="5" name="lzr_wan_1_src_to_dst_addr_port" class="content_input_fd">停用
</td>
</tr>
<tr>
<th>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<a class="hintstyle" href="javascript:void(0);" onClick="openOverHint(36);">客户端地址至目标地址协议端口列表</a></th>
<td>
<input id="lzr_wan_1_src_to_dst_addr_port_file" type="text" maxlength="255" class="input_32_table" name="lzr_wan_1_src_to_dst_addr_port_file" value="/jffs/scripts/lz/data/wan_1_src_to_dst_addr_port.txt" onchange="checkTextField(this)" autocorrect="off" autocapitalize="off">
</td>
</tr>
<tr>
<th><a class="hintstyle" href="javascript:void(0);" onClick="openOverHint(82);">第二 WAN</a></th>
<td colspan="4">
<input type="radio" value="0" name="lzr_wan_2_src_to_dst_addr_port" class="content_input_fd">启用
<input type="radio" value="5" name="lzr_wan_2_src_to_dst_addr_port" class="content_input_fd">停用
</td>
</tr>
<tr>
<th>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<a class="hintstyle" href="javascript:void(0);" onClick="openOverHint(37);">客户端地址至目标地址协议端口列表</a></th>
<td>
<input id="lzr_wan_2_src_to_dst_addr_port_file" type="text" maxlength="255" class="input_32_table" name="lzr_wan_2_src_to_dst_addr_port_file" value="/jffs/scripts/lz/data/wan_2_src_to_dst_addr_port.txt" onchange="checkTextField(this)" autocorrect="off" autocapitalize="off">
</td>
</tr>
</table>

<table width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable">
<thead>
<tr>
<td colspan="2"><a class="hintstyle" href="javascript:void(0);" onClick="openOverHint(38);">高优先级客户端至预设目标 IP 地址协议端口动态访问策略</a></td>
</tr>
</thead>
<tr>
<th><a class="hintstyle" href="javascript:void(0);" onClick="openOverHint(82);">首选 WAN</a></th>
<td colspan="4">
<input type="radio" value="0" name="lzr_high_wan_1_src_to_dst_addr_port" class="content_input_fd">启用
<input type="radio" value="5" name="lzr_high_wan_1_src_to_dst_addr_port" class="content_input_fd">停用
</td>
</tr>
<tr>
<th>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<a class="hintstyle" href="javascript:void(0);" onClick="openOverHint(39);">客户端地址至目标地址协议端口列表</a></th>
<td>
<input id="lzr_high_wan_1_src_to_dst_addr_port_file" type="text" maxlength="255" class="input_32_table" name="lzr_high_wan_1_src_to_dst_addr_port_file" value="/jffs/scripts/lz/data/high_wan_1_src_to_dst_addr_port.txt" onchange="checkTextField(this)" autocorrect="off" autocapitalize="off">
</td>
</tr>
</table>

<table width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable">
<thead>
<tr>
<td colspan="2"><a class="hintstyle" href="javascript:void(0);" onClick="openOverHint(40);">客户端负载均衡动态访问策略</a></td>
</tr>
</thead>
<tr>
<th>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<a class="hintstyle" href="javascript:void(0);" onClick="openOverHint(41);">客户端 IP 地址列表</a></th>
<td>
<input id="lzr_local_ipsets_file" type="text" maxlength="255" class="input_32_table" name="lzr_local_ipsets_file" value="/jffs/scripts/lz/data/local_ipsets_data.txt" onchange="checkTextField(this)" autocorrect="off" autocapitalize="off">
</td>
</tr>
</table>

<table width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable">
<thead>
<tr>
<td colspan="2"><a class="hintstyle" href="javascript:void(0);" onClick="openOverHint(42);">远程连接策略</a></td>
</tr>
</thead>
<tr>
<th><a class="hintstyle" href="javascript:void(0);" onClick="openOverHint(43);">远程接入口</a></th>
<td colspan="4">
<input type="radio" value="0" name="lzr_wan_access_port" class="content_input_fd">首选 WAN
<input type="radio" value="1" name="lzr_wan_access_port" class="content_input_fd">第二 WAN
</td>
</tr>
<tr>
<th><a class="hintstyle" href="javascript:void(0);" onClick="openOverHint(44);">VPN 客户端通过路由器访问外网策略</a></th>
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
<td colspan="2"><a class="hintstyle" href="javascript:void(0);" onClick="openOverHint(46);">Fancyss 服务支持</a></td>
</tr>
</thead>
<tr>
<th><a class="hintstyle" href="javascript:void(0);" onClick="openOverHint(84);">启用服务支持</a></th>
<td colspan="4">
<input type="radio" value="0" name="lzr_fancyss_support" class="content_input_fd">是
<input type="radio" value="5" name="lzr_fancyss_support" class="content_input_fd">否
</td>
</tr>
</table>

</div>

<div id="runtimeConfig">
<table width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable">
<thead>
<tr>
<td colspan="2"><a class="hintstyle" href="javascript:void(0);" onClick="openOverHint(47);">运行设置</a></td>
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
<th><a class="hintstyle" href="javascript:void(0);" onClick="openOverHint(50);">域名地址预解析</a></th>
<td>
<input type="text" maxlength="15" class="input_15_table" id="lzr_pre_dns" name="lzr_pre_dns" value="8.8.8.8" onKeyPress="return validator.isIPAddr(this, event);" onchange="checkIPaddrField(this)" autocorrect="off" autocapitalize="off">
</td>
</tr>
<tr>
<th><a class="hintstyle" href="javascript:void(0);" onClick="openOverHint(51);">域名解析后 IP 地址缓存时间<br />(0--永久; 1~2147483秒)</a></th>
<td>
<input type="number" min="0" max="2147483" maxlength="7" class="input_15_table" id="lzr_dn_cache_time" name="lzr_dn_cache_time" value="864000" onkeypress="return validator.isNumber(this, event);" onchange="checkNumberField(this)" autocorrect="off" autocapitalize="off">
</td>
</tr>
<tr>
<th><a class="hintstyle" href="javascript:void(0);" onClick="openOverHint(52);">路由表缓存</a></th>
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

</div>

<div id="iPTVConfig">
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
<td colspan="2"><a class="hintstyle" href="javascript:void(0);" onClick="openOverHint(58);">IPTV 机顶盒及网络组播</a></td>
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
<th><a class="hintstyle" href="javascript:void(0);" onClick="openOverHint(61);">IPTV 机顶盒 IP 地址列表</a></th>
<td>
<input id="lzr_iptv_box_ip_lst_file" type="text" maxlength="255" class="input_32_table" name="lzr_iptv_box_ip_lst_file" value="/jffs/scripts/lz/data/iptv_box_ip_lst.txt" onchange="checkTextField(this)" autocorrect="off" autocapitalize="off">
</td>
</tr>
<tr>
<th><a class="hintstyle" href="javascript:void(0);" onClick="openOverHint(62);">IPTV 网络服务 IP 地址列表</a></th>
<td>
<input id="lzr_iptv_isp_ip_lst_file" type="text" maxlength="255" class="input_32_table" name="lzr_iptv_isp_ip_lst_file" value="/jffs/scripts/lz/data/iptv_isp_ip_lst.txt" onchange="checkTextField(this)" autocorrect="off" autocapitalize="off">
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
<input type="number" min="1" max="65535" maxlength="5" class="input_6_table" id="lzr_wan1_udpxy_port" name="lzr_wan1_udpxy_port" value="8686" onkeypress="return validator.isNumber(this, event);" onchange="checkNumberField(this)" autocorrect="off" autocapitalize="off">
</td>
</tr>
<tr>
<th><a class="hintstyle" href="javascript:void(0);" onClick="openOverHint(67);">UDPXY 缓冲区 (4096~2097152 bytes)</a></th>
<td>
<input type="number" min="4096" max="2097152" maxlength="7" class="input_12_table" id="lzr_wan1_udpxy_buffer" name="lzr_wan1_udpxy_buffer" value="65536" onkeypress="return validator.isNumber(this, event);" onchange="checkNumberField(this)" autocorrect="off" autocapitalize="off">
</td>
</tr>
<tr>
<th><a class="hintstyle" href="javascript:void(0);" onClick="openOverHint(68);">UDPXY 客户端数量 (1~5000)</a></th>
<td>
<input type="number" min="1" max="5000" maxlength="4" class="input_6_table" id="lzr_wan1_udpxy_client_num" name="lzr_wan1_udpxy_client_num" value="10" onkeypress="return validator.isNumber(this, event);" onchange="checkNumberField(this)" autocorrect="off" autocapitalize="off">
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
<input type="number" min="1" max="65535" maxlength="5" class="input_6_table" id="lzr_wan2_udpxy_port" name="lzr_wan2_udpxy_port" value="8888" onkeypress="return validator.isNumber(this, event);" onchange="checkNumberField(this)" autocorrect="off" autocapitalize="off">
</td>
</tr>
<tr>
<th><a class="hintstyle" href="javascript:void(0);" onClick="openOverHint(72);">UDPXY 缓冲区 (4096~2097152 bytes)</a></th>
<td>
<input type="number" min="4096" max="2097152" maxlength="7" class="input_12_table" id="lzr_wan2_udpxy_buffer" name="lzr_wan2_udpxy_buffer" value="65536" onkeypress="return validator.isNumber(this, event);" onchange="checkNumberField(this)" autocorrect="off" autocapitalize="off">
</td>
</tr>
<tr>
<th><a class="hintstyle" href="javascript:void(0);" onClick="openOverHint(73);">UDPXY 客户端数量 (1~5000)</a></th>
<td>
<input type="number" min="1" max="5000" maxlength="4" class="input_6_table" id="lzr_wan2_udpxy_client_num" name="lzr_wan2_udpxy_client_num" value="10" onkeypress="return validator.isNumber(this, event);" onchange="checkNumberField(this)" autocorrect="on" autocapitalize="on">
</td>
</tr>
</table>

</div>

<div id="insertScriptConfig">
<table width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable">
<thead>
<tr>
<td colspan="2"><a class="hintstyle" href="javascript:void(0);" onClick="openOverHint(74);">外置脚本设置</a></td>
</tr>
</thead>
</tr>
<th rowspan="2"><a class="hintstyle" href="javascript:void(0);" onClick="openOverHint(75);">外置用户自定义清理资源脚本</a></th>
<td colspan="4">
<input type="radio" value="0" name="lzr_custom_clear_scripts" class="content_input_fd">启用
<input type="radio" value="5" name="lzr_custom_clear_scripts" class="content_input_fd">停用
</td>
</tr>
<tr>
<td>
<input id="lzr_custom_clear_scripts_filename" type="text" maxlength="255" class="input_32_table" name="lzr_custom_clear_scripts_filename" value="/jffs/scripts/lz/custom_clear_scripts.sh" onchange="checkTextField(this)" autocorrect="off" autocapitalize="off">
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
<input id="lzr_custom_config_scripts_filename" type="text" maxlength="255" class="input_32_table" name="lzr_custom_config_scripts_filename" value="/jffs/scripts/lz/custom_config.sh" onchange="checkTextField(this)" autocorrect="off" autocapitalize="off">
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
<input id="lzr_custom_dualwan_scripts_filename" type="text" maxlength="255" class="input_32_table" name="lzr_custom_dualwan_scripts_filename" value="/jffs/scripts/lz/custom_dualwan_scripts.sh" onchange="checkTextField(this)" autocorrect="off" autocapitalize="off">
</td>
</table>

</div>

<div class="apply_gen">
<input name="button" type="button" class="button_gen" onclick="applyRule()" value="应用本页面设置"/>
</div>

</td>
</tr>
</tbody>
</table>
</td>
</form>
</tr>
</table>
</td>
<td width="10" align="center" valign="top">&nbsp;</td>
</tr>
</table>
<div id="footer"></div>
</body>
</html>

