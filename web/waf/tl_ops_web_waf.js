const _add_form_btn_id_name = "tl-ops-web-waf-form-submit";
const _add_form_id_name = "tl-ops-web-waf-form";
let res_data = {};

const tl_ops_web_waf_main = function (){
    window.$ = layui.$;
    window.form = layui.form;

    tl_ops_waf_render()

    $("#tl_ops_waf_submit").on("click",tl_ops_web_waf_submit)
};

const tl_ops_waf_render = function(){
    axios.get("/tlops/waf/get").then((res)=>{
        res = res.data;
        if(res.code === 0){
            res_data = res.data;
            form.val(_add_form_id_name, res_data)
            form.render()
        }
    })
}

const tl_ops_web_waf_submit = function () {
    let waf = form.val(_add_form_id_name);

    for(let key in waf){
        if(key === 'tl_ops_waf_ip_err_code'){
            waf[key] = parseInt(waf[key])
        }
        if(key === 'tl_ops_waf_api_err_code'){
            waf[key] = parseInt(waf[key])
        }
        if(key === 'tl_ops_waf_cc_err_code'){
            waf[key] = parseInt(waf[key])
        }
        if(key === 'tl_ops_waf_header_err_code'){
            waf[key] = parseInt(waf[key])
        }
        if(key === 'tl_ops_waf_cookie_err_code'){
            waf[key] = parseInt(waf[key])
        }
        if(key === 'tl_ops_waf_param_err_code'){
            waf[key] = parseInt(waf[key])
        }
        if(waf[key] < 200 || waf[key] > 599){
            layer.msg("错误码范围应该在 200 ~ 599 内")
            return
        }
    }
    $.ajax(tl_ajax_data({
        url: '/tlops/waf/set',
        data : JSON.stringify(waf),
        contentType : "application/json",
        success : (res)=>{
            layer.msg(res.msg)
            tl_ops_waf_render()
        }
    }));
}