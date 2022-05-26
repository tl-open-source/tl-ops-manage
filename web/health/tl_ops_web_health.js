const _health_view_id_name = "tl-ops-web-health-service-view";
const _health_tlp_id_name = "tl-ops-web-health-service-tpl";
const _health_form_btn_id_name = "tl-ops-web-health-btn";
const _health_form_perfix_id_name = "tl-ops-web-health-form-";

const _add_form_btn_id_name = "tl-ops-web-health-form-submit"

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
            tl_ops_web_health_render(res_data.tl_ops_health_options_list)
        }
    })
};


const tl_ops_web_health_render = function( data ){
    laytpl(document.getElementById(_health_tlp_id_name).innerHTML).render((()=>{
        return data;
    })(), (html)=>{
        document.getElementById(_health_view_id_name).innerHTML = html;
    });
    form.render()
}


//管理节点
const tl_ops_web_health_edit = function (name) {
    let index = layer.open({
        type: 2
        ,title: '管理【'+name+'】健康检查配置'
        ,content: 'tl_ops_web_health_form.html?service='+name
        ,maxmin: true
        ,minStack:false
        ,area: ['650px', '750px']
        ,btn: ['确定', '取消']
        ,yes: function(index, dom){
            let iframeWindow = window['layui-layer-iframe'+ index]
                ,submit = dom.find('iframe').contents().find('#'+ _add_form_btn_id_name);

            iframeWindow.layui.form.on('submit('+ _add_form_btn_id_name +')', function(data){
                if(!tl_ops_health_data_edit_filter(data)){
                    return;
                }
                $.ajax(tl_ajax_data({
                    url: '/tlops/health/set',
                    data : JSON.stringify(res_data),
                    contentType : "application/json",
                    success : (res)=>{
                        layer.msg(res.msg)
                        tl_ops_web_health_render(res_data.tl_ops_health_options_list)
                    }
                }));
                layer.close(index);
            });
            submit.trigger('click');
        },
        success: function(dom, index) {
            let evtdata = res_data.tl_ops_health_options_list.filter((item)=>{
                return item.check_service_name === name;
            })
            if (evtdata && evtdata.length === 1){
                let editForm = dom.find('iframe')[0].contentWindow;
                editForm.tl_ops_web_health_form_render(evtdata[0]);
            }else{
                layer.msg("渲染编辑框失败")
            }
        },
    });
    if(parent.window.tl_side_screen() < 1){
        layer.full(index);
    }
};


//过滤数据
const tl_ops_health_data_edit_filter = function( data ) {
    delete data.field.file;
    for(let key in data.field){
        if(data.field[key] === undefined || data.field[key] === null || data.field[key] === ''){
            layer.msg(key + "未填写")
            return false;
        }
        if(key === 'check_timeout'){
            data.field[key] = parseInt(data.field[key])
        }
        if(key === 'check_interval'){
            data.field[key] = parseInt(data.field[key])
        }
        if(key === 'check_success_max_count'){
            data.field[key] = parseInt(data.field[key])
        }
        if(key === 'check_failed_max_count'){
            data.field[key] = parseInt(data.field[key])
        }
        if((key === 'check_success_max_count' || key === 'check_failed_max_count' || 
            key === 'check_timeout' || key === 'check_interval') && data.field[key] <= 0){
            layer.msg(key + "不合法")
            return false;
        }
        if(key === 'check_content' && data.field[key].length > 500){
            layer.msg("请求内容长度超过500")
            return false;
        }
        if(key === 'check_success_status'){
            let statusList = data.field[key].split(",");
            if(statusList.length > 50){
                layer.msg("状态码定义过多")
                return false
            }
            let statusIntList = [];
            for(let statusIndex in statusList){
                statusIntList.push(parseInt(statusList[statusIndex]))
            }
            data.field[key] = statusIntList
        }
    }
    let cur_list = []
    res_data.tl_ops_health_options_list.forEach((item)=>{
        if(item.check_service_name === data.field.check_service_name){
            item = data.field;
        }
        cur_list.push(item)
    })
    res_data.tl_ops_health_options_list = cur_list;

    return true;
}