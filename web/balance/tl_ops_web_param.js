const _table_id_name = "tl-ops-web-param-table";
const _search_id_name = "tl-ops-web-param-search";
const _add_form_btn_id_name = "tl-ops-web-param-form-submit";
const _add_form_id_name = "tl-ops-web-param-form";
let rule = '';
let res_data = {};

const tl_ops_web_param_main = function (){
    window.$ = layui.$;
    window.form = layui.form;
    window.table = layui.table;
    window.layedit = layui.layedit;

    tl_ops_web_param_render();

    //表格外部事件操作
    $('.layui-btn.layuiadmin-btn-useradmin').on('click', function(){
        let type = $(this).data('type');
        tl_ops_web_param_event()[type] ? tl_ops_web_param_event()[type].call(this) : '';
    });

    //搜索
    form.on('submit('+_search_id_name+')', function(data){
        tl_ops_web_param_reload(data.field);
    });

    //行事件操作
    table.on('tool('+_table_id_name+')', function(obj) {
        let type = obj.event;
        let data = obj.data;
        tl_ops_web_param_event()[type] ? tl_ops_web_param_event()[type].call(this, data) : '';
    });

};

//事件监听定义
const tl_ops_web_param_event = function () {
    return {
        add:  tl_ops_web_param_add,
        edit : tl_ops_web_param_edit,
        delete : tl_ops_web_param_delete
    }
};

//表格cols -- point策略
const tl_ops_web_param_point_cols = function () {
    return [[
        {
            type:'checkbox',fixed : 'left', width: "5%"
        }, {
            field: 'id', title: 'ID',width:"10%"
        },  {
            field: 'host', title: '域名',width:"15%"
        }, {
            field: 'key', title: '请求参数键', width:"10%"
        }, {
            field: 'value', title: '请求参数值', width:"10%"
        }, {
            field: 'service', title: '所属服务',width:"15%"
        }, {
            field: 'node', title: '节点索引',width:"10%"
        }, {
            field: 'updatetime', title: '更新时间',width:"15%",
        }, {
            width: "10%",
            align: 'center',
            fixed: 'right',
            title: '操作',
            toolbar: '#tl-ops-web-param-operate'
        }
    ]];
};

//表格cols -- random策略
const tl_ops_web_param_random_cols = function () {
    return [[
        {
            type:'checkbox',fixed : 'left', width: "5%"
        }, {
            field: 'id', title: 'ID', width:"10%"
        }, {
            field: 'host', title: '域名',width:"15%"
        }, {
            field: 'key', title: '请求参数键', width:"10%"
        }, {
            field: 'value', title: '请求参数值', width:"10%"
        }, {
            field: 'service', title: '所属服务',width:"15%"
        },  {
            field: 'updatetime', title: '更新时间',width:"20%",
        }, {
            width: "15%",
            align: 'center',
            fixed: 'right',
            title: '操作',
            toolbar: '#tl-ops-web-param-operate'
        }
    ]];
};

//表格render
const tl_ops_web_param_render = function () {
    table.render(tl_ajax_data({
        elem: '#'+_table_id_name,
        url: '/tlops/balance/param/list',
        cols: rule === 'random' ? tl_ops_web_param_random_cols() : tl_ops_web_param_point_cols(),
        page:true,
        needReloadMsg : false,
        toolbar: '#tl-ops-web-param-toolbar',
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
            rule = res_data.tl_ops_balance_param_rule
            let datas = res_data.tl_ops_balance_param_list[rule];
            if (datas === undefined){ datas = []; }
            datas = datas.sort(function(a, b){return b.id - a.id})

            $('#tl-ops-web-param-cur-rule')[0].innerHTML = `<b style='color:red;font-size:16px;cursor: pointer;' class="layui-badge layui-bg-red" 
                id="tl-param-rule" onmouseleave="tl_mouse_leave_tips()" onclick="tl_ops_web_param_change_rule()" 
                onmouseenter="tl_mouse_enter_tips('tl-param-rule','点击切换策略，切换将实时生效')">
                ${rule}
            </b><b> ( ${rule==='random' ? '随机节点路由' : '指定节点路由'} )</b>`;

            return {
                "code": res.code,
                "msg": res.msg,
                "count": res.data.tl_ops_balance_param_list[rule].length,
                "data": res.data.tl_ops_balance_param_list[rule]
            };
        }
    }));
};

