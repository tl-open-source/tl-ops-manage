const _console_waf_count_view_id_name = "tl-ops-web-console-waf-count-view";
const _console_waf_count_tpl_id_name = "tl-ops-web-console-waf-count-tpl";

const tl_ops_web_console_waf_count_main = async function () {
    window.$ = layui.$;
    window.form = layui.form;
    window.table = layui.table;
    window.layer = layui.layer;
    window.laytpl = layui.laytpl;

    let waf_count_list = []
    let waf_api_count_today = 0;
    let waf_cc_count_today = 0;
    let waf_ip_count_today = 0;
    let waf_cookie_count_today = 0;
    let waf_header_count_today = 0;
    let waf_param_count_today = 0;
    let waf_api_count_all = 0;
    let waf_cc_count_all = 0;
    let waf_ip_count_all = 0;
    let waf_cookie_count_all = 0;
    let waf_header_count_all = 0;
    let waf_param_count_all = 0;

    let index = layer.load()

    let apiRes = await axios.get("/tlops/waf/count/api/list");
    apiRes = apiRes.data;
    if (apiRes.code === 0) {
        let data = apiRes.data;
        waf_count_list.push({
            name : "API规则WAF拦截详情",
            list : data
        })
        waf_api_count_today = tl_ops_web_console_waf_count_today_count_get(data);
        waf_api_count_all = tl_ops_web_console_waf_count_all_count_get(data);
    }

    let ipRes = await axios.get("/tlops/waf/count/ip/list");
    ipRes = ipRes.data;
    if (ipRes.code === 0) {
        let data = ipRes.data;
        waf_count_list.push({
            name : "IP规则WAF拦截详情",
            list : data
        })
        waf_ip_count_today = tl_ops_web_console_waf_count_today_count_get(data);
        waf_ip_count_all = tl_ops_web_console_waf_count_all_count_get(data);
    }

    let ccRes = await axios.get("/tlops/waf/count/cc/list");
    ccRes = ccRes.data;
    if (ccRes.code === 0) {
        let data = ccRes.data;
        waf_count_list.push({
            name : "CC规则WAF拦截详情",
            list : data
        })
        waf_cc_count_today = tl_ops_web_console_waf_count_today_count_get(data);
        waf_cc_count_all = tl_ops_web_console_waf_count_all_count_get(data);
    }

    let cookieRes = await axios.get("/tlops/waf/count/cookie/list");
    cookieRes = cookieRes.data;
    if (cookieRes.code === 0) {
        let data = cookieRes.data;
        waf_count_list.push({
            name : "Cookie规则WAF拦截详情",
            list : data
        })
        waf_cookie_count_today = tl_ops_web_console_waf_count_today_count_get(data);
        waf_cookie_count_all = tl_ops_web_console_waf_count_all_count_get(data);
    }

    let headerRes = await axios.get("/tlops/waf/count/header/list");
    headerRes = headerRes.data;
    if (headerRes.code === 0) {
        let data = headerRes.data;
        waf_count_list.push({
            name : "Header规则WAF拦截详情",
            list : data
        })
        waf_header_count_today = tl_ops_web_console_waf_count_today_count_get(data);
        waf_header_count_all = tl_ops_web_console_waf_count_all_count_get(data);
    }

    let paramRes = await axios.get("/tlops/waf/count/param/list");
    paramRes = paramRes.data;
    if (paramRes.code === 0) {
        let data = paramRes.data;
        waf_count_list.push({
            name : "Param规则WAF拦截详情",
            list : data
        })
        waf_param_count_today = tl_ops_web_console_waf_count_today_count_get(data);
        waf_param_count_all = tl_ops_web_console_waf_count_all_count_get(data);
    }

    layer.close(index)

    tl_ops_web_console_waf_count_render({
        waf_api_count_today : waf_api_count_today,
        waf_cc_count_today : waf_cc_count_today,
        waf_ip_count_today : waf_ip_count_today,
        waf_cookie_count_today : waf_cookie_count_today,
        waf_header_count_today : waf_header_count_today,
        waf_param_count_today : waf_param_count_today,
        waf_api_count_all : waf_api_count_all,
        waf_cc_count_all : waf_cc_count_all,
        waf_ip_count_all : waf_ip_count_all,
        waf_cookie_count_all : waf_cookie_count_all,
        waf_header_count_all : waf_header_count_all,
        waf_param_count_all : waf_param_count_all,
        waf_count_list : waf_count_list
    })
}

// 全量计数
const tl_ops_web_console_waf_count_all_count_get = function(list){
    let allCount = 0;
    list.forEach(api => {
        let count_list = api.count_list || []
        for(let time in count_list){
            let count = count_list[time] || 0;
            allCount += count;
        }
    });
    return allCount;
}

// 当天计数
const tl_ops_web_console_waf_count_today_count_get = function(list){
    let allCount = 0;
    list.forEach(api => {
        let count_list = api.count_list || []
        for(let time in count_list){
            let count = count_list[time] || 0;
            let day = time.toString().split(" ")[0]
            let cur_day = getDateStr(0);
            //当天内
            if (day.includes(cur_day)) {
                allCount += count;
            }
        }
    });
    return allCount;
}

const tl_ops_web_console_waf_count_render = function (data) {
    laytpl(document.getElementById(_console_waf_count_tpl_id_name).innerHTML).render((() => {
        return data
    })(), (html) => {
        document.getElementById(_console_waf_count_view_id_name).innerHTML = html;
    });
    form.render()
}


function getDateStr(day) {
    let cur = new Date();
    cur.setDate(cur.getDate() + day);
    let y = cur.getFullYear();
    let m = cur.getMonth() + 1;
    let d = cur.getDate();
    return y + '-' + (m < 10 ? '0' + m : m) + '-' + (d < 10 ? '0' + d : d);
}