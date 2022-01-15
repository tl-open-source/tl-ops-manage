const _table_id_name = "tl-ops-web-service-table";
const _search_id_name = "tl-ops-web-service-search";
const _add_form_btn_id_name = "tl-ops-web-service-form-submit";
const _add_form_id_name = "tl-ops-web-service-form";
let rule = '';
let res_data = {};

const tl_ops_web_service_main = function (){
    window.$ = layui.$;
    window.form = layui.form;
    window.table = layui.table;
    window.layedit = layui.layedit;

    axios.get("/tlops/service/list").then((res)=>{
        res = res.data;
        if(res.code === 0){
            rule = res.data.tl_ops_balance_service_rule;
            //首次渲染
            tl_ops_web_service_render();

            $('#tl-ops-web-service-cur-rule')[0].innerHTML = `
                <b style='color:red;font-size:16px'>${rule}</b> 
                <b> ( ${rule==='auto_load' ? '系统启动时开启自检' : '手动启动某次自检'} )</b>
            `;

            //表格外部事件操作
            $('.layui-btn.layuiadmin-btn-useradmin').on('click', function(){
                let type = $(this).data('type');
                tl_ops_web_service_event()[type] ? tl_ops_web_service_event()[type].call(this) : '';
            });

            //搜索
            form.on('submit('+_search_id_name+')', function(data){
                tl_ops_web_service_reload(data.field);
            });

            //行事件操作
            table.on('tool('+_table_id_name+')', function(obj) {
                let type = obj.event;
                let data = obj.data;
                tl_ops_web_service_event()[type] ? tl_ops_web_service_event()[type].call(this, data) : '';
            });
        }
    })
};

//事件监听定义
const tl_ops_web_service_event = function () {
    return {
        add:  tl_ops_web_service_add,
    }
};

//表格cols
const tl_ops_web_service_cols = function () {
    return [[
        {
            field: 'name', title: '服务名称', width:"30%"
        },  {
            field: 'node', title: '节点列表',width:"30%",
            templet : (d)=>{
                return `<p style='text-decoration: underline;color:red;font-weight:700;cursor: pointer;' onclick='tl_ops_web_service_node_manage("${d.name}")'>${d.node.length}个节点</p>`;
            }
        }, {
            field: 'state', title: '服务健康状态',width:"40%",
            templet : (d)=>{
                return `<span> 上线节点-${1}，个 </span> <span> 下线节点-${1}个 </span>`;
            }
        }
    ]];
};

//表格render
const tl_ops_web_service_render = function () {
    table.render(tl_ajax_data({
        elem: '#'+_table_id_name,
        url: '/tlops/service/list',
        cols: tl_ops_web_service_cols(),
        page:true,
        needReloadMsg : false,
        toolbar: '#tl-ops-web-service-toolbar',
        defaultToolbar: ['filter', 'print', 'exports'],
        totalRow: true, //开启合计行
        parseData: function(res){
            res_data = res.data;
            let datas = [], keys = Object.keys(res.data.tl_ops_balance_service_list);
            for(key in keys){
                datas.push({
                    name : keys[key],
                    node : Object.keys(res.data.tl_ops_balance_service_list[keys[key]]).length !== 0 
                            ? res.data.tl_ops_balance_service_list[keys[key]] : []
                })
            }
            return {
                "code": res.code,
                "msg": res.msg,
                "count": datas.length,
                "data": datas
            };
        }
    }));
};

//表格reload
const tl_ops_web_service_reload = function (matcher) {
    table.render(tl_ajax_data({
        elem: '#'+_table_id_name,
        url: '/tlops/service/list',
        where : matcher,
        cols: tl_ops_web_service_cols(),
        page:true,
        needReloadMsg : false,
        toolbar: '#tl-ops-web-service-toolbar',
        defaultToolbar: ['filter', 'print', 'exports'],
        totalRow: true, //开启合计行
        parseData: function(res){
            res_data = res.data;
            let datas = [], keys = Object.keys(res.data.tl_ops_balance_service_list);
            for(key in keys){
                datas.push({
                    name : keys[key],
                    node : Object.keys(res.data.tl_ops_balance_service_list[keys[key]]).length !== 0 
                            ? res.data.tl_ops_balance_service_list[keys[key]] : []
                })
            }
            return {
                "code": res.code,
                "msg": res.msg,
                "count": datas.length,
                "data": datas
            };
        }
    }));
};

//添加
const tl_ops_web_service_add = function () {
    layer.open({
        type: 2
        ,title: '添加SERVICE服务'
        ,content: 'tl_ops_web_service_form.html'
        ,maxmin: true
        ,minStack:false
        ,area: ['700px', '600px']
        ,btn: ['确定', '取消']
        ,yes: function(index, layero){
            let iframeWindow = window['layui-layer-iframe'+ index]
                ,submit = layero.find('iframe').contents().find('#'+ _add_form_btn_id_name);

            iframeWindow.layui.form.on('submit('+ _add_form_btn_id_name +')', function(data){
                if(!tl_ops_service_data_add_filter(data)){
                    return;
                }
                $.ajax(tl_ajax_data({
                    url: '/tlops/service/set',
                    data : JSON.stringify(res_data),
                    contentType : "application/json",
                    success : (res)=>{
                        tl_ops_web_service_reload();
                    }
                }));
                layer.close(index);

                //管理节点
                layer.open({
                     type: 2
                    ,title: '服务健康检查配置'
                    ,content: '../../health/tl_ops_web_health.html?newservice='+data.field.service
                    ,area: ['850px', '600px']
                    ,closeBtn : false
                });

            });
            submit.trigger('click');
        }
    });
};

//管理节点
const tl_ops_web_service_node_manage = function (name) {
    let index = layer.open({
        type: 2
        ,title: '管理服务【'+name+'】节点列表'
        ,content: 'tl_ops_web_service_node.html?service='+name
        ,maxmin: true
        ,minStack:false
        ,area: ['600px', '600px']
        ,end : function () {
            tl_ops_web_service_reload()
        }
    });
    layer.full(index);
};


//过滤数据
const tl_ops_service_data_add_filter = function( data ) {
    for(let key in data.field){
        if(data.field[key] === undefined || data.field[key] === null || data.field[key] === ''){
            layer.msg(key + "未填写")
            return false;
        }
    }
    res_data.tl_ops_balance_service_list[data.field.service] = [];
    res_data.tl_ops_health_service_options_version = true
    return true
}