const _console_echarts_view_id_name = "tl-ops-web-console-echarts-service-view";
const _console_echarts_tlp_id_name = "tl-ops-web-console-echarts-service-tpl";

const _console_view_id_name = "tl-ops-web-console-service-view";
const _console_tlp_id_name = "tl-ops-web-console-service-tpl";

let res_data = {};
let cur_type = 'balance';

const tl_ops_web_console_main = function () {
    window.$ = layui.$;
    window.form = layui.form;
    window.table = layui.table;
    window.laytpl = layui.laytpl;
    window.layer = layui.layer;

    window.consoleEchartsList = [];
    window.syncDataInterId = 0;

    let index = layer.load()

    form.on('switch()', function(data){
        if(data.elem.checked){ //实时刷数据
            syncDataInterId = setInterval(tl_ops_web_console_reflush, 2000)
            $("#tl-console-load-sync-icon").css("display","inline-block")
        }else{
            clearInterval(syncDataInterId);
            $("#tl-console-load-sync-icon").css("display","none")
        }
    });  

    axios.get("/tlops/state/get").then((res) => {
        res = res.data;
        if (res.code === 0) {
            res_data = res.data
            let service_data = res.data.service
            //渲染dom
            if(cur_type === 'balance'){
                tl_ops_web_console_echarts_balance_render(service_data)
            }else if(cur_type === 'fuselimit'){
                tl_ops_web_console_echarts_fuselimit_render(service_data)
            }else if(cur_type === 'health'){
                tl_ops_web_console_echarts_health_render(service_data)
            }else if(cur_type === 'waf'){
                tl_ops_web_console_echarts_waf_render(service_data)
            }
            
            tl_ops_web_console_service_state_render(service_data)
        }
        layer.close(index)
    }).then((res) => {
        window.onresize = function () {
            consoleEchartsList.forEach((item) => {
                item.echart.resize();
            })
        };
    })
};


// 实时刷数据
const tl_ops_web_console_reflush = function(){
    axios.get("/tlops/state/get").then((res) => {
        res = res.data;
        if (res.code === 0) {
            res_data = res.data
            let service_data = res.data.service
            //渲染dom
            if(cur_type === 'balance'){
                tl_ops_web_console_echarts_balance_render_reflush(service_data);
            }else if(cur_type === 'fuselimit'){
                tl_ops_web_console_echarts_fuselimit_render_reflush(service_data);
            }else if(cur_type === 'health'){
                tl_ops_web_console_echarts_health_render_reflush(service_data);
            }else if(cur_type === 'waf'){
                tl_ops_web_console_echarts_waf_render_reflush(service_data);
            }
            tl_ops_web_console_service_state_render(service_data)
        }
    })
    
}


//health get option
const tl_ops_web_console_echarts_health_get_option = function(data){
    var option = {
        title: {
            text: `${data.id}-在线节点:${data.online_count}-下线节点:${data.offine_count}`,
            show: true,
            textStyle: {
                fontSize: 14,
            },
            x: 'center',
            y: 'bottom'
        },
        tooltip: {
            trigger: 'axis',
            axisPointer: { type: 'cross' }
        },
        legend: {},
        xAxis: [
            {
                type: 'category',
                axisTick: {
                    alignWithLabel: true
                },
                data: data.nodeList,
                axisLabel: { //轴文字标签
                    interval: 0,
                    show: true,
                    textStyle: {
                        color: '#B0CEFC',
                    },
                    formatter: function (val) {
                        var strs = val.split(''); //字符串数组  
                        var str = ''
                        for (var i = 0, s; s = strs[i++];) { //遍历字符串数组  
                            str += s;
                            if (!(i % 18)) str += '\n';
                        }
                        return str
                    }
                }
            }
        ],
        yAxis: [
            {
                type: 'value',
                name: '心跳成功',
                position: 'left',
                axisLabel: {
                    formatter: '{value} 次'
                },
                nameTextStyle: {
                    color: '#01AAED',
                    padding: 10
                },
            },
            {
                type: 'value',
                name: '心跳失败',
                position: 'right',
                axisLabel: {
                    formatter: '{value} 次'
                },
                nameTextStyle: {
                    color: '#bfbfbf',
                    padding: 10
                },
            }
        ],
        series: [
            {
                name: '心跳成功',
                type: 'bar',
                yAxisIndex: 0,
                data: data.successList,
                color: '#01AAED',
                itemStyle: {
                    normal: {
                        color: function (params) { return '#01AAED'; }
                    }
                },
            },
            {
                name: '心跳失败',
                type: 'bar',
                smooth: true,
                yAxisIndex: 1,
                color: '#bfbfbf',
                data: data.failedList,
                itemStyle: {
                    normal: {
                        color: function (params) { return '#bfbfbf'; }
                    }
                }
            }
        ]
    };

    return option;
}

