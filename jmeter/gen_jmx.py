# -*- coding: utf-8 -*-
"""
生成农产品电商平台压力测试的 JMeter 测试计划(.jmx)
用法: python gen_jmx.py
"""
import os

BASE = os.path.dirname(os.path.abspath(__file__))

HEADER = '''<?xml version="1.0" encoding="UTF-8"?>
<jmeterTestPlan version="1.2" properties="5.0" jmeter="5.6.3">
  <hashTree>
    <TestPlan guiclass="TestPlanGui" testclass="TestPlan" testname="{plan_name}" enabled="true">
      <stringProp name="TestPlan.comments">农产品溯源电商平台压力测试</stringProp>
      <boolProp name="TestPlan.functional_mode">false</boolProp>
      <boolProp name="TestPlan.serialize_threadgroups">false</boolProp>
      <elementProp name="TestPlan.user_defined_variables" elementType="Arguments" guiclass="ArgumentsPanel" testclass="Arguments" testname="User Defined Variables" enabled="true">
        <collectionProp name="Arguments.arguments"/>
      </elementProp>
    </TestPlan>
    <hashTree>
'''

FOOTER = '''    </hashTree>
  </hashTree>
</jmeterTestPlan>
'''


def thread_group(name, threads, ramp, loops, enabled=True, duration=None):
    scheduler = "true" if duration else "false"
    return f'''      <ThreadGroup guiclass="ThreadGroupGui" testclass="ThreadGroup" testname="{name}" enabled="{str(enabled).lower()}">
        <stringProp name="ThreadGroup.on_sample_error">continue</stringProp>
        <elementProp name="ThreadGroup.main_controller" elementType="LoopController" guiclass="LoopControlPanel" testclass="LoopController" testname="Loop Controller" enabled="true">
          <boolProp name="LoopController.continue_forever">{"true" if duration else "false"}</boolProp>
          <stringProp name="LoopController.loops">{loops}</stringProp>
        </elementProp>
        <stringProp name="ThreadGroup.num_threads">{threads}</stringProp>
        <stringProp name="ThreadGroup.ramp_time">{ramp}</stringProp>
        <boolProp name="ThreadGroup.scheduler">{scheduler}</boolProp>
        <stringProp name="ThreadGroup.duration">{duration if duration else ""}</stringProp>
        <stringProp name="ThreadGroup.delay"></stringProp>
      </ThreadGroup>
      <hashTree>
'''


def defaults():
    return '''        <ConfigTestElement guiclass="HttpDefaultsGui" testclass="ConfigTestElement" testname="HTTP Request Defaults" enabled="true">
          <elementProp name="HTTPsampler.Arguments" elementType="Arguments" guiclass="HTTPArgumentsPanel" testclass="Arguments" testname="User Defined Variables" enabled="true">
            <collectionProp name="Arguments.arguments"/>
          </elementProp>
          <stringProp name="HTTPSampler.domain">127.0.0.1</stringProp>
          <stringProp name="HTTPSampler.port">8085</stringProp>
          <stringProp name="HTTPSampler.protocol">http</stringProp>
          <stringProp name="HTTPSampler.contentEncoding">UTF-8</stringProp>
          <stringProp name="HTTPSampler.path"></stringProp>
          <boolProp name="HTTPSampler.image_parser">false</boolProp>
        </ConfigTestElement>
        <hashTree/>
        <CookieManager guiclass="CookiePanel" testclass="CookieManager" testname="HTTP Cookie Manager" enabled="true">
          <collectionProp name="CookieManager.cookies"/>
          <boolProp name="CookieManager.clearEachIteration">false</boolProp>
        </CookieManager>
        <hashTree/>
        <HeaderManager guiclass="HeaderPanel" testclass="HeaderManager" testname="HTTP Header Manager" enabled="true">
          <collectionProp name="HeaderManager.headers">
            <elementProp name="" elementType="Header">
              <stringProp name="Header.name">User-Agent</stringProp>
              <stringProp name="Header.value">JMeter-5.6.3-LoadTest</stringProp>
            </elementProp>
          </collectionProp>
        </HeaderManager>
        <hashTree/>
'''