//表格reload
const tl_ops_web_param_reload = function (matcher) {
    table.render(tl_ajax_data({
        elem: '#'+_table_id_name,
        url: '/tlops/balance/param/list',
        where : matcher,
        cols: rule === 'random' ? tl_ops_web_param_random_cols() : tl_ops_web_param_point_cols(),
        page:true,
        needReloadMsg : false,
        toolbar: '#tl-ops-web-param-toolbar',
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
            rule = res_data.tl_ops_balance_param_rule;
            let datas = res_data.tl_ops_balance_param_list[rule];
            if (datas === undefined){ datas = []; }
            datas = datas.sort(function(a, b){return b.id - a.id})
            
            $('#tl-ops-web-param-cur-rule')[0].innerHTML = `<b style='color:red;font-size:16px;cursor: pointer;' class="layui-badge layui-bg-red" 
                id="tl-param-rule" onmouseleave="tl_mouse_leave_tips()" onclick="tl_ops_web_param_change_rule()" 
                onmouseenter="tl_mouse_enter_tips('tl-param-rule','点击切换策略，切换将实时生效')">
                ${rule}
            </b><b> ( ${rule==='random' ? '随机节点路由' : '指定节点路由'} )</b>`;
            return {
                "code": res.code,
                "msg": res.msg,
                "count": res.data.tl_ops_balance_param_list[rule].length,
                "data": res.data.tl_ops_balance_param_list[rule]
            };
        }
    }));
};

//删除param路由
const tl_ops_web_param_delete = function () {
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

    let new_list = res_data.tl_ops_balance_param_list[rule].filter(item=>{
        return !idList.includes(item.id);
    })

    res_data.tl_ops_balance_param_list[rule] = new_list;

    $.ajax(tl_ajax_data({
        url: '/tlops/balance/param/set',
        data : JSON.stringify(res_data),
        contentType : "application/json",
        success : (res)=>{
            tl_ops_web_param_reload()
        }
    }));
}


//更新param路由策略
const tl_ops_web_param_change_rule = function () {
    if(rule === undefined || rule === ''){
        layer.msg("路由策略有误，刷新页面重试")
        return;
    }

    if(rule === 'point'){
        rule = 'random';
    }else if(rule === 'random'){
        rule = 'point';
    }

    res_data.tl_ops_balance_param_rule = rule;

    $.ajax(tl_ajax_data({
        url: '/tlops/balance/param/set',
        data : JSON.stringify(res_data),
        contentType : "application/json",
        success : (res)=>{
            tl_ops_web_param_reload()
        }
    }));
}


//添加
const tl_ops_web_param_add = function () {
    layer.open({
        type: 2
        ,title: '添加自定义请求参数路由'
        ,content: 'tl_ops_web_param_form.html?rule='+rule
        ,maxmin: true
        ,minStack:false
        ,area: ['700px', '600px']
        ,btn: ['确定', '取消']
        ,yes: function(index, layero){
            let iframeWindow = window['layui-layer-iframe'+ index]
                ,submit = layero.find('iframe').contents().find('#'+ _add_form_btn_id_name);

            iframeWindow.layui.form.on('submit('+ _add_form_btn_id_name +')', function(data){
                if(!tl_ops_param_data_add_filter(data)){
                    return;
                }
                $.ajax(tl_ajax_data({
                    url: '/tlops/balance/param/set',
                    data : JSON.stringify(res_data),
                    contentType : "application/json",
                    success : (res)=>{
                        tl_ops_web_param_reload()
                    }
                }));
                layer.close(index);
            });
            submit.trigger('click');
        }
    });
};


