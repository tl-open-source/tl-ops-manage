const _form_btn_id_name = "tl-ops-web-waf-header-form-submit";
const _form_id_name = "tl-ops-web-waf-header-form";

const _form_select_view_id_name = "tl-ops-web-waf-header-form-service-view";
const _form_select_tlp_id_name = "tl-ops-web-waf-header-form-service-tpl";
const _form_select_service_id_name = "tl-ops-web-waf-header-form-service";

const _form_select_node_view_id_name = "tl-ops-web-waf-header-form-service-node-view";
const _form_select_node_tlp_id_name = "tl-ops-web-waf-header-form-service-node-tpl";
const _form_select_node_service_id_name = "tl-ops-web-waf-header-form-service-node";
let service_data = {};

const tl_ops_web_waf_header_form_main = async function (){
    window.$ = layui.$;
    window.form = layui.form;
    window.laytpl = layui.laytpl;
    window.layedit = layui.layedit;

    // let rule_args = tl_request_get_param("rule");
    // if(rule_args === 'random'){
    //     document.querySelector("#"+_form_select_node_view_id_name).style = 'display:none';
    // }

    //监听select
    form.on('select', function(data){
        if(data.elem.id === _form_select_service_id_name){//service
            tl_ops_web_waf_header_form_select_service_node_render(data.value)
        }
    }); 

    let res = await axios.get("/tlops/service/list");
    res = res.data;
    if(res.code === 0){
        service_data = res.data.tl_ops_service_list;
    }

    //渲染select
    tl_ops_web_waf_header_form_select_service_render();

    //处理编辑情况
    let service_args = tl_request_get_param("service");
    let node_args = tl_request_get_param("node");
    let white_args = tl_request_get_param("white");
    if(service_args || node_args || white_args){
        form.val(_form_id_name, Object.assign(form.val(_form_id_name), {
            service : service_args
        }))

        form.val(_form_id_name, Object.assign(form.val(_form_id_name), {
            white : white_args
        }))

        //渲染完tpl，进行编辑赋值
        tl_ops_web_waf_header_form_select_service_node_render( service_args )
        form.val(_form_id_name, Object.assign(form.val(_form_id_name), {
            node : node_args
        }))
    }
};


const tl_ops_web_waf_header_form_select_service_render = function(  ){
    laytpl(document.getElementById(_form_select_tlp_id_name).innerHTML).render((()=>{    
        return service_data;
    })(), (html)=>{
        document.getElementById(_form_select_view_id_name).innerHTML = html;
    });
    form.render()
}

const tl_ops_web_waf_header_form_select_service_node_render = function( service_name ){
    laytpl(document.getElementById(_form_select_node_tlp_id_name).innerHTML).render((()=>{
        if(!service_name){
            return []
        }
        return service_data[service_name];
    })(), (html)=>{
        document.getElementById(_form_select_node_view_id_name).innerHTML = html;
    });
    form.render()
}

