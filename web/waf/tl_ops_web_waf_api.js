const _table_id_name = "tl-ops-web-waf-api-table";
const _search_id_name = "tl-ops-web-waf-api-search";
const _add_form_btn_id_name = "tl-ops-web-waf-api-form-submit";
const _add_form_id_name = "tl-ops-web-waf-api-form";
let res_data = {};

const tl_ops_web_waf_api_main = function (){
    window.$ = layui.$;
    window.form = layui.form;
    window.table = layui.table;
    window.layedit = layui.layedit;

    tl_ops_web_waf_api_render();

    //表格外部事件操作
    $('.layui-btn.layuiadmin-btn-useradmin').on('click', function(){
        let type = $(this).data('type');
        tl_ops_web_waf_api_event()[type] ? tl_ops_web_waf_api_event()[type].call(this) : '';
    });

    //搜索
    form.on('submit('+_search_id_name+')', function(data){
        tl_ops_web_waf_api_reload(data.field);
    });

    //行事件操作
    table.on('tool('+_table_id_name+')', function(obj) {
        let type = obj.event;
        let data = obj.data;
        tl_ops_web_waf_api_event()[type] ? tl_ops_web_waf_api_event()[type].call(this, data) : '';
    });

};

//事件监听定义
const tl_ops_web_waf_api_event = function () {
    return {
        add:  tl_ops_web_waf_api_add,
        edit : tl_ops_web_waf_api_edit,
        delete : tl_ops_web_waf_api_delete
    }
};

//表格cols
const tl_ops_web_waf_api_cols = function () {
    return [[
        {
            type:'checkbox',fixed : 'left', width: "5%"
        }, {
            field: 'id', title: 'ID',width:"10%"
        }, {
            field: 'host', title: '域名',width:"15%"
        }, {
            field: 'value', title: '正则过滤', width:"20%"
        }, {
            field: 'service', title: '所属服务',width:"15%"
        }, {
            field: 'white', title: '白名单',width:"10%"
        }, {
            field: 'updatetime', title: '更新时间',width:"15%",
        }, {
            width: "10%",
            align: 'center',
            fixed: 'right',
            title: '操作',
            toolbar: '#tl-ops-web-waf-api-operate'
        }
    ]];
};

