const _submit_btn_id_name = "tl-ops-web-auth-btn";
const _auth_form_id_name = "tl-ops-web-auth-form";
const _user_form_btn_id_name = "tl-ops-web-auth-user-form-submit";


const tl_ops_web_auth_main = function (){
    window.$ = layui.$;
    window.form = layui.form;
    window.code = layui.code;
    window.layedit = layui.layedit;

    //加载数据
    tl_ops_web_auth_render();

    $("#tl-ops-web-auth-user-btn").on("click",function(){
        tl_ops_web_auth_user_list()
    })

    //提交保存
    form.on('submit('+_submit_btn_id_name+')', function(data){
        tl_ops_web_auth_login_update(data)
    });

};


//加载
const tl_ops_web_auth_render = function () {
    let index = layer.load();
    $.ajax(tl_ajax_data({
        url: '/tlops/auth/get',
        success: (res)=>{
            layer.close(index);
            if(res.code === 0){
                let data = res.data
                form.val(_auth_form_id_name, data.tl_ops_plugin_auth_login);
            }else{
                layer.msg(res.msg)
            }
        },
        error : (res)=>{
            window.location.reload()
        }
    }));
};


//更新
const tl_ops_web_auth_login_update = function (data) {
    data = tl_ops_web_auth_login_edit_filter(data)
    
    $.ajax(tl_ajax_data({
        url: '/tlops/auth/set',
        data :  JSON.stringify({
            tl_ops_plugin_auth_login : data
        }),
        contentType : "application/json",
        success : (res)=>{
            if(res.code === 0){
                layer.msg("success")
                setTimeout(() => {
                    tl_ops_web_auth_render();
                }, 500);
            }else{
                layer.msg(res.msg)
            }
        }
    }));
};


//过滤编辑数据
const tl_ops_web_auth_login_edit_filter = function( data ) {
    delete data.field.file;

    for(let key in data.field){
        if(data.field[key] === undefined || data.field[key] === null || data.field[key] === ''){
            layer.msg(key + "未填写")
            return false;
        }
        if(key === 'auth_time' || key === 'code'){
            data.field[key] = parseInt(data.field[key])   
        }
        if(key === 'code' && (data.field[key] < 200 || data.field[key] > 599)){
            layer.msg(key + "需要在200 ~ 599范围内")
            return false;
        }
        if(key === 'intercept' || key === 'filter'){
            let valueList = data.field[key].split(",");
            data.field[key] = valueList
        }
    }

    return data.field
}

