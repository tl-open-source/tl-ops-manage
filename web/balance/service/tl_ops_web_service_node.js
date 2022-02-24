const _table_id_name = "tl-ops-web-service-node-table";
const _search_id_name = "tl-ops-web-service-node-search";
const _add_form_btn_id_name = "tl-ops-web-service-node-form-submit";
const _add_form_id_name = "tl-ops-web-service-node-form";
let service = '';
let rule = '';
let res_data = {};

const tl_ops_web_service_node_main = function (){
    window.$ = layui.$;
    window.form = layui.form;
    window.table = layui.table;
    window.layedit = layui.layedit;
    service = tl_request_get_param("service");

    axios.get("/tlops/service/list").then((res)=>{
        res = res.data;
        if(res.code === 0){
            rule = res.data.tl_ops_service_node_rule;
            //首次渲染
            tl_ops_web_service_node_render();

            //表格外部事件操作
            $('.layui-btn.layuiadmin-btn-useradmin').on('click', function(){
                let type = $(this).data('type');
                tl_ops_web_service_node_event()[type] ? tl_ops_web_service_node_event()[type].call(this) : '';
            });

            //搜索
            form.on('submit('+_search_id_name+')', function(data){
                tl_ops_web_service_node_reload(data.field);
            });

            //行事件操作
            table.on('tool('+_table_id_name+')', function(obj) {
                let type = obj.event;
                let data = obj.data;
                tl_ops_web_service_node_event()[type] ? tl_ops_web_service_node_event()[type].call(this, data) : '';
            });
        }
    })
};

//事件监听定义
const tl_ops_web_service_node_event = function () {
    return {
        add:  tl_ops_web_service_node_add,
        edit:  tl_ops_web_service_node_edit,
    }
};

//表格cols
const tl_ops_web_service_node_cols = function () {
    return [[
        {
            field: 'id', title: 'ID',width:"15%"
        }, {
            field: 'service', title: '服务名称', width:"10%"
        },  {
            field: 'name', title: '节点名称',width:"15%"
        },  {
            field: 'protocol', title: '节点请求协议',width:"10%"
        },  {
            field: 'ip', title: 'ip地址',width:"15%"
        },  {
            field: 'port', title: '端口号',width:"10%"
        },{
            field: 'updatetime', title: '更新时间',width:"15%",
        }, {
            width: "10%",
            align: 'center',
            fixed: 'right',
            title: '操作',
            toolbar: '#tl-ops-web-service-node-operate'
        }
    ]];
};


//表格render
const tl_ops_web_service_node_render = function () {
    table.render(tl_ajax_data({
        elem: '#'+_table_id_name,
        url: '/tlops/service/list',
        cols: tl_ops_web_service_node_cols(),
        page:true,
        needReloadMsg : false,
        toolbar: true,
        defaultToolbar: ['filter', 'print', 'exports'],
        totalRow: true, //开启合计行
        parseData: function(res){
            res_data = res.data;
            return {
                "code": res.code,
                "msg": res.msg,
                "count": res.data.tl_ops_service_list[service].length,
                "data": res.data.tl_ops_service_list[service]
            };
        }
    }));
};

//表格reload
const tl_ops_web_service_node_reload = function (matcher) {
    table.render(tl_ajax_data({
        elem: '#'+_table_id_name,
        url: '/tlops/service/list',
        where : matcher,
        cols: tl_ops_web_service_node_cols(),
        page:true,
        needReloadMsg : false,
        toolbar: true,
        defaultToolbar: ['filter', 'print', 'exports'],
        totalRow: true, //开启合计行
        parseData: function(res){
            res_data = res.data;
            return {
                "code": res.code,
                "msg": res.msg,
                "count": res.data.tl_ops_service_list[service].length,
                "data": res.data.tl_ops_service_list[service]
            };
        }
    }));
};



