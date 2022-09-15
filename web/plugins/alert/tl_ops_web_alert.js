const _table_id_name = "tl-ops-web-alert-table";
const _search_id_name = "tl-ops-web-alert-search";
const _add_form_btn_id_name = "tl-ops-web-alert-form-submit";
const _add_form_id_name = "tl-ops-web-alert-form";
let res_data = {};

const tl_ops_web_alert_main = function (){
    window.$ = layui.$;
    window.form = layui.form;
    window.table = layui.table;
    window.layedit = layui.layedit;

    tl_ops_web_alert_render();

    //事件操作
    $('.layui-btn.layuiadmin-btn-useradmin').on('click', function(){
        let type = $(this).data('type');
        tl_ops_web_alert_event()[type] ? tl_ops_web_alert_event()[type].call(this) : '';
    });

    //搜索
    form.on('submit('+_search_id_name+')', function(data){
        tl_ops_web_alert_reload(data.field);
    });

    //行事件操作
    table.on('tool('+_table_id_name+')', function(obj) {
        let type = obj.event;
        let data = obj.data;
        tl_ops_web_alert_event()[type] ? tl_ops_web_alert_event()[type].call(this, data) : '';
    });

};

//事件监听定义
const tl_ops_web_alert_event = function () {
    return {
        add:  tl_ops_web_alert_add,
        edit : tl_ops_web_alert_edit,
        delete : tl_ops_web_alert_delete
    }
};

//表格cols
const tl_ops_web_alert_cols = function () {
    return [[
        {
            type:'checkbox',fixed : 'left', width: "5%"
        }, {
            field: 'id', title: 'ID',width:"5%"
        }, {
            field: 'time', title: '耗时阈值', width:"10%"
        }, {
            field: 'count', title: '触发次数',width:"10%"
        }, {
            field: 'interval', title: '周期时间',width:"10%"
        }, {
            field: 'mode', title: '告警模式',width:"15%"
        }, {
            field: 'target', title: '告警对象',width:"20%"
        }, {
            field: 'updatetime', title: '更新时间',width:"15%",
        }, {
            width: "10%",
            align: 'center',
            fixed: 'right',
            title: '操作',
            toolbar: '#tl-ops-web-alert-operate'
        }
    ]];
};


