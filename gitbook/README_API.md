# 管理端API

本项目提供了一系列API，供可视化界面来对接，不过需要注意的是目前提供的管理端API是较为简介的，如有需要可依赖管理端API自行定制不同的可视化界面。默认提供的是由layui写的一个可视化管理界面

## 默认模块接口

默认模块指的是项目的核心模块配置管理接口，如负载配置，WAF配置，健康检查配置，限流配置等等

## 插件模块接口

除了默认模块的配置外，项目还支持插件自行提供对外API管理接口，典型的例子就是， `SSL插件` 提供的 `get_ssl.lua` 和 `set_ssl.lua`