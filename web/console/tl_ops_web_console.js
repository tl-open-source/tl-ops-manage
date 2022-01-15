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
            let service_data = res.data.service
            //渲染dom
            tl_ops_web_console_echarts_dom_render(service_data)
            tl_ops_web_console_dom_render(service_data)

            //渲染echarts
            for(let key in service_data){
                let serviceList = Object.keys(service_data[key]);//服务列表
                let successList = [];//成功列表
                let failedList = [];//失败列表
                let service = service_data[key];//节点列表
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
                
                tl_ops_web_console_echarts_render({
                    id : key,
                    online_count : online_count,
                    offine_count : offine_count,
                    nodeList : serviceList,
                    successList : successList,
                    failedList : failedList
                })
            }
        }
    }).then((res)=>{
        window.onresize = function() {
            consoleEchartsList.forEach((item)=>{
                item.resize();
            })
        };
    })
};


const tl_ops_web_console_echarts_dom_render = function( data ){
    laytpl(document.getElementById(_console_echarts_tlp_id_name).innerHTML).render((()=>{
        return Object.keys(data)
    })(), (html)=>{
        document.getElementById(_console_echarts_view_id_name).innerHTML = html;
    });
    form.render()
}


const tl_ops_web_console_dom_render = function( data ){
    laytpl(document.getElementById(_console_tlp_id_name).innerHTML).render((()=>{
        let nodeList = {};
        for(let key in data){
            for(let node in data[key]){
                nodeList[node] = data[key][node];
            }
        }
        return nodeList
    })(), (html)=>{
        document.getElementById(_console_view_id_name).innerHTML = html;
    });
    form.render()
}

const tl_ops_web_console_echarts_render = function( data ){
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
                    color: '#3582fb',
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
                    color: '#93c36b',
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
            },
            {
                name: '心跳失败',
                type: 'bar',
                smooth: true,
                yAxisIndex: 1,
                data: data.failedList
            }
        ]
    };
    var consoleEchart = echarts.init(document.getElementById(data.id));
    consoleEchart.setOption(option);

    consoleEchartsList.push(consoleEchart);
}