//health 统计数量
const tl_ops_web_console_health_state_caculate = function (data) {
    let config = []
    for (let key in data) {
        let service = data[key];
        let nodes = service.nodes;//节点列表
        let serviceList = Object.keys(nodes);//服务列表
        let successList = [];//成功列表
        let failedList = [];//失败列表
        let online_count = 0; //在线节点数
        let offine_count = 0; //下线节点数

        for (let nKey in nodes) {
            if (typeof (nodes[nKey].health_state) === 'boolean' && nodes[nKey].health_state) {
                online_count += 1;
            } else {
                offine_count += 1;
            }
            successList.push(parseInt(nodes[nKey].health_success))
            failedList.push(typeof (nodes[nKey].health_failed) === 'string' ? 0 : parseInt(nodes[nKey].health_failed))
        }

        config.push({
            id: key,
            online_count: online_count,
            offine_count: offine_count,
            nodeList: serviceList,
            successList: successList,
            failedList: failedList
        })
    }
    return config
}

//health echarts 初始化
const tl_ops_web_console_echarts_health_options = function (data) {
    var option = tl_ops_web_console_echarts_health_get_option(data)

    var consoleEchart = echarts.init(document.getElementById(data.id));
    consoleEchart.setOption(option);

    consoleEchartsList.push({
        id : data.id,
        type : cur_type,
        echart : consoleEchart
    });
}

//health echarts 初始化渲染
const tl_ops_web_console_echarts_health_render = function (data) {
    let serviceList = [];
    for(let serviceName in data){
        serviceList.push({
            id : serviceName,
            type : 'health',
            uncheck : data[serviceName].health_uncheck
        })
    }
    serviceList = serviceList.sort(function(a, b){return a.id.localeCompare(b.id,'zh-CN')})

    laytpl(document.getElementById(_console_echarts_tlp_id_name).innerHTML).render((() => {
        return serviceList
    })(), (html) => {
        document.getElementById(_console_echarts_view_id_name).innerHTML = html;
    });
    form.render()

    //渲染echarts
    tl_ops_web_console_health_state_caculate(data).forEach((item) => {
        tl_ops_web_console_echarts_health_options(item)
    })
}

//health echarts option 刷新
const tl_ops_web_console_echarts_health_options_reflush = function (data){
    var option = tl_ops_web_console_echarts_health_get_option(data)

    consoleEchartsList.filter((item)=>{
        if(item.type === 'health' && item.id === data.id){
            item.echart.setOption(option)
        }
    })
}

//health echarts 刷新渲染
const tl_ops_web_console_echarts_health_render_reflush = function (data) {
    //渲染echarts
    tl_ops_web_console_health_state_caculate(data).forEach((item) => {
        tl_ops_web_console_echarts_health_options_reflush(item)
    })
}





//balance get option
const tl_ops_web_console_echarts_balance_get_option = function(data){
    var option = {
        title: {
            text: `${data.id}-负载总量:${data.balance_count}`,
            show: true,
            textStyle: {
                fontSize: 14,
            },
            x: 'center',
            y: 'bottom'
        },
        tooltip: {
            trigger: 'axis',
            axisPointer: { type: 'cross' }
        },
        legend: {},
        xAxis: {
            type: 'category',
            axisTick: {
                alignWithLabel: true
            },
            data: data.timeList,
            axisLabel: { //轴文字标签
                interval: 0,
                show: true,
                textStyle: {
                    color: '#B0CEFC',
                },
                formatter: function (val) {
                    var strs = val.split(''); //字符串数组  
                    var str = ''
                    for (var i = 0, s; s = strs[i++];) { //遍历字符串数组  
                        str += s;
                        if (!(i % 18)) str += '\n';
                    }
                    return str
                }
            }
        },
        yAxis: {
            type: 'value',
            name: '负载请求量',
            position: 'left',
            axisLabel: {
                formatter: '{value} 次'
            },
            nameTextStyle: {
                color: '#3582fb',
                padding: 10
            },
        },
        series: data.seriesBalanceList
    };
    return option;
}

