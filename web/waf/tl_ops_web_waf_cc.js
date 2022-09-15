const _table_id_name = "tl-ops-web-waf-cc-table";
const _search_id_name = "tl-ops-web-waf-cc-search";
const _add_form_btn_id_name = "tl-ops-web-waf-cc-form-submit";
const _add_form_id_name = "tl-ops-web-waf-cc-form";
let res_data = {};

const tl_ops_web_waf_cc_main = function (){
    window.$ = layui.$;
    window.form = layui.form;
    window.table = layui.table;
    window.layedit = layui.layedit;

    tl_ops_web_waf_cc_render();

    //事件操作
    $('.layui-btn.layuiadmin-btn-useradmin').on('click', function(){
        let type = $(this).data('type');
        tl_ops_web_waf_cc_event()[type] ? tl_ops_web_waf_cc_event()[type].call(this) : '';
    });

    //搜索
    form.on('submit('+_search_id_name+')', function(data){
        tl_ops_web_waf_cc_reload(data.field);
    });

    //行事件操作
    table.on('tool('+_table_id_name+')', function(obj) {
        let type = obj.event;
        let data = obj.data;
        tl_ops_web_waf_cc_event()[type] ? tl_ops_web_waf_cc_event()[type].call(this, data) : '';
    });

};

//事件监听定义
const tl_ops_web_waf_cc_event = function () {
    return {
        add:  tl_ops_web_waf_cc_add,
        edit : tl_ops_web_waf_cc_edit,
        delete : tl_ops_web_waf_cc_delete
    }
};

//表格cols
const tl_ops_web_waf_cc_cols = function () {
    return [[
        {
            type:'checkbox',fixed : 'left', width: "5%"
        }, {
            field: 'id', title: 'ID',width:"10%"
        }, {
            field: 'host', title: '域名',width:"15%"
        }, {
            field: 'time', title: '时间周期', width:"15%"
        }, {
            field: 'count', title: '触发次数', width:"15%"
        }, {
            field: 'service', title: '所属服务',width:"15%"
        }, {
            field: 'updatetime', title: '更新时间',width:"15%",
        }, {
            width: "10%",
            align: 'center',
            fixed: 'right',
            title: '操作',
            toolbar: '#tl-ops-web-waf-cc-operate'
        }
    ]];
};