//编辑
const tl_ops_web_param_edit = function (evtdata) {
    layer.open({
        type: 2
        ,title: '编辑请求参数自定义配置'
        ,content: 'tl_ops_web_param_form.html?rule='+rule+"&service="+evtdata.service+"&node="+evtdata.node
        ,maxmin: true
        ,minStack:false
        ,area: ['700px', '600px']
        ,btn: ['确定', '取消']
        ,yes: function(index, dom){
            let iframeWindow = window['layui-layer-iframe'+ index]
                ,submit = dom.find('iframe').contents().find('#'+ _add_form_btn_id_name);
            iframeWindow.layui.form.on('submit('+ _add_form_btn_id_name +')', function(data){
                if(!tl_ops_param_data_edit_filter(data)){
                    return;
                }
                $.ajax(tl_ajax_data({
                    url: '/tlops/balance/param/set',
                    data : JSON.stringify(res_data),
                    contentType : "application/json",
                    success : (res)=>{
                        tl_ops_web_param_reload()
                    }
                }));
                layer.close(index);
            });
            submit.trigger('click');
        },
        success: function(dom, index) {
            //通过索引获取到当前iframe弹出层
            let editForm = dom.find('iframe').contents().find('#'+ _add_form_id_name);

            for (let key in evtdata){
                editForm.find('#'+key).val(evtdata[key])
            }
        },
    });
};


//过滤新增数据
const tl_ops_param_data_add_filter = function( data ) {
    if(rule === 'random'){
        delete data.field.node
    }
    for(let key in data.field){
        if(key === 'id'){
            continue;
        }
        if(data.field[key] === undefined || data.field[key] === null || data.field[key] === ''){
            layer.msg(key + "未填写")
            return false;
        }
        if(key === 'node'){
            data.field[key] = parseInt(data.field[key])   
        }
        if(key === 'value'){
            let valueList = data.field[key].split(",");
            if(valueList.length > 50){
                layer.msg("请求参数值定义过多，最多50个")
                return false
            }
            data.field[key] = valueList
        }
    }

    for(let i = 0; i < res_data.tl_ops_balance_param_list[rule].length; i++){
        let obj = res_data.tl_ops_balance_param_list[rule][i];
        if (obj.key === data.field.key && obj.value === data.field.value && obj.id !== data.field.id){
            layer.msg("请求参数键值对 “"+obj.key+"” 已存在")
            return false;
        }
    }

    res_data.tl_ops_balance_param_list[rule].push(data.field)

    res_data.tl_ops_balance_param_list[rule].forEach(item=>{
        if( item.LAY_TABLE_INDEX !== undefined){
            delete item.LAY_TABLE_INDEX
        }
    })

    return true
}


//过滤编辑数据
const tl_ops_param_data_edit_filter = function( data ) {
    if(rule === 'random'){
        delete data.field.node
    }
    for(let key in data.field){
        if(data.field[key] === undefined || data.field[key] === null || data.field[key] === ''){
            layer.msg(key + "未填写")
            return false;
        }
        if(key === 'node'){
            data.field[key] = parseInt(data.field[key])   
        }
        if(key === 'value'){
            let valueList = data.field[key].split(",");
            if(valueList.length > 50){
                layer.msg("请求参数值定义过多，最多50个")
                return false
            }
            data.field[key] = valueList
        }
    }
    let cur_list = []
    res_data.tl_ops_balance_param_list[rule].forEach((item)=>{
        if(parseInt(item.id) === parseInt(data.field.id)){
            data.field.change = true;
            item = data.field;
        }
        cur_list.push(item)
    })

    for(let i = 0; i < res_data.tl_ops_balance_param_list[rule].length; i++){
        let obj = res_data.tl_ops_balance_param_list[rule][i];
        if (obj.key === data.field.key && obj.value === data.field.value && obj.id !== data.field.id){
            layer.msg("请求参数键值对 “"+obj.key+"” 已存在")
            return false;
        }
    }

    res_data.tl_ops_balance_param_list[rule] = cur_list;

    res_data.tl_ops_balance_param_list[rule].forEach(item=>{
        if( item.LAY_TABLE_INDEX !== undefined){
            delete item.LAY_TABLE_INDEX
        }
    })

    return true
}