//添加
const tl_ops_web_service_node_add = function () {
    layer.open({
        type: 2
        ,title: '添加SERVICE-NODE节点'
        ,content: 'tl_ops_web_service_node_form.html?&service='+service
        ,maxmin: true
        ,minStack:false
        ,area: ['700px', '600px']
        ,btn: ['确定', '取消']
        ,yes: function(index, layero){
            let iframeWindow = window['layui-layer-iframe'+ index]
                ,submit = layero.find('iframe').contents().find('#'+ _add_form_btn_id_name);

            iframeWindow.layui.form.on('submit('+ _add_form_btn_id_name +')', function(data){
                if(!tl_ops_service_node_data_add_filter(data)){
                    return;
                }
                $.ajax(tl_ajax_data({
                    url: '/tlops/service/set',
                    data : JSON.stringify(res_data),
                    contentType : "application/json",
                    success : (res)=>{
                        tl_ops_web_service_node_reload()
                    }
                }));
                layer.close(index); //关闭弹层
            });
            submit.trigger('click');
        }
    });
};

//编辑
const tl_ops_web_service_node_edit = function (evtdata) {
    layer.open({
        type: 2
        ,title: '编辑SERVICE-NODE节点'
        ,content: 'tl_ops_web_service_node_form.html?&service='+service
        ,maxmin: true
        ,minStack:false
        ,area: ['700px', '600px']
        ,btn: ['确定', '取消']
        ,yes: function(index, dom){
            let iframeWindow = window['layui-layer-iframe'+ index]
                ,submit = dom.find('iframe').contents().find('#'+ _add_form_btn_id_name);

            iframeWindow.layui.form.on('submit('+ _add_form_btn_id_name +')', function(data){
                if(!tl_ops_service_node_data_edit_filter(data)){
                    return;
                }
                $.ajax(tl_ajax_data({
                    url: '/tlops/service/set',
                    data : JSON.stringify(res_data),
                    contentType : "application/json",
                    success : (res)=>{
                        tl_ops_web_service_node_reload()
                    }
                }));
                layer.close(index);
            });
            submit.trigger('click');
        },
        success: function(dom, index) {
            //通过索引获取到当前iframe弹出层
            let editForm = dom.find('iframe')[0].contentWindow;
            editForm.tl_ops_web_service_node_form_render(evtdata);
        },
    });
};


//过滤数据
const tl_ops_service_node_data_add_filter = function( data ) {
    for(let key in data.field){
        if (key === 'id'){
            continue;
        }
        if(data.field[key] === undefined || data.field[key] === null || data.field[key] === ''){
            layer.msg(key + "未填写")
            return false;
        }
        if(key === 'port'){
            data.field[key] = parseInt(data.field[key])
        }
        if(key === 'ip' && !tl_validate_ip(data.field[key])){
            layer.msg(key + "不合法")
            return false;
        }
        if(key === 'port' && data.field[key] <= 0){
            layer.msg(key + "不合法")
            return false;
        }
    }
    if(res_data.tl_ops_service_list[data.field.service].length === undefined){
        res_data.tl_ops_service_list[data.field.service] = [];
    }
    res_data.tl_ops_service_list[data.field.service].push(data.field);
    res_data.has_new_service_name = false

    return true;
}

//过滤数据
const tl_ops_service_node_data_edit_filter = function( data ) {
    for(let key in data.field){
        if(data.field[key] === undefined || data.field[key] === null || data.field[key] === ''){
            layer.msg(key + "未填写")
            return false;
        }
        if(key === 'port'){
            data.field[key] = parseInt(data.field[key])
        }
        if(key === 'ip' && !tl_validate_ip(data.field[key])){
            layer.msg(key + "不合法")
            return false;
        }
        if(key === 'port' && data.field[key] <= 0){
            layer.msg(key + "不合法")
            return false;
        }
    }
    let cur_list = []
    res_data.tl_ops_service_list[data.field.service].forEach((item)=>{
        if(item.id === data.field.id){
            item = data.field;
        }
        cur_list.push(item)
    })
    res_data.tl_ops_service_list[data.field.service] = cur_list;
    res_data.has_new_service_name = false

    return true;
}
