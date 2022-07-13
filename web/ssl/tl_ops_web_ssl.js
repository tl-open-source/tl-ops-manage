const _table_id_name = "tl-ops-web-ssl-table";
const _search_id_name = "tl-ops-web-ssl-search";
const _add_form_btn_id_name = "tl-ops-web-ssl-form-submit";
const _add_form_id_name = "tl-ops-web-ssl-form";
let res_data = {};

const tl_ops_web_ssl_main = function (){
    window.$ = layui.$;
    window.form = layui.form;
    window.table = layui.table;
    window.layedit = layui.layedit;

    tl_ops_web_ssl_render();

    //表格外部事件操作
    $('.layui-btn.layuiadmin-btn-useradmin').on('click', function(){
        let type = $(this).data('type');
        tl_ops_web_ssl_event()[type] ? tl_ops_web_ssl_event()[type].call(this) : '';
    });

    //搜索
    form.on('submit('+_search_id_name+')', function(data){
        tl_ops_web_ssl_reload(data.field);
    });

    //行事件操作
    table.on('tool('+_table_id_name+')', function(obj) {
        let type = obj.event;
        let data = obj.data;
        tl_ops_web_ssl_event()[type] ? tl_ops_web_ssl_event()[type].call(this, data) : '';
    });

};

//事件监听定义
const tl_ops_web_ssl_event = function () {
    return {
        add:  tl_ops_web_ssl_add,
        edit : tl_ops_web_ssl_edit,
        delete : tl_ops_web_ssl_delete
    }
};

//表格cols
const tl_ops_web_ssl_cols = function () {
    return [[
        {
            type:'checkbox',fixed : 'left', width: "5%"
        }, {
            field: 'id', title: 'ID',width:"10%"
        }, {
            field: 'host', title: '域名',width:"20%"
        }, {
            field: 'pem', title: '证书', width:"20%"
        }, {
            field: 'key', title: '私钥',width:"20%"
        }, {
            field: 'updatetime', title: '更新时间',width:"15%",
        }, {
            width: "10%",
            align: 'center',
            fixed: 'right',
            title: '操作',
            toolbar: '#tl-ops-web-ssl-operate'
        }
    ]];
};


//表格render
const tl_ops_web_ssl_render = function () {
    table.render(tl_ajax_data({
        elem: '#'+_table_id_name,
        url: '/tlops/ssl/list',
        cols: tl_ops_web_ssl_cols(),
        page:true,
        needReloadMsg : false,
        toolbar: '#tl-ops-web-ssl-toolbar',
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
            let datas = res_data.tl_ops_ssl_list;
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
const tl_ops_web_ssl_reload = function (matcher) {
    table.render(tl_ajax_data({
        elem: '#'+_table_id_name,
        url: '/tlops/ssl/list',
        where : matcher,
        cols: tl_ops_web_ssl_cols(),
        page:true,
        needReloadMsg : false,
        toolbar: '#tl-ops-web-ssl-toolbar',
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
            let datas = res_data.tl_ops_ssl_list;
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


//删除ssl
const tl_ops_web_ssl_delete = function () {
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

    let new_list = res_data.tl_ops_ssl_list.filter(item=>{
        return !idList.includes(item.id);
    })

    res_data.tl_ops_ssl_list = new_list;

    $.ajax(tl_ajax_data({
        url: '/tlops/ssl/set',
        data : JSON.stringify(res_data),
        contentType : "application/json",
        success : (res)=>{
            tl_ops_web_ssl_reload()
        }
    }));
}


//添加
const tl_ops_web_ssl_add = function () {
    let index = layer.open({
        type: 2
        ,title: '添加自定义ssl配置'
        ,content: 'tl_ops_web_ssl_form.html'
        ,maxmin: true
        ,minStack:false
        ,area: ['700px', '600px']
        ,btn: ['确定', '取消']
        ,yes: function(sub_index, layero){
            let iframeWindow = window['layui-layer-iframe'+ sub_index]
                ,submit = layero.find('iframe').contents().find('#'+ _add_form_btn_id_name);

            iframeWindow.layui.form.on('submit('+ _add_form_btn_id_name +')', function(data){
                if(!tl_ops_ssl_data_add_filter(data)){
                    return;
                }
                $.ajax(tl_ajax_data({
                    url: '/tlops/ssl/set',
                    data : JSON.stringify(res_data),
                    contentType : "application/json",
                    success : (res)=>{
                        tl_ops_web_ssl_reload()
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
const tl_ops_web_ssl_edit = function (evtdata) {
    let index = layer.open({
        type: 2
        ,title: '编辑ssl自定义配置'
        ,content: 'tl_ops_web_ssl_form.html'
        ,maxmin: true
        ,minStack:false
        ,area: ['700px', '600px']
        ,btn: ['确定', '取消']
        ,yes: function(sub_index, dom){
            let iframeWindow = window['layui-layer-iframe'+ sub_index]
                ,submit = dom.find('iframe').contents().find('#'+ _add_form_btn_id_name);
            iframeWindow.layui.form.on('submit('+ _add_form_btn_id_name +')', function(data){
                if(!tl_ops_ssl_data_edit_filter(data)){
                    return;
                }
                $.ajax(tl_ajax_data({
                    url: '/tlops/ssl/set',
                    data : JSON.stringify(res_data),
                    contentType : "application/json",
                    success : (res)=>{
                        tl_ops_web_ssl_reload()
                    }
                }));
                layer.close(sub_index);
            });
            submit.trigger('click');
        },
        success: function(dom, index) {
            let editForm = dom.find('iframe')[0].contentWindow;
            editForm.tl_ops_web_ssl_form_render(evtdata);
        },
    });
    layer.full(index)
};


//过滤新增数据
const tl_ops_ssl_data_add_filter = function( data ) {
    delete data.field.file;
    for(let key in data.field){
        if(key === 'id'){
            continue;
        }
        if(data.field[key] === undefined || data.field[key] === null || data.field[key] === ''){
            layer.msg(key + "未填写")
            return false;
        }
    }
    res_data.tl_ops_ssl_list.push(data.field)

    res_data.tl_ops_ssl_list.forEach(item=>{
        if( item.LAY_TABLE_INDEX !== undefined){
            delete item.LAY_TABLE_INDEX
        }
    })

    return true
}


//过滤编辑数据
const tl_ops_ssl_data_edit_filter = function( data ) {
    delete data.field.file;
    for(let key in data.field){
        if(data.field[key] === undefined || data.field[key] === null || data.field[key] === ''){
            layer.msg(key + "未填写")
            return false;
        }
    }
    let cur_list = []
    res_data.tl_ops_ssl_list.forEach((item)=>{
        if(parseInt(item.id) === parseInt(data.field.id)){
            data.field.change = true;
            item = data.field;
        }
        cur_list.push(item)
    })
    res_data.tl_ops_ssl_list = cur_list;

    res_data.tl_ops_ssl_list.forEach(item=>{
        if( item.LAY_TABLE_INDEX !== undefined){
            delete item.LAY_TABLE_INDEX
        }
    })

    return true
}