const _console_balance_count_view_id_name = "tl-ops-web-console-balance-count-view";
const _console_balance_count_tpl_id_name = "tl-ops-web-console-balance-count-tpl";

const tl_ops_web_console_balance_count_main = async function () {
    window.$ = layui.$;
    window.form = layui.form;
    window.table = layui.table;
    window.laytpl = layui.laytpl;
    window.layer = layui.layer;

    let balance_count_list = []
    let balance_api_count_today = 0;
    let balance_body_count_today = 0;
    let balance_cookie_count_today = 0;
    let balance_header_count_today = 0;
    let balance_param_count_today = 0;

    let balance_api_count_all = 0;
    let balance_body_count_all = 0;
    let balance_cookie_count_all = 0;
    let balance_header_count_all = 0;
    let balance_param_count_all = 0;

    let index = layer.load()

    let apiRes = await axios.get("/tlops/balance/count/api/list");
    apiRes = apiRes.data;
    if (apiRes.code === 0) {
        let data = apiRes.data;
        balance_count_list.push({
            name : "API规则负载详情",
            list : data
        })
        balance_api_count_today = tl_ops_web_console_balance_count_today_count_get(data);
        balance_api_count_all = tl_ops_web_console_balance_count_all_count_get(data);
    }

    let bodyRes = await axios.get("/tlops/balance/count/body/list");
    bodyRes = bodyRes.data;
    if (bodyRes.code === 0) {
        let data = bodyRes.data;
        balance_count_list.push({
            name : "Body规则负载详情",
            list : data
        })
        balance_body_count_today = tl_ops_web_console_balance_count_today_count_get(data);
        balance_body_count_all = tl_ops_web_console_balance_count_all_count_get(data);
    }

    let cookieRes = await axios.get("/tlops/balance/count/cookie/list");
    cookieRes = cookieRes.data;
    if (cookieRes.code === 0) {
        let data = cookieRes.data;
        balance_count_list.push({
            name : "Cookie规则负载详情",
            list : data
        })
        balance_cookie_count_today = tl_ops_web_console_balance_count_today_count_get(data);
        balance_cookie_count_all = tl_ops_web_console_balance_count_all_count_get(data);
    }

    let headerRes = await axios.get("/tlops/balance/count/header/list");
    headerRes = headerRes.data;
    if (headerRes.code === 0) {
        let data = headerRes.data;
        balance_count_list.push({
            name : "Header规则负载详情",
            list : data
        })
        balance_header_count_today = tl_ops_web_console_balance_count_today_count_get(data);
        balance_header_count_all = tl_ops_web_console_balance_count_all_count_get(data);
    }

    let paramRes = await axios.get("/tlops/balance/count/param/list");
    paramRes = paramRes.data;
    if (paramRes.code === 0) {
        let data = paramRes.data;
        balance_count_list.push({
            name : "Param规则负载详情",
            list : data
        })
        balance_param_count_today = tl_ops_web_console_balance_count_today_count_get(data);
        balance_param_count_all = tl_ops_web_console_balance_count_all_count_get(data);
    }

    layer.close(index)
    
    tl_ops_web_console_balance_count_render({
        balance_api_count_today : balance_api_count_today,
        balance_body_count_today : balance_body_count_today,
        balance_cookie_count_today : balance_cookie_count_today,
        balance_header_count_today : balance_header_count_today,
        balance_param_count_today : balance_param_count_today,
        balance_api_count_all : balance_api_count_all,
        balance_body_count_all : balance_body_count_all,
        balance_cookie_count_all : balance_cookie_count_all,
        balance_header_count_all : balance_header_count_all,
        balance_param_count_all : balance_param_count_all,
        balance_count_list : balance_count_list
    })
}

// 全量计数
const tl_ops_web_console_balance_count_all_count_get = function(list){
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
const tl_ops_web_console_balance_count_today_count_get = function(list){
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

const tl_ops_web_console_balance_count_render = function (data) {
    laytpl(document.getElementById(_console_balance_count_tpl_id_name).innerHTML).render((() => {
        return data
    })(), (html) => {
        document.getElementById(_console_balance_count_view_id_name).innerHTML = html;
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