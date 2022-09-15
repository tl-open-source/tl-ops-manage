const _cluster_view_id_name = "tl-ops-web-cluster-service-view";
const _cluster_tlp_id_name = "tl-ops-web-cluster-service-tpl";
const _cluster_form_btn_id_name = "tl-ops-web-cluster-btn";

const _add_form_btn_id_name = "tl-ops-web-cluster-form-submit"

let res_data = {};

const tl_ops_web_cluster_main = function (){
    window.$ = layui.$;
    window.form = layui.form;
    window.table = layui.table;
    window.laytpl = layui.laytpl;
    window.element = layui.element;

    axios.get("/tlops/cluster/get").then((res)=>{
        res = res.data;
        if(res.code === 0){
            res_data = res.data;
            let current = res_data.tl_ops_plugin_sync_cluster_current
            let other = res_data.tl_ops_plugin_sync_cluster_other
            other.push(current)
            tl_ops_web_cluster_render(other)
        }
    })
};

const tl_ops_web_cluster_render = function( data ){
    laytpl(document.getElementById(_cluster_tlp_id_name).innerHTML).render((()=>{
        return data;
    })(), (html)=>{
        document.getElementById(_cluster_view_id_name).innerHTML = html;
    });
    form.render()
}


//管理节点
const tl_ops_web_cluster_edit = function (node) {
    let index = layer.open({
        type: 2
        ,title: '管理【'+node.ip+'】节点'
        ,content: 'tl_ops_web_cluster_form.html?id='+node.id
        ,maxmin: true
        ,minStack:false
        ,area: ['650px', '650px']
        ,btn: ['确定', '取消']
        ,yes: function(index, dom){
            let iframeWindow = window['layui-layer-iframe'+ index]
                ,submit = dom.find('iframe').contents().find('#'+ _add_form_btn_id_name);

            iframeWindow.layui.form.on('submit('+ _add_form_btn_id_name +')', function(data){
                // if(!tl_ops_cluster_data_edit_filter(data)){
                //     return;
                // }
                // let updateInfo = {}
                // updateInfo[node.id] = res_data[name]

                // $.ajax(tl_ajax_data({
                //     url: '/tlops/cluster/set',
                //     data : JSON.stringify(updateInfo),
                //     contentType : "application/json",
                //     success : (res)=>{
                //         layer.msg(res.msg)
                //         tl_ops_web_cluster_render()
                //     }
                // }));
                layer.close(index);
            });
            submit.trigger('click');
        },
        success: function(dom, index) {
            // let evtdata = res_data[name]
            // if (evtdata){
            //     let editForm = dom.find('iframe')[0].contentWindow;
            //     editForm.tl_ops_web_cluster_form_render(evtdata);
            // }else{
            //     layer.msg("渲染编辑框失败")
            // }
        },
    });
    if(parent.window.tl_side_screen() < 1){
        layer.full(index);
    }
};


//过滤数据
const tl_ops_cluster_data_edit_filter = function( data ) {
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