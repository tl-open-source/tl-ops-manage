const _form_btn_id_name = "tl-ops-web-ssl-form-submit";
const _form_id_name = "tl-ops-web-ssl-form";

const tl_ops_web_ssl_form_main = function () {
    window.$ = layui.$;
    window.form = layui.form;
    window.laytpl = layui.laytpl;
    window.layedit = layui.layedit;

    window.tl_ops_web_ssl_form_render = function(data){
        form.val(_form_id_name, Object.assign(form.val(_form_id_name), data))
        form.render()
    }

    form.render()
};