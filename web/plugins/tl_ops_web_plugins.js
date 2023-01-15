const _plugins_view_id_name = "tl-ops-web-plugins-service-view";
const _plugins_tlp_id_name = "tl-ops-web-plugins-service-tpl";
const _plugins_form_btn_id_name = "tl-ops-web-plugins-btn";

const _add_form_btn_id_name = "tl-ops-web-plugins-form-submit"

let plugin_list = []
let res_data = {}

const tl_ops_web_plugins_main = function (){
    window.$ = layui.$;
    window.form = layui.form;
    window.table = layui.table;
    window.laytpl = layui.laytpl;
    window.element = layui.element;

    axios.get("/tlops/plugins/get").then(async (res)=>{
        res = res.data;
        if(res.code === 0){
            res_data = res.data;
            tl_ops_web_plugins_render(await tl_ops_plugins_handler_render_data(res.data))
        }
    })
};

//渲染列表
const tl_ops_plugins_handler_render_data = async function(data){
    let list = data.tl_ops_plugins_list;

    for(let index in list){
        let plugin = list[index]
        try{
            let res = await axios.get(plugin.get);
            if(res.data.data && typeof res.data.data === 'string'){
                plugin.data = {
                    zname : "",
                    name : plugin.name,
                    open : false,
                    scope : "",
                    page : ""
                }
                continue
            }
            plugin['data'] = res.data.data['tl_ops_plugins_export_' + plugin.name]
        }catch(e){
            console.log(e)
            plugin.data = {
                zname : "",
                name : plugin.name,
                open : false,
                scope : "",
                page : ""
            }
        }
    }

    list = list.sort(function(a, b){return a.id - b.id})
    
    plugin_list = list;

    return list
}

// 渲染单个
const tl_ops_plugins_handler_render_single_data = function(data, name){
    if(!data){
        return;
    }
    
    let single = data['tl_ops_plugins_export_' + name]

    plugin_list.forEach((item)=>{
        if(item.name === single.name){
            item = single
        }
    })

    return plugin_list
}

const tl_ops_web_plugins_render = function( data ){
    laytpl(document.getElementById(_plugins_tlp_id_name).innerHTML).render((()=>{
        return data;
    })(), (html)=>{
        document.getElementById(_plugins_view_id_name).innerHTML = html;
    });
    form.render()
}


//插件管理
const tl_ops_web_plugins_edit = function (name, zname) {
    let index = layer.open({
        type: 2
        ,title: '管理【'+zname+'】插件配置'
        ,content: 'tl_ops_web_plugins_form.html?name='+name
        ,maxmin: true
        ,minStack:false
        ,area: ['650px', '650px']
        ,btn: ['确定', '取消']
        ,yes: function(index, dom){
            let iframeWindow = window['layui-layer-iframe'+ index]
                ,submit = dom.find('iframe').contents().find('#'+ _add_form_btn_id_name);

            iframeWindow.layui.form.on('submit('+ _add_form_btn_id_name +')', function(data){
                if(!tl_ops_plugins_data_edit_filter(data)){
                    return;
                }

                let updateInfo = { }
                plugin_list.forEach((item)=>{
                    if(item.name === name){
                        updateInfo = item
                    }
                })
                $.ajax(tl_ajax_data({
                    url: updateInfo.set,
                    data : JSON.stringify({
                        ['tl_ops_plugins_export_' + name] : updateInfo.data
                    }),
                    contentType : "application/json",
                    success : (res)=>{
                        layer.msg(res.msg)
                        tl_ops_web_plugins_render(tl_ops_plugins_handler_render_single_data(res.data, name))
                    }
                }));
                layer.close(index);
            });
            submit.trigger('click');
        },
        success: function(dom, index) {
            let evtdata = null
            plugin_list.forEach((item)=>{
                if(item.name === name){
                    evtdata = item
                }
            })
            if (evtdata){
                let editForm = dom.find('iframe')[0].contentWindow;
                editForm.tl_ops_web_plugins_form_render(evtdata.data);
            }else{
                layer.msg("渲染编辑框失败")
            }
        },
    });
    if(parent.window.tl_side_screen() < 1){
        layer.full(index);
    }
};


