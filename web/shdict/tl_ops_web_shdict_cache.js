const _table_id_name = "tl-ops-web-shdict-table";
const _search_id_name = "tl-ops-web-shdict-search";

const tl_ops_web_shdict_main = function (){
    window.$ = layui.$;
    window.form = layui.form;
    window.table = layui.table;
    window.layedit = layui.layedit;

    tl_ops_web_shdict_render();

    //行事件操作
    table.on('tool('+_table_id_name+')', function(obj) {
        let type = obj.event;
        let data = obj.data;
        tl_ops_web_shdict_event()[type] ? tl_ops_web_shdict_event()[type].call(this, data) : '';
    });

};

//事件监听定义
const tl_ops_web_shdict_event = function () {
    return {
        view : tl_ops_web_shdict_view,
    }
};

//表格cols
const tl_ops_web_shdict_cols = function () {
    return [[
        {
            field: 'key', title: '键名称', width:"50%", sort : true
        },  {
            field: 'type', title: '数据类型',width:"15%"
        },  {
            field: 'expire', title: '过期时间',width:"15%"
        },  {
            width: "20%",
            align: 'center',
            fixed: 'right',
            title: '操作',
            toolbar: '#tl-ops-web-shdict-operate'
        }
    ]];
};


//表格render
const tl_ops_web_shdict_render = function () {
    table.render(tl_ajax_data({
        elem: '#'+_table_id_name,
        url: '/tlops/state/shdict/get?type=cache',
        cols: tl_ops_web_shdict_cols(),
        page: true,
        needReloadMsg : false,
        toolbar: '#tl-ops-web-shdict-toolbar',
        defaultToolbar: ['filter', 'print', 'exports'],
        totalRow: true,
        parseData: function(res){
            let capacity = res.data.capacity || 0;
            let free_space = res.data.free_space || 0;
            let keys = res.data.keys || [];

            $('#tl-ops-web-shdict-cache-all')[0].innerHTML = `
                <b style='color:red;font-size:16px;cursor: pointer;' class="layui-badge layui-bg-red">
                    ${capacity}
                </b>
                <b>(约${tl_byte_to_m(capacity)} )</b>
            `;

            $('#tl-ops-web-shdict-cache-used')[0].innerHTML = `
                <b style='color:red;font-size:16px;cursor: pointer;' class="layui-badge layui-bg-red">
                    ${capacity - free_space}
                </b>
                <b>(约${tl_byte_to_m(capacity - free_space)} )</b>
            `;

            let data = []

            keys.forEach(key => {
                data.push({
                    key : key,
                    expire : 0,
                    type : "string",
                })
            });
            
            return {
                "code": res.code,
                "msg": res.msg,
                "count": data.count,
                "data":  data
            };
        }
    }));
};

// 表格reload
const tl_ops_web_shdict_reload = function (matcher) {
    table.render(tl_ajax_data({
        elem: '#'+_table_id_name,
        url: '/tlops/shdict/list',
        where : matcher,
        page : true,
        cols: tl_ops_web_shdict_cols(),
        needReloadMsg : false,
        toolbar: '#tl-ops-web-shdict-toolbar',
        defaultToolbar: ['filter', 'print', 'exports'],
        totalRow: true,
        parseData: function(res){
            let capacity = res.data.capacity || 0;
            let free_space = res.data.free_space || 0;
            let keys = res.data.keys || [];

            $('#tl-ops-web-shdict-cache-all')[0].innerHTML = `
                <b style='color:red;font-size:16px;cursor: pointer;' class="layui-badge layui-bg-red">
                    ${capacity}
                </b>
                <b>(约${tl_byte_to_m(capacity)} )</b>
            `;

            $('#tl-ops-web-shdict-cache-used')[0].innerHTML = `
                <b style='color:red;font-size:16px;cursor: pointer;' class="layui-badge layui-bg-red">
                    ${capacity - free_space}
                </b>
                <b>(约${tl_byte_to_m(capacity - free_space)} )</b>
            `;

            let data = []

            keys.forEach(key => {
                data.push({
                    key : key,
                    expire : 0,
                    type : "string",
                })
            });
            
            return {
                "code": res.code,
                "msg": res.msg,
                "count": data.count,
                "data":  data
            };
        }
    }));
};


//查看
const tl_ops_web_shdict_view = function (evtdata) {
    let index = layer.open({
        type: 2
        ,title: '查看'+evtdata.key+'数据内容'
        ,content: 'tl_ops_web_shdict_view.html?type=cache&key='+evtdata.key
        ,maxmin: true
        ,minStack:false
        ,area: ['700px', '600px']
        ,success: function(dom, index) {
            
        },
    });

    layer.full(index);
};