//balance 统计数量 (以当天为单位)
const tl_ops_web_console_balance_time_list_caculate_days = function (data) {
    let config = []
    for (let key in data) {
        let balance_count = 0; //服务总量统计
        let seriesBalanceList = [];
        let nodes = data[key].nodes;
        for (let skey in nodes) {
            let balanceNodeList = nodes[skey].balance_node_count;

            for (let time in balanceNodeList) {
                let count = balanceNodeList[time];
                balance_count += count;
            }

            let dayTimeCountList = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0] //节点总量统计
            for (let timeItem in balanceNodeList) {
                let count = balanceNodeList[timeItem];
                let day = timeItem.toString().split(" ")[0]
                let time = timeItem.toString().split(" ")[1]
                let hours = parseInt(time.split(":")[0])
                let cur_day = getDateStr(0);

                //当天内
                if (day.includes(cur_day)) {
                    let dayTimeCountIndex = parseInt((hours % 2) === 0 ? (hours / 2) : (hours / 2) + 1) - 1;
                    dayTimeCountList[dayTimeCountIndex] += count
                }
            }
            seriesBalanceList.push({
                name: skey,
                type: 'line',
                yAxisIndex: 0,
                data: dayTimeCountList,
            })
        }
        config.push({
            id: key,
            balance_count: balance_count,
            seriesBalanceList: seriesBalanceList,
            timeList: ['1点', '3点', '5点', '7点', '9点', '11点', '13点', '15点', '17点', '19点', '21点', '23点']
        })
    }
    return config
}

//balance echarts 初始化
const tl_ops_web_console_echarts_balance_options = function (data) {
    var option = tl_ops_web_console_echarts_balance_get_option(data);

    var consoleEchart = echarts.init(document.getElementById(data.id));
    consoleEchart.setOption(option);

    consoleEchartsList.push({
        id : data.id,
        type : cur_type,
        echart : consoleEchart
    });
}

//balance echarts 初始化渲染
const tl_ops_web_console_echarts_balance_render = function (data) {
    let serviceList = [];
    for(let serviceName in data){
        serviceList.push({
            id : serviceName,
            type : 'balance',
        })
    }
    serviceList = serviceList.sort(function(a, b){return a.id.localeCompare(b.id,'zh-CN')})

    laytpl(document.getElementById(_console_echarts_tlp_id_name).innerHTML).render((() => {
        return serviceList
    })(), (html) => {
        document.getElementById(_console_echarts_view_id_name).innerHTML = html;
    });
    form.render()

    //渲染echarts
    tl_ops_web_console_balance_time_list_caculate_days(data).forEach((item) => {
        tl_ops_web_console_echarts_balance_options(item)
    })
}

//balance echarts 刷新
const tl_ops_web_console_echarts_balance_options_reflush = function (data) {
    var option = tl_ops_web_console_echarts_balance_get_option(data);

    consoleEchartsList.filter((item)=>{
        if(item.type === 'balance' && item.id === data.id){
            item.echart.setOption(option)
        }
    })
}

//balance echarts 刷新渲染
const tl_ops_web_console_echarts_balance_render_reflush = function (data) {
    //渲染echarts
    tl_ops_web_console_balance_time_list_caculate_days(data).forEach((item) => {
        tl_ops_web_console_echarts_balance_options_reflush(item)
    })
}






//waf get option
const tl_ops_web_console_echarts_waf_get_option = function(data){
    var option = {
        title: {
            text: `${data.id}-WAF总量:${data.waf_count}`,
            show: true,
            textStyle: {
                fontSize: 14,
            },
            x: 'center',
            y: 'bottom'
        },
        tooltip: {
            trigger: 'axis',
            axisPointer: { type: 'cross' }
        },
        legend: {},
        xAxis: {
            type: 'category',
            axisTick: {
                alignWithLabel: true
            },
            data: data.timeList,
            axisLabel: { //轴文字标签
                interval: 0,
                show: true,
                textStyle: {
                    color: '#B0CEFC',
                },
                formatter: function (val) {
                    var strs = val.split(''); //字符串数组  
                    var str = ''
                    for (var i = 0, s; s = strs[i++];) { //遍历字符串数组  
                        str += s;
                        if (!(i % 18)) str += '\n';
                    }
                    return str
                }
            }
        },
        yAxis: {
            type: 'value',
            name: 'WAF拦截量',
            position: 'left',
            axisLabel: {
                formatter: '{value} 次'
            },
            nameTextStyle: {
                color: '#3582fb',
                padding: 10
            },
        },
        series: data.seriesWafList
    };
    return option;
}