//插件自定义配置页面
const tl_ops_web_plugins_config_edit = function (name, zname, page) {
    let index = layer.open({
        type: 2
        ,title: '管理【'+zname+'】插件配置'
        ,content: page
        ,maxmin: true
        ,minStack:false
        ,area: ['100%','100%']
    });
    if(parent.window.tl_side_screen() < 1){
        layer.full(index);
    }
};


// 添加插件页面
const tl_ops_plugins_add = function(){
    let index = layer.open({
        type: 2
        ,title: '添加插件'
        ,content: 'tl_ops_web_plugins_form_add.html'
        ,maxmin: true
        ,minStack:false
        ,area: ['650px', '650px']
        ,btn: ['确定', '取消']
        ,yes: function(index, dom){
            let iframeWindow = window['layui-layer-iframe'+ index]
                ,submit = dom.find('iframe').contents().find('#'+ _add_form_btn_id_name);

            iframeWindow.layui.form.on('submit('+ _add_form_btn_id_name +')', function(data){
                if(!tl_ops_plugins_data_add_filter(data)){
                    return;
                }
                $.ajax(tl_ajax_data({
                    url: "/tlops/plugins/set",
                    data : JSON.stringify(res_data),
                    contentType : "application/json",
                    success : (res)=>{
                        if(res.code === 0){
                            window.location.reload()
                            layer.msg(res.msg)
                        }else{
                            layer.msg("插件数据不完整或不存在, msg="+res.msg)
                        }
                    }
                }));
                layer.close(index);
            });
            submit.trigger('click');
        }
    });
    if(parent.window.tl_side_screen() < 1){
        layer.full(index);
    }
}


//过滤添加数据
const tl_ops_plugins_data_add_filter = function( data ){
    let name = data.field.name

    if(name === undefined || name === null || name === ''){
        layer.msg(key + "名称未填写")
        return false;
    }

    let hasPlugin = plugin_list.filter((item)=>{
        return item.name === name;
    })

    if(hasPlugin && hasPlugin.length > 0){
        layer.msg(name + "名称已经存在")
        return false
    }

    res_data.tl_ops_plugins_list.push({
        name : name,
        add : true
    })

    return true
}

//过滤编辑数据
const tl_ops_plugins_data_edit_filter = function( data ) {
    let name = data.field.name
    if(name === 'template'){
        layer.closeAll()
        layer.msg("示例插件默认模板不能修改，仅作展示")
        return
    }
    delete data.field.file;
    if(data.field.open === undefined){
        data.field.open = false
    }else{
        data.field.open = true
    }
    for(let key in data.field){
        if(key === 'page' || key === 'scope'){
            continue
        }
        if(data.field[key] === undefined || data.field[key] === null || data.field[key] === ''){
            layer.msg(key + "未填写")
            return false;
        }
    }
    plugin_list.forEach((item)=>{
        if(item.name === name){
            item.data = data.field;
        }
    })
    return true;
}


//过滤删除数据
const tl_ops_plugins_data_delete_filter = function( name ){
    if(name === undefined || name === null || name === ''){
        layer.msg(key + "名称未填写")
        return false;
    }

    plugin_list.forEach((item)=>{
        if(item.name === name){
            item.del = true
        }
    })

    res_data.tl_ops_plugins_list = plugin_list

    return true
}

const tl_ops_plugins_doc = function(){
    let index = layer.open({
        type: 2
        ,title: '添加插件流程'
        ,content: "https://book.iamtsm.cn/usage/plugin/"
        ,maxmin: true
        ,minStack:false
        ,area: ["80%", "80%"]
    });
    if(parent.window.tl_side_screen() < 1){
        layer.full(index);
    }
}

const tl_ops_plugins_delete = function(name, zname){
    layer.confirm(`是否移除插件‘${zname ? zname : name}’`, (index) => {
        if(!tl_ops_plugins_data_delete_filter(name)){
            return;
        }

        $.ajax(tl_ajax_data({
            url: "/tlops/plugins/set",
            data : JSON.stringify(res_data),
            contentType : "application/json",
            success : (res)=>{
                if(res.code === 0){
                    window.location.reload()
                    layer.msg(res.msg)
                }else{
                    layer.msg("删除失败, msg="+res.msg)
                }
            }
        }));
    }, (index) => {
        layer.close(index)
    })
}