//表格render
const tl_ops_web_waf_api_render = function () {
    table.render(tl_ajax_data({
        elem: '#'+_table_id_name,
        url: '/tlops/waf/api/list',
        cols: tl_ops_web_waf_api_cols(),
        page:true,
        needReloadMsg : false,
        toolbar: '#tl-ops-web-waf-api-toolbar',
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
            let datas = res_data.tl_ops_waf_api_list;
            let scope = res_data.tl_ops_waf_api_scope;
            if (datas === undefined){ datas = []; }
            datas = datas.sort(function(a, b){return b.id - a.id})

            $('#tl-ops-web-waf-api-cur-scope')[0].innerHTML = `<b style='color:red;font-size:16px;cursor: pointer;' class="layui-badge layui-bg-red" 
                id="tl-waf-api-scope" onmouseleave="tl_mouse_leave_tips()" onclick="tl_ops_web_waf_api_change_scope()" 
                onmouseenter="tl_mouse_enter_tips('tl-waf-api-scope','点击切换作用域，切换将实时生效')">
                ${scope}
            </b><b> ( ${scope === 'global' ? '全局级别WAF' : '服务级别WAF'} )</b>`;

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
const tl_ops_web_waf_api_reload = function (matcher) {
    table.render(tl_ajax_data({
        elem: '#'+_table_id_name,
        url: '/tlops/waf/api/list',
        where : matcher,
        cols: tl_ops_web_waf_api_cols(),
        page:true,
        needReloadMsg : false,
        toolbar: '#tl-ops-web-waf-api-toolbar',
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
            let datas = res_data.tl_ops_waf_api_list;
            let scope = res_data.tl_ops_waf_api_scope;
            if (datas === undefined){ datas = []; }
            datas = datas.sort(function(a, b){return b.id - a.id})

            $('#tl-ops-web-waf-api-cur-scope')[0].innerHTML = `<b style='color:red;font-size:16px;cursor: pointer;' class="layui-badge layui-bg-red" 
                id="tl-waf-api-scope" onmouseleave="tl_mouse_leave_tips()" onclick="tl_ops_web_waf_api_change_scope()" 
                onmouseenter="tl_mouse_enter_tips('tl-waf-api-scope','点击切换策略，切换将实时生效')">
                ${scope}
            </b><b> ( ${scope === 'global' ? '全局级别WAF' : '服务级别WAF'} )</b>`;
            
            return {
                "code": res.code,
                "msg": res.msg,
                "count": datas.length,
                "data": datas
            };
        }
    }));
};


//删除api路由
const tl_ops_web_waf_api_delete = function () {
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

    let new_list = res_data.tl_ops_waf_api_list.filter(item=>{
        return !idList.includes(item.id);
    })

    res_data.tl_ops_waf_api_list = new_list;

    $.ajax(tl_ajax_data({
        url: '/tlops/waf/api/set',
        data : JSON.stringify(res_data),
        contentType : "application/json",
        success : (res)=>{
            tl_ops_web_waf_api_reload()
        }
    }));
}


//更新api作用域
const tl_ops_web_waf_api_change_scope = function () {
    let scope = res_data.tl_ops_waf_api_scope;

    if(scope === undefined || scope === ''){
        layer.msg("WAF作用域有误，刷新页面重试")
        return;
    }

    if(scope === 'global'){
        scope = 'service';
    }else if(scope === 'service'){
        scope = 'global';
    }

    res_data.tl_ops_waf_api_scope = scope;

    $.ajax(tl_ajax_data({
        url: '/tlops/waf/api/set',
        data : JSON.stringify(res_data),
        contentType : "application/json",
        success : (res)=>{
            tl_ops_web_waf_api_reload()
        }
    }));
}


//添加
const tl_ops_web_waf_api_add = function () {
    layer.open({
        type: 2
        ,title: '添加自定义API-WAF规则'
        ,content: 'tl_ops_web_waf_api_form.html'
        ,maxmin: true
        ,minStack:false
        ,area: ['700px', '600px']
        ,btn: ['确定', '取消']
        ,yes: function(index, layero){
            let iframeWindow = window['layui-layer-iframe'+ index]
                ,submit = layero.find('iframe').contents().find('#'+ _add_form_btn_id_name);

            iframeWindow.layui.form.on('submit('+ _add_form_btn_id_name +')', function(data){
                if(!tl_ops_waf_api_data_add_filter(data)){
                    return;
                }
                $.ajax(tl_ajax_data({
                    url: '/tlops/waf/api/set',
                    data : JSON.stringify(res_data),
                    contentType : "application/json",
                    success : (res)=>{
                        tl_ops_web_waf_api_reload()
                    }
                }));
                layer.close(index);
            });
            submit.trigger('click');
        }
    });
};


//编辑
const tl_ops_web_waf_api_edit = function (evtdata) {
    layer.open({
        type: 2
        ,title: '编辑API-WAF配置'
        ,content: 'tl_ops_web_waf_api_form.html?service='+evtdata.service+"&white="+evtdata.white+"&scope="+res_data.tl_ops_waf_api_scope
        ,maxmin: true
        ,minStack:false
        ,area: ['700px', '600px']
        ,btn: ['确定', '取消']
        ,yes: function(index, dom){
            let iframeWindow = window['layui-layer-iframe'+ index]
                ,submit = dom.find('iframe').contents().find('#'+ _add_form_btn_id_name);
            iframeWindow.layui.form.on('submit('+ _add_form_btn_id_name +')', function(data){
                if(!tl_ops_waf_api_data_edit_filter(data)){
                    return;
                }
                $.ajax(tl_ajax_data({
                    url: '/tlops/waf/api/set',
                    data : JSON.stringify(res_data),
                    contentType : "application/json",
                    success : (res)=>{
                        tl_ops_web_waf_api_reload()
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
const tl_ops_waf_api_data_add_filter = function( data ) {
    if( data.field['white'] === undefined || data.field['white'] === null){
        data.field['white'] = false
    }
    for(let key in data.field){
        if(key === 'id'){
            continue;
        }
        if(data.field[key] === undefined || data.field[key] === null || data.field[key] === ''){
            layer.msg(key + "未填写")
            return false;
        }
        if(key === 'white'){
            if(data.field[key] === 'true'){
                data.field[key] = true
            }else{
                data.field[key] = false
            }
        }
    }

    if (res_data.tl_ops_waf_api_open === 'true'){
        res_data.tl_ops_waf_api_open = true
    }

    if (res_data.tl_ops_waf_api_open === 'false'){
        res_data.tl_ops_waf_api_open = false
    }

    res_data.tl_ops_waf_api_list.push(data.field)

    res_data.tl_ops_waf_api_list.forEach(item=>{
        if( item.LAY_TABLE_INDEX !== undefined){
            delete item.LAY_TABLE_INDEX
        }
    })

    return true
}


//过滤编辑数据
const tl_ops_waf_api_data_edit_filter = function( data ) {
    if( data.field['white'] === undefined || data.field['white'] === null){
        data.field['white'] = false
    }
    for(let key in data.field){
        if(data.field[key] === undefined || data.field[key] === null || data.field[key] === ''){
            layer.msg(key + "未填写")
            return false;
        }
        if(key === 'white'){
            if(data.field[key] === 'true'){
                data.field[key] = true
            }else{
                data.field[key] = false
            }
        }
    }
    let cur_list = []
    res_data.tl_ops_waf_api_list.forEach((item)=>{
        if(parseInt(item.id) === parseInt(data.field.id)){
            data.field.change = true;
            item = data.field;
        }
        cur_list.push(item)
    })

    if (res_data.tl_ops_waf_api_open === 'true'){
        res_data.tl_ops_waf_api_open = true
    }

    if (res_data.tl_ops_waf_api_open === 'false'){
        res_data.tl_ops_waf_api_open = false
    }

    res_data.tl_ops_waf_api_list = cur_list;

    res_data.tl_ops_waf_api_list.forEach(item=>{
        if( item.LAY_TABLE_INDEX !== undefined){
            delete item.LAY_TABLE_INDEX
        }
    })

    return true
}