//表格render
const tl_ops_web_alert_render = function () {
    table.render(tl_ajax_data({
        elem: '#'+_table_id_name,
        url: '/tlops/alert/get',
        cols: tl_ops_web_alert_cols(),
        page:true,
        needReloadMsg : false,
        toolbar: '#tl-ops-web-alert-toolbar',
        defaultToolbar: ['filter', 'print', 'exports'],
        totalRow: true, //开启合计行
        parseData: function(res){
            if (res.code !== 0){
                return {
                    "code": res.code,
                    "msg": res.msg,
                    "count": 0,
                    "data": []
                };
            }
            res_data = res.data;
            let datas = res_data.tl_ops_plugin_time_alert_options;
            if (datas === undefined){ datas = []; }
            datas = datas.sort(function(a, b){return b.id - a.id})
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
const tl_ops_web_alert_reload = function (matcher) {
    table.render(tl_ajax_data({
        elem: '#'+_table_id_name,
        url: '/tlops/alert/get',
        where : matcher,
        cols: tl_ops_web_alert_cols(),
        page:true,
        needReloadMsg : false,
        toolbar: '#tl-ops-web-alert-toolbar',
        defaultToolbar: ['filter', 'print', 'exports'],
        totalRow: true, //开启合计行
        parseData: function(res){
            if (res.code !== 0){
                return {
                    "code": res.code,
                    "msg": res.msg,
                    "count": 0,
                    "data": []
                };
            }
            res_data = res.data;
            let datas = res_data.tl_ops_plugin_time_alert_options;
            if (datas === undefined){ datas = []; }
            datas = datas.sort(function(a, b){return b.id - a.id})
            return {
                "code": res.code,
                "msg": res.msg,
                "count": datas.length,
                "data": datas
            };
        }
    }));
};


//删除alert
const tl_ops_web_alert_delete = function () {
    let checkStatus = table.checkStatus(_table_id_name)
        ,checkData = checkStatus.data; //得到选中的数据

    if(checkData.length === 0){
       layer.msg('请选删除择数据');
       return;
    }

    let idList = [];
    for(let i = 0; i < checkData.length; i++){
        idList.push(checkData[i].id);
    }

    let new_list = res_data.tl_ops_plugin_time_alert_options.filter(item=>{
        return !idList.includes(item.id);
    })

    res_data.tl_ops_plugin_time_alert_options = new_list;

    $.ajax(tl_ajax_data({
        url: '/tlops/alert/set',
        data : JSON.stringify(res_data),
        contentType : "application/json",
        success : (res)=>{
            tl_ops_web_alert_reload()
        }
    }));
}


//添加
const tl_ops_web_alert_add = function () {
    let index = layer.open({
        type: 2
        ,title: '添加自定义告警配置'
        ,content: 'tl_ops_web_alert_form.html'
        ,maxmin: true
        ,minStack:false
        ,area: ['700px', '600px']
        ,btn: ['确定', '取消']
        ,yes: function(sub_index, layero){
            let iframeWindow = window['layui-layer-iframe'+ sub_index]
                ,submit = layero.find('iframe').contents().find('#'+ _add_form_btn_id_name);

            iframeWindow.layui.form.on('submit('+ _add_form_btn_id_name +')', function(data){
                if(!tl_ops_alert_data_add_filter(data)){
                    return;
                }
                $.ajax(tl_ajax_data({
                    url: '/tlops/alert/set',
                    data : JSON.stringify(res_data),
                    contentType : "application/json",
                    success : (res)=>{
                        tl_ops_web_alert_reload()
                    }
                }));
                layer.close(sub_index);
            });
            submit.trigger('click');
        }
    });
    layer.full(index)
};


//编辑
const tl_ops_web_alert_edit = function (evtdata) {
    let index = layer.open({
        type: 2
        ,title: '编辑告警自定义配置'
        ,content: 'tl_ops_web_alert_form.html'
        ,maxmin: true
        ,minStack:false
        ,area: ['700px', '600px']
        ,btn: ['确定', '取消']
        ,yes: function(sub_index, dom){
            let iframeWindow = window['layui-layer-iframe'+ sub_index]
                ,submit = dom.find('iframe').contents().find('#'+ _add_form_btn_id_name);
            iframeWindow.layui.form.on('submit('+ _add_form_btn_id_name +')', function(data){
                if(!tl_ops_alert_data_edit_filter(data)){
                    return;
                }
                $.ajax(tl_ajax_data({
                    url: '/tlops/alert/set',
                    data : JSON.stringify(res_data),
                    contentType : "application/json",
                    success : (res)=>{
                        tl_ops_web_alert_reload()
                    }
                }));
                layer.close(sub_index);
            });
            submit.trigger('click');
        },
        success: function(dom, index) {
            let editForm = dom.find('iframe')[0].contentWindow;
            editForm.tl_ops_web_alert_form_render(evtdata);
        },
    });
    layer.full(index)
};


//过滤新增数据
const tl_ops_alert_data_add_filter = function( data ) {
    delete data.field.file;
    for(let key in data.field){
        if(key === 'id'){
            continue;
        }
        if(data.field[key] === undefined || data.field[key] === null || data.field[key] === ''){
            layer.msg(key + "未填写")
            return false;
        }
        if(key === 'time' || key === 'count' || key === 'interval'){
            data.field[key] = parseInt(data.field[key])
        }
    }
    res_data.tl_ops_plugin_time_alert_options.push(data.field)

    res_data.tl_ops_plugin_time_alert_options.forEach(item=>{
        if( item.LAY_TABLE_INDEX !== undefined){
            delete item.LAY_TABLE_INDEX
        }
    })

    return true
}


//过滤编辑数据
const tl_ops_alert_data_edit_filter = function( data ) {
    delete data.field.file;
    for(let key in data.field){
        if(data.field[key] === undefined || data.field[key] === null || data.field[key] === ''){
            layer.msg(key + "未填写")
            return false;
        }
    }
    let cur_list = []
    res_data.tl_ops_plugin_time_alert_options.forEach((item)=>{
        if(parseInt(item.id) === parseInt(data.field.id)){
            data.field.change = true;
            item = data.field;
        }
        cur_list.push(item)
    })
    res_data.tl_ops_plugin_time_alert_options = cur_list;

    res_data.tl_ops_plugin_time_alert_options.forEach(item=>{
        if( item.LAY_TABLE_INDEX !== undefined){
            delete item.LAY_TABLE_INDEX
        }
    })

    return true
}