def sampler(name, method, path, params=None, comment=""):
    args = ""
    if params:
        items = ""
        for k, v in params.items():
            items += f'''
            <elementProp name="{k}" elementType="HTTPArgument">
              <boolProp name="HTTPArgument.always_encode">true</boolProp>
              <stringProp name="Argument.value">{v}</stringProp>
              <stringProp name="Argument.metadata">=</stringProp>
              <boolProp name="HTTPArgument.use_equals">true</boolProp>
              <stringProp name="Argument.name">{k}</stringProp>
            </elementProp>'''
        args = f'''
          <elementProp name="HTTPsampler.Arguments" elementType="Arguments" guiclass="HTTPArgumentsPanel" testclass="Arguments" testname="User Defined Variables" enabled="true">
            <collectionProp name="Arguments.arguments">{items}
            </collectionProp>
          </elementProp>'''
    else:
        args = '''
          <elementProp name="HTTPsampler.Arguments" elementType="Arguments" guiclass="HTTPArgumentsPanel" testclass="Arguments" testname="User Defined Variables" enabled="true">
            <collectionProp name="Arguments.arguments"/>
          </elementProp>'''

    return f'''        <HTTPSamplerProxy guiclass="HttpTestSampleGui" testclass="HTTPSamplerProxy" testname="{name}" enabled="true">{args}
          <stringProp name="HTTPSampler.domain"></stringProp>
          <stringProp name="HTTPSampler.port"></stringProp>
          <stringProp name="HTTPSampler.protocol"></stringProp>
          <stringProp name="HTTPSampler.contentEncoding">UTF-8</stringProp>
          <stringProp name="HTTPSampler.path">{path}</stringProp>
          <stringProp name="HTTPSampler.method">{method}</stringProp>
          <stringProp name="HTTPSampler.comment">{comment}</stringProp>
          <boolProp name="HTTPSampler.follow_redirects">true</boolProp>
          <boolProp name="HTTPSampler.auto_redirects">false</boolProp>
          <boolProp name="HTTPSampler.use_keepalive">true</boolProp>
          <boolProp name="HTTPSampler.DO_MULTIPART_POST">false</boolProp>
          <stringProp name="HTTPSampler.embedded_url_re"></stringProp>
          <stringProp name="HTTPSampler.connect_timeout">10000</stringProp>
          <stringProp name="HTTPSampler.response_timeout">30000</stringProp>
        </HTTPSamplerProxy>
        <hashTree/>
'''


def listener_summary():
    return '''        <ResultCollector guiclass="SummaryReport" testclass="ResultCollector" testname="Summary Report" enabled="true">
          <boolProp name="ResultCollector.error_logging">false</boolProp>
          <objProp>
            <name>saveConfig</name>
            <value class="SampleSaveConfiguration">
              <time>true</time>
              <latency>true</latency>
              <timestamp>true</timestamp>
              <success>true</success>
              <label>true</label>
              <code>true</code>
              <message>true</message>
              <threadName>true</threadName>
              <dataType>true</dataType>
              <encoding>false</encoding>
              <assertions>true</assertions>
              <subresults>true</subresults>
              <responseData>false</responseData>
              <samplerData>false</samplerData>
              <xml>false</xml>
              <fieldNames>true</fieldNames>
              <responseHeaders>false</responseHeaders>
              <requestHeaders>false</requestHeaders>
              <responseDataOnError>false</responseDataOnError>
              <saveAssertionResultsFailureMessage>true</saveAssertionResultsFailureMessage>
              <assertionsResultsToSave>0</assertionsResultsToSave>
              <bytes>true</bytes>
              <sentBytes>true</sentBytes>
              <url>true</url>
              <threadCounts>true</threadCounts>
              <idleTime>true</idleTime>
              <connectTime>true</connectTime>
            </value>
          </objProp>
          <stringProp name="filename"></stringProp>
        </ResultCollector>
        <hashTree/>
'''