//waf 统计数量 (以当天为单位)
const tl_ops_web_console_waf_time_list_caculate_days = function (data) {
    let config = []
    for (let key in data) {
        let waf_count = 0; //服务总量统计
        let seriesWafList = [];
        let wafSuccessList = data[key].waf_success;

        for (let time in wafSuccessList) {
            let count = wafSuccessList[time];
            waf_count += count;
        }

        let dayTimeCountList = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0] //总量统计
        for (let timeItem in wafSuccessList) {
            let count = wafSuccessList[timeItem];
            let day = timeItem.toString().split(" ")[0]
            let time = timeItem.toString().split(" ")[1]
            let hours = parseInt(time.split(":")[0])
            let cur_day = getDateStr(0);

            //当天内
            if (day.includes(cur_day)) {
                let dayTimeCountIndex = parseInt((hours % 2) === 0 ? (hours / 2) : (hours / 2) + 1) - 1;
                dayTimeCountList[dayTimeCountIndex] += count
            }
        }
        seriesWafList.push({
            name: key+"-服务层级",
            type: 'line',
            yAxisIndex: 0,
            data: dayTimeCountList,
        })
        config.push({
            id: key,
            waf_count: waf_count,
            seriesWafList: seriesWafList,
            timeList: ['1点', '3点', '5点', '7点', '9点', '11点', '13点', '15点', '17点', '19点', '21点', '23点']
        })
    }

    //全局统计
    let waf_count = 0;
    let wafSuccessList = res_data.waf.waf_success;
    for (let time in wafSuccessList) {
        let count = wafSuccessList[time];
        waf_count += count;
    }
    let dayTimeCountList = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0] //总量统计
    for (let timeItem in wafSuccessList) {
        let count = wafSuccessList[timeItem];
        let day = timeItem.toString().split(" ")[0]
        let time = timeItem.toString().split(" ")[1]
        let hours = parseInt(time.split(":")[0])
        let cur_day = getDateStr(0);

        //当天内
        if (day.includes(cur_day)) {
            let dayTimeCountIndex = parseInt((hours % 2) === 0 ? (hours / 2) : (hours / 2) + 1) - 1;
            dayTimeCountList[dayTimeCountIndex] += count
        }
    }
    let seriesWafList = [{
        name: "全局层级",
        type: 'line',
        yAxisIndex: 0,
        data: dayTimeCountList,
    }]
    config.push({
        id: "全局层级",
        waf_count: waf_count,
        seriesWafList: seriesWafList,
        timeList: ['1点', '3点', '5点', '7点', '9点', '11点', '13点', '15点', '17点', '19点', '21点', '23点']
    })

    return config
}

//waf echarts 初始化
const tl_ops_web_console_echarts_waf_options = function (data) {
    var option = tl_ops_web_console_echarts_waf_get_option(data);

    var consoleEchart = echarts.init(document.getElementById(data.id));
    consoleEchart.setOption(option);

    consoleEchartsList.push({
        id : data.id,
        type : cur_type,
        echart : consoleEchart
    });
}

//waf echarts 初始化渲染
const tl_ops_web_console_echarts_waf_render = function (data) {
    let serviceList = [];
    for(let serviceName in data){
        serviceList.push({
            id : serviceName,
            type : 'waf',
        })
    }
    serviceList = serviceList.sort(function(a, b){return a.id.localeCompare(b.id,'zh-CN')})

    serviceList.unshift({
        id : "全局层级",
        type : 'waf',
    })

    laytpl(document.getElementById(_console_echarts_tlp_id_name).innerHTML).render((() => {
        return serviceList
    })(), (html) => {
        document.getElementById(_console_echarts_view_id_name).innerHTML = html;
    });
    form.render()

    //渲染echarts
    tl_ops_web_console_waf_time_list_caculate_days(data).forEach((item) => {
        tl_ops_web_console_echarts_waf_options(item)
    })
}

