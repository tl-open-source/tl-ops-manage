const _table_id_name = "tl-ops-web-api-table";
const _search_id_name = "tl-ops-web-api-search";
const _add_form_btn_id_name = "tl-ops-web-api-form-submit";
const _add_form_id_name = "tl-ops-web-api-form";
let rule = '';
let res_data = {};

const tl_ops_web_api_main = function (){
    window.$ = layui.$;
    window.form = layui.form;
    window.table = layui.table;
    window.layedit = layui.layedit;

    axios.get("/tlops/api/list").then((res)=>{
        res = res.data;
        if(res.code === 0){
            rule = res.data.tl_ops_api_rule;
            //渲染
            tl_ops_web_api_render();

            $('#tl-ops-web-api-cur-rule')[0].innerHTML = `<b style='color:red;font-size:16px;cursor: pointer;' class="layui-badge layui-bg-red" 
                id="tl-api-rule" onmouseleave="tl_mouse_leave_tips()"
                onmouseenter="tl_mouse_enter_tips('tl-api-rule','修改tl_ops_constant_balance.lua配置可调整策略')">
                ${rule}
            </b><b> ( ${rule==='random' ? '随机NODE路由' : '指定NODE路由'} )</b>`;

            //表格外部事件操作
            $('.layui-btn.layuiadmin-btn-useradmin').on('click', function(){
                let type = $(this).data('type');
                tl_ops_web_api_event()[type] ? tl_ops_web_api_event()[type].call(this) : '';
            });

            //搜索
            form.on('submit('+_search_id_name+')', function(data){
                tl_ops_web_api_reload(data.field);
            });

            //行事件操作
            table.on('tool('+_table_id_name+')', function(obj) {
                let type = obj.event;
                let data = obj.data;
                tl_ops_web_api_event()[type] ? tl_ops_web_api_event()[type].call(this, data) : '';
            });
        }
    })
};

//事件监听定义
const tl_ops_web_api_event = function () {
    return {
        add:  tl_ops_web_api_add,
        edit : tl_ops_web_api_edit,
    }
};

//表格cols -- url策略
const tl_ops_web_api_url_cols = function () {
    return [[
        {
            field: 'id', title: 'ID',width:"15%"
        }, {
            field: 'url', title: '请求的API', width:"30%"
        },  {
            field: 'service', title: '路由的SERVICE名称',width:"15%"
        },  {
            field: 'node', title: '具体的NODE索引',width:"15%"
        },  {
            field: 'updatetime', title: '更新时间',width:"15%",
        }, {
            width: "10%",
            align: 'center',
            fixed: 'right',
            title: '操作',
            toolbar: '#tl-ops-web-api-operate'
        }
    ]];
};

//表格cols -- random策略
const tl_ops_web_api_random_cols = function () {
    return [[
        {
            field: 'id', title: 'ID', width:"15%"
        }, {
            field: 'url', title: '请求的API', width:"30%"
        },  {
            field: 'service', title: '路由的SERVICE',width:"25%"
        },  {
            field: 'updatetime', title: '更新时间',width:"20%",
        }, {
            width: "10%",
            align: 'center',
            fixed: 'right',
            title: '操作',
            toolbar: '#tl-ops-web-api-operate'
        }
    ]];
};

//表格render
const tl_ops_web_api_render = function () {
    table.render(tl_ajax_data({
        elem: '#'+_table_id_name,
        url: '/tlops/api/list',
        cols: rule === 'random' ? tl_ops_web_api_random_cols() : tl_ops_web_api_url_cols(),
        page:true,
        needReloadMsg : false,
        toolbar: '#tl-ops-web-api-toolbar',
        defaultToolbar: ['filter', 'print', 'exports'],
        totalRow: true, //开启合计行
        parseData: function(res){
            res_data = res.data;
            return {
                "code": res.code,
                "msg": res.msg,
                "count": res.data.tl_ops_api_list[rule].length,
                "data": res.data.tl_ops_api_list[rule]
            };
        }
    }));
};

//表格reload
const tl_ops_web_api_reload = function (matcher) {
    table.render(tl_ajax_data({
        elem: '#'+_table_id_name,
        url: '/tlops/api/list',
        where : matcher,
        cols: rule === 'random' ? tl_ops_web_api_random_cols() : tl_ops_web_api_url_cols(),
        page:true,
        needReloadMsg : false,
        toolbar: '#tl-ops-web-api-toolbar',
        defaultToolbar: ['filter', 'print', 'exports'],
        totalRow: true, //开启合计行
        parseData: function(res){
            res_data = res.data;
            return {
                "code": res.code,
                "msg": res.msg,
                "count": res.data.tl_ops_api_list[rule].length,
                "data": res.data.tl_ops_api_list[rule]
            };
        }
    }));
};


//添加
const tl_ops_web_api_add = function () {
    layer.open({
        type: 2
        ,title: '添加自定义API路由'
        ,content: 'tl_ops_web_api_form.html?rule='+rule
        ,maxmin: true
        ,minStack:false
        ,area: ['700px', '600px']
        ,btn: ['确定', '取消']
        ,yes: function(index, layero){
            let iframeWindow = window['layui-layer-iframe'+ index]
                ,submit = layero.find('iframe').contents().find('#'+ _add_form_btn_id_name);

            iframeWindow.layui.form.on('submit('+ _add_form_btn_id_name +')', function(data){
                if(!tl_ops_api_data_add_filter(data)){
                    return;
                }
                $.ajax(tl_ajax_data({
                    url: '/tlops/api/set',
                    data : JSON.stringify(res_data),
                    contentType : "application/json",
                    success : (res)=>{
                        tl_ops_web_api_reload()
                    }
                }));
                layer.close(index);
            });
            submit.trigger('click');
        }
    });
};


//编辑
const tl_ops_web_api_edit = function (evtdata) {
    layer.open({
        type: 2
        ,title: '编辑API自定义配置'
        ,content: 'tl_ops_web_api_form.html?rule='+rule+"&service="+evtdata.service+"&node="+evtdata.node
        ,maxmin: true
        ,minStack:false
        ,area: ['700px', '600px']
        ,btn: ['确定', '取消']
        ,yes: function(index, dom){
            let iframeWindow = window['layui-layer-iframe'+ index]
                ,submit = dom.find('iframe').contents().find('#'+ _add_form_btn_id_name);
            iframeWindow.layui.form.on('submit('+ _add_form_btn_id_name +')', function(data){
                if(!tl_ops_api_data_edit_filter(data)){
                    return;
                }
                $.ajax(tl_ajax_data({
                    url: '/tlops/api/set',
                    data : JSON.stringify(res_data),
                    contentType : "application/json",
                    success : (res)=>{
                        tl_ops_web_api_reload()
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
const tl_ops_api_data_add_filter = function( data ) {
    console.log(data, rule)
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
    }
    res_data.tl_ops_api_list[rule].push(data.field)

    return true
}


//过滤编辑数据
const tl_ops_api_data_edit_filter = function( data ) {
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
    }
    let cur_list = []
    res_data.tl_ops_api_list[rule].forEach((item)=>{
        if(item.id === data.field.id){
            item = data.field;
        }
        cur_list.push(item)
    })
    res_data.tl_ops_api_list[rule] = cur_list;

    return true
}