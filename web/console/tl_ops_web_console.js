const _console_echarts_view_id_name = "tl-ops-web-console-echarts-service-view";
const _console_echarts_tlp_id_name = "tl-ops-web-console-echarts-service-tpl";

const _console_view_id_name = "tl-ops-web-console-service-view";
const _console_tlp_id_name = "tl-ops-web-console-service-tpl";

let res_data = {};

const tl_ops_web_console_main = function (){
    window.$ = layui.$;
    window.form = layui.form;
    window.table = layui.table;
    window.laytpl = layui.laytpl;
    
    window.consoleEchartsList = [];

    axios.get("/tlops/health/state").then((res)=>{
        res = res.data;
        if(res.code === 0){
            res_data = res.data
            let service_data = res.data.service
            //渲染dom
            tl_ops_web_console_echarts_health_render(service_data)
            tl_ops_web_console_service_state_render(service_data)
        }
    }).then((res)=>{
        window.onresize = function() {
            consoleEchartsList.forEach((item)=>{
                item.resize();
            })
        };
    })
};


//service state render
const tl_ops_web_console_service_state_render = function( data ){
    laytpl(document.getElementById(_console_tlp_id_name).innerHTML).render((()=>{
        let serviceList = [];
        for(let sKey in data){
            let online_count = 0
            let offine_count = 0
            for(let nKey in data[sKey]){
                if(typeof(data[sKey][nKey].state) === 'boolean' && data[sKey][nKey].state){
                    online_count += 1;
                }else{
                    offine_count += 1;
                }
            }
            serviceList.push({
                name : sKey,
                online_count : online_count,
                offine_count : offine_count
            })
        }
        return serviceList
    })(), (html)=>{
        document.getElementById(_console_view_id_name).innerHTML = html;
    });
    form.render()
}




//health echarts 
const tl_ops_web_console_echarts_health_render = function( data ){
    laytpl(document.getElementById(_console_echarts_tlp_id_name).innerHTML).render((()=>{
        return data ? Object.keys(data) : []
    })(), (html)=>{
        document.getElementById(_console_echarts_view_id_name).innerHTML = html;
    });
    form.render()

    //渲染echarts
    tl_ops_web_console_health_state_caculate(data).forEach((item)=>{
        tl_ops_web_console_echarts_health_options(item)
    })
}