//waf echarts 刷新
const tl_ops_web_console_echarts_waf_options_reflush = function (data) {
    var option = tl_ops_web_console_echarts_waf_get_option(data);

    consoleEchartsList.filter((item)=>{
        if(item.type === 'waf' && item.id === data.id){
            item.echart.setOption(option)
        }
    })
}

//waf echarts 刷新渲染
const tl_ops_web_console_echarts_waf_render_reflush = function (data) {
    //渲染echarts
    tl_ops_web_console_waf_time_list_caculate_days(data).forEach((item) => {
        tl_ops_web_console_echarts_waf_options_reflush(item)
    })
}






//fuselimit get option
const tl_ops_web_console_echarts_fuselimit_get_option = function(data){
    
    var option = {
        legend: {
            orient: 'vertical',
            x: 'left',
        },
        graphic: [
            {
                type: 'text',
                left: 0,
                top: 0,
                z: 2,
                zlevel: 100,
                style: {
                    text: data.name,
                    fontWeight: 'bold',
                    fill: data.fill,
                    textAlign: 'center',
                    fontSize: 13,
                }
            },
            {
                type: 'text',
                left: 'center',
                top: '32%',
                z: 2,
                zlevel: 100,
                style: {
                    text: "阈值:"+data.threshold,
                    textAlign: 'center',
                    fontSize: 12,
                },
            },
            {
                type: 'text',
                left: 'center',
                top: '47%',
                z: 2,
                zlevel: 100,
                style: {
                    text: data.state,
                    textAlign: 'center',
                    fontWeight: 'bold',
                    fill: data.fill,
                    fontSize: 18,
                },
            },
            {
                type: 'text',
                left: 'center',
                top: '67%',
                z: 2,
                zlevel: 100,
                style: {
                    text: "当前:"+data.currentThreshold,
                    textAlign: 'center',
                    fill: data.fill,
                    fontSize: 12,
                },
            },
        ],

        series: [
            // 最内层背景色
            {
                type: 'pie',
                radius: [0, '60%'],
                hoverAnimation: false,
                labelLine: {
                    normal: {
                        show: false,
                    },
                },
                animation: false,
                data: [
                    {
                        value: 100,
                        itemStyle: {
                            normal: {
                                color: '#f5f5f5',
                            },
                            emphasis: { color: '#f5f5f5' },
                        },
                    },
                ],
            },
            // 内边框
            {
                type: 'pie',
                radius: ['60%', '61%'],
                labelLine: {
                    normal: {
                        show: false,
                    },
                },
                hoverAnimation: false,
                avoidLabelOverlap: false,
                animationEasing: 'cubicOut',
                data: [
                    {
                        value: data.currentThreshold,
                        itemStyle: {
                            color: '#fff',
                        },
                    },
                ],
            },
            // 进度条
            {
                type: 'pie',
                radius: ['62%', '73%'],
                itemStyle: {
                    normal: {
                        color: '#6a5acd',
                    },
                },
                labelLine: {
                    normal: {
                        show: false,
                    },
                },
                hoverAnimation: false,
                avoidLabelOverlap: false,
                silent: true, //取消鼠标移入高亮效果: 不响应和触发鼠标事件
                animationEasing: 'cubicOut',
                data: [
                    //value当前进度 + 颜色
                    {
                        value: data.currentThreshold,
                        itemStyle: {
                            //渐变颜色
                            color: {
                                type: 'linear',
                                x: 0,
                                y: 0,
                                x2: 0,
                                y2: 1,
                                colorStops: [
                                    {
                                        offset: 0,
                                        color: '#C9FFCB', // 0% 处的颜色
                                    },
                                    {
                                        offset: 1,
                                        color: data.fill, // 100% 处的颜色
                                    },
                                ],
                                global: false, // 缺省为 false
                            },
                            borderRadius: ['20%', '50%'],
                        },
                    },
                    //(maxValue进度条最大值 - value当前进度) + 颜色
                    {
                        value: data.threshold - data.currentThreshold,
                        itemStyle: {
                            // 径向渐变颜色
                            color: {
                                type: 'radial',
                                x: 1,
                                y: 1,
                                r: 1,
                                colorStops: [
                                    {
                                        offset: 0,
                                        color: '#FCFCFC',
                                    },
                                    {
                                        offset: 1,
                                        color: '#F7F7F7',
                                    },
                                ],
                                global: false,
                            },
                        },
                    },
                ],
            },
            // 外框
            {
                type: 'pie',
                radius: ['73%', '85%'],
                itemStyle: {
                    // 阴影
                    shadowBlur: 12,
                    shadowOffsetX: 0,
                    shadowColor: 'rgba(0, 0, 0, 0.1)',
                },
                labelLine: {
                    normal: {
                        show: false,
                    },
                },
                hoverAnimation: false,
                animationEasing: 'cubicOut',
                data: [
                    {
                        value: data.currentThreshold,
                        itemStyle: {
                            color: new echarts.graphic.LinearGradient(0, 0, 0, 1, [
                                {
                                    offset: 0,
                                    color: '#F7F7F7',
                                },
                                {
                                    offset: 1,
                                    color: '#FCFCFC',
                                },
                            ]),
                        },
                    },
                ],
            },
        ],
    }

    return option;
}

