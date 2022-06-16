const _add_form_btn_id_name = "tl-ops-web-balance-form-submit";
const _add_form_id_name = "tl-ops-web-balance-form";
let res_data = {};

const tl_ops_web_balance_main = function (){
    window.$ = layui.$;
    window.form = layui.form;

    tl_ops_balance_render()

    $("#tl_ops_balance_submit").on("click",tl_ops_web_balance_submit)
};

const tl_ops_balance_render = function(){
    axios.get("/tlops/balance/get").then((res)=>{
        res = res.data;
        if(res.code === 0){
            res_data = res.data;
            form.val(_add_form_id_name, res_data)
            form.render()
        }
    })
}

const tl_ops_web_balance_submit = function () {
    let balance = form.val(_add_form_id_name);

    for(let key in balance){
        if(key === 'tl_ops_balance_host_empty_err_code'){
            balance[key] = parseInt(balance[key])
        }
        if(key === 'tl_ops_balance_host_pass_err_code'){
            balance[key] = parseInt(balance[key])
        }
        if(key === 'tl_ops_balance_leak_limit_err_code'){
            balance[key] = parseInt(balance[key])
        }
        if(key === 'tl_ops_balance_mode_empty_err_code'){
            balance[key] = parseInt(balance[key])
        }
        if(key === 'tl_ops_balance_offline_err_code'){
            balance[key] = parseInt(balance[key])
        }
        if(key === 'tl_ops_balance_service_empty_err_code'){
            balance[key] = parseInt(balance[key])
        }
        if(key === 'tl_ops_balance_token_limit_err_code'){
            balance[key] = parseInt(balance[key])
        }
        if(balance[key] < 200 || balance[key] > 599){
            layer.msg("错误码范围应该在 200 ~ 599 内")
            return
        }
    }
    $.ajax(tl_ajax_data({
        url: '/tlops/balance/set',
        data : JSON.stringify(balance),
        contentType : "application/json",
        success : (res)=>{
            layer.msg(res.msg)
            tl_ops_balance_render()
        }
    }));
}