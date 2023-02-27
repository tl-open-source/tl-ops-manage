# 插件开发流程

插件是tl-ops-manage扩展的一种能力，在openresty的多阶段基础上植入一些模板钩子方法，达到引入自定义插件的目的


## 模板示例

对于要接入插件开发的场景来说，需要按照约定的规范格式来编写插件代码，并在相应的配置中引入。对此，我提供了一个模板示例，`tl-ops-manage/plugins/tl_ops_template` 。如果需要新开发一个插件并引入至tl-ops-manage中，需要以下三个步骤


### 复制示例模板

    复制一份 tl_ops_template 文件夹，更改为你的插件名称，注意，名称需以 `tl_ops_` 开头。如你的插件名称为 `test`，对应的文件夹名称为 `tl_ops_test`

### 编写插件代码

根据你想编写的插件，在模板文件中相应阶段编写相应的代码。

`tl_ops_plugin_core` : 插件逻辑

`tl_ops_plugin_constant` : 插件配置数据定义

`tl_ops_plugin_open` : 插件开关

`tl_ops_plugin_api` : 插件对外api接口


### 添加插件

添加插件支持两种形式，从 tl_ops_constant_plugins_manage.lua 配置文件中添加， 从管理后台插件管理中添加