//fuselimit 统计数量
const tl_ops_web_console_fuselimit_state_caculate = function () {
    let config = []
    if(res_data === null || res_data === undefined){
        return;
    }
    let data = res_data.service;
    let option_list = res_data && res_data.limit ? res_data.limit.option_list : []
    for (let key in data) {
        let service = data[key];
        let nodeList = [];
        let upgrad = 0;
        let degrad = 0;

        let serviceState = "未知";
        let serviceFill = "grey";
        if(service.state === 1){
            serviceState = "半熔断";
            serviceFill = "#e2e529";
        }else if(service.state === 2){
            serviceState = "全熔断";
            serviceFill = "#df2929";
        }else{
            serviceState = "正常";
            serviceFill = "#1E9FFF";
        }

        let matcherOptions = option_list.filter(option=>{
            return option.service_name === key;
        })
        let matcherOption = matcherOptions.length > 0 ? matcherOptions[0] : {};

        let nodes = service.nodes;//节点列表
        for(let nKey in nodes){
            let nodeState = "未知";
            let nodeFill = "grey";
            let currentThreshold = nodes[nKey].limit_failed / (nodes[nKey].limit_success + nodes[nKey].limit_failed)
            if(!currentThreshold){
                currentThreshold = 0;
            }
            currentThreshold = currentThreshold.toFixed(2)
            if(currentThreshold >= matcherOption.node_threshold){
                upgrad++;
            }else{
                degrad++;
            }

            if(nodes[nKey].limit_state === 1){
                nodeState = "半熔断";
                nodeFill = "#e2e529";
            }else if(nodes[nKey].limit_state === 2){
                nodeState = "全熔断";
                nodeFill = "#df2929";
            }else{
                nodeState = "正常";
                nodeFill = "#1E9FFF";
            }

            nodeList.push({
                id : key+"-"+nKey,
                name : nKey,
                state : nodeState,
                fill : nodeFill,
                currentThreshold : currentThreshold,
                threshold : matcherOption.node_threshold,
                success : nodes[nKey].limit_success,
                failed : nodes[nKey].limit_failed
            })
        }

        let currentThreshold = upgrad / upgrad + degrad;
        if(!currentThreshold){
            currentThreshold = 0;
        }
        currentThreshold = currentThreshold.toFixed(2)

        config.push({
            id: key,
            state : serviceState,
            fill : serviceFill,
            nodeList: nodeList,
            option : matcherOption,
            currentThreshold : currentThreshold,
            threshold : matcherOption.service_threshold,
            upgrad : upgrad,
            degrad : degrad
        })
    }
    return config
}

//fuselimit options 初始化
const tl_ops_web_console_echarts_fuselimit_options = function (data) {
    var option = tl_ops_web_console_echarts_fuselimit_get_option(data)

    var consoleEchart = echarts.init(document.getElementById(data.id));
    consoleEchart.setOption(option);

    consoleEchartsList.push({
        id : data.id,
        type : cur_type,
        echart : consoleEchart
    });
}

