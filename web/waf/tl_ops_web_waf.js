const _waf_view_id_name = "tl-ops-web-waf-service-view";
const _waf_tlp_id_name = "tl-ops-web-waf-service-tpl";
const _waf_form_btn_id_name = "tl-ops-web-waf-btn";

const _add_form_btn_id_name = "tl-ops-web-waf-form-submit"

let res_data = {};

const tl_ops_web_waf_main = function (){
    window.$ = layui.$;
    window.form = layui.form;
    window.table = layui.table;
    window.laytpl = layui.laytpl;
    window.element = layui.element;

    axios.get("/tlops/waf/get").then((res)=>{
        res = res.data;
        if(res.code === 0){
            res_data = res.data;
            tl_ops_web_waf_render(tl_ops_waf_handler_render_data(res_data))
        }
    })
};


const tl_ops_waf_handler_render_data = function(data){
    let options_list = []
    for(let name in data){
        let err_name = "其他";
        if(name === 'waf_ip'){
            err_name = "请求IP拦截"
        }else if(name === 'waf_api'){
            err_name = "请求API拦截"
        }else if(name === 'waf_cc'){
            err_name = "请求CC拦截"
        }else if(name === 'waf_header'){
            err_name = "请求头拦截"
        }else if(name === 'waf_cookie'){
            err_name = "请求Cookie拦截"
        }else if(name === 'waf_param'){
            err_name = "请求参数拦截"
        }
        data[name]['err_name'] = err_name
        data[name]['name'] = name
        data[name]['content_sub'] = data[name].content.substring(0,15) + "...("+data[name]['content'].length+"字符)"
        options_list.push(data[name])
    }

    options_list = options_list.sort(function(a, b){return a.name.localeCompare(b.name,'zh-CN')})

    return options_list
}

const tl_ops_web_waf_render = function( data ){
    laytpl(document.getElementById(_waf_tlp_id_name).innerHTML).render((()=>{
        return data;
    })(), (html)=>{
        document.getElementById(_waf_view_id_name).innerHTML = html;
    });
    form.render()
}


//管理节点
const tl_ops_web_waf_edit = function (name) {
    let index = layer.open({
        type: 2
        ,title: '自定义【'+name+'】错误配置'
        ,content: 'tl_ops_web_waf_form.html?name='+name
        ,maxmin: true
        ,minStack:false
        ,area: ['650px', '650px']
        ,btn: ['确定', '取消']
        ,yes: function(index, dom){
            let iframeWindow = window['layui-layer-iframe'+ index]
                ,submit = dom.find('iframe').contents().find('#'+ _add_form_btn_id_name);

            iframeWindow.layui.form.on('submit('+ _add_form_btn_id_name +')', function(data){
                if(!tl_ops_waf_data_edit_filter(data)){
                    return;
                }
                let updateInfo = {}
                updateInfo[name] = res_data[name]

                $.ajax(tl_ajax_data({
                    url: '/tlops/waf/set',
                    data : JSON.stringify(updateInfo),
                    contentType : "application/json",
                    success : (res)=>{
                        layer.msg(res.msg)
                        tl_ops_web_waf_render(tl_ops_waf_handler_render_data(res_data))
                    }
                }));
                layer.close(index);
            });
            submit.trigger('click');
        },
        success: function(dom, index) {
            let evtdata = res_data[name]
            if (evtdata){
                let editForm = dom.find('iframe')[0].contentWindow;
                editForm.tl_ops_web_waf_form_render(evtdata);
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
const tl_ops_waf_data_edit_filter = function( data ) {
    let name = data.field.name
    delete data.field.file;
    delete data.field.err_name;
    delete data.field.content_sub;
    delete data.field.name;
    for(let key in data.field){
        if(data.field[key] === undefined || data.field[key] === null || data.field[key] === ''){
            layer.msg(key + "未填写")
            return false;
        }
        if(key === 'code'){
            data.field[key] = parseInt(data.field[key])
        }
        if(key === 'code'){
            if(data.field[key] < 200 || data.field[key] > 599){
                layer.msg(key + "应该在200~599范围内")
                return false;
            }
        }
    }

    res_data[name] = data.field;
    return true;
}