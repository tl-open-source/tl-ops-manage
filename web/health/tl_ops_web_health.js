const _health_view_id_name = "tl-ops-web-health-service-view";
const _health_tlp_id_name = "tl-ops-web-health-service-tpl";
const _health_form_btn_id_name = "tl-ops-web-health-btn";
const _health_form_perfix_id_name = "tl-ops-web-health-form-";

let res_data = {};

const tl_ops_web_health_main = function (){
    window.$ = layui.$;
    window.form = layui.form;
    window.table = layui.table;
    window.laytpl = layui.laytpl;
    window.element = layui.element;

    axios.get("/tlops/health/list").then((res)=>{
        res = res.data;
        if(res.code === 0){
            res_data = res.data;
            //新增service,生成一个默认配置
            let newservice = tl_request_get_param("newservice");
            if(typeof(newservice) === 'string' && newservice !== ''){
                let newserviceconfig = {
                    check_failed_max_count : 5,
                    check_success_max_count : 2,
                    check_interval : 5 * 1000,
                    check_timeout : 1000,
                    check_content : "GET / HTTP/1.0\r\n\r\n\r\n",
                    check_service_name : newservice
                }
                res.data.tl_ops_health_options_config.push(newserviceconfig)
            }
            tl_ops_web_health_render(res.data.tl_ops_health_options_config)
        }
    })

    $('#'+_health_form_btn_id_name).on('click', function(){
        let newServiceList = [];
        for(let i = 0; i < res_data.tl_ops_health_options_config.length; i++){
            let service = form.val(_health_form_perfix_id_name + i);
            service.check_failed_max_count = parseInt(service.check_failed_max_count)
            service.check_success_max_count = parseInt(service.check_success_max_count)
            service.check_interval = parseInt(service.check_interval)
            service.check_timeout = parseInt(service.check_timeout)
            newServiceList.push(service);
        }
        res_data.tl_ops_health_options_config = newServiceList;
        $.ajax(tl_ajax_data({
            url: '/tlops/health/set',
            data : JSON.stringify(res_data),
            contentType : "application/json",
            success : (res)=>{
                layer.msg(res.msg)
                setTimeout(() => {
                    top.window.location.reload()
                }, 500);
            }
        }));
    });
};


const tl_ops_web_health_render = function( data ){
    laytpl(document.getElementById(_health_tlp_id_name).innerHTML).render((()=>{
        return data;
    })(), (html)=>{
        document.getElementById(_health_view_id_name).innerHTML = html;
    });
    form.render()
    element.render('collapse');
}
