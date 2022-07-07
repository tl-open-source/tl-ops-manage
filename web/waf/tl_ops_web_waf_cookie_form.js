const _form_btn_id_name = "tl-ops-web-waf-cookie-form-submit";
const _form_id_name = "tl-ops-web-waf-cookie-form";

const _form_select_view_id_name = "tl-ops-web-waf-cookie-form-service-view";
const _form_select_tlp_id_name = "tl-ops-web-waf-cookie-form-service-tpl";

let service_data = {};

const tl_ops_web_waf_cookie_form_main = async function (){
    window.$ = layui.$;
    window.form = layui.form;
    window.laytpl = layui.laytpl;
    window.layedit = layui.layedit;

    let scope_args = tl_request_get_param("scope");
    if(scope_args === 'global'){
        document.querySelector("#"+_form_select_view_id_name).style = 'display:none';
    }

    let res = await axios.get("/tlops/service/list");
    res = res.data;
    if(res.code === 0){
        service_data = res.data.tl_ops_service_list;
    }

    //渲染select
    tl_ops_web_waf_cookie_form_select_service_render();

    //处理编辑情况
    let service_args = tl_request_get_param("service");
    let white_args = tl_request_get_param("white");
    if(service_args || white_args){
        form.val(_form_id_name, Object.assign(form.val(_form_id_name), {
            service : service_args
        }))

        form.val(_form_id_name, Object.assign(form.val(_form_id_name), {
            white : white_args
        }))
    }
};


const tl_ops_web_waf_cookie_form_select_service_render = function(  ){
    laytpl(document.getElementById(_form_select_tlp_id_name).innerHTML).render((()=>{    
        return service_data;
    })(), (html)=>{
        document.getElementById(_form_select_view_id_name).innerHTML = html;
    });
    form.render()
}
