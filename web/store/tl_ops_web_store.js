const _table_id_name = "tl-ops-web-store-table";
const _search_id_name = "tl-ops-web-store-search";
let res_data = {};

const tl_ops_web_store_main = function (){
    window.$ = layui.$;
    window.form = layui.form;
    window.table = layui.table;
    window.layedit = layui.layedit;

    tl_ops_web_store_render();

    //行事件操作
    table.on('tool('+_table_id_name+')', function(obj) {
        let type = obj.event;
        let data = obj.data;
        tl_ops_web_store_event()[type] ? tl_ops_web_store_event()[type].call(this, data) : '';
    });

};

//事件监听定义
const tl_ops_web_store_event = function () {
    return {
        view : tl_ops_web_store_view,
    }
};

//表格cols
const tl_ops_web_store_cols = function () {
    return [[
        {
            field: 'id', title: 'ID',width:"15%", sort: true
        }, {
            field: 'name', title: '文件名称', width:"30%"
        },  {
            field: 'size', title: '文件大小',width:"15%",sort: true
        },  {
            field: 'version', title: '版本数量',width:"15%", sort: true
        },  {
            field: 'updatetime', title: '更新时间',width:"15%",sort: true
        }, {
            width: "10%",
            align: 'center',
            fixed: 'right',
            title: '操作',
            toolbar: '#tl-ops-web-store-operate'
        }
    ]];
};


//表格render
const tl_ops_web_store_render = function () {
    table.render(tl_ajax_data({
        elem: '#'+_table_id_name,
        url: '/tlops/store/list',
        cols: tl_ops_web_store_cols(),
        page:true,
        needReloadMsg : false,
        toolbar: '#tl-ops-web-store-toolbar',
        defaultToolbar: ['filter', 'print', 'exports'],
        totalRow: true,
        parseData: function(res){
            let data = []
            for(let key in res.data){
                let updatetime = null
                let newList = []
                if (res.data[key].list){
                    res.data[key].list.forEach((item)=>{
                        if(new Date(item.time) > updatetime){
                            updatetime = new Date(item.time)
                        }
                        if(item.value.includes("{")){
                            item.value = eval(`(` + item.value + `)`)
                            newList.push(item)
                        }
                    })
                }
                res.data[key].version = parseInt(res.data[key].version)
                res.data[key].updatetime = updatetime ? updatetime.toLocaleString() : null
                res.data[key].list = newList;
                data.push(res.data[key])
            }
            data = data.sort(function(a, b){return new Date(a.id) - new Date(b.id)})

            return {
                "code": res.code,
                "msg": res.msg,
                "count": data.length,
                "data":  data
            };
        }
    }));
};

// 表格reload
const tl_ops_web_store_reload = function (matcher) {
    table.render(tl_ajax_data({
        elem: '#'+_table_id_name,
        url: '/tlops/store/list',
        where : matcher,
        cols: tl_ops_web_store_cols(),
        needReloadMsg : false,
        toolbar: '#tl-ops-web-store-toolbar',
        defaultToolbar: ['filter', 'print', 'exports'],
        totalRow: true,
        parseData: function(res){
            let data = []
            for(let key in res.data){
                let updatetime = null
                let newList = []
                if (res.data[key].list){
                    res.data[key].list.forEach((item)=>{
                        if(new Date(item.time) > updatetime){
                            updatetime = new Date(item.time)
                        }
                        if(item.value.includes("{")){
                            item.value = eval(`(` + item.value + `)`)
                            newList.push(item)
                        }
                    })
                }
                res.data[key].updatetime = updatetime ? updatetime.toLocaleString() : null
                res.data[key].list = newList;
                data.push(res.data[key])
            }
            data = data.sort(function(a, b){return new Date(a.id) - new Date(b.id)})
            return {
                "code": res.code,
                "msg": res.msg,
                "count": data.length,
                "data":  data
            };
        }
    }));
};


//查看
const tl_ops_web_store_view = function (evtdata) {
    window.localStorage.setItem(evtdata.name, JSON.stringify(evtdata))

    let index = layer.open({
        type: 2
        ,title: '查看'+evtdata.name+'历史版本'
        ,content: 'tl_ops_web_store_view.html?filename='+evtdata.name
        ,maxmin: true
        ,minStack:false
        ,area: ['700px', '600px']
        ,success: function(dom, index) {
            
        },
    });

    layer.full(index);
};