//表格render
const tl_ops_web_waf_cc_render = function () {
    table.render(tl_ajax_data({
        elem: '#'+_table_id_name,
        url: '/tlops/waf/cc/list',
        cols: tl_ops_web_waf_cc_cols(),
        page:true,
        needReloadMsg : false,
        toolbar: '#tl-ops-web-waf-cc-toolbar',
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
            let datas = res_data.tl_ops_waf_cc_list;
            let scope = res_data.tl_ops_waf_cc_scope;
            if (datas === undefined){ datas = []; }
            datas = datas.sort(function(a, b){return b.id - a.id})

            $('#tl-ops-web-waf-cc-cur-scope')[0].innerHTML = `<b style='color:red;font-size:16px;cursor: pointer;' class="layui-badge layui-bg-red" 
                id="tl-waf-cc-scope" onmouseleave="tl_mouse_leave_tips()" onclick="tl_ops_web_waf_cc_change_scope()" 
                onmouseenter="tl_mouse_enter_tips('tl-waf-cc-scope','点击切换作用域，切换将实时生效')">
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
const tl_ops_web_waf_cc_reload = function (matcher) {
    table.render(tl_ajax_data({
        elem: '#'+_table_id_name,
        url: '/tlops/waf/cc/list',
        where : matcher,
        cols: tl_ops_web_waf_cc_cols(),
        page:true,
        needReloadMsg : false,
        toolbar: '#tl-ops-web-waf-cc-toolbar',
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
            let datas = res_data.tl_ops_waf_cc_list;
            let scope = res_data.tl_ops_waf_cc_scope;
            if (datas === undefined){ datas = []; }
            datas = datas.sort(function(a, b){return b.id - a.id})

            $('#tl-ops-web-waf-cc-cur-scope')[0].innerHTML = `<b style='color:red;font-size:16px;cursor: pointer;' class="layui-badge layui-bg-red" 
                id="tl-waf-cc-scope" onmouseleave="tl_mouse_leave_tips()" onclick="tl_ops_web_waf_cc_change_scope()" 
                onmouseenter="tl_mouse_enter_tips('tl-waf-cc-scope','点击切换策略，切换将实时生效')">
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


//删除cc路由
const tl_ops_web_waf_cc_delete = function () {
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

    let new_list = res_data.tl_ops_waf_cc_list.filter(item=>{
        return !idList.includes(item.id);
    })

    res_data.tl_ops_waf_cc_list = new_list;

    $.ajax(tl_ajax_data({
        url: '/tlops/waf/cc/set',
        data : JSON.stringify(res_data),
        contentType : "application/json",
        success : (res)=>{
            tl_ops_web_waf_cc_reload()
        }
    }));
}


//更新cc作用域
const tl_ops_web_waf_cc_change_scope = function () {
    let scope = res_data.tl_ops_waf_cc_scope;

    if(scope === undefined || scope === ''){
        layer.msg("WAF作用域有误，刷新页面重试")
        return;
    }

    if(scope === 'global'){
        scope = 'service';
    }else if(scope === 'service'){
        scope = 'global';
    }

    res_data.tl_ops_waf_cc_scope = scope;

    $.ajax(tl_ajax_data({
        url: '/tlops/waf/cc/set',
        data : JSON.stringify(res_data),
        contentType : "application/json",
        success : (res)=>{
            tl_ops_web_waf_cc_reload()
        }
    }));
}


//添加
const tl_ops_web_waf_cc_add = function () {
    layer.open({
        type: 2
        ,title: '添加自定义CC-WAF规则'
        ,content: 'tl_ops_web_waf_cc_form.html'
        ,maxmin: true
        ,minStack:false
        ,area: ['700px', '600px']
        ,btn: ['确定', '取消']
        ,yes: function(index, layero){
            let iframeWindow = window['layui-layer-iframe'+ index]
                ,submit = layero.find('iframe').contents().find('#'+ _add_form_btn_id_name);

            iframeWindow.layui.form.on('submit('+ _add_form_btn_id_name +')', function(data){
                if(!tl_ops_waf_cc_data_add_filter(data)){
                    return;
                }
                $.ajax(tl_ajax_data({
                    url: '/tlops/waf/cc/set',
                    data : JSON.stringify(res_data),
                    contentType : "application/json",
                    success : (res)=>{
                        tl_ops_web_waf_cc_reload()
                    }
                }));
                layer.close(index);
            });
            submit.trigger('click');
        }
    });
};


//编辑
const tl_ops_web_waf_cc_edit = function (evtdata) {
    layer.open({
        type: 2
        ,title: '编辑CC-WAF配置'
        ,content: 'tl_ops_web_waf_cc_form.html?service='+evtdata.service+"&scope="+res_data.tl_ops_waf_cc_scope
        ,maxmin: true
        ,minStack:false
        ,area: ['700px', '600px']
        ,btn: ['确定', '取消']
        ,yes: function(index, dom){
            let iframeWindow = window['layui-layer-iframe'+ index]
                ,submit = dom.find('iframe').contents().find('#'+ _add_form_btn_id_name);
            iframeWindow.layui.form.on('submit('+ _add_form_btn_id_name +')', function(data){
                if(!tl_ops_waf_cc_data_edit_filter(data)){
                    return;
                }
                $.ajax(tl_ajax_data({
                    url: '/tlops/waf/cc/set',
                    data : JSON.stringify(res_data),
                    contentType : "application/json",
                    success : (res)=>{
                        tl_ops_web_waf_cc_reload()
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
const tl_ops_waf_cc_data_add_filter = function( data ) {
    for(let key in data.field){
        if(key === 'id'){
            continue;
        }
        if(data.field[key] === undefined || data.field[key] === null || data.field[key] === ''){
            layer.msg(key + "未填写")
            return false;
        }
        if(key === 'time' || key === 'count'){
            data.field[key] = parseInt(data.field[key])   
        }
    }

    if (res_data.tl_ops_waf_cc_open === 'true'){
        res_data.tl_ops_waf_cc_open = true
    }

    if (res_data.tl_ops_waf_cc_open === 'false'){
        res_data.tl_ops_waf_cc_open = false
    }

    res_data.tl_ops_waf_cc_list.push(data.field)

    res_data.tl_ops_waf_cc_list.forEach(item=>{
        if( item.LAY_TABLE_INDEX !== undefined){
            delete item.LAY_TABLE_INDEX
        }
    })

    return true
}


//过滤编辑数据
const tl_ops_waf_cc_data_edit_filter = function( data ) {
    for(let key in data.field){
        if(data.field[key] === undefined || data.field[key] === null || data.field[key] === ''){
            layer.msg(key + "未填写")
            return false;
        }
        if(key === 'time' || key === 'count'){
            data.field[key] = parseInt(data.field[key])   
        }
    }
    let cur_list = []
    res_data.tl_ops_waf_cc_list.forEach((item)=>{
        if(parseInt(item.id) === parseInt(data.field.id)){
            data.field.change = true;
            item = data.field;
        }
        cur_list.push(item)
    })

    if (res_data.tl_ops_waf_cc_open === 'true'){
        res_data.tl_ops_waf_cc_open = true
    }

    if (res_data.tl_ops_waf_cc_open === 'false'){
        res_data.tl_ops_waf_cc_open = false
    }

    res_data.tl_ops_waf_cc_list = cur_list;

    res_data.tl_ops_waf_cc_list.forEach(item=>{
        if( item.LAY_TABLE_INDEX !== undefined){
            delete item.LAY_TABLE_INDEX
        }
    })

    return true
}