# ---------------- 核心接口清单 ----------------
REQUESTS = [
    ("01-首页index.jsp", "GET", "/nongchanpin/index.jsp", None, "前台首页：商品列表+公告+轮播图"),
    ("02-商品列表productmore.jsp", "GET", "/nongchanpin/productmore.jsp", None, "商品分页列表"),
    ("03-商品详情productDetail.jsp", "GET", "/nongchanpin/productDetail.jsp?id=${__Random(30,35)}", None, "商品详情，商品ID 30~35 随机"),
    ("04-商品搜索search.jsp", "GET", "/nongchanpin/search.jsp?proname=%E5%A4%A7%E8%91%B1", None, "搜索关键词：大葱"),
    ("05-公告列表notices.jsp", "GET", "/nongchanpin/notices.jsp", None, "公告列表"),
    ("06-留言板msg.jsp", "GET", "/nongchanpin/msg.jsp", None, "留言板"),
    ("07-会员登录memberLogin.action", "POST", "/nongchanpin/memberLogin.action",
     {"uname": "zhangsan", "upass": "123"}, "会员登录（含MD5校验+数据库查询）"),
]


def build_load_scenario(filename, plan_name, tg_name, threads, ramp, loops, duration=None):
    body = HEADER.format(plan_name=plan_name)
    body += thread_group(tg_name, threads, ramp, loops, duration=duration)
    body += defaults()
    for r in REQUESTS:
        body += sampler(r[0], r[1], r[2], r[3], r[4])
    body += listener_summary()
    body += "      </hashTree>\n"
    body += FOOTER
    path = os.path.join(BASE, filename)
    with open(path, "w", encoding="utf-8") as f:
        f.write(body)
    print("generated:", path)


def build_flow_scenario(filename):
    """完整业务流程：登录→首页→商品详情→加入购物车→查看购物车→退出"""
    plan_name = "农产品电商-完整业务流程压测"
    body = HEADER.format(plan_name=plan_name)
    body += thread_group("S5-业务流程-10并发", 10, 10, 5)
    body += defaults()
    flow = [
        ("1-会员登录", "POST", "/nongchanpin/memberLogin.action",
         {"uname": "zhangsan", "upass": "123"}, "前置：会员 zhangsan 登录"),
        ("2-浏览首页", "GET", "/nongchanpin/index.jsp", None, "登录后浏览首页"),
        ("3-商品详情", "GET", "/nongchanpin/productDetail.jsp?id=30", None, "查看商品ID=30"),
        ("4-加入购物车", "POST", "/nongchanpin/carAdd.action",
         {"productid": "30", "num": "1", "memberid": "7"}, "加入购物车，memberid=7(zhangsan)"),
        ("5-查看购物车", "GET", "/nongchanpin/car.jsp", None, "查看购物车列表"),
        ("6-退出登录", "GET", "/nongchanpin/memberExit.action", None, "退出登录"),
    ]
    for f in flow:
        body += sampler(f[0], f[1], f[2], f[3], f[4])
    body += listener_summary()
    body += "      </hashTree>\n"
    body += FOOTER
    path = os.path.join(BASE, filename)
    with open(path, "w", encoding="utf-8") as f:
        f.write(body)
    print("generated:", path)


if __name__ == "__main__":
    build_load_scenario("nongchanpin-S1-20.jmx", "场景S1-基础负载(20并发持续60秒)",
                        "S1-基础负载-20线程持续60秒", 20, 5, -1, duration=60)
    build_load_scenario("nongchanpin-S2-50.jmx", "场景S2-中等负载(50并发持续60秒)",
                        "S2-中等负载-50线程持续60秒", 50, 5, -1, duration=60)
    build_load_scenario("nongchanpin-S3-100.jmx", "场景S3-高并发(100并发持续60秒)",
                        "S3-高并发-100线程持续60秒", 100, 5, -1, duration=60)
    build_load_scenario("nongchanpin-S4-200.jmx", "场景S4-极限并发(200并发持续60秒)",
                        "S4-极限并发-200线程持续60秒", 200, 5, -1, duration=60)
    build_load_scenario("nongchanpin-S6-持续压力.jmx", "场景S6-持续压力(50并发持续120秒)",
                        "S6-持续压力-50线程120秒", 50, 10, 1, duration=120)
    build_flow_scenario("nongchanpin-S5-业务流程.jmx")
