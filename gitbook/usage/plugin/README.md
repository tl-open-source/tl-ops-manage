# 插件开发流程

插件是tl-ops-manage扩展的一种能力，在openresty的多阶段基础上植入一些模板钩子方法，达到引入自定义插件的目的


## 模板示例

对于要接入插件开发的场景来说，需要按照约定的规范格式来编写插件代码，并在相应的配置中引入。对此，我提供了一个模板示例，`tl-ops-manage/plugins/tl_ops_template` 。如果需要新开发一个插件并引入至tl-ops-manage中，需要以下三个步骤


### 复制示例模板

    复制一份 tl_ops_template 文件夹，更改为你的插件名称，注意，名称需以 `tl_ops_` 开头。如你的插件名称为 `test`，对应的文件夹名称为 `tl_ops_test`

### 编写插件代码

    根据你想编写的插件，在tl_ops_plugin_core模板文件中相应阶段编写相应的代码。

### 修改配置文件

    在总配置文件中 `tl-ops-manage/tl_ops_manage_env` 引入插件名称。


## 插件实例

tl-ops-manage提供了一个同步器插件，`tl_ops_sync`，此插件的作用是，在启动nginx/openresty时，同步静态配置中的数据至store文件中，并提供配置数据预热功能。且支持新增静态配置字段时，同步新增至对应store文件中