//health echarts option
const tl_ops_web_console_echarts_health_options = function( data ){
    var option = {
        title : {
            text : `${data.id}-在线节点:${data.online_count}-下线节点:${data.offine_count}`,
            show : true,
            textStyle: {
                fontSize: 14,
            },
            x : 'center',
            y : 'bottom'
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
                    formatter:function(val){  
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
                color : '#01AAED',
                itemStyle: {
                    normal: {
                        color: function(params) {return '#01AAED';}
                    }
                },
            },
            {
                name: '心跳失败',
                type: 'bar',
                smooth: true,
                yAxisIndex: 1,
                color : '#bfbfbf',
                data: data.failedList,
                itemStyle: {
                    normal: {
                        color: function(params) {return '#bfbfbf';}
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
const tl_ops_web_console_health_state_caculate = function(data){
    let config = []
    for(let key in data){
        let serviceList = Object.keys(data[key]);//服务列表
        let successList = [];//成功列表
        let failedList = [];//失败列表
        let service = data[key];//节点列表
        let online_count = 0; //在线节点数
        let offine_count = 0; //下线节点数
        for(let skey in service){
            state = service[skey].state;
            if(typeof(service[skey].state) === 'boolean' && service[skey].state){
                online_count += 1;
            }else{
                offine_count += 1;
            }
            successList.push(parseInt(service[skey].success))
            failedList.push(typeof(service[skey].failed) === 'string' ? 0 : parseInt(service[skey].failed))
        }
        
        config.push({
            id : key,
            online_count : online_count,
            offine_count : offine_count,
            nodeList : serviceList,
            successList : successList,
            failedList : failedList
        })
    }
    return config
}




//balance echarts 
const tl_ops_web_console_echarts_balance_render = function( data ){
    laytpl(document.getElementById(_console_echarts_tlp_id_name).innerHTML).render((()=>{
        return data ? Object.keys(data) : []
    })(), (html)=>{
        document.getElementById(_console_echarts_view_id_name).innerHTML = html;
    });
    form.render()

    //渲染echarts
    tl_ops_web_console_balance_time_list_caculate_days(data).forEach((item)=>{
        tl_ops_web_console_echarts_balance_options(item)
    })
}

//balance echarts option
const tl_ops_web_console_echarts_balance_options = function( data ){
    var option = {
        title : {
            text : `${data.id}-负载总量:${data.balance_count}`,
            show : true,
            textStyle: {
                fontSize: 14,
            },
            x : 'center',
            y : 'bottom'
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
                formatter:function(val){  
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
const tl_ops_web_console_balance_time_list_caculate_days = function ( data ){
    let config = []
    for(let key in data){    
        let balance_count = 0; //服务总量统计
        let seriesBalanceList = [];
        for(let skey in data[key]){
            let balanceSuccessList = data[key][skey].balance_success;

            for(let time in balanceSuccessList){
                let count = balanceSuccessList[time];
                balance_count += count;
            }

            let dayTimeCountList = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0] //节点总量统计
            for(let timeItem in balanceSuccessList){
                let count = balanceSuccessList[timeItem];
                let day = timeItem.toString().split(" ")[0]
                let time = timeItem.toString().split(" ")[1]
                let hours = parseInt(time.split(":")[0])
                let cur_day = getDateStr(0);

                //当天内
                if(day.includes(cur_day)){
                    let dayTimeCountIndex = parseInt((hours % 2) === 0 ? (hours / 2) : (hours / 2) + 1) - 1;
                    dayTimeCountList[ dayTimeCountIndex ] += count
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
            id : key,
            balance_count : balance_count,
            seriesBalanceList : seriesBalanceList,
            timeList : ['1点','3点','5点','7点','9点','11点','13点','15点','17点','19点','21点','23点']
        })
    }
    return config
}


//fuselimit echarts
const tl_ops_web_console_echarts_fuselimit_render = function( data ){

}




const tl_ops_web_console_change_nav = function( type ){
    if ( type == 'health'){
        document.getElementById("health-nav").className = 'tl-inspector-span tl-inspector-span-active'
        document.getElementById("balance-nav").className = 'tl-inspector-span '
        document.getElementById("fuselimit-nav").className = 'tl-inspector-span '
        
        document.getElementById("tl-balance-span").style.display = "none"

        tl_ops_web_console_echarts_health_render(res_data.service)
    }else if(type === 'balance'){
        document.getElementById("balance-nav").className = 'tl-inspector-span tl-inspector-span-active'
        document.getElementById("health-nav").className = 'tl-inspector-span '
        document.getElementById("fuselimit-nav").className = 'tl-inspector-span '

        document.getElementById("tl-balance-span").style.display = "block"

        tl_ops_web_console_echarts_balance_render(res_data.service)
    }else if(type === 'fuselimit'){
        document.getElementById("fuselimit-nav").className = 'tl-inspector-span tl-inspector-span-active'
        document.getElementById("balance-nav").className = 'tl-inspector-span '
        document.getElementById("health-nav").className = 'tl-inspector-span '

        document.getElementById("tl-balance-span").style.display = "none"

        tl_ops_web_console_echarts_fuselimit_render(res_data.service)
    }
}


function getDateStr( day ) {
    let cur = new Date();
    cur.setDate(cur.getDate() + day);
    let y = cur.getFullYear();
    let m = cur.getMonth() + 1;
    let d = cur.getDate();
    return y + '-' + (m < 10 ? '0' + m : m) + '-' + d;
}