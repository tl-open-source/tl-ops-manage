const _console_echarts_view_id_name = "tl-ops-web-console-echarts-service-view";
const _console_echarts_tlp_id_name = "tl-ops-web-console-echarts-service-tpl";

const _console_view_id_name = "tl-ops-web-console-service-view";
const _console_tlp_id_name = "tl-ops-web-console-service-tpl";

let res_data = {};

const tl_ops_web_console_main = function () {
    window.$ = layui.$;
    window.form = layui.form;
    window.table = layui.table;
    window.laytpl = layui.laytpl;

    window.consoleEchartsList = [];

    axios.get("/tlops/health/state").then((res) => {
        res = res.data;
        if (res.code === 0) {
            res_data = res.data
            let service_data = res.data.service
            //渲染dom
            tl_ops_web_console_echarts_health_render(service_data)
            tl_ops_web_console_service_state_render(service_data)
        }
    }).then((res) => {
        window.onresize = function () {
            consoleEchartsList.forEach((item) => {
                item.resize();
            })
        };
    })
};


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
        return serviceList
    })(), (html) => {
        document.getElementById(_console_view_id_name).innerHTML = html;
    });
    form.render()
}




//health echarts 
const tl_ops_web_console_echarts_health_render = function (data) {
    let serviceList = [];
    for(let serviceName in data){
        serviceList.push({
            id : serviceName
        })
    }
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

//health echarts option
const tl_ops_web_console_echarts_health_options = function (data) {
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
    var consoleEchart = echarts.init(document.getElementById(data.id));
    consoleEchart.setOption(option);

    consoleEchartsList.push(consoleEchart);
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




//balance echarts 
const tl_ops_web_console_echarts_balance_render = function (data) {
    let serviceList = [];
    for(let serviceName in data){
        serviceList.push({
            id : serviceName
        })
    }
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

//balance echarts option
const tl_ops_web_console_echarts_balance_options = function (data) {
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
    var consoleEchart = echarts.init(document.getElementById(data.id));
    consoleEchart.setOption(option);

    consoleEchartsList.push(consoleEchart);
}

//balance 统计数量 (以当天为单位)
const tl_ops_web_console_balance_time_list_caculate_days = function (data) {
    let config = []
    for (let key in data) {
        let balance_count = 0; //服务总量统计
        let seriesBalanceList = [];
        let nodes = data[key].nodes;
        for (let skey in nodes) {
            let balanceSuccessList = nodes[skey].balance_success;

            for (let time in balanceSuccessList) {
                let count = balanceSuccessList[time];
                balance_count += count;
            }

            let dayTimeCountList = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0] //节点总量统计
            for (let timeItem in balanceSuccessList) {
                let count = balanceSuccessList[timeItem];
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




//fuselimit echarts
const tl_ops_web_console_echarts_fuselimit_render = function (data) {
    let serviceList = [];
    for(let serviceName in data){
        let nodeList = [];
        for(let nodeName in data[serviceName].nodes){
            nodeList.push({
                id : nodeName
            })
        }
        serviceList.push({
            id : serviceName,
            nodes : nodeList
        })
    }
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

//fuselimit options
const tl_ops_web_console_echarts_fuselimit_options = function (data) {
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
                },
            },
            {
                type: 'text',
                right: 0,
                top: 0,
                z: 2,
                zlevel: 100,
                style: {
                    text: '路由成功 : '+data.success,
                    fontWeight: 'bold',
                    fill: data.fill,
                    textAlign: 'center',
                    fontSize: 12,
                },
            },
            {
                type: 'text',
                right: 0,
                top: '10%',
                z: 2,
                zlevel: 100,
                style: {
                    text: '路由失败 : '+data.failed,
                    fontWeight: 'bold',
                    fill: data.fill,
                    textAlign: 'center',
                    fontSize: 12,
                },
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

    var consoleEchart = echarts.init(document.getElementById(data.id));
    consoleEchart.setOption(option);

    consoleEchartsList.push(consoleEchart);
}

//fuselimit 统计数量
const tl_ops_web_console_fuselimit_state_caculate = function () {
    let config = []
    if(res_data === null || res_data === undefined){
        return;
    }
    let data = res_data.service;
    let option_list = res_data.limit.option_list
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
            serviceFill = "#5adfae";
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
                nodeFill = "#5adfae";
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



const tl_ops_web_console_change_nav = function (type) {
    if (type == 'health') {
        document.getElementById("health-nav").className = 'tl-inspector-span tl-inspector-span-active'
        document.getElementById("balance-nav").className = 'tl-inspector-span '
        document.getElementById("fuselimit-nav").className = 'tl-inspector-span '

        document.getElementById("tl-balance-span").style.display = "none"

        tl_ops_web_console_echarts_health_render(res_data.service)
    } else if (type === 'balance') {
        document.getElementById("balance-nav").className = 'tl-inspector-span tl-inspector-span-active'
        document.getElementById("health-nav").className = 'tl-inspector-span '
        document.getElementById("fuselimit-nav").className = 'tl-inspector-span '

        document.getElementById("tl-balance-span").style.display = "block"

        tl_ops_web_console_echarts_balance_render(res_data.service)
    } else if (type === 'fuselimit') {
        document.getElementById("fuselimit-nav").className = 'tl-inspector-span tl-inspector-span-active'
        document.getElementById("balance-nav").className = 'tl-inspector-span '
        document.getElementById("health-nav").className = 'tl-inspector-span '

        document.getElementById("tl-balance-span").style.display = "none"

        tl_ops_web_console_echarts_fuselimit_render(res_data.service)
    }
}


function getDateStr(day) {
    let cur = new Date();
    cur.setDate(cur.getDate() + day);
    let y = cur.getFullYear();
    let m = cur.getMonth() + 1;
    let d = cur.getDate();
    return y + '-' + (m < 10 ? '0' + m : m) + '-' + d;
}