/*
# lz_policy_routing.js v4.7.4
# By LZ 妙妙呜 (larsonzhang@gmail.com)

# LZ JavaScript for Asuswrt-Merlin Router
*/

function setPolicyRoutingPage() {
    document.form.current_page.value = window.location.pathname.substring(1);
    document.form.next_page.value = window.location.pathname.substring(1);
}

let policySettingsArray = {};
function getVersion() {
    policySettingsArray["version"] = "";
    policySettingsArray["fuck_asd"] = "5";
    $.ajax({
        async: false,
        url: '/ext/lzr/LZRVersion.html',
        dataType: 'text',
        success: function(response) {
            let buf = response.match(/^[\s]*LZ_VERSION[=]v[\d]+([\.][\d]+)+/m);
            if (buf != null) policySettingsArray.version = (buf.length > 0) ? buf[0].replace(/^[\s]*LZ_VERSION[=](v[\d]+([\.][\d]+)+)/, "$1") : "";
            buf = response.match(/^[\s]*FUCK_ASD[=]([\w]+|[\"][\w]+[\"])/m);
            if (buf != null) policySettingsArray.fuck_asd = (buf.length > 0) ? buf[0].replace(/^[\s]*FUCK_ASD[=]([\"]?)([\w]+)([\"]?)/, "$2") : "5";
            if (policySettingsArray.fuck_asd != "0") policySettingsArray.fuck_asd = "5";
        }
    });
}

function getLastVersion() {
    policySettingsArray["lastVersion"] = policySettingsArray.version;
    let siteStr="";
    if (policySettingsArray.hasOwnProperty("lzr_repo_site")) {
        siteStr=" in Gitee";
        if (policySettingsArray["lzr_repo_site"] == 1) siteStr=" in Github";
    }
    $.ajax({
        url: '/ext/lzr/detect_version.js',
        dataType: 'script',
        error: function(xhr) {
            setTimeout(getLastVersion, 1000);
        },
        success: function() {
            if (versionStatus == 'InProgress')
                setTimeout(getLastVersion, 1000);
            else if (versionStatus != 'None') {
                policySettingsArray.lastVersion = versionStatus;
                if (policySettingsArray.lastVersion != policySettingsArray.version) {
                    $("#lzr_new_version_prompt_block").html("有新版本:&nbsp&nbsp").show();
                    $("#lzr_last_version_block").html(policySettingsArray.lastVersion + siteStr).show();
                    setInterval(function() {
                        $("#lzr_last_version_block").fadeOut(200);
                        $("#lzr_last_version_block").fadeIn(100);
                    }, 3000);
                } else {
                    $("#lzr_new_version_prompt_block").html("").show();
                    $("#lzr_last_version_block").html(policySettingsArray.lastVersion + siteStr).show();
                }
            } else if (versionStatus == 'None') {
                $("#lzr_new_version_prompt_block").html("在线检测新版本失败" + siteStr).show();
                $("#lzr_last_version_block").html("").show();
            }
        }
    });
}

function getASDStatus() {
    $.ajax({
        url: '/ext/lzr/detect_asd.js',
        dataType: 'script',
        error: function(xhr) {
            setTimeout(getASDStatus, 1000);
        },
        success: function() {
            if (asdStatus == 'InProgress')
                setTimeout(getASDStatus, 1000);
            else if (asdStatus != 'None') {
                asdStatus = (asdStatus == '0') ? "0" : "5";
                if (policySettingsArray.fuck_asd != asdStatus) {
                    policySettingsArray.fuck_asd = asdStatus;
                    initCheckRadio("fuck_asd", 0, 0, 5);
                }
                $("#fuck_asd_tr").show();
            }
        }
    });
}

function detectASD() {
    $.ajax({
        async: false,
        url: '/ext/lzr/LZRInstance.html',
        dataType: 'text',
        error: function(xhr) {
            if (xhr.status == 404) {
                document.scriptActionsForm.action_script.value = 'start_LZDetectASD';
                document.scriptActionsForm.action_wait.value = "0";
                document.scriptActionsForm.submit();
                setTimeout(getASDStatus, 1000);
            }
        },
        success: function() {
            setTimeout(detectASD, 3000);
        }
    });
}

function getPath() {
    policySettingsArray["path"] = "/jffs/scripts/lz";
    $.ajax({
        async: false,
        url: '/ext/lzr/LZRService.html',
        dataType: 'text',
        success: function(response) {
            let buf = response.match(/^[\s]*[\w\/]+[\/]interface[\/]lz_rule_service[\.]sh/m);
            if (buf != null) policySettingsArray.path = (buf.length > 0) ? buf[0].replace(/^[\s]*([\w\/]+)[\/]interface[\/]lz_rule_service[\.]sh$/, "$1") : "/jffs/scripts/lz";
        }
    });
}

function showProduct() {
    getVersion();
    let currentProductId = document.form.productid.value;
    (currentProductId == "undefined" || currentProductId == null || currentProductId == "") && (currentProductId = '<% nvram_get("odmpid"); %>');
    (currentProductId == "") && (currentProductId = '<% nvram_get("model"); %>');
    if (currentProductId != "") {
        document.title = "ASUS Wireless Router " + currentProductId +" - 策略路由";
        currentProductId = " for " + currentProductId;
    }
    if (policySettingsArray.hasOwnProperty("version") && policySettingsArray.version != "")
        $("#lzr_producid_block").html(`LZ RULE ${policySettingsArray.version} ${currentProductId} by 妙妙呜&#8482;`);
    else
        $("#lzr_producid_block").html(`LZ RULE ${currentProductId} by 妙妙呜&#8482;`);
    getPath();
}

function getPolicyState() {
    let retVal = false;
    $.ajax({
        async: false,
        url: '/ext/lzr/LZRState.html',
        dataType: 'text',
        success: function(response) {
            retVal = response.match(/^[\s]*[\w\/]+lz_rule[\.]sh[\s]*([#].*){0,1}$/m) != null;
        }
    });
    return retVal;
}

function initPolicyEnableCtrl() {
    policySettingsArray["policyEnable"] = getPolicyState();
    $('#lzr_policy_routing_enable').iphoneSwitch(policySettingsArray["policyEnable"],
        function() {policySettingsArray["policyEnable"] = true;},
        function() {policySettingsArray["policyEnable"] = false;}
    );
}

let customSettings;
function loadCustomSettings() {
    customSettings = '<% get_custom_settings(); %>';
    if (typeof customSettings == "string" 
        && /^[\s]*[\{]([\s]*[\"][^\"]+[\"][\s]*[\:][\s]*[\"][^\"]*[\"][\s][,])*[\s]*[\"][^\"]+[\"][\s]*[\:][\s]*[\"][^\"]*[\"][\s][\}][\s]*$|^[\s]*[\{]([\s]*[\"][^\"]+[\"][\s]*[\:][\s]*[\"][^\"]*[\"][\s]){0,1}[\}][\s]*$/.test(customSettings)) {
        customSettings = JSON.parse(customSettings);
        for (let prop in customSettings) {
            if (Object.prototype.hasOwnProperty.call(customSettings, prop))
                if (prop.indexOf("lz_rule_") != -1)
                    eval("delete customSettings." + prop);
        }
    } else customSettings = undefined;
}
/*
function isNewVersion() {
    let retVal = false;
    $.ajax({
        async: false,
        url: '/ext/lzr/LZRGlobal.html',
        dataType: 'text',
        success: function(response) {
            retVal = (response.match(/QnkgTFog5aaZ5aaZ5ZGc77yI6Juk6J[\+]G5aKp5YS[\/]77yJ/m) != null) ? true : false;
        }
    });
    return retVal;
}*/

function loadPolicySettings() {
    let retVal = false;
    $.ajax({
        async: false,
        url: '/ext/lzr/LZRConfig.html',
        dataType: 'text',
        success: function(response) {
            let buf = response.match(/^[\s]*[\w]+[=].*$/gm);
            if (buf == null) return;
            while (buf.length > 0) {
                buf[0] = buf[0].replace(/^[\s]+|[# \t].*$|[\'\"]/g, "").split('=');
                buf[0][0] = "lzr_" + buf[0][0];
                (buf[0][1] == null) && (buf[0][1] = "");
                if (buf[0][1] == "*" && (buf[0][0] == "lzr_ruid_timer_hour" || buf[0][0] == "lzr_ruid_timer_min"))
                    policyBkSettingsArray[buf[0][0]] = 404;
                else if (buf[0][1] == "true" || buf[0][1] == "false")
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

let policyBkSettingsArray = {};
function loadBkPolicyBkSettings() {
    let retVal = false;
    $.ajax({
        async: false,
        url: '/ext/lzr/LZRBKData.html',
        dataType: 'text',
        success: function(response) {
            let buf = response.match(/^[\s]*[\w]+[=].*$/gm);
            if (buf == null) return;
            while (buf.length > 0) {
                buf[0] = buf[0].replace(/^[\s]+|[# \t].*$|[\'\"]/g, "").split('=');
                buf[0][0] = "lzr_" + buf[0][0].replace(/^lz_config_/, "");
                (buf[0][1] == null) && (buf[0][1] = "");
                if (buf[0][1] == "*" && (buf[0][0] == "lzr_ruid_timer_hour" || buf[0][0] == "lzr_ruid_timer_min"))
                    policyBkSettingsArray[buf[0][0]] = 404;
                else if (buf[0][1] == "true" || buf[0][1] == "false")
                    policyBkSettingsArray[buf[0][0]] = JSON.parse(buf[0][1]);
                else if ((!isNaN(parseFloat(buf[0][1])) && isFinite(buf[0][1])))
                    policyBkSettingsArray[buf[0][0]] = Number(buf[0][1]);
                else
                    policyBkSettingsArray[buf[0][0]] = String(buf[0][1]);
                buf.splice(0, 1);
            }
            retVal = true;
        }
    });
    return retVal;
}

function checkPolicySettings() {
    for (let key in policySettingsArray) {
        if (key.indexOf("lzr_") == 0 && policySettingsArray.hasOwnProperty(key)) {
            if (!policyBkSettingsArray.hasOwnProperty(key))
                return false;
            if (policySettingsArray[key] != policyBkSettingsArray[key])
                return false;
        }
    }
    return true;
}

function clonePolicyBkSettings() {
    for (let key in policyBkSettingsArray) {
        if (policyBkSettingsArray.hasOwnProperty(key))
            policySettingsArray[key] = policyBkSettingsArray[key];
    }
}

function initPolicySetting() {
    let retVal = false;
    if (!loadBkPolicyBkSettings())
        loadPolicySettings();
    else if (isNewVersion())
        clonePolicyBkSettings();
    else if (!loadPolicySettings())
        clonePolicyBkSettings();
    else if (checkPolicySettings())
        retVal = true;
    policyBkSettingsArray = null;
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
            radioArray[i].checked = true;
        else
            radioArray[i].checked = false;
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
    initCheckRadio("lzr_proxy_route", 0, 1, 5);
    initTextEdit("lzr_proxy_remote_node_addr_file");
    initCheckRadio("lzr_usage_mode", 0, 1, 0);
    initCheckRadio("lzr_custom_hosts", 0, 0, 5);
    initTextEdit("lzr_custom_hosts_file");
    initCheckRadio("lzr_repo_site", 0, 1, 0);
    initListBox("lzr_dn_pre_resolved", 0, 2, 5);
    initTextEdit("lzr_pre_dns");
    initNumberEdit("lzr_dn_cache_time", 0, 2147483, 864000);
    initCheckRadio("fuck_asd", 0, 0, 5);
    $("#fuck_asd_tr").hide();
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

function checkNumberField(ptr, defaultVal) {
    if (isNaN(parseInt(ptr.value))) {
        if (policySettingsArray.hasOwnProperty(ptr.id))
            ptr.value = policySettingsArray[ptr.id];
        else {
            if (defaultVal == undefined || isNaN(parseInt(defaultVal)))
                defaultVal = 0;
            ptr.value = defaultVal;
            policySettingsArray[ptr.id] = defaultVal;
        }
    } else {
        if (!isNaN(parseInt(ptr.max)) && parseInt(ptr.value) > parseInt(ptr.max))
            ptr.value = ptr.max;
        else if (!isNaN(parseInt(ptr.min)) && parseInt(ptr.value) < parseInt(ptr.min))
            ptr.value = ptr.min;
    }
}

function checkTextField(ptr) {
    let str = ptr.value.replace(/[^\w\/\.\-]+/g, "").replace(/[\/][\/]+/g, "\/");
    if (str == "" && policySettingsArray.hasOwnProperty(ptr.id)) ptr.value = policySettingsArray[ptr.id];
    else if (str != ptr.value) ptr.value = str;
}

function checkPortTextField(ptr) {
    let str = ptr.value.replace(/[^\d\:\,]+/g, "").replace(/[\,][\,]+/g, "\,").replace(/[\:][\:]+/g, "\:").replace(/[^\d][^\d]+/g, "\,").replace(/([\:][\d]+)([\:][\d]+)+/g, "$1").replace(/^[^\d]*(([\d]+([\:][\d]+)*[\,]){15}).*$/, "$1").replace(/^[^\d]+|[^\d]+$/g, "");
    if (str != ptr.value) ptr.value = str;
}

validator.targetDomainName = function($o) {
    let str = $o.val();
    if (str == "") {
        $("#alert_block").hide();
        return false;
    }
    /*if (!validator.string($o[0])) {
        $("#alert_block").hide();
        return false;
    }*/
    for (i = 0; i < str.length; i++) {
        let c = str.charCodeAt(i);
        if (!validator.hostNameChar(c)) {
            $("#alert_block").html("网域名称包含无效字符 「" + str.charAt(i) + "」 !").show();
            return false;
        }
    }
    $("#alert_block").hide();
    return true;
}

function checkdestIPTextField(ptr) {
    validator.targetDomainName($("#" + ptr.id));
}

function checkIPaddress(ptr, defaultVal) {
    if (defaultVal == undefined) defaultVal = "";
    let patt = /^[0]*([\d]+)[\.][0]*([\d]+)[\.][0]*([\d]+)[\.][0]*([\d]+)$/;
    if (ptr.value.match(patt) == null) {
        ptr.value = defaultVal;
        return;
    }
    let val1 = ptr.value.replace(patt,"$1");
    let val2 = ptr.value.replace(patt,"$2");
    let val3 = ptr.value.replace(patt,"$3");
    let val4 = ptr.value.replace(patt,"$4");
    if (val1 > 255) val1 = "255";
    if (val2 > 255) val2 = "255";
    if (val3 > 255) val3 = "255";
    if (val4 > 255) val4 = "255";
    let val = val1 + "." + val2 + "." + val3 + "." + val4;
    if (val != ptr.value) ptr.value = val;
    patt = /^((?:(?:[2][5][0-5]|(?:[2][0-4]|[1][\d]|[\d])?[\d])[\.]){3}(?:[2][5][0-5]|(?:[2][0-4]|[1][\d]|[\d])?[\d]))$/;
    if (!patt.test(val)) ptr.value = defaultVal;
}

function checkIPaddrField(ptr) {
    checkIPaddress(ptr, "8.8.8.8");
}

function checkDNSIPaddrField(ptr) {
    checkIPaddress(ptr);
}

let divLabelArray = { 
    "Basic" : [ "基础", "0", "0", "basicConfig" ], 
    "Advanced" : [ "高级", "1", "0", "advancedConfig" ], 
    "Runtime" : [ "运行", "2", "0", "runtimeConfig" ], 
    "IPTV" : [ "IPTV", "3", "0", "iPTVConfig" ], 
    "InsertScript" : [ "外置脚本", "4", "0", "insertScriptConfig" ], 
    "Tools" : [ "工具", "5", "0", "scriptTools" ], 
    "Donation" : [ "捐助", "6", "0", "Donation" ] 
};

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
            pressed_code += "<div style='width:100px;height:30px;float:left;" + _cssMode + "' class='block_filter_pressed'>";
            pressed_code += "<div style='text-align:center;padding-top:5px;font-size:14px'>" + _itemArray[0] + "</div>";
            pressed_code += "</div>";
            return pressed_code;
        };
        let gen_not_pressed_content = function(_itemArray, _cssMode) {
            let not_pressed_code = "";
            not_pressed_code += "<div style='cursor:pointer;width:100px;height:30px;float:left;" + _cssMode + "' onclick='switchDivPage(" + _itemArray[1] + ");' class='block_filter'>";
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
    if (key == "Runtime")
        height = 0;
    else if (key == "Tools")
        hideCNT("0");
    closeRTIPList();
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
        content += "本策略仅对路由器下属<b>客户端</b>设备访问外部网络的数据流量有效。<br />";
        content += "<br /><b>出口均分</b>：将所选<b>运营商 IP 地址</b>条目数据平均划分为两部分，前一部分匹配<b>首选 WAN</b>，后一部分匹配<b>第二 WAN</b>。<br />";
        content += "<br /><b>反向均分</b>：将<b>出口均分</b>的流量出口匹配方式倒置。<br />";
        content += "<br /><b>负载均衡</b>：<b>动态分流模式</b>时，由系统采用<b>链路负载均衡</b>技术在<b>首选 WAN</b> 与<b>第二 WAN</b> 二者之中按流量比例随机分配<b>链路</b>流量出口，缺点是易导致网络访问不稳定和不正常；<b>静态分流模式</b>时，软件将根据路由器中所有已设置策略的流量出口分布情况，以系统策略路由库资源占用最小化为原则，自动为策略流量指定一个固定出口，运行中的实际出口可在<b>外部网络(WAN) - 策略路由(IPv4) - 运行</b>中点击<b>「获取运行状态」</b>按钮查看。<br />";
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
        content += "<br /><b>负载均衡</b>：<b>动态分流模式</b>时，由系统采用<b>链路负载均衡</b>技术在<b>首选 WAN</b> 与<b>第二 WAN</b> 二者之中按流量比例随机分配<b>链路</b>流量出口，缺点是易导致网络访问不稳定和不正常；<b>静态分流模式</b>时，软件将根据路由器中所有已设置策略的流量出口分布情况，以系统策略路由库资源占用最小化为原则，自动为策略流量指定一个固定出口，运行中的实际出口可在<b>外部网络(WAN) - 策略路由(IPv4) - 运行</b>中点击<b>「获取运行状态」</b>按钮查看。<br />";
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
        content += "<br /><b>负载均衡</b>：<b>动态分流模式</b>时，由系统采用<b>链路负载均衡</b>技术在<b>首选 WAN</b> 与<b>第二 WAN</b> 二者之中按流量比例随机分配<b>链路</b>流量出口，缺点是易导致网络访问不稳定和不正常；<b>静态分流模式</b>时，软件将根据路由器中所有已设置策略的流量出口分布情况，以系统策略路由库资源占用最小化为原则，自动为策略流量指定一个固定出口，运行中的实际出口可在<b>外部网络(WAN) - 策略路由(IPv4) - 运行</b>中点击<b>「获取运行状态」</b>按钮查看。<br />";
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
        content += "<br /><b>负载均衡</b>：<b>动态分流模式</b>时，由系统采用<b>链路负载均衡</b>技术在<b>首选 WAN</b> 与<b>第二 WAN</b> 二者之中按流量比例随机分配<b>链路</b>流量出口，缺点是易导致网络访问不稳定和不正常；<b>静态分流模式</b>时，软件将根据路由器中所有已设置策略的流量出口分布情况，以系统策略路由库资源占用最小化为原则，自动为策略流量指定一个固定出口，运行中的实际出口可在<b>外部网络(WAN) - 策略路由(IPv4) - 运行</b>中点击<b>「获取运行状态」</b>按钮查看。<br />";
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
        content += "<br /><b>负载均衡</b>：<b>动态分流模式</b>时，由系统采用<b>链路负载均衡</b>技术在<b>首选 WAN</b> 与<b>第二 WAN</b> 二者之中按流量比例随机分配<b>链路</b>流量出口，缺点是易导致网络访问不稳定和不正常；<b>静态分流模式</b>时，软件将根据路由器中所有已设置策略的流量出口分布情况，以系统策略路由库资源占用最小化为原则，自动为策略流量指定一个固定出口，运行中的实际出口可在<b>外部网络(WAN) - 策略路由(IPv4) - 运行</b>中点击<b>「获取运行状态」</b>按钮查看。<br />";
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
        content += "<br /><b>负载均衡</b>：<b>动态分流模式</b>时，由系统采用<b>链路负载均衡</b>技术在<b>首选 WAN</b> 与<b>第二 WAN</b> 二者之中按流量比例随机分配<b>链路</b>流量出口，缺点是易导致网络访问不稳定和不正常；<b>静态分流模式</b>时，软件将根据路由器中所有已设置策略的流量出口分布情况，以系统策略路由库资源占用最小化为原则，自动为策略流量指定一个固定出口，运行中的实际出口可在<b>外部网络(WAN) - 策略路由(IPv4) - 运行</b>中点击<b>「获取运行状态」</b>按钮查看。<br />";
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
        content += "<br /><b>负载均衡</b>：<b>动态分流模式</b>时，由系统采用<b>链路负载均衡</b>技术在<b>首选 WAN</b> 与<b>第二 WAN</b> 二者之中按流量比例随机分配<b>链路</b>流量出口，缺点是易导致网络访问不稳定和不正常；<b>静态分流模式</b>时，软件将根据路由器中所有已设置策略的流量出口分布情况，以系统策略路由库资源占用最小化为原则，自动为策略流量指定一个固定出口，运行中的实际出口可在<b>外部网络(WAN) - 策略路由(IPv4) - 运行</b>中点击<b>「获取运行状态」</b>按钮查看。<br />";
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
        content += "<br /><b>负载均衡</b>：<b>动态分流模式</b>时，由系统采用<b>链路负载均衡</b>技术在<b>首选 WAN</b> 与<b>第二 WAN</b> 二者之中按流量比例随机分配<b>链路</b>流量出口，缺点是易导致网络访问不稳定和不正常；<b>静态分流模式</b>时，软件将根据路由器中所有已设置策略的流量出口分布情况，以系统策略路由库资源占用最小化为原则，自动为策略流量指定一个固定出口，运行中的实际出口可在<b>外部网络(WAN) - 策略路由(IPv4) - 运行</b>中点击<b>「获取运行状态」</b>按钮查看。<br />";
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
        content += "<br /><b>负载均衡</b>：<b>动态分流模式</b>时，由系统采用<b>链路负载均衡</b>技术在<b>首选 WAN</b> 与<b>第二 WAN</b> 二者之中按流量比例随机分配<b>链路</b>流量出口，缺点是易导致网络访问不稳定和不正常；<b>静态分流模式</b>时，软件将根据路由器中所有已设置策略的流量出口分布情况，以系统策略路由库资源占用最小化为原则，自动为策略流量指定一个固定出口，运行中的实际出口可在<b>外部网络(WAN) - 策略路由(IPv4) - 运行</b>中点击<b>「获取运行状态」</b>按钮查看。<br />";
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
        content += "<br /><b>负载均衡</b>：<b>动态分流模式</b>时，由系统采用<b>链路负载均衡</b>技术在<b>首选 WAN</b> 与<b>第二 WAN</b> 二者之中按流量比例随机分配<b>链路</b>流量出口，缺点是易导致网络访问不稳定和不正常；<b>静态分流模式</b>时，软件将根据路由器中所有已设置策略的流量出口分布情况，以系统策略路由库资源占用最小化为原则，自动为策略流量指定一个固定出口，运行中的实际出口可在<b>外部网络(WAN) - 策略路由(IPv4) - 运行</b>中点击<b>「获取运行状态」</b>按钮查看。<br />";
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
        content += "<br /><b>负载均衡</b>：<b>动态分流模式</b>时，由系统采用<b>链路负载均衡</b>技术在<b>首选 WAN</b> 与<b>第二 WAN</b> 二者之中按流量比例随机分配<b>链路</b>流量出口，缺点是易导致网络访问不稳定和不正常；<b>静态分流模式</b>时，软件将根据路由器中所有已设置策略的流量出口分布情况，以系统策略路由库资源占用最小化为原则，自动为策略流量指定一个固定出口，运行中的实际出口可在<b>外部网络(WAN) - 策略路由(IPv4) - 运行</b>中点击<b>「获取运行状态」</b>按钮查看。<br />";
        content += "<br /><b>策略执行优先级</b>：详见<b>基本设置&nbsp;-&nbsp;策略路由优先级</b></div>";
    } else if (itemNum == 12) {
        content = "<div><b>国外运营商</b>流量出口选项："
        content += "<ul>";
        content += "<li>首选 WAN (缺省)</li>";
        content += "<li>第二 WAN</li>";
        content += "<li>负载均衡</li>";
        content += "</ul>";
        content += "<b>负载均衡</b>：<b>动态分流模式</b>时，由系统采用<b>链路负载均衡</b>技术在<b>首选 WAN</b> 与<b>第二 WAN</b> 二者之中按流量比例随机分配<b>链路</b>流量出口，缺点是易导致网络访问不稳定和不正常；<b>静态分流模式</b>时，软件将根据路由器中所有已设置策略的流量出口分布情况，以系统策略路由库资源占用最小化为原则，自动为策略流量指定一个固定出口，运行中的实际出口可在<b>外部网络(WAN) - 策略路由(IPv4) - 运行</b>中点击<b>「获取运行状态」</b>按钮查看。<br />";
        content += "<br /><b>策略执行优先级</b>：详见<b>基本设置&nbsp;-&nbsp;策略路由优先级</b></div>";
    } else if (itemNum == 13) {
        content = "<div><b>运营商 IP 地址数据</b>经常发生变化，建议<b>启用定时更新</b>。<br /><br />亦可前往<b>外部网络(WAN) - 策略路由(IPv4) - 工具 - 快捷命令 - 命令 - 运营商 IP 地址数据</b>手动更新数据。</div>";
    } else if (itemNum == 14) {
        content = "<div>本策略仅对路由器下属<b>客户端</b>设备访问外部网络的数据流量有效。<br />";
        content += "<br /><b>动态分流模式</b>时自动与同一出口的运营商 IP 地址数据合集，采用同一条限定优先级的动态路由策略。<br />";
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
        content += "<b>负载均衡</b>：<b>动态分流模式</b>时，由系统采用<b>链路负载均衡</b>技术在<b>首选 WAN</b> 与<b>第二 WAN</b> 二者之中按流量比例随机分配<b>链路</b>流量出口，缺点是易导致网络访问不稳定和不正常；<b>静态分流模式</b>时，软件将根据路由器中所有已设置策略的流量出口分布情况，以系统策略路由库资源占用最小化为原则，自动为策略流量指定一个固定出口，运行中的实际出口可在<b>外部网络(WAN) - 策略路由(IPv4) - 运行</b>中点击<b>「获取运行状态」</b>按钮查看。<br />";
        content += "<br /><b>策略执行优先级</b>：详见<b>基本设置&nbsp;-&nbsp;策略路由优先级</b></div>";
    } else if (itemNum == 16) {
        content = `<div>缺省文件名为 <b>${policySettingsArray.path}/data/custom_data_1.txt</b>，无有效数据条目。<br />`;
        content += "<br />文件路径、名称可自定义和修改，文件路径及名称不得为空。<br />";
        content += "<br />文本格式：一个网址/网段一行，为一个条目，可多行多个条目。<br />";
        content += "<br />例如：<br />";
        content += "123.234.123.111<br />";
        content += "133.234.123.0/24<br />";
        content += "<br />此文件中 <b>0.0.0.0/0</b>、<b>0.0.0.0</b> 和<b>路由器本地 IP 地址</b>为无效地址。<br />";
        content += "<br />为避免软件升级更新或重新安装导致配置重置为缺省状态，建议更改文件名或文件存储路径。</div>";
    } else if (itemNum == 17) {
        content = "<div><b>自定义策略 - 2</b> 流量出口选项："
        content += "<ul>";
        content += "<li>首选 WAN</li>";
        content += "<li>第二 WAN</li>";
        content += "<li>负载均衡</li>";
        content += "<li>停用 (缺省)</li>";
        content += "</ul>";
        content += "<b>负载均衡</b>：<b>动态分流模式</b>时，由系统采用<b>链路负载均衡</b>技术在<b>首选 WAN</b> 与<b>第二 WAN</b> 二者之中按流量比例随机分配<b>链路</b>流量出口，缺点是易导致网络访问不稳定和不正常；<b>静态分流模式</b>时，软件将根据路由器中所有已设置策略的流量出口分布情况，以系统策略路由库资源占用最小化为原则，自动为策略流量指定一个固定出口，运行中的实际出口可在<b>外部网络(WAN) - 策略路由(IPv4) - 运行</b>中点击<b>「获取运行状态」</b>按钮查看。<br />";
        content += "<br /><b>策略执行优先级</b>：详见<b>基本设置&nbsp;-&nbsp;策略路由优先级</b></div>";
    } else if (itemNum == 18) {
        content = "<div>为<b>客户端 IP 地址列表</b>中所有访问预设域名地址的设备设定流量出口。<br />";
        content += "<br />仅对以 DHCP 方式自动连接路由器，或 DNS 指向路由器主机本地地址的<b>客户端</b>内的网络流量有效。若客户端内软件使用其他 DNS 服务器解析网络访问地址，则本功能无效。<br />";
        content += "<br />功能优先级高于<b>客户端静态直通策略</b>，低于<b>客户端至预设目标 IP 地址静态直通策略</b>、<b>高优先级客户端静态直通策略</b>和<b>客户端至预设目标 IP 地址静态直通策略</b>。<br />";
        content += "<br /><b>策略执行优先级</b>：详见<b>基本设置&nbsp;-&nbsp;策略路由优先级</b></div>";
    } else if (itemNum == 19) {
        content = "<div>文件中具体定义所有使用<b>首选 WAN 口域名地址动态访问策略</b>的客户端在本地网络中的 IP 地址。<br />";
        content += `<br />缺省文件名为 <b>${policySettingsArray.path}/data/wan_1_domain_client_src_addr.txt</b>，无有效数据条目。<br />`;
        content += "<br />文件路径、名称可自定义和修改，文件路径及名称不得为空。<br />";
        content += "<br />文本格式：一个网址/网段一行，为一个条目，可多行多个条目。<br />";
        content += "<br />例如：<br />";
        content += "192.168.50.11<br />";
        content += "10.0.0.0/31<br />";
        content += "<br />可以用 <b>0.0.0.0/0</b> 表示所有客户端，<b>0.0.0.0</b> 和<b>路由器本地 IP 地址</b>为无效地址。<br />";
        content += "<br />为避免软件升级更新或重新安装导致配置重置为缺省状态，建议更改文件名或文件存储路径。</div>";
    } else if (itemNum == 20) {
        content = "<div>文件中具体定义所有使用<b>首选 WAN</b> 口作为流量出口的预设域名地址。<br />";
        content += `<br />缺省文件名为 <b>${policySettingsArray.path}/data/wan_1_domain.txt</b>，无有效数据条目。<br />`;
        content += "<br />文件路径、名称可自定义和修改，文件路径及名称不得为空。<br />";
        content += "<br />文本格式：一个域名地址一行，为一个条目，可多行多个条目。<br />";
        content += "<br />例如：<br />";
        content += "abc.def.com.cn<br />";
        content += "xxx.yyy.zzz<br />";
        content += "<br />本域名地址列表仅支持英文域名地址。<br />";
        content += "<br />一个域名地址条目由多个不同级别的域名连接而成，之间用点号 (.) 相隔，级别最低的在最左边，最高的在最右边。构成域名的字符只能使用英文字母 (a~z，不区分大小写)、数字 (0~9) 以及连接符 (-)。连接符 (-) 不能连续出现，也不能放在域名的开头或结尾。每一级域名不超过 63 个字符，完整域名 (域名地址) 总共不超过 255 个字符。<br />";
        content += "<br />域名地址条目中不能有网络协议前缀 (如 http://、https:// 或 ftp:// 等)、端口号 (如 :23456) 、路径及文件名、特殊符号等影响地址解析的内容。<br />";
        content += "<br />为避免软件升级更新或重新安装导致配置重置为缺省状态，建议更改文件名或文件存储路径。</div>";
    } else if (itemNum == 21) {
        content = "<div>文件中具体定义所有使用<b>第二 WAN 口域名地址动态访问策略</b>的客户端在本地网络中的 IP 地址。<br />";
        content += `<br />缺省文件名为 <b>${policySettingsArray.path}/data/wan_2_domain_client_src_addr.txt</b>，无有效数据条目。<br />`;
        content += "<br />文件路径、名称可自定义和修改，文件路径及名称不得为空。<br />";
        content += "<br />文本格式：一个网址/网段一行，为一个条目，可多行多个条目。<br />";
        content += "<br />例如：<br />";
        content += "192.168.50.102<br />";
        content += "10.0.0.0/30<br />";
        content += "<br />可以用 <b>0.0.0.0/0</b> 表示所有客户端，<b>0.0.0.0</b> 和<b>路由器本地 IP 地址</b>为无效地址。<br />";
        content += "<br />为避免软件升级更新或重新安装导致配置重置为缺省状态，建议更改文件名或文件存储路径。</div>";
    } else if (itemNum == 22) {
        content = "<div>文件中具体定义所有使用<b>第二 WAN</b> 口作为流量出口的预设域名地址。<br />";
        content += `<br />缺省文件名为 <b>${policySettingsArray.path}/data/wan_2_domain.txt</b>，无有效数据条目。<br />`;
        content += "<br />文件路径、名称可自定义和修改，文件路径及名称不得为空。<br />";
        content += "<br />文本格式：一个域名地址一行，为一个条目，可多行多个条目。<br />";
        content += "<br />例如：<br />";
        content += "abc.def.com<br />";
        content += "xxx.yyy.org<br />";
        content += "<br />本域名地址列表仅支持英文域名地址。<br />";
        content += "<br />一个域名地址条目由多个不同级别的域名连接而成，之间用点号 (.) 相隔，级别最低的在最左边，最高的在最右边。构成域名的字符只能使用英文字母 (a~z，不区分大小写)、数字 (0~9) 以及连接符 (-)。连接符 (-) 不能连续出现，也不能放在域名的开头或结尾。每一级域名不超过 63 个字符，完整域名 (域名地址) 总共不超过 255 个字符。<br />";
        content += "<br />域名地址条目中不能有网络协议前缀 (如 http://、https:// 或 ftp:// 等)、端口号 (如 :23456) 、路径及文件名、特殊符号等影响地址解析的内容。<br />";
        content += "<br />为避免软件升级更新或重新安装导致配置重置为缺省状态，建议更改文件名或文件存储路径。</div>";
    } else if (itemNum == 23) {
        content = "<div>为<b>客户端 IP 地址列表</b>中所有使用固定出口的设备绑定流量出口。<br />";
        content += "<br /><b>策略执行优先级</b>：详见<b>基本设置&nbsp;-&nbsp;策略路由优先级</b></div>";
    } else if (itemNum == 24) {
        content = "<div>文件中具体定义所有使用<b>首选 WAN 口客户端静态直通策略</b>的客户端在本地网络中的 IP 地址。<br />";
        content += `<br />缺省文件名为 <b>${policySettingsArray.path}/data/wan_1_client_src_addr.txt</b>，无有效数据条目。<br />`;
        content += "<br />文件路径、名称可自定义和修改，文件路径及名称不得为空。<br />";
        content += "<br />文本格式：一个网址/网段一行，为一个条目，可多行多个条目。<br />";
        content += "<br />例如：<br />";
        content += "192.168.50.101<br />";
        content += "10.6.0.0/24<br />";
        content += "<br />可以用 <b>0.0.0.0/0</b> 表示所有客户端，<b>0.0.0.0</b> 和<b>路由器本地 IP 地址</b>为无效地址。<br />";
        content += "<br />为避免软件升级更新或重新安装导致配置重置为缺省状态，建议更改文件名或文件存储路径。</div>";
    } else if (itemNum == 25) {
        content = "<div>文件中具体定义所有使用<b>第二 WAN 口客户端静态直通策略</b>的客户端在本地网络中的 IP 地址。<br />";
        content += `<br />缺省文件名为 <b>${policySettingsArray.path}/data/wan_2_client_src_addr.txt</b>，无有效数据条目。<br />`;
        content += "<br />文件路径、名称可自定义和修改，文件路径及名称不得为空。<br />";
        content += "<br />文本格式：一个网址/网段一行，为一个条目，可多行多个条目。<br />";
        content += "<br />例如：<br />";
        content += "192.168.50.17<br />";
        content += "10.10.10.0/31<br />";
        content += "<br />可以用 <b>0.0.0.0/0</b> 表示所有客户端，<b>0.0.0.0</b> 和<b>路由器本地 IP 地址</b>为无效地址。<br />";
        content += "<br />为避免软件升级更新或重新安装导致配置重置为缺省状态，建议更改文件名或文件存储路径。</div>";
    } else if (itemNum == 26) {
        content = "<div>为<b>客户端 IP 地址列表</b>中所有使用固定出口的设备以高优先级方式绑定流量出口。<br />";
        content += "<br /><b>策略执行优先级</b>：详见<b>基本设置&nbsp;-&nbsp;策略路由优先级</b></div>";
    } else if (itemNum == 27) {
        content = "<div>文件中具体定义所有使用<b>首选 WAN 口高优先级客户端静态直通策略</b>的客户端在本地网络中的 IP 地址。<br />";
        content += `<br />缺省文件名为 <b>${policySettingsArray.path}/data/high_wan_1_client_src_addr.txt</b>，无有效数据条目。<br />`;
        content += "<br />文件路径、名称可自定义和修改，文件路径及名称不得为空。<br />";
        content += "<br />文本格式：一个网址/网段一行，为一个条目，可多行多个条目。<br />";
        content += "<br />例如：<br />";
        content += "192.168.50.9<br />";
        content += "10.0.0.0/25<br />";
        content += "<br />可以用 <b>0.0.0.0/0</b> 表示所有客户端，<b>0.0.0.0</b> 和<b>路由器本地 IP 地址</b>为无效地址。<br />";
        content += "<br />为避免软件升级更新或重新安装导致配置重置为缺省状态，建议更改文件名或文件存储路径。</div>";
    } else if (itemNum == 28) {
        content = "<div>文件中具体定义所有使用<b>第二 WAN 口高优先级客户端静态直通策略</b>的客户端在本地网络中的 IP 地址。<br />";
        content += `<br />缺省文件名为 <b>${policySettingsArray.path}/data/high_wan_2_client_src_addr.txt</b>，无有效数据条目。<br />`;
        content += "<br />文件路径、名称可自定义和修改，文件路径及名称不得为空。<br />";
        content += "<br />文本格式：一个网址/网段一行，为一个条目，可多行多个条目。<br />";
        content += "<br />例如：<br />";
        content += "192.168.50.12<br />";
        content += "10.10.10.0/31<br />";
        content += "<br />可以用 <b>0.0.0.0/0</b> 表示所有客户端，<b>0.0.0.0</b> 和<b>路由器本地 IP 地址</b>为无效地址。<br />";
        content += "<br />为避免软件升级更新或重新安装导致配置重置为缺省状态，建议更改文件名或文件存储路径。</div>";
    } else if (itemNum == 29) {
        content = "<div>指定客户端以静态路由方式访问预设目标 IP 地址时使用的流量出口。<br />";
        content += "<br /><b>策略执行优先级</b>：详见<b>基本设置&nbsp;-&nbsp;策略路由优先级</b></div>";
    } else if (itemNum == 30) {
        content = "<div>文件中具体定义使用<b>首选 WAN 口客户端至预设目标 IP 地址静态直通策略</b>的客户端 IP 地址和目标 IP 地址。<br />";
        content += `<br />缺省文件名为 <b>${policySettingsArray.path}/data/wan_1_src_to_dst_addr.txt</b>，无有效数据条目。<br />`;
        content += "<br />文件路径、名称可自定义和修改，文件路径及名称不得为空。<br />";
        content += "<br />文本格式：每行的<b>源地址</b>和<b>目标地址</b>之间按顺序用<b>空格</b>隔开，一个条目一行，可多行多个条目。<br />";
        content += "<br />例如：<br />";
        content += "192.168.50.101&nbsp;103.10.4.108<br />";
        content += "0.0.0.0/0&nbsp;202.89.233.100<br />";
        content += "<br />可以用 <b>0.0.0.0/0</b> 表示所有未知 IP 地址，<b>0.0.0.0</b> 和<b>路由器本地 IP 地址</b>为无效地址。<br />";
        content += "<br /><b>NAS 设备</b>远程访问接入示例：<br />";
        content += "假设 NAS 设备本地地址为 192.168.50.123，通过本 WAN 口远程访问，需填写如下两个条目：<br />";
        content += "192.168.50.123&nbsp;0.0.0.0/0<br />";
        content += "0.0.0.0/0&nbsp;192.168.50.123<br />";
        content += "若有多个 NAS 设备通过本 WAN 口远程访问，可按地址依次填写条目对。<br />";
        content += "同时要求<b>外部网络(WAN) - 策略路由(IPv4) - 高级 - 远程访问及本机应用访问外网静态直通策略 - 远程访问入口及本机应用访问外网出口</b>和路由器系统的 <b>DDNS</b> 出口必须也设置为本 WAN 口。<br />";
        content += "<br />建议列表条目数量不要多于512条，否则易导致软件启动时系统<b>策略路由</b>库加载数据时间过长。<br />";
        content += "<br />为避免软件升级更新或重新安装导致配置重置为缺省状态，建议更改文件名或文件存储路径。</div>";
    } else if (itemNum == 31) {
        content = "<div>文件中具体定义使用<b>第二 WAN 口客户端至预设目标 IP 地址静态直通策略</b>的客户端 IP 地址和目标 IP 地址。<br />";
        content += `<br />缺省文件名为 <b>${policySettingsArray.path}/data/wan_2_src_to_dst_addr.txt</b>，无有效数据条目。<br />`;
        content += "<br />文件路径、名称可自定义和修改，文件路径及名称不得为空。<br />";
        content += "<br />文本格式：每行的<b>源地址</b>和<b>目标地址</b>之间按顺序用<b>空格</b>隔开，一个条目一行，可多行多个条目。<br />";
        content += "<br />例如：<br />";
        content += "192.168.50.102&nbsp;210.74.0.0/16<br />";
        content += "<br />可以用 <b>0.0.0.0/0</b> 表示所有未知 IP 地址，<b>0.0.0.0</b> 和<b>路由器本地 IP 地址</b>为无效地址。<br />";
        content += "<br /><b>NAS 设备</b>远程访问接入示例：<br />";
        content += "假设 NAS 设备本地地址为 192.168.50.123，通过本 WAN 口远程访问，需填写如下两个条目：<br />";
        content += "192.168.50.123&nbsp;0.0.0.0/0<br />";
        content += "0.0.0.0/0&nbsp;192.168.50.123<br />";
        content += "若有多个 NAS 设备通过本 WAN 口远程访问，可按地址依次填写条目对。<br />";
        content += "同时要求<b>外部网络(WAN) - 策略路由(IPv4) - 高级 - 远程访问及本机应用访问外网静态直通策略 - 远程访问入口及本机应用访问外网出口</b>和路由器系统的 <b>DDNS</b> 出口必须也设置为本 WAN 口。<br />";
        content += "<br />建议列表条目数量不要多于512条，否则易导致软件启动时系统<b>策略路由</b>库加载数据时间过长。<br />";
        content += "<br />为避免软件升级更新或重新安装导致配置重置为缺省状态，建议更改文件名或文件存储路径。</div>";
    } else if (itemNum == 32) {
        content = "<div>指定客户端以高优先级的静态路由方式访问预设目标 IP 地址时使用的流量出口。<br />";
        content += "<br /><b>策略执行优先级</b>：详见<b>基本设置&nbsp;-&nbsp;策略路由优先级</b></div>";
    } else if (itemNum == 33) {
        content = "<div>文件中具体定义使用<b>首选 WAN 口高优先级客户端至预设目标 IP 地址静态直通策略</b>的客户端 IP 地址和目标 IP 地址。<br />";
        content += `<br />缺省文件名为 <b>${policySettingsArray.path}/data/high_wan_1_src_to_dst_addr.txt</b>，无有效数据条目。<br />`;
        content += "<br />文件路径、名称可自定义和修改，文件路径及名称不得为空。<br />";
        content += "<br />文本格式：每行的<b>源地址</b>和<b>目标地址</b>之间按顺序用<b>空格</b>隔开，一个条目一行，可多行多个条目。<br />";
        content += "<br />例如：<br />";
        content += "192.168.50.0/27&nbsp;0.0.0.0/0<br />";
        content += "<br />可以用 <b>0.0.0.0/0</b> 表示所有未知 IP 地址，<b>0.0.0.0</b> 和<b>路由器本地 IP 地址</b>为无效地址。<br />";
        content += "<br /><b>NAS 设备</b>远程访问接入示例：<br />";
        content += "假设 NAS 设备本地地址为 192.168.50.123，通过本 WAN 口远程访问，需填写如下两个条目：<br />";
        content += "192.168.50.123&nbsp;0.0.0.0/0<br />";
        content += "0.0.0.0/0&nbsp;192.168.50.123<br />";
        content += "若有多个 NAS 设备通过本 WAN 口远程访问，可按地址依次填写条目对。<br />";
        content += "同时要求<b>外部网络(WAN) - 策略路由(IPv4) - 高级 - 远程访问及本机应用访问外网静态直通策略 - 远程访问入口及本机应用访问外网出口</b>和路由器系统的 <b>DDNS</b> 出口必须也设置为本 WAN 口。<br />";
        content += "<br />建议列表条目数量不要多于512条，否则易导致软件启动时系统<b>策略路由</b>库加载数据时间过长。<br />";
        content += "<br />为避免软件升级更新或重新安装导致配置重置为缺省状态，建议更改文件名或文件存储路径。</div>";
    } else if (itemNum == 34) {
        content = "<div>按照目标地址的协议端口设定流量出口。<br />";
        content += "<br />本策略仅对路由器下属<b>客户端</b>设备访问外部网络的数据流量有效。<br />";
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
        caption = "客户端地址至目标地址协议端口列表";
        content = "<div>文件中具体定义客户端使用<b>首选 WAN</b> 口作为流量出口访问预设地址协议端口的客户端 IP 地址和目标 IP 地址的协议端口。<br />";
        content += `<br />缺省文件名为 <b>${policySettingsArray.path}/data/wan_1_src_to_dst_addr_port.txt</b>，无有效数据条目。<br />`;
        content += "<br />文件路径、名称可自定义和修改，文件路径及名称不得为空。<br />";
        content += "<br />文本格式：每行各字段之间用<b>空格</b>隔开，一个条目一行，可多行多个条目。<br />";
        content += "<br />客户端地址&nbsp;目标地址&nbsp;通讯协议&nbsp;客户端源端口号&nbsp;目标端口号<br />";
        content += "客户端地址&nbsp;目标地址&nbsp;通讯协议&nbsp;目标端口号<br />";
        content += "客户端地址&nbsp;目标地址&nbsp;通讯协议<br />";
        content += "客户端地址&nbsp;目标地址<br />";
        content += "客户端地址<br />";
        content += "<br />例如：<br />";
        content += "192.168.50.101&nbsp;123.123.123.121&nbsp;tcp&nbsp;80,443,6881:6889,25671&nbsp;801,4431,16881:16889,225671<br />";
        content += "192.168.50.102&nbsp;123.123.123.122&nbsp;udp&nbsp;any&nbsp;8080<br />";
        content += "192.168.50.103&nbsp;123.123.123.123&nbsp;tcp&nbsp;8081&nbsp;any<br />";
        content += "192.168.50.104&nbsp;123.123.123.124&nbsp;udp&nbsp;80,443,6881:6889,25671<br />";
        content += "192.168.50.0/27&nbsp;123.123.123.0/24&nbsp;tcp&nbsp;4334<br />";
        content += "0.0.0.0/0&nbsp;123.123.123.125&nbsp;udplite&nbsp;12345<br />";
        content += "192.168.50.105&nbsp;0.0.0.0/0&nbsp;sctp<br />";
        content += "0.0.0.0/0&nbsp;0.0.0.0/0<br />";
        content += "192.168.50.106<br />";
        content += "<br />可以用 <b>0.0.0.0/0</b> 表示所有未知 IP 地址，<b>0.0.0.0</b> 和<b>路由器本地 IP 地址</b>为无效地址，<b>any</b> 表示任意未知端口号。<br />";
        content += "<br /><b>客户端地址</b>为必选项。<br />";
        content += "<br /><b>目标地址</b>、<b>通讯协议</b>、<b>客户端源端口号</b>及<b>目标端口号</b>为可选项。填写<b>通讯协议</b>时，<b>目标地址</b>则成为必选项，后续依此类推。<br />";
        content += "<br />每个条目只能使用一个端口通讯协议，只能是 TCP、UDP、UDPLITE、SCTP 四种协议中的一个，字母英文大小写均可。<br />";
        content += "<br />连续端口号中间用英文半角 <b>:</b> 冒号相隔，如：6881:6889 表示 6881~6889 的连续端口号。<br />";
        content += "<br />每个条目最多可设置 15 个不连续的目标访问端口号埠，不连续的端口号埠之间用英文半角 <b>,</b> 逗号相隔，不要有空格。<br />";
        content += "<br />等效设置一，例如：<br />";
        content += "192.168.50.12&nbsp;123.123.123.151&nbsp;tcp&nbsp;any&nbsp;80,443,6881:6889,25671<br />";
        content += "192.168.50.12&nbsp;123.123.123.151&nbsp;tcp&nbsp;80,443,6881:6889,25671<br />";
        content += "<br />等效设置二，例如：<br />";
        content += "192.168.50.12&nbsp;123.123.123.151&nbsp;tcp&nbsp;any&nbsp;any<br />";
        content += "192.168.50.12&nbsp;123.123.123.151&nbsp;tcp&nbsp;any<br />";
        content += "192.168.50.12&nbsp;123.123.123.151&nbsp;tcp<br />";
        content += "<br />等效设置三，例如：<br />";
        content += "192.168.50.12&nbsp;0.0.0.0/0<br />";
        content += "192.168.50.12<br />";
        content += "<br />为避免软件升级更新或重新安装导致配置重置为缺省状态，建议更改文件名或文件存储路径。</div>";
    } else if (itemNum == 37) {
        mode = 1;
        caption = "客户端地址至目标地址协议端口列表";
        content = "<div>文件中具体定义客户端使用<b>第二 WAN</b> 口作为流量出口访问预设地址协议端口的客户端 IP 地址和目标 IP 地址的协议端口。<br />";
        content += `<br />缺省文件名为 <b>${policySettingsArray.path}/data/wan_2_src_to_dst_addr_port.txt</b>，无有效数据条目。<br />`;
        content += "<br />文件路径、名称可自定义和修改，文件路径及名称不得为空。<br />";
        content += "<br />文本格式：每行各字段之间用<b>空格</b>隔开，一个条目一行，可多行多个条目。<br />";
        content += "<br />客户端地址&nbsp;目标地址&nbsp;通讯协议&nbsp;客户端源端口号&nbsp;目标端口号<br />";
        content += "客户端地址&nbsp;目标地址&nbsp;通讯协议&nbsp;目标端口号<br />";
        content += "客户端地址&nbsp;目标地址&nbsp;通讯协议<br />";
        content += "客户端地址&nbsp;目标地址<br />";
        content += "客户端地址<br />";
        content += "<br />例如：<br />";
        content += "192.168.50.101&nbsp;123.123.123.121&nbsp;tcp&nbsp;80,443,6881:6889,25671&nbsp;801,4431,16881:16889,225671<br />";
        content += "192.168.50.102&nbsp;123.123.123.122&nbsp;udp&nbsp;any&nbsp;8080<br />";
        content += "192.168.50.103&nbsp;123.123.123.123&nbsp;tcp&nbsp;8081&nbsp;any<br />";
        content += "192.168.50.104&nbsp;123.123.123.124&nbsp;udp&nbsp;80,443,6881:6889,25671<br />";
        content += "192.168.50.0/27&nbsp;123.123.123.0/24&nbsp;tcp&nbsp;4334<br />";
        content += "0.0.0.0/0&nbsp;123.123.123.125&nbsp;udplite&nbsp;12345<br />";
        content += "192.168.50.105&nbsp;0.0.0.0/0&nbsp;sctp<br />";
        content += "0.0.0.0/0&nbsp;0.0.0.0/0<br />";
        content += "192.168.50.106<br />";
        content += "<br />可以用 <b>0.0.0.0/0</b> 表示所有未知 IP 地址，<b>0.0.0.0</b> 和<b>路由器本地 IP 地址</b>为无效地址，<b>any</b> 表示任意未知端口号。<br />";
        content += "<br /><b>客户端地址</b>为必选项。<br />";
        content += "<br /><b>目标地址</b>、<b>通讯协议</b>、<b>客户端源端口号</b>及<b>目标端口号</b>为可选项。填写<b>通讯协议</b>时，<b>目标地址</b>则成为必选项，后续依此类推。<br />";
        content += "<br />每个条目只能使用一个端口通讯协议，只能是 TCP、UDP、UDPLITE、SCTP 四种协议中的一个，字母英文大小写均可。<br />";
        content += "<br />连续端口号中间用英文半角 <b>:</b> 冒号相隔，如：6881:6889 表示 6881~6889 的连续端口号。<br />";
        content += "<br />每个条目最多可设置 15 个不连续的目标访问端口号埠，不连续的端口号埠之间用英文半角 <b>,</b> 逗号相隔，不要有空格。<br />";
        content += "<br />等效设置一，例如：<br />";
        content += "192.168.50.12&nbsp;123.123.123.151&nbsp;tcp&nbsp;any&nbsp;80,443,6881:6889,25671<br />";
        content += "192.168.50.12&nbsp;123.123.123.151&nbsp;tcp&nbsp;80,443,6881:6889,25671<br />";
        content += "<br />等效设置二，例如：<br />";
        content += "192.168.50.12&nbsp;123.123.123.151&nbsp;tcp&nbsp;any&nbsp;any<br />";
        content += "192.168.50.12&nbsp;123.123.123.151&nbsp;tcp&nbsp;any<br />";
        content += "192.168.50.12&nbsp;123.123.123.151&nbsp;tcp<br />";
        content += "<br />等效设置三，例如：<br />";
        content += "192.168.50.12&nbsp;0.0.0.0/0<br />";
        content += "192.168.50.12<br />";
        content += "<br />为避免软件升级更新或重新安装导致配置重置为缺省状态，建议更改文件名或文件存储路径。</div>";
    } else if (itemNum == 38) {
        content = "<div>定义客户端高优先级方式使用指定流量出口访问预设地址的协议端口，可一次性的同时实现多种灵活、精准的流量策略。<br />";
        content += "<br />仅用于 TCP、UDP、UDPLITE、SCTP 四类协议端口。<br />";
        content += "<br />功能优先级高于<b>域名地址动态访问策略</b>和<b>客户端静态直通策略</b>，低于<b>高优先级客户端静态直通策略</b>和<b>客户端至预设目标 IP 地址静态直通策略</b>。<br />";
        content += "<br /><b>策略执行优先级</b>：详见<b>基本设置&nbsp;-&nbsp;策略路由优先级</b></div>";
    } else if (itemNum == 39) {
        mode = 1;
        caption = "客户端地址至目标地址协议端口列表";
        content = "<div>文件中具体定义客户端使用<b>首选 WAN</b> 口作为流量出口高优先级访问预设地址协议端口的客户端 IP 地址和目标 IP 地址的协议端口。<br />";
        content += `<br />缺省文件名为 <b>${policySettingsArray.path}/data/high_wan_1_src_to_dst_addr_port.txt</b>，无有效数据条目。<br />`;
        content += "<br />文件路径、名称可自定义和修改，文件路径及名称不得为空。<br />";
        content += "<br />文本格式：每行各字段之间用<b>空格</b>隔开，一个条目一行，可多行多个条目。<br />";
        content += "<br />客户端地址&nbsp;目标地址&nbsp;通讯协议&nbsp;客户端源端口号&nbsp;目标端口号<br />";
        content += "客户端地址&nbsp;目标地址&nbsp;通讯协议&nbsp;目标端口号<br />";
        content += "客户端地址&nbsp;目标地址&nbsp;通讯协议<br />";
        content += "客户端地址&nbsp;目标地址<br />";
        content += "客户端地址<br />";
        content += "<br />例如：<br />";
        content += "192.168.50.101&nbsp;123.123.123.121&nbsp;tcp&nbsp;80,443,6881:6889,25671&nbsp;801,4431,16881:16889,225671<br />";
        content += "192.168.50.102&nbsp;123.123.123.122&nbsp;udp&nbsp;any&nbsp;8080<br />";
        content += "192.168.50.103&nbsp;123.123.123.123&nbsp;tcp&nbsp;8081&nbsp;any<br />";
        content += "192.168.50.104&nbsp;123.123.123.124&nbsp;udp&nbsp;80,443,6881:6889,25671<br />";
        content += "192.168.50.0/27&nbsp;123.123.123.0/24&nbsp;tcp&nbsp;4334<br />";
        content += "0.0.0.0/0&nbsp;123.123.123.125&nbsp;udplite&nbsp;12345<br />";
        content += "192.168.50.105&nbsp;0.0.0.0/0&nbsp;sctp<br />";
        content += "0.0.0.0/0&nbsp;0.0.0.0/0<br />";
        content += "192.168.50.106<br />";
        content += "<br />可以用 <b>0.0.0.0/0</b> 表示所有未知 IP 地址，<b>0.0.0.0</b> 和<b>路由器本地 IP 地址</b>为无效地址，<b>any</b> 表示任意未知端口号。<br />";
        content += "<br /><b>客户端地址</b>为必选项。<br />";
        content += "<br /><b>目标地址</b>、<b>通讯协议</b>、<b>客户端源端口号</b>及<b>目标端口号</b>为可选项。填写<b>通讯协议</b>时，<b>目标地址</b>则成为必选项，后续依此类推。<br />";
        content += "<br />每个条目只能使用一个端口通讯协议，只能是 TCP、UDP、UDPLITE、SCTP 四种协议中的一个，字母英文大小写均可。<br />";
        content += "<br />连续端口号中间用英文半角 <b>:</b> 冒号相隔，如：6881:6889 表示 6881~6889 的连续端口号。<br />";
        content += "<br />每个条目最多可设置 15 个不连续的目标访问端口号埠，不连续的端口号埠之间用英文半角 <b>,</b> 逗号相隔，不要有空格。<br />";
        content += "<br />等效设置一，例如：<br />";
        content += "192.168.50.12&nbsp;123.123.123.151&nbsp;tcp&nbsp;any&nbsp;80,443,6881:6889,25671<br />";
        content += "192.168.50.12&nbsp;123.123.123.151&nbsp;tcp&nbsp;80,443,6881:6889,25671<br />";
        content += "<br />等效设置二，例如：<br />";
        content += "192.168.50.12&nbsp;123.123.123.151&nbsp;tcp&nbsp;any&nbsp;any<br />";
        content += "192.168.50.12&nbsp;123.123.123.151&nbsp;tcp&nbsp;any<br />";
        content += "192.168.50.12&nbsp;123.123.123.151&nbsp;tcp<br />";
        content += "<br />等效设置三，例如：<br />";
        content += "192.168.50.12&nbsp;0.0.0.0/0<br />";
        content += "192.168.50.12<br />";
        content += "<br />为避免软件升级更新或重新安装导致配置重置为缺省状态，建议更改文件名或文件存储路径。</div>";
    } else if (itemNum == 40) {
        content = "<div>列入本策略<b>客户端 IP 地址列表</b>中的设备访问外网时不受其他路由策略影响，仅由系统采用<b>链路负载均衡</b>技术在<b>首选 WAN</b> 与<b>第二 WAN</b> 二者之中按流量比例随机分配<b>链路</b>流量出口，缺点是易导致网络访问不稳定和不正常。该功能可实现一些特殊用途的应用 (如带速叠加下载，但外部影响因素较多，不保证此业务在所有情况下都能实现)。<br />";
        content += "<br /><b>策略执行优先级</b>：详见<b>基本设置&nbsp;-&nbsp;策略路由优先级</b></div>";
    } else if (itemNum == 41) {
        content = `<div>缺省文件名为 <b>${policySettingsArray.path}/data/local_ipsets_data.txt</b>，无有效数据条目。<br />`;
        content += "<br />文件路径、名称可自定义和修改，文件路径及名称不得为空。<br />";
        content += "<br />文文本格式：一个网址/网段一行，为一个条目，可多行多个条目。<br />";
        content += "<br />例如：<br />";
        content += "192.168.50.0/31<br />";
        content += "192.168.50.207<br />";
        content += "<br />此文件中 <b>0.0.0.0/0</b>、<b>0.0.0.0</b> 和<b>路由器本地 IP 地址</b>为无效地址。<br />";
        content += "<br />为避免软件升级更新或重新安装导致配置重置为缺省状态，建议更改文件名或文件存储路径。</div>";
    } else if (itemNum == 42) {
        content = "<div>本策略用于从外部网络远程连接路由器访问本地网络，以及路由器本机内部应用访问外部网络。<br />";
        content += "<br /><b>策略执行优先级</b>：详见<b>基本设置&nbsp;-&nbsp;策略路由优先级</b></div>";
    } else if (itemNum == 43) {
        content = "<div>该网口用于从外网访问路由器及本地网络 (应与 DDNS 出口保持一致)，以及路由器本机内部应用访问外部网络，上述网络流量共用同一个路由器外网网口，缺省为<b>首选 WAN</b>。<br />";
        content += "<br />部分版本的固件系统，已在系统底层将路由器内置的 DDNS 绑定至<b>首选 WAN</b>，更改或可导致远程访问路由器失败。<br />";
        content += "<br /><b>策略执行优先级</b>：详见<b>基本设置&nbsp;-&nbsp;策略路由优先级</b></div>";
    } else if (itemNum == 44) {
        content = "<div>VPN 客户端在双线路负载均衡模式下远程接入路由器成功后，远程的 VPN 客户端作为虚拟的路由器本地内网设备，可为其指定访问外部网络的路由器流量出口。<br />";
        content += "<br />访问外网出口选项：<br />";
        content += "<ul>";
        content += "<li>首选 WAN (缺省)</li>";
        content += "<li>第二 WAN</li>";
        content += "<li>现有策略</li>";
        content += "</ul>";
        content += "<b>现有策略</b>：已在路由器上运行的其他策略。选择此选项时，唯有 WireGuard 虚拟专用网络服务器在<b>动态分流模式</b>下由路由器<b>系统</b>自动分配流量出口，不受路由器上运行的其他策略影响。<br />";
        content += "<br />对于 OpenVPN Server，本路由器系统仅支持网络层的 TUN 虚拟设备接口类型，可收发第三层数据报文包，无法对采用链路层 TAP 接口类型的第二层数据报文包进行路由控制。<br />";
        content += "<br /><b>策略执行优先级</b>：详见<b>基本设置&nbsp;-&nbsp;策略路由优先级</b></div>";
    } else if (itemNum == 45) {
        content = "<div>缺省为 <b>5</b> 秒。<br />";
        content += "<br />用于双线路负载均衡模式下路由器内置的 PPTP、IPSec  和WireGuard 虚拟专用网络服务器，对 OpenVPN 虚拟专用网络服务器无效。<br />";
        content += "<br />能够在设定的时间间隔内通过后台守护进程，轮询检测和监控 PPTP、IPSec  和WireGuard 服务器和客户端的启停及远程接入状态，适时调整和更新路由器内相关的路由规则和工作方式。<br />";
        content += "<br />时间间隔越短，客户端路由连接可尽早建立，接入越快。但过短的时间间隔有可能早造成路由器资源争抢。对于 GT-AX6000 类硬件平台的路由器，可设置为1~3秒。对于性能较弱，或版本老旧的路由器，可根据路由器 CPU 资源占用的实测结果和应用体验合理调整该参数。</div>";
    } else if (itemNum == 46) {
        content = "<div>本策略以<b>静态直通</b>方式为路由器内的第三方<b>传输转发代理</b>软件与外网<b>节点服务器</b>之间的双向网络链路流量设置路由，且只针对<b>远程节点服务器地址列表</b>中的有效地址条目。<br />";
        content += "<br /><b>停用</b>时，路由器内的所有<b>传输转发代理</b>软件与外网<b>节点服务器</b>之间的双向网络链路流量将按照<b>远程访问及本机应用访问外网静态直通策略</b>中的设置，作为路由器本机内部应用访问外部网络和从外网访问路由器的方式进行路由，不用在<b>远程节点服务器地址列表</b>中设置任何远程节点服务器的地址条目。<br />";
        content += "<br /><b>策略执行优先级</b>：详见<b>基本设置&nbsp;-&nbsp;策略路由优先级</b></div>";
    } else if (itemNum == 47) {
        content = "<div>路由策略运行时参数配置。</div>";
    } else if (itemNum == 48) {
        mode = 1;
        caption = "应用模式";
        content = "<div>缺省为<b>动态分流模式</b> (推荐)。<br />";
        content += "<br /><b>动态路由</b>：<br />";
        content += "采用基于连接跟踪的报文数据包地址匹配标记导流的数据路由传输技术，能通过算法动态生成数据经由路径，较少占用系统<b>策略路由</b>库静态资源。<br />";
        content += "<br /><b>静态路由</b>：<br />";
        content += "采用按数据来源和目标地址通过经由路径规则直接映射网络出口的数据路由传输技术，当经由路径规则条目数很多时会大量占用系统<b>策略路由</b>库的静态资源，若硬件平台性能有限，会出现数据库启动加载时间过长的现象。<br />";
        content += "<br /><b>动态分流模式</b>：<br />";
        content += "国内及国外运营商目标 IP 地址流量采用<b>动态路由</b>技术，其他功能中混合使用<b>静态路由</b>技术，适用于绝大部分功能。<br />";
        content += "路由器主机内应用的流量出口由设备系统内部自动分配，不受用户定义的流量策略控制，用户规则只作用于路由器内网终端访问外网时的流量。<br />";
        content += "<br /><b>静态分流模式</b>：<br />";
        content += "国内及国外运营商目标 IP 地址流量采用<b>静态路由</b>技术。一个通道采用逐条匹配用户策略的方式传输流量，之外的流量则不再逐条匹配，而是采取整体推送的方式传输至另一通道，从而节省设备系统资源，提高传输效率。<br />";
        content += "路由器主机内部应用的流量出口按用户所定义的流量策略分配。<br />";
        content += "<br />本工具提供两种应用模式 (<b>动态分流模式</b>、<b>静态路由</b>)，将<b>动态路由</b>、<b>静态路由</b>两种作用于路由器 WAN 口通道的基础网络数据路由传输技术，组合形成<b>策略路由</b>服务的多种运行模式，并在此基础上结合运营商 IP 地址数据及出口参数配置等场景因素进行更高层的应用级封装，对软件运行时参数进行自动化配置，从而最大限度的降低用户配置参数的复杂度和难度。</div>";
    } else if (itemNum == 49) {
        content = "<div>缺省使用<b>系统 DNS</b>。<br />";
        content += "<br />启用<b>代理转发静态直通策略</b>功能时，若<b>远程节点服务器地址列表</b>中包含有域名地址，可使用本功能在<b>策略路由</b>软件启动过程中提前对该列表内的域名条目进行 IPv4 地址解析，以获取远程节点的静态 IP 地址。<br />";
        content += "<br /><b>系统 DNS</b>：使用路由器的 DNS 设置进行网络地址解析；可同时获取域名的多个 IPv4 地址。<br />";
        content += "<br /><b>自定义 DNS</b>：用于与第三方传输代理软件中使用的特定 DNS 服务器保持一致，可避免 DNS 劫持和污染；能同时获取域名的多个 IPv4 地址。若第三方传输代理软件中未使用特定的 DNS 服务器，使用系统 DNS 即可。<br />";
        content += "<br /><b>系统 DNS + 自定义 DNS</b>：同时使用<b>系统 DNS</b> 和<b>自定义 DNS</b> 对代理转发远程节点服务器域名条目进行预解析。<br />";
        content += "<br /><b>域名地址预解析</b>仅在<b>策略路由</b>软件启动时执行，若路由器运行过程中远程节点服务器域名的 IPv4 地址发生改变，由于路由器系统对第三方传输代理软件的<b>代理转发静态直通策略</b>只支持<b>静态直通路由</b>方式，需手动重启<b>策略路由</b>软件更新该域名的流量路由。</div>";
    } else if (itemNum == 50) {
        content = "<div>缺省为 <b>8.8.8.8</b>。<br />";
        content += "<br />用于设置路由器内第三方传输代理软件中使用的特定 DNS 服务器 IPv4 地址，可避免 DNS 劫持和污染。<br />";
        content += "<br />本地址也用于<b>运行 - 软件版本资源库位置</b>功能连接访问<b>国际 (Github)</b> 站点时解析域名地址。</div>";
    } else if (itemNum == 51) {
        content = "<div>缺省为 <b>864000</b> 秒 (<b>10</b> 天)。<br /><br />若设置缓存时间，软件重启后，时间会重新计数。<br /><br />该参数对<b>代理转发静态直通策略</b>中的静态域名地址解析无效。</div>";
    } else if (itemNum == 52) {
        content = "<div>缺省为<b>启用</b>。<br />";
        content += "<br />在软件执行结束时执行一次，<b>启用</b>后同时会在<b>自动清理路由表及系统缓存时间间隔 (小时)</b> 的定时任务中执行。</div>";
    } else if (itemNum == 53) {
        content = "<div>缺省为<b>启用</b>。<br />";
        content += "<br />在软件执行结束时执行一次，<b>启用</b>后同时会在<b>自动清理路由表及系统缓存时间间隔 (小时)</b> 的定时任务中执行。</div>";
    } else if (itemNum == 54) {
        content = "<div>缺省为每 <b>4</b> 小时清理一次。<br />";
        content += "<br /><b>路由表缓存清理</b>或<b>系统缓存清理</b>中任一个功能启用后，该功能才会执行。</div>";
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
        content += `<br />缺省文件名为 <b>${policySettingsArray.path}/data/iptv_box_ip_lst.txt</b>，无有效数据条目。<br />`;
        content += "<br />文件路径、名称可自定义和修改，文件路径及名称不得为空。<br />";
        content += "<br />文本格式，一个机顶盒IPv4格式地址一行，可逐行填入多个机顶盒地址。<br />";
        content += "<br />例如：<br />";
        content += "192.168.50.46<br />";
        content += "192.168.50.86<br />";
        content += "192.168.50.101<br />";
        content += "<br />此文件中 <b>0.0.0.0/0</b>、<b>0.0.0.0</b> 和<b>路由器本地 IP 地址</b>为无效地址。<br />";
        content += "<br />为避免软件升级更新或重新安装导致配置重置为缺省状态，建议更改文件名或文件存储路径。</div>";
    } else if (itemNum == 62) {
        content = "<div>仅在<b>IPTV 机顶盒访问 IPTV 线路方式</b>为<b>按服务地址访问</b>时使用。<br />";
        content += "<br />这些不是 IPTV 节目播放源地址，而是运营商的 IPTV 后台网络服务地址，需要用户自己获取和填写，如果地址不全或错误，机顶盒将无法通过路由器正确接入 IPTV 线路。若填入的地址覆盖了用户使用的互联网访问地址，会导致机顶盒无法通过该地址访问互联网。<br />";
        content += `<br />缺省文件名为 <b>${policySettingsArray.path}/data/iptv_isp_ip_lst.txt</b>，无有效数据条目。<br />`;
        content += "<br />文件路径、名称可自定义和修改，文件路径及名称不得为空。<br />";
        content += "<br />文本格式，一个IPv4格式网址/网段一行，可逐行填入多个网址/网段。<br />";
        content += "<br />此文件中 <b>0.0.0.0/0</b>、<b>0.0.0.0</b> 和<b>路由器本地 IP 地址</b>为无效地址。<br />";
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
        content += `<br />缺省文件名为 <b>${policySettingsArray.path}/custom_dualwan_scripts.sh</b>，实体文件不存在，使用时由用户创建。<br />`;
        content += "<br />文件路径、名称可自定义和修改，文件路径及名称不得为空。<br />";
        content += "<br />该文件由用户创建，文件编码格式为 UTF-8 (LF)，首行代码顶齐第一个字符开始必须为：<b>#!bin/sh</b><br />";
        content += "<br />例如：<br />";
        content += "#!/bin/sh<br />";
        content += "cru d LZISPRO<br />";
        content += "<br />该脚本先于<b>外置用户自定义配置脚本</b>执行。</div>";
    } else if (itemNum == 76) {
        content = "<div><b>Linux Shell 脚本</b>。<br />";
        content += "<br /><b>启用</b>后随软件初始化时启动执行。<br />";
        content += `<br />缺省文件名为 <b>${policySettingsArray.path}/custom_config.sh</b>，实体文件不存在，使用时由用户创建。<br />`;
        content += "<br />文件路径、名称可自定义和修改，文件路径及名称不得为空。<br />";
        content += "<br />该文件由用户创建，文件编码格式为 UTF-8 (LF)，首行代码顶齐第一个字符开始必须为：<b>#!bin/sh</b><br />";
        content += "<br />可在其中加入自定义全局变量并初始化，也可加入随系统启动自动执行的其他自定义脚本代码。<br />";
        content += "<br />该脚本晚于<b>外置用户自定义清理资源脚本</b>，早于<b>外置用户自定义双线路脚本</b>执行。</div>";
    } else if (itemNum == 77) {
        content = "<div><b>Linux Shell 脚本</b>。<br />";
        content += "<br /><b>启用</b>后仅在双线路同时接通 WAN 口网络条件下执行。<br />";
        content += `<br />缺省文件名为 <b>${policySettingsArray.path}/custom_dualwan_scripts.sh</b>，实体文件不存在，使用时由用户创建。<br />`;
        content += "<br />文件路径、名称可自定义和修改，文件路径及名称不得为空。<br />";
        content += "<br />该文件由用户创建，文件编码格式为 UTF-8 (LF)，首行代码顶齐第一个字符开始必须为：<b>#!bin/sh</b><br />";
        content += "<br />例如：<br />";
        content += "#!/bin/sh<br />";
        content += "cru&nbsp;a&nbsp;LZISPRO&nbsp;\"13&nbsp;4&nbsp;*/3&nbsp;*&nbsp;*&nbsp;sh&nbsp;/jffs/scripts/lzispro/lzstart.sh\"<br />";
        content += "<br />该脚本晚于<b>外置用户自定义配置脚本</b>执行。</div>";
    } else if (itemNum == 78) {
        content = "<div>缺省为 <b>5</b> 天。</div>";
    } else if (itemNum == 79) {
        content = "<div>缺省为<b>自动</b>安排启动时间 (1:00 ~ 5:59)。<br />";
        content += "<br />数据更新过程中，软件会重新启动，为避免影响路由器正常使用，减轻网络拥塞和数据下载服务器压力，建议将更新<b>启动时间</b>安排在当日的 <b>1:00</b> 之后的空闲时段，并且尽量不要设置<b>整点</b>时刻。</div>";
    } else if (itemNum == 80) {
        content = "<div>缺省为 <b>5</b> 次。</div>";
    } else if (itemNum == 81) {
        content = `<div>缺省文件名为 <b>${policySettingsArray.path}/data/custom_data_2.txt</b>，无有效数据条目。<br />`;
        content += "<br />文件路径、名称可自定义和修改，文件路径及名称不得为空。<br />";
        content += "<br />文本格式：一个网址/网段一行，为一个条目，可多行多个条目。<br />";
        content += "<br />例如：<br />";
        content += "123.234.123.112<br />";
        content += "133.234.0.0/16<br />";
        content += "<br />此文件中 <b>0.0.0.0/0</b>、<b>0.0.0.0</b> 和<b>路由器本地 IP 地址</b>为无效地址。<br />";
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
        content = "<div>文件中具体定义路由器内第三方<b>传输转发代理</b>软件中的远程<b>节点服务器</b>的 IPv4 地址或拥有 IPv4 地址的域名地址，可设置多个。<br />";
        content += "<br />缺省为<b>停用</b>。<br />";
        content += `<br />缺省的<b>远程节点服务器地址列表</b>文件名为 <b>${policySettingsArray.path}/data/proxy_remote_node_addr.txt</b>，无有效数据条目。<br />`;
        content += "<br />文件路径、名称可自定义和修改，文件路径及名称不得为空。<br />";
        content += "<br />文本格式：一个网址/网段/域名地址一行，为一个条目，可多行多个条目。<br />";
        content += "<br />例如：<br />";
        content += "123.234.123.111<br />";
        content += "133.234.123.0/24<br />";
        content += "abc.def.com.cn<br />";
        content += "<br />此文件中 <b>0.0.0.0/0</b>、<b>0.0.0.0</b> 和<b>路由器本地 IP 地址</b>为无效地址。地址条目中不能有网络协议前缀 (如 http:// 或 https:// 或 ftp:// 等)、端口号 (如 :23456) 、路径及文件名、特殊符号等影响地址解析的内容。<br />";
        content += "<br />当列表数据文件中包含<b>域名格式</b>地址时，需启用本策略中的<b>域名地址预解析</b>功能。若第三方传输代理软件中使用有特定的 DNS 服务器，为避免 DNS 劫持和污染，可同时启用和设置<b>自定义预解析 DNS 服务器</b>为该 DNS 服务器地址。<br />";
        content += "<br />由于该地址列表仅用于<b>静态直通路由</b>，所有远程节点服务器地址应为<b>静态地址</b>。当使用域名格式地址时，路由器运行过程中域名条目对应的 IP 地址一旦改变，原有线路连接可能失效，需手动<b>重启策略路由</b>软件进行域名地址解析以<b>重新</b>构建路由。<br />";
        content += "<br />为避免软件升级更新或重新安装导致配置重置为缺省状态，建议更改文件名或文件存储路径。</div>";
    } else if (itemNum == 85) {
        content = "<div>实用命令工具集。</div>";
    } else if (itemNum == 86) {
        mode = 1;
        caption = "快捷命令";
        content = "<div><b>命令</b>选项：<br />";
        content += "<ul>";
        content += "<li>查询路由器出口 (缺省)</li>";
        content += "<li>显示系统路由表</li>";
        content += "<li>显示系统路由规则</li>";
        content += "<li>显示系统防火墙规则链</li>";
        content += "<li>显示系统定时任务</li>";
        content += "<li>显示 firewall-start 启动项</li>";
        content += "<li>显示 service-event 服务触发项</li>";
        content += "<li>显示 openvpn-event 事件触发项</li>";
        content += "<li>显示 post-mount 挂载启动项</li>";
        content += "<li>显示 dnsmasq.conf.add 配置项</li>";
        content += "<li>更新运营商 IP 地址数据</li>";
        content += "<li>解除程序运行锁</li>";
        content += "<li>恢复缺省配置参数</li>";
        content += "<li>卸载策略路由</li>";
        content += "</ul>";
        content += "<b>查询路由器出口</b>：<br />根据目标主机域名或 IP 地址，查询访问该地址流量使用的路由器出口，以及该主机地址的运营商归属。域名解析后可能会得到多个 IP 地址，由此会出现多条信息。<br />";
        content += "<br /><b>显示系统路由表</b>：<br />显示当前系统中，<b>策略路由</b>所依赖的路由表，以及路由表内容。<br />";
        content += "<br /><b>显示系统路由规则</b>：<br />显示当前系统<b>策略路由</b>库中的所有路由规则项。<br />";
        content += "<br /><b>显示系统防火墙规则链</b>：<br />显示当前与<b>策略路由</b>运行有关的系统主要防火墙规则链及其内容。<br />";
        content += "<br /><b>显示系统定时任务</b>：<br />显示路由器系统中当前存在的定时任务。<br />";
        content += "<br /><b>显示 firewall-start 启动项</b>：<br />显示系统启动、防火墙动作、WAN 口 IP 改变、网络重连或掉线、拨号连接等网络事件发生时，触发启动执行的命令或软件项。<b>策略路由</b>启动后会在此放置<b>自启动</b>命令。<br />";
        content += "<br /><b>显示 service-event 服务触发项</b>：<br />显示由服务事件触发启动执行的自定义命令或软件项。<b>策略路由</b>通过该服务事件触发项由前台页面向后台服务发送<b>工作指令</b>。<br />";
        content += "<br /><b>显示 openvpn-event 事件触发项</b>：<br />显示 OpenVPN 触发启动执行的自定义命令或软件项。该功能用于维护远程 OpenVPN 客户端与服务器端的可靠连接。<br />";
        content += "<br /><b>显示 post-mount 挂载启动项</b>：<br />显示设备挂载事件触发启动执行的自定义命令或软件项。当<b>策略路由</b>软件安装在 <b>USB</b> 盘的 <b>Entware</b> 软件包管理分区内时，需要在该挂载启动项中放置启动命令，以保证设备重启时可以<b>自动启动</b>。<br />";
        content += "<br /><b>显示 dnsmasq.conf.add 配置项</b>：<br />显示 <b>DNSmasq</b> 的<b>自定义扩展配置项</b>。<b>DNSmasq</b> 是一个小巧且方便地用于配置 <b>DNS</b> 和 <b>DHCP</b> 的工具，适用于小型网络。提供的 <b>DNS</b> 功能和可选择的 <b>DHCP</b> 功能可以取代 dhcpd (DHCPD 服务配置) 和 bind 等服务，配置简单，适用于虚拟化和大数据环境的部署。<br />";
        content += "<br /><b>更新运营商 IP 地址数据</b>：<br />通过互联网手动更新<b>策略路由</b>中的<b>运营商 IP 地址数据</b>库。该数据经常发生变化，为保证业务的精准性，请定期及时更新。亦可在<b>外部网络(WAN) - 策略路由(IPv4) - 基础 - 运营商 IP 地址数据</b>中<b>启用定时更新</b>。<br />";
        content += "<br /><b>解除程序运行锁</b>：<br />软件启动或操作过程中，若操作 ctrl+c 组合键，或其他意外原因造成运行中断，导致程序被内部的同步运行安全机制锁住，在不重启路由器的情况下，无法再次启动或有关命令无法继续执行，可通过此命令强制解锁，然后请再次重新启动<b>策略路由</b>，即可恢复正常。<b>注意</b>，正常运行过程中不要随意执行此命令，以免造成安全机制失效。<br />";
        content += "<br /><b>恢复缺省配置参数</b>：<br />将<b>策略路由</b>工作参数恢复至初始<b>缺省</b>状态。此操作将<b>不可恢复</b>的清除用户所有已配置数据，执行此命令请务必<b>慎重</b>。<br />";
        content += "<br /><b>卸载策略路由</b>：<br />卸载<b>策略路由</b>软件。此操作将<b>不可恢复</b>的卸载并清除<b>策略路由</b>软件。卸载命令执行后，路由器<b>策略路由</b>项目目录内仅遗留与用户配置有关的数据文件，若不需要，可手工删除。执行此命令请务必<b>慎重</b>。</div>";
    } else if (itemNum == 87) {
        content = "<div>目标主机的<b>域名地址</b>或 <b>IP 地址</b>，内容不可为空。</div>";
    } else if (itemNum == 88) {
        content = "<div>目标主机地址为域名地址时，可指定域名解析的 <b>DNS 服务器</b>地址。内容为空时，表示使用路由器内置的 DNS 服务。<br />";
        content += "<br />若查询的是自定义域名地址，<b>DNS 服务器</b>地址请设置为路由器主机<b>内网 IP 地址</b>或 <b>0.0.0.0</b>。</div>";
    } else if (itemNum == 89) {
        content = "<div>此功能用于将指定<b>域名</b>解析到特定的 <b>IP 地址</b>上，可实现本地网络的 DNS 劫持；还支持实现关联已有域名的自定义别名。<br />";
        content += "<br /><b>自定义域名地址解析列表</b>文件中所定义的<b>域名</b>被访问时将跳转到指定的 <b>IP 地址</b>，作用与主机上的 <b>hosts</b> 文件相同。<br />";
        content += "<br />仅对以 DHCP 方式自动连接路由器，或 DNS 指向路由器主机本地地址的<b>客户端</b>内的网络流量有效。若客户端内软件使用其他 DNS 服务器解析网络访问地址，则本功能无效。<br />";
        content += "<br />缺省为<b>停用</b>。<br />";
        content += `<br />缺省<b>自定义域名地址解析列表</b>文件名为 <b>${policySettingsArray.path}/data/custom_hosts.txt</b>，无有效数据条目。<br />`;
        content += "<br />文件路径、名称可自定义和修改，文件路径及名称不得为空。<br />";
        content += "<br />文本格式：每行由目标 <b>IP 地址/域名</b>和自定义<b>域名/别名</b>两个字段组成，字段之间用<b>空格</b>隔开，一个条目一行，可多行多个条目。<br />";
        content += "<br />例如：<br />";
        content += "123.123.123.123 xxx123.com<br />";
        content += "192.168.50.15 yyy.cn<br />";
        content += "www.qq.com mydomain.alias<br />";
        content += "<br />此文件中 <b>0.0.0.0</b> 为无效地址。<br />";
        content += "<br />为避免软件升级更新或重新安装导致配置重置为缺省状态，建议更改文件名或文件存储路径。</div>";
    } else if (itemNum == 90) {
        content = "<div>用于在线检测本软件最新版本，以及通过网络进行本软件的在线升级或重新安装。<br />";
        content += "<br />缺省为<b>中国大陆 (Gitee)</b> 站点。<br />";
        content += "<br /><b>中国大陆 (Gitee)</b> 站点是<b>国际 (Github)</b> 站点的镜像备份。<br />";
        content += "<br />本软件连接访问<b>国际 (Github)</b> 站点时，为避免 DNS 劫持和污染，使用<b>高级 - 代理转发静态直通策略 - 自定义预解析 DNS 服务器</b>功能定义的 DNS 服务器地址实时解析域名地址。<br />";
        content += "<br />从中国大陆内地访问<b>国际 (Github)</b> 站点，线路通畅性可能不佳，若有受到干扰甚至屏蔽，或版本检测或在线安装功能无法正常使用时，请选择<b>中国大陆 (Gitee)</b> 站点。</b></div>";
    } else if (itemNum == 91) {
        content = "<div>本策略用于路由器主机内置的 OpenVPN、PPTP、IPSec 和 WireGuard 虚拟专用网络服务器的远程 VPN 客户端，在双线路负载均衡模式下远程接入成功后，该客户端作为虚拟的路由器本地内网设备，通过本策略经由路由器其他流量出口访问外部网络。<br />";
        content += "<br /><b>策略执行优先级</b>：详见<b>基本设置&nbsp;-&nbsp;策略路由优先级</b></div>";
    } else if (itemNum == 92) {
        content = "<div>缺省为<b>启用</b>。<br />";
        content += "<br /><b>ASD</b> 是华硕路由器中的一个内置安全守护程序。<br />";
        content += "<br />策略路由安装程序会在软件安装和软件初次运行时关闭 <b>ASD</b> 进程，以保护本软件程序及相关资源文件不因其误判为恶意代码而被删除。<br />";
        content += "<br />在软件正常运行后，亦可<b>停用</b>本功能，恢复 <b>ASD</b> 进程的正常作用。<br />";
        content += "<br />执行<b>停用</b>操作后，<b>ASD</b> 进程恢复时会触发系统防火墙动作，导致网络重连和<b>策略路由</b>后台服务再次重启。</div>";
    } else if (itemNum == 100) {
        mode = 1;
        caption = "基本设置 - 策略路由优先级";
        content = "<div><b>策略路由</b>优先级顺序：序号 <b>1</b> 为最高优先级，网络流量优先匹配高优先级策略。<br />";
        content += "<ol>";
        content += "<li>负载均衡</li>";
        content += "<li>IPTV 机顶盒</li>";
        content += "<li>代理转发静态直通策略</li>";
        content += "<li>远程访问及本机应用访问外网静态直通策略</li>";
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
    } else if (itemNum == 102) {
        mode = 2;
        content = "<div>天佑白嫖。</div>";
    } else if (itemNum == 103) {
        mode = 2;
        content = "<div>我想买台最新型号的 ASUS 路由器。</div>";
    }
    if (content != "") {
        if (mode == 1) {
            setMouseOut(1);
            return overlib(content, OFFSETX, -160, LEFT, DELAY, 400, WIDTH, 600, STICKY, CAPTION, caption);
        } else if (mode == 2) {
            setMouseOut(0);
            return overlib(content, OFFSETX, -160, HAUTO);
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

function saveSettings(saveData) {
    if (!policySettingsArray.hasOwnProperty("policyEnable"))
        return;
    if (saveData) {
        $("[name*=lzr_]").prop("disabled", false);
        $("#amng_custom").val(JSON.stringify(getPolicyChangedItem($("#ruleForm").serializeObject())).replace(/\"lzr_/g, "\"lz_rule_"));
    } else {
        $("[name*=lzr_]").prop("disabled", true);
        $("#amng_custom").val("");
    }
    let asdValue = $("input[name='fuck_asd']:checked").val();
    if (policySettingsArray.hasOwnProperty("fuck_asd") 
        && (asdValue == "0" || asdValue == "5" ) && asdValue != policySettingsArray.fuck_asd) {
        document.form.action_script.value = policySettingsArray.policyEnable ? 'start_LZASDRule_' + asdValue : "stop_LZASDRule_" + asdValue;
        document.form.action_wait.value = (asdValue == "0") ? "20" : "30";
    } else {
        document.form.action_script.value = policySettingsArray.policyEnable ? "start_LZRule" : "stop_LZRule";
        document.form.action_wait.value = "20";
    }
    showLoading();
    document.form.submit();
}

function isInstance() {
    let retVal = true;
    $.ajax({
        async: false,
        url: '/ext/lzr/LZRInstance.html',
        dataType: 'text',
        error: function(xhr) {
            if (xhr.status == 404) {
                retVal = false;
            }
        },
    });
    return retVal;
}

function applyRule() {
    if (isInstance())
        alert("上一个任务正在进行中，请稍后再试。");
    else
        saveSettings(true);
}

let height = 0;
let statusEnable = true;
function getStatus() {
    let h = 0;
    $.ajax({
        async: true,
        url: '/ext/lzr/LZRStatus.html',
        dataType: 'text',
        error: function(xhr) {
            if (xhr.status == 404) {
                height = 0;
                statusEnable = false;
                if (document.getElementById("statusButton").disabled) {
                    $("#loadingStatusIcon").hide();
                    $("#statusButton").fadeIn(500);
                    document.getElementById("statusButton").disabled = false;
                }
            } else
                setTimeout(getStatus, 1000);
        },
        success: function(response) {
            h = $("#statusArea").scrollTop();
            if (divLabelArray["Runtime"][2] == "1" && !(height > 0 && h < height)) {
                let infoString = htmlEnDeCode.htmlEncode(response.toString());
                if (infoString.search(/^[\s]*$/) < 0) {
                    if (infoString.search(/[\]][\:]($|[\n])/) >= 0) {
                        if (document.getElementById("statusButton").disabled) {
                            $("#loadingStatusIcon").hide();
                            $("#statusButton").show();
                            document.getElementById("statusButton").disabled = false;
                        }
                    } else if (!document.getElementById("statusButton").disabled) {
                        document.getElementById("statusButton").disabled = true;
                        $("#statusButton").hide();
                        $("#loadingStatusIcon").show();
                    }
                } else
                    infoString = "";
                document.getElementById("statusArea").innerHTML = infoString;
                $("#statusArea").animate({ scrollTop: 9999999 }, "slow");
                setTimeout('height = $("#statusArea").scrollTop();', 500);
            }
            setTimeout(getStatus, 3000);
        }
    });
}

function queryStatus() {
    if (isInstance()) {
        alert("上一个任务正在进行中，请稍后再试。");
        return;
    }
    if (!document.getElementById("statusButton").disabled) {
        document.getElementById("statusButton").disabled = true;
        $("#statusButton").hide();
        $("#loadingStatusIcon").fadeIn(300);
    }
    document.getElementById("statusArea").innerHTML = "";
    height = 0;
    document.scriptActionsForm.action_script.value = 'start_LZStatus';
    document.scriptActionsForm.action_wait.value = "0";
    document.scriptActionsForm.submit();
    if (!statusEnable) {
        statusEnable = true;
        setTimeout(getStatus, 100);
    }
}

function disabledToolsButton(_timeVal) {
    if (document.getElementById("toolsButton").disabled)
        return;
    document.getElementById("toolsButton").disabled = true;
    $("#toolsButton").hide();
    if (_timeVal != undefined)
        $("#loadingToolsIcon").fadeIn(_timeVal);
    else
        $("#loadingToolsIcon").show();
}

function enabledToolsButton(_timeVal) {
    if (!document.getElementById("toolsButton").disabled)
        return;
    $("#loadingToolsIcon").hide();
    if (_timeVal != undefined)
        $("#toolsButton").fadeIn(_timeVal);
    else
        $("#toolsButton").show();
    document.getElementById("toolsButton").disabled = false;
}

let toolsCMDArray = {
    "Address" : ["LZRAddress.html", "0", true, /[\]][\:]($|[\n])/, "LZAddress"], 
    "Routing" : ["LZRRouting.html", "1", true, /(^|[\n])Total[\:]/, "LZRouting"], 
    "Rules" : ["LZRRules.html", "2", true, /(^|[\n])Total[\:]/, "LZRtRules"], 
    "Iptables" : ["LZRIptables.html", "3", true, /(^|[\n])Total[\:]/, "LZIptables"], 
    "Crontab" : ["LZRCrontab.html", "4", true, /(^|[\n])Total[\:]/, "LZCrontab"], 
    "Unlock" : ["LZRUnlock.html", "11", true, /[\]][\:]($|[\n])/, "LZUnlock"]
};

let toolsInfoHeight = 0;
function getToolsInfo(id) {
    let h = 0;
    $.ajax({
        async: true,
        url: '/ext/lzr/' + toolsCMDArray[id][0],
        dataType: 'text',
        error: function(xhr) {
            if (xhr.status == 404 
                && id != "" 
                && toolsCMDArray.hasOwnProperty(id)) {
                toolsCMDArray[id][2] = false;
                toolsInfoHeight = 0;
                enabledToolsButton();
            } else
                setTimeout(getToolsInfo, 1000, id);
        },
        success: function(response) {
            h = $("#toolsTextArea").scrollTop();
            if (divLabelArray["Tools"][2] == "1" 
                && id != "" 
                && toolsCMDArray.hasOwnProperty(id) 
                && document.getElementById("cmdMethod").value == toolsCMDArray[id][1] 
                && !(toolsInfoHeight > 0 && h < toolsInfoHeight)) {
                let infoString = htmlEnDeCode.htmlEncode(response.toString());
                if (infoString.search(/^[\s]*$/) < 0) {
                    if (infoString.search(toolsCMDArray[id][3]) >= 0)
                        enabledToolsButton();
                    else
                        disabledToolsButton();
                } else
                    infoString = "";
                document.getElementById("toolsTextArea").innerHTML = infoString;
                $("#toolsTextArea").animate({ scrollTop: 9999999 }, "slow");
                setTimeout('toolsInfoHeight = $("#toolsTextArea").scrollTop();', 500);
            }
            setTimeout(getToolsInfo, 3000, id);
        }
    });
}

function getEventInterfaceInfo(filename, index) {
    $.ajax({
        async: true,
        url: '/ext/lzr/' + filename,
        dataType: 'text',
        error: function(xhr) {
            if (xhr.status == 404)
                enabledToolsButton();
            else
                setTimeout(getEventInterfaceInfo, 1000, filename, index);
        },
        success: function(response) {
            if (divLabelArray["Tools"][2] == "1" 
                && document.getElementById("cmdMethod").value == index) {
                let infoString = htmlEnDeCode.htmlEncode(response.toString());
                if (infoString.search(/^[\s]*$/) < 0)
                    disabledToolsButton();
                else
                    infoString = "";
                document.getElementById("toolsTextArea").innerHTML = infoString;
                enabledToolsButton();
            }
        }
    });
}

function hideClients_Block() {
    document.getElementById("pull_arrow").src = "/ext/lzr/arrow-down.gif";
    document.getElementById('ClientList_Block_PC').style.display = 'none';
}

let over_var = 0;
function setClientIP(ipaddr) {
    document.form.destIP.value = ipaddr;
    hideClients_Block();
    $("#alert_block").hide();
    over_var = 0;
}

function showLANIPList() {
    let AppListArray = [
        ["Google ", "www.google.com"], ["Facebook", "www.facebook.com"], ["Youtube", "www.youtube.com"], ["Yahoo", "www.yahoo.com"],
        ["Baidu", "www.baidu.com"], ["Wikipedia", "www.wikipedia.org"], ["Windows Live", "www.live.com"], ["QQ", "www.qq.com"],
        ["Twitter", "www.twitter.com"], ["Taobao", "www.taobao.com"], ["Blogspot", "www.blogspot.com"],
        ["Linkedin", "www.linkedin.com"], ["eBay", "www.ebay.com"], ["Bing", "www.bing.com"],
        ["Яндекс", "www.yandex.ru"], ["WordPress", "www.wordpress.com"], ["ВКонтакте", "www.vk.com"]
    ];
    let code = "";
    for(let i = 0; i < AppListArray.length; i++) {
        code += '<a><div onmouseover="over_var=1;" onmouseout="over_var=0;" onclick="setClientIP(\'' + AppListArray[i][1] + '\');"><strong>' + AppListArray[i][0] + '</strong></div></a>';
    }
    code += '<!--[if lte IE 6.5]><iframe class="hackiframe2"></iframe><![endif]-->';
    document.getElementById("ClientList_Block_PC").innerHTML = code;
}

function pullLANIPList(obj) {
    let element = document.getElementById('ClientList_Block_PC');
    let isMenuopen = element.offsetWidth > 0 || element.offsetHeight > 0;
    if (isMenuopen == 0) {
        obj.src = "/ext/lzr/arrow-top.gif"
        document.getElementById("ClientList_Block_PC").style.display = 'block';
        document.form.destIP.focus();
    } else
        hideClients_Block();
}

function printToolsInfo(id) {
    if (!toolsCMDArray.hasOwnProperty(id))
        return;
    document.getElementById("toolsTextArea").innerHTML = "";
    toolsInfoHeight = 0;
    document.scriptActionsForm.action_script.value = 'start_' + toolsCMDArray[id][4];
    document.scriptActionsForm.action_wait.value = "0";
    document.scriptActionsForm.submit();
    if (!toolsCMDArray[id][2]) {
        toolsCMDArray[id][2] = true;
        setTimeout(getToolsInfo, 100, id);
    }
}

function printEventInterfaceInfo(filename, index) {
    document.getElementById("toolsTextArea").innerHTML = "";
    setTimeout(getEventInterfaceInfo, 500, filename, index);
}

function hideCNT(_val) {
    document.getElementById("toolsTextArea").innerHTML = "";
    let val = parseInt(_val);
    if (val == 0) {
        $("#toolsButton").val("执行命令");
        document.getElementById("cmdMethod").value = _val;
        document.getElementById("destIPCNT_tr").style.display = "";
        document.getElementById("dnsIPAddressCNT_tr").style.display = "";
        enabledToolsButton();
       toolsInfoHeight = 0;
        if (!toolsCMDArray["Address"][2]) {
            toolsCMDArray["Address"][2] = true;
            setTimeout(getToolsInfo, 100, "Address");
        }
    } else if (val >= 1 && val <= 13) {
        document.getElementById("cmdMethod").value = _val;
        document.getElementById("destIPCNT_tr").style.display = "none";
        document.getElementById("dnsIPAddressCNT_tr").style.display = "none";
        let operable = !isInstance();
        if (val >= 1 && val <= 9) {
            $("#toolsButton").val("刷新命令");
            if (!operable && val >= 1 && val < 5)
                enabledToolsButton();
            else
                disabledToolsButton();
        } else {
            $("#toolsButton").val("执行命令");
            enabledToolsButton();
        }
        switch (val) {
            case 1:
               toolsInfoHeight = 0;
                if (operable)
                    printToolsInfo("Routing");
                break;
            case 2:
               toolsInfoHeight = 0;
                if (operable)
                    printToolsInfo("Rules");
                break;
            case 3:
               toolsInfoHeight = 0;
                if (operable)
                    printToolsInfo("Iptables");
                break;
            case 4:
               toolsInfoHeight = 0;
                if (operable)
                    printToolsInfo("Crontab");
                break;
            case 5:
                printEventInterfaceInfo("LZRState.html", "5");
                break;
            case 6:
                printEventInterfaceInfo("LZRService.html", "6");
                break;
            case 7:
                printEventInterfaceInfo("LZROpenvpn.html", "7");
                break;
            case 8:
                printEventInterfaceInfo("LZRPostMount.html", "8");
                break;
            case 9:
                printEventInterfaceInfo("LZRDNSmasq.html", "9");
                break;
            case 11:
               toolsInfoHeight = 0;
                if (!toolsCMDArray["Unlock"][2]) {
                    toolsCMDArray["Unlock"][2] = true;
                    setTimeout(getToolsInfo, 100, "Unlock");
                }
                break;
            default:
                break;
        }
    }
}

function toolsCommand() {
    let val = parseInt(document.getElementById("cmdMethod").value);
    if ((val < 5 || (val > 9 && val != 11)) && isInstance()) {
        alert("上一个任务正在进行中，请稍后再试。");
        return;
    }
    if (val >= 1 && val <= 9)
        disabledToolsButton();
    switch (val) {
        case 0:
            let destIPVal = document.getElementById("destIP").value;
            if (destIPVal == "") {
                alert("「目标」不能为空！");
                break;
            }
            if (!validator.targetDomainName($("#destIP")))
                break;
            let dnsIPAddressVal = document.getElementById("dnsIPAddress").value;
            disabledToolsButton();
            document.getElementById("toolsTextArea").innerHTML = "";
            toolsInfoHeight = 0;
            document.scriptActionsForm.action_script.value = "start_" + toolsCMDArray["Address"][4] + "_" + destIPVal + "_" + dnsIPAddressVal + "_";
            document.scriptActionsForm.action_wait.value = "0";
            document.scriptActionsForm.submit();
            if (!toolsCMDArray["Address"][2]) {
                toolsCMDArray["Address"][2] = true;
                setTimeout(getToolsInfo, 100, "Address");
            }
            break;
        case 1:
            printToolsInfo("Routing");
            break;
        case 2:
            printToolsInfo("Rules");
            break;
        case 3:
            printToolsInfo("Iptables");
            break;
        case 4:
            printToolsInfo("Crontab");
            break;
        case 5:
            printEventInterfaceInfo("LZRState.html", "5");
            break;
        case 6:
            printEventInterfaceInfo("LZRService.html", "6");
            break;
        case 7:
            printEventInterfaceInfo("LZROpenvpn.html", "7");
            break;
        case 8:
            printEventInterfaceInfo("LZRPostMount.html", "8");
            break;
        case 9:
            printEventInterfaceInfo("LZRDNSmasq.html", "9");
            break;
        case 10:
            disabledToolsButton();
            if (!getPolicyState()) {
                alert("「策略路由」未开启，启动后才可执行此操作。");
                enabledToolsButton();
                break;
            }
            $("#amng_custom").val("");
            document.form.action_script.value = "start_LZUpdate";
            document.form.action_wait.value = "25";
            showLoading();
            document.form.submit();
            break;
        case 11:
            if (!confirm("「解除程序运行锁」后会造成同步运行安全机制失效，需重新启动「策略路由」才可恢复。\n\n确定要执行此操作吗？"))
                break;
            disabledToolsButton();
            printToolsInfo("Unlock");
            break;
        case 12:
            if (!confirm("「恢复缺省配置」将不可恢复的清除用户所有已配置数据。\n\n确定要执行此操作吗？"))
                break;
            $("#amng_custom").val("");
            document.form.action_script.value = "start_LZDefault";
            document.form.action_wait.value = "20";
            showLoading();
            document.form.submit();
            break;
        case 13:
            if (!confirm("「卸载策略路由」将不可恢复的卸载并清除「策略路由」软件。\n\n卸载命令执行后，该软件的路由器项目目录内仅遗留与用户配置有关的数据文件，若不需要，可手工删除。\n\n确定要执行此操作吗？"))
                break;
            $("#amng_custom").val("");
            document.form.current_page.value = "Advanced_WANPort_Content.asp";
            document.form.action_script.value = "start_LZUnintall";
            document.form.action_wait.value = "25";
            showLoading();
            document.form.submit();
            break;
        default:
            break;
    }
}

let ipListDialogIDArray = {
    "custom_data_wan_port_1_list" : ["24991", "Advanced"], 
    "custom_data_wan_port_2_list" : ["24990", "Advanced"], 
    "wan0_dest_port_list" : ["24983_0x3333", "Advanced"], 
    "wan1_dest_port_list" : ["24982_0x2222", "Advanced"], 
    "wan_1_client_src_addr_list" : ["24979", "Advanced"], 
    "wan_2_client_src_addr_list" : ["24978", "Advanced"], 
    "wan_1_domain_list" : ["24977_0x9191_c_0", "Advanced"], 
    "wan_1_domain_addr_list" : ["24977_0x9191_d_0", "Advanced"], 
    "wan_2_domain_list" : ["24976_0x8181_c_1", "Advanced"], 
    "wan_2_domain_addr_list" : ["24976_0x8181_d_1", "Advanced"], 
    "wan_1_src_to_dst_addr_port_list" : ["24975_0x3131", "Advanced"], 
    "wan_2_src_to_dst_addr_port_list" : ["24974_0x2121", "Advanced"], 
    "high_wan_1_src_to_dst_addr_port_list" : ["24973_0x1717", "Advanced"], 
    "high_wan_1_client_src_addr_list" : ["24970", "Advanced"], 
    "high_wan_2_client_src_addr_list" : ["24969", "Advanced"], 
    "wan_1_src_to_dst_addr_list" : ["24966", "Advanced"], 
    "wan_2_src_to_dst_addr_list" : ["24965", "Advanced"], 
    "high_wan_1_src_to_dst_addr_list" : ["24964", "Advanced"], 
    "proxy_remote_node_addr_list" : ["24960", "Advanced"], 
    "local_ipsets_list" : ["24962", "Advanced"], 
    "custom_hosts_list" : ["hosts", "Runtime"], 
    "iptv_box_ip_list" : ["888_box", "IPTV"], 
    "iptv_isp_ip_list" : ["888_isp", "IPTV"]
};

function initRTIPListDialog() {
    let code = "";
    for (let key in ipListDialogIDArray) {
        if (ipListDialogIDArray.hasOwnProperty(key) 
            && document.getElementById(key) != null 
            && document.getElementById(key + "_status") != null) {
            code = '<div id="'+ key + '_title" style="margin-top:8px; text-align:center;"></div>';
            code += '<textarea cols="63" rows="27" wrap="off" readonly="readonly" id="' + key + '_area" class="textarea_ssh_table" ';
            code += 'style="margin-top:8px; margin-left:1%; width:97%; margin-bottom:8px; font-family:\'Courier New\', Courier, mono; font-size:11px; background-color:black;">';
            code += '</textarea>';
            code += '<div style="padding-bottom:10px; width:100%; text-align:center;">';
            code += '<input name="close_' + key + '" id="close_' + key + '" class="button_gen" type="button" onclick="closeRTIPList();" value="关闭">';
            code += '<img id="loading_' + key + '_Icon" style="display:none;" src="/ext/lzr/InternetScan.gif">';
            code += '</div>';
            document.getElementById(key).innerHTML = code;
            if (key == "wan0_dest_port_list" || key == "wan1_dest_port_list")
                document.getElementById(key + "_status").style = "margin-left:387px; text-decoration:underline; cursor:pointer;";
            else
                document.getElementById(key + "_status").style = "margin-left:27px; text-decoration:underline; cursor:pointer;";
            document.getElementById(key + "_status").setAttribute('onclick', 'openRTIPList(this);');
            document.getElementById(key + "_status").title = "显示列表中当前正在运行的有效地址条目。";
            document.getElementById(key + "_status").setAttribute('onmouseover', 'over_var=1;');
            document.getElementById(key + "_status").setAttribute('onmouseout', 'over_var=0;');
            document.getElementById(key + "_status").innerHTML = "状态";
            let str1 = "";
            let str2 = " - ";
            let str3 = "";
            if (document.getElementById(key + "_channel") != null)
                str1 = $("#" + key + "_channel").html();
            else if (key == "wan_1_domain_addr_list" && document.getElementById("wan_1_domain_list_channel") != null)
                str1 = $("#wan_1_domain_list_channel").html();
            else if (key == "wan_2_domain_addr_list" && document.getElementById("wan_2_domain_list_channel") != null)
                str1 = $("#wan_2_domain_list_channel").html();
            if (document.getElementById(key + "_name") != null)
                str3 = $("#" + key + "_name").html();
            else if (key == "wan0_dest_port_list" || key == "wan1_dest_port_list")
                str3 = "协议目标端口列表";
            if (key == "proxy_remote_node_addr_list")
                str3 = str3 + " (已预解析)";
            if (str1 == "" || str3 == "")
                str2 = "";
            if (document.getElementById(key + "_title") != null)
                $("#" + key + "_title").html(str1 + str2 + str3);
        }
    }
}

function disabledRtListCloseButton(id) {
    if (id == "" 
        || !ipListDialogIDArray.hasOwnProperty(id) 
        || document.getElementById(id) == null 
        || document.getElementById(id + "_area") == null 
        || document.getElementById("close_" + id) == null
        || document.getElementById("loading_" + id + "_Icon") == null)
        return;
    if (!document.getElementById("close_" + id).disabled) {
        document.getElementById("close_" + id).disabled = true;
        $("#close_" + id).hide();
        $("#loading_" + id + "_Icon").show();
    }
}

function enabledRtListCloseButton(id) {
    if (id == "" 
        || !ipListDialogIDArray.hasOwnProperty(id) 
        || document.getElementById(id) == null 
        || document.getElementById(id + "_area") == null 
        || document.getElementById("close_" + id) == null
        || document.getElementById("loading_" + id + "_Icon") == null)
        return;
    if (document.getElementById("close_" + id).disabled) {
        $("#loading_" + id + "_Icon").hide();
        $("#close_" + id).show();
        document.getElementById("close_" + id).disabled = false;
    }
}

let rtListInfoHeight = 0;
let rtListInfoEnable = true;
function getRtListInfo() {
    let id = ipListID;
    let h = 0;
    $.ajax({
        async: true,
        url: '/ext/lzr/LZRList.html',
        dataType: 'text',
        error: function(xhr) {
            if (xhr.status == 404) {
                rtListInfoEnable = false;
                rtListInfoHeight = 0;
                enabledRtListCloseButton(id);
            } else
                setTimeout(getRtListInfo, 1000);
        },
        success: function(response) {
            if (id != "" 
                && ipListDialogIDArray.hasOwnProperty(id) 
                && document.getElementById(id) != null 
                && document.getElementById(id + "_area") != null) {
                h = $("#" + id + "_area").scrollTop();
                if (divLabelArray[ipListDialogIDArray[id][1]][2] == "1" 
                    && !(rtListInfoHeight > 0 && h < rtListInfoHeight)) {
                    let infoString = htmlEnDeCode.htmlEncode(response.toString());
                    if (infoString.search(/^[\s]*$/) < 0) {
                        if (infoString.search(/(^|[\n])Total[\:]/) >= 0)
                            enabledRtListCloseButton(id);
                        else
                            disabledRtListCloseButton(id);
                    } else
                        infoString = "";
                    document.getElementById(id + "_area").innerHTML = infoString;
                    $("#" + id + "_area").animate({ scrollTop: 9999999 }, "slow");
                    setTimeout('rtListInfoHeight = $("#' + id + '_area").scrollTop();', 500);
                }
            }
            setTimeout(getRtListInfo, 3000);
        }
    });
}

let ipListID="";
function closeRTIPList() {
    if (ipListID == "")
        return;
    if (document.getElementById(ipListID) != null) {
        $("#" + ipListID).fadeOut(500);
        if ($("#" + ipListID).css("display") != "none")
            $("#" + ipListID).css("display", "none");
    }
    if (document.getElementById(ipListID + "_area") != null)
        document.getElementById(ipListID + "_area").innerHTML = "";
    enabledRtListCloseButton(ipListID);
    rtListInfoHeight = 0;
    ipListID="";
}

function openRTIPList(ptr) {
    if (isInstance()) {
        alert("上一个任务正在进行中，请稍后再试。");
        return;
    }
    closeRTIPList();
    if (ptr == null) return;
    ipListID = ptr.id.replace(/_status$/, "");
    if (!ipListDialogIDArray.hasOwnProperty(ipListID))
        return;
    if (document.getElementById(ipListID + "_area") != null) {
        document.getElementById(ipListID + "_area").style = "margin-top:8px; margin-left:1%; width:97%; margin-bottom:8px; font-family:'Courier New', Courier, mono; font-size:11px; background-color:black;";
        document.getElementById(ipListID + "_area").innerHTML = "";
    }
    if (document.getElementById(ipListID) != null) {
        $("#" + ipListID).css("position", "absolute");
        $("#" + ipListID).css("-webkit-border-radius", "5px");
        $("#" + ipListID).css("-moz-border-radius", "5px");
        $("#" + ipListID).css("border-radius", "5px");
        $("#" + ipListID).css("z-index", "500");
        $("#" + ipListID).css("background-color", "#2B373B");
        $("#" + ipListID).css("margin-left", "15%");
        $("#" + ipListID).css("margin-top", "10px");
        $("#" + ipListID).css("width", "600px");
        $("#" + ipListID).css("box-shadow", "3px 3px 10px #000");
        $("#" + ipListID).fadeIn(500);
        disabledRtListCloseButton(ipListID);
        rtListInfoHeight = 0;
        document.scriptActionsForm.action_script.value = 'start_LZRTList_' + ipListDialogIDArray[ipListID][0];
        document.scriptActionsForm.action_wait.value = "0";
        document.scriptActionsForm.submit();
        if (!rtListInfoEnable) {
            rtListInfoEnable = true;
            setTimeout(getRtListInfo, 100);
        }
    }
}

function initAjaxTextArea() {
    for (let key in ipListDialogIDArray) {
        if (ipListDialogIDArray.hasOwnProperty(key) 
            && document.getElementById(key) != null 
            && document.getElementById(key + "_area") != null 
            && document.getElementById("close_" + key) != null
            && document.getElementById("loading_" + key + "_Icon") != null) {
            document.getElementById(key + "_area").scrollTop = 9999999; //make Scroll_y bottom
        }
    }
    setTimeout(getRtListInfo, 100);
    document.getElementById('statusArea').scrollTop = 9999999; //make Scroll_y bottom
    setTimeout(getStatus, 100);
    document.getElementById('toolsTextArea').scrollTop = 9999999; //make Scroll_y bottom
    for (let key in toolsCMDArray) {
        if (toolsCMDArray.hasOwnProperty(key))
            setTimeout(getToolsInfo, 100, key);
    }
}

function detectVersion() {
    $.ajax({
        async: false,
        url: '/ext/lzr/LZRInstance.html',
        dataType: 'text',
        error: function(xhr) {
            if (xhr.status == 404) {
                document.scriptActionsForm.action_script.value = 'start_LZDetectVersion';
                document.scriptActionsForm.action_wait.value = "0";
                document.scriptActionsForm.submit();
                setTimeout(getLastVersion, 3000);
            }
        },
        success: function() {
            setTimeout(detectVersion, 3000);
        }
    });
}

function initial() {
    setPolicyRoutingPage();
    showProduct();
    initPolicyEnableCtrl();
    loadCustomSettings();
    let restart = !initPolicySetting();
    show_menu();
    initControls();
    inithideDivPage();
    initSwitchDivPage();
    initRTIPListDialog();
    showLANIPList();
    document.body.addEventListener("click", function(_evt) {
        if (ipListID != "" 
            && ipListDialogIDArray.hasOwnProperty(ipListID) 
            && document.getElementById(ipListID) != null 
            && document.getElementById(ipListID + "_status") != null 
            && !document.getElementById(ipListID).contains(_evt.target) 
            && !document.getElementById(ipListID + "_status").contains(_evt.target)) {
            closeRTIPList();
            return;
        }
        control_dropdown_client_block("ClientList_Block_PC", "pull_arrow", _evt);
    });
    initAjaxTextArea();
    if (restart)
        saveSettings(false);
    else {
        setTimeout(detectASD, 100);
        setTimeout(detectVersion, 1000);
    }
}

$(document).ready(function() {
    $("#lzr_producid").click(function() {
        if ($("#lzr_infomation").html() == "")
            $("#lzr_infomation").html('华硕梅林路由器双线路策略路由服务配置工具&#169;<br />项目地址:&nbsp;<a href="https://github.com/larsonzh/amdwprprsct.git" target="_blank" style="font-family:Lucida Console;text-decoration:underline;">https://github.com/larsonzh/amdwprprsct</a> &nbsp; 国内镜像:&nbsp;<a href="https://gitee.com/larsonzh/amdwprprsct.git" target="_blank" style="font-family:Lucida Console;text-decoration:underline;">https://gitee.com/larsonzh/amdwprprsct</a>').show();
        else
            $("#lzr_infomation").html("").hide();
    });
    $("#lzr_infomation").click(function() {
        $("#lzr_infomation").html("").hide();
    });
    $("#lzr_last_version_block").click(function() {
        if (isInstance()) {
            alert("上一个任务正在进行中，请稍后再试。");
            return;
        }
        if (!confirm("当前版本：" + policySettingsArray.version + "       最新版本：" + policySettingsArray.lastVersion + "\n\n软件「在线升级」或「在线重新安装」时，须保持内外部网络畅通。\n\n请确保路由器软件安装目录里有 2 MB 以上的剩余存储空间。\n\n此操作不会改变软件原有参数设置。\n\n确定要执行此操作吗？"))
            return;
        $("#amng_custom").val("");
        document.form.action_script.value = "start_LZDoUpdate";
        document.form.action_wait.value = "25";
        showLoading();
        document.form.submit();
    });
});