//fuselimit echarts  初始化渲染
const tl_ops_web_console_echarts_fuselimit_render = function (data) {
    let serviceList = [];
    for(let serviceName in data){
        let mode = "";
        
        if (res_data.limit && res_data.limit.option_list){
            res_data.limit.option_list.forEach(item=>{
                if(item.service_name === serviceName){
                    mode = item.mode
                }
            })
        }

        let nodeList = [];
        for(let nodeName in data[serviceName].nodes){
            let state = data[serviceName].nodes[nodeName].health_state ? "上线" : "下线";

            let fuse_msg = "";
            if(mode === 'balance_fail'){
                fuse_msg = "<div >当前熔断策略 : 路由失败率策略 </div>" +
                "<div >当前路由成功 : "+data[serviceName].nodes[nodeName].limit_success+"</div>" +
                "<div >当前路由失败 : "+data[serviceName].nodes[nodeName].limit_failed+"</div>";
            }else{
                fuse_msg = "<div >当前熔断策略 : 健康状态策略 </div>" +
                           "<div >当前节点状态 : "+state+"</div>";
            }

            let pre_time = data[serviceName].nodes[nodeName].limit_pre_time === 'nil' ? "nil" : 
                            new Date(data[serviceName].nodes[nodeName].limit_pre_time * 1000).toLocaleString()
            let limit_msg = "<div >当前限流策略 : "+data[serviceName].nodes[nodeName].limit_depend+"</div>" +
                            "<div >当前最大容量 : "+data[serviceName].nodes[nodeName].limit_capacity+"</div>"+
                            "<div >当前剩余容量 : "+data[serviceName].nodes[nodeName].limit_bucket+"</div>"+
                            "<div >当前流控单位 : "+data[serviceName].nodes[nodeName].limit_block+"</div>"+
                            "<div >当前流控速度 : "+data[serviceName].nodes[nodeName].limit_rate+"</div>"+
                            "<div >最近补充时间 : "+pre_time+"</div>";
            nodeList.push({
                id : nodeName,
                fuse_msg : fuse_msg,
                limit_msg : limit_msg
            })
        }
        serviceList.push({
            id : serviceName,
            type : 'fuselimit',
            nodes : nodeList
        })
    }
    serviceList = serviceList.sort(function(a, b){return a.id.localeCompare(b.id,'zh-CN')})

    laytpl(document.getElementById(_console_echarts_tlp_id_name).innerHTML).render((() => {
        return serviceList
    })(), (html) => {
        document.getElementById(_console_echarts_view_id_name).innerHTML = html;
    });
    form.render()

    //渲染echarts
    tl_ops_web_console_fuselimit_state_caculate().forEach((item) => {
        item.nodeList.forEach(node=>{
            tl_ops_web_console_echarts_fuselimit_options(node)
        })
    })
}

//fuselimit options 刷新
const tl_ops_web_console_echarts_fuselimit_options_reflush = function (data) {
    var option = tl_ops_web_console_echarts_fuselimit_get_option(data)

    consoleEchartsList.filter((item)=>{
        if(item.type === 'fuselimit' && item.id === data.id){
            item.echart.setOption(option)
        }
    })
}

//fuselimit echarts 刷新渲染
const tl_ops_web_console_echarts_fuselimit_render_reflush = function (data) {
    let serviceList = [];
    for(let serviceName in data){

        let mode = "";
        if (res_data.limit && res_data.limit.option_list){
            res_data.limit.option_list.forEach(item=>{
                if(item.service_name === serviceName){
                    mode = item.mode
                }
            })
        }

        let nodeList = [];
        for(let nodeName in data[serviceName].nodes){
            let state = data[serviceName].nodes[nodeName].health_state ? "上线" : "下线";

            let fuse_msg = "";
            if(mode === 'balance_fail'){
                fuse_msg = "<div >当前熔断策略 : 路由失败率策略 </div>" +
                "<div >当前路由成功 : "+data[serviceName].nodes[nodeName].limit_success+"</div>" +
                "<div >当前路由失败 : "+data[serviceName].nodes[nodeName].limit_failed+"</div>";
            }else{
                fuse_msg = "<div >当前熔断策略 : 健康状态策略 </div>" +
                           "<div >当前节点状态 : "+state+"</div>";
            }
            
            let pre_time = data[serviceName].nodes[nodeName].limit_pre_time === 'nil' ? "nil" : 
                            new Date(data[serviceName].nodes[nodeName].limit_pre_time * 1000).toLocaleString()  
            let limit_msg = "<div >当前限流策略 : "+data[serviceName].nodes[nodeName].limit_depend+"</div>" +
                            "<div >当前最大容量 : "+data[serviceName].nodes[nodeName].limit_capacity+"</div>"+
                            "<div >当前剩余容量 : "+data[serviceName].nodes[nodeName].limit_bucket+"</div>"+
                            "<div >当前流控单位 : "+data[serviceName].nodes[nodeName].limit_block+"</div>"+
                            "<div >当前流控速度 : "+data[serviceName].nodes[nodeName].limit_rate+"</div>"+
                            "<div >最近补充时间 : "+pre_time+"</div>";
            nodeList.push({
                id : nodeName,
                fuse_msg : fuse_msg,
                limit_msg : limit_msg
            })
        }
        serviceList.push({
            id : serviceName,
            type : 'fuselimit',
            nodes : nodeList
        })
    }
    serviceList = serviceList.sort(function(a, b){return a.id.localeCompare(b.id,'zh-CN')})

    laytpl(document.getElementById(_console_echarts_tlp_id_name).innerHTML).render((() => {
        return serviceList
    })(), (html) => {
        document.getElementById(_console_echarts_view_id_name).innerHTML = html;
    });

    //渲染echarts
    tl_ops_web_console_fuselimit_state_caculate().forEach((item) => {
        item.nodeList.forEach(node=>{
            tl_ops_web_console_echarts_fuselimit_options(node)
        })
    })
}



//service state render
const tl_ops_web_console_service_state_render = function (data) {
    laytpl(document.getElementById(_console_tlp_id_name).innerHTML).render((() => {
        let serviceList = [];
        for (let sKey in data) {
            let online_count = 0
            let offine_count = 0
            let nodes = data[sKey].nodes;
            for (let nKey in nodes) {
                if (typeof (nodes[nKey].health_state) === 'boolean' && nodes[nKey].health_state) {
                    online_count += 1;
                } else {
                    offine_count += 1;
                }
            }
            serviceList.push({
                name: sKey,
                online_count: online_count,
                offine_count: offine_count
            })
        }
        serviceList = serviceList.sort(function(a, b){return a.name.localeCompare(b.name,'zh-CN')})

        return serviceList
    })(), (html) => {
        document.getElementById(_console_view_id_name).innerHTML = html;
    });
    form.render()
}



const tl_ops_web_console_change_nav = function (type) {
    cur_type = type;
    if (type == 'health') {
        document.getElementById("health-nav").className = 'tl-inspector-span tl-inspector-span-active'
        document.getElementById("balance-nav").className = 'tl-inspector-span '
        document.getElementById("fuselimit-nav").className = 'tl-inspector-span '
        document.getElementById("waf-nav").className = 'tl-inspector-span '

        tl_ops_web_console_echarts_health_render(res_data.service)
    } else if (type === 'balance') {
        document.getElementById("balance-nav").className = 'tl-inspector-span tl-inspector-span-active'
        document.getElementById("health-nav").className = 'tl-inspector-span '
        document.getElementById("fuselimit-nav").className = 'tl-inspector-span '
        document.getElementById("waf-nav").className = 'tl-inspector-span '

        tl_ops_web_console_echarts_balance_render(res_data.service)
    } else if (type === 'fuselimit') {
        document.getElementById("fuselimit-nav").className = 'tl-inspector-span tl-inspector-span-active'
        document.getElementById("balance-nav").className = 'tl-inspector-span '
        document.getElementById("health-nav").className = 'tl-inspector-span '
        document.getElementById("waf-nav").className = 'tl-inspector-span '

        tl_ops_web_console_echarts_fuselimit_render(res_data.service)
    } else if (type === 'waf') {
        document.getElementById("waf-nav").className = 'tl-inspector-span tl-inspector-span-active'
        document.getElementById("balance-nav").className = 'tl-inspector-span '
        document.getElementById("health-nav").className = 'tl-inspector-span '
        document.getElementById("fuselimit-nav").className = 'tl-inspector-span '

        tl_ops_web_console_echarts_waf_render(res_data.service)
    }
}


function getDateStr(day) {
    let cur = new Date();
    cur.setDate(cur.getDate() + day);
    let y = cur.getFullYear();
    let m = cur.getMonth() + 1;
    let d = cur.getDate();
    return y + '-' + (m < 10 ? '0' + m : m) + '-' + (d < 10 ? '0' + d : d);
}