# 开发指引

tl-ops-manage总体设计比较简单，对于稍微了解lua的同学来说，也可以快速上手，进行二次开发以贴合业务，我从以下几个方面来引导需要进行二次开发或者参与项目维护的同学


### 明确需求

首先需要了解当前项目的设计概览，执行流程，可能遇到的问题，以及你想在项目中做什么样的功能与维护。在了解和明确了这些情况后，可以着手试着写一些代码，看看能否正常执行，能否达到预期。


如果达到预期，就可以开始二次开发了。


### 测试

测试是一个必不可少的步骤，测试的完整性决定了你写的代码的可用性，一般的功能可以通过日志和模拟操作进行调试，更完善一些的可以通过编写一些test:ngixn用例（ 需要学习一些前置试用知识 ）。

如果有可能，可以对功能进行单独压测和链路压测。提供记录一些性能瓶颈，以便于后续优化。