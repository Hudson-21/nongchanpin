# 农产品溯源电商服务平台（nongchanpin）测试报告

- 测试时间：2026-09-22
- 测试环境：Windows 11 / JDK 1.8.0_501 / Tomcat 9.0.122 / MySQL 8.0.28 / IDEA 2025.3.3 社区版 + Smart Tomcat
- 测试方式：HTTP 接口 + 会话保持（Cookie）+ 数据库落库校验（mysql 客户端直连核对）
- 测试地址：http://127.0.0.1:8085/nongchanpin（独立测试实例，未占用 8080）

---

## 一、测试结论概览

| 模块 | 用例数 | 通过 | 失败 | 结论 |
|---|---|---|---|---|
| 前台页面渲染 | 12 | 11 | 1 | 基本正常 |
| 权限控制 | 4 | 4 | 0 | 拦截有效但方式不合理（见缺陷 1） |
| 会员注册/登录 | 4 | 4 | 0 | 通过 |
| 会员中心页面 | 4 | 4 | 0 | 通过 |
| 后台管理页面 | 14 | 14 | 0 | 通过 |
| 后台增删改 | 6 | 6 | 0 | 通过（含数据库校验） |
| 购物车/下单 | 3 | 3 | 0 | 通过（含数据库校验） |
| 订单流转（付款/发货/退货） | 4 | 1 | 3 | **存在缺陷**（见缺陷 2、3） |
| 搜索/留言 | 2 | 2 | 0 | 通过 |
| **合计** | **53** | **49** | **4** | 核心购物链路可用 |

---

## 二、详细测试结果

### 1. 前台公开页面
| 页面 | 结果 |
|---|---|
| /index.jsp | 200（37987 字节，标题“农产品溯源电商服务平台”） |
| /login.jsp、/register.jsp、/notices.jsp、/msg.jsp、/help.jsp、/productmore.jsp、/hotsales.jsp、/search.jsp、/admin/login.jsp、/noticeDetail.jsp?id=1 | 全部 200 |
| /productDetail.jsp?id=1 | 失败（库中无 id=1 的商品，实际商品 id 从 30 起；换真实 id 后正常，非功能缺陷） |

### 2. 权限控制
未登录访问 `/car.jsp`、`/orders.jsp`、`/memberinfo.jsp`、`/fav.jsp` 均被拦截（500/连接中断），登录后全部 200 —— 会话权限控制有效。

### 3. 会员流程
- 注册（uname/upass/realname/sex/age/tel/addr/type）：成功，数据库 `sysuser` 表落库正确，密码以 MD5 大写形式存储，中文（会员、姓名）编码正确。
- 登录正确密码：成功（`location.replace("/nongchanpin/index.jsp")`）
- 登录错误密码：失败并提示“用户名或密码错误”
- 登录后 `/car.jsp`、`/orders.jsp`、`/memberinfo.jsp`、`/fav.jsp` 全部 200

### 4. 后台管理（管理员 adm304）
14 个页面全部 200：公告、分类、商品、留言、订单、退货、会员、广告、入库记录、库存、推荐商品、销售统计、财务统计、修改密码。

### 5. 后台业务操作（含数据库校验）
| 操作 | 结果 | 数据库校验 |
|---|---|---|
| 新增分类「测试分类83」 | 200 | protype 表新增 id=17 ✔ |
| 删除分类 id=17 | 200 | 记录已删除（count=0）✔ |
| 新增公告「测试公告88」 | 200 | notice 表新增 id=8 ✔ |
| 删除公告 id=8 | 200 | 记录已删除 ✔ |
| 发表留言 | 200 | msg 表新增 id=37 ✔ |
| 后台回复留言 msgReply | 200 | ✔ |
| 删除留言 msgDel | 200 | ✔ |

### 6. 前台购物流程（含数据库校验）
| 步骤 | 结果 | 数据库校验 |
|---|---|---|
| 加入购物车 carAdd（productid=30, num=2） | 返回 `1`（Ajax 成功） | car 表新增 id=12 ✔ |
| 提交订单 orderAdd | 成功 | orders 表新增 id=40，金额 39.6，状态「未付款/未发货」✔ |
| 下单后购物车清空 | 成功 | car 表该会员记录数 = 0 ✔ |
| 搜索（proname=大葱） | 200 | — |

### 7. 订单流转（失败项）
| 操作 | 结果 | 说明 |
|---|---|---|
| 会员付款 orderFk → bank.jsp | 连接中断/500 | 数据已更新为「已付款」，但跳转支付页 bank.jsp 报错 |
| 管理员发货 orderFh | 500 | Action 内部异常 |
| 会员申请退货 orderTh | 请求异常 | 数据实际已变更（fhstatus=退货申请中、type=1） |
| 退货管理页 admin/ordersth.jsp | 500 | 页面渲染异常 |

---

## 三、发现并已修复的问题（阻塞级）

| # | 问题 | 原因 | 处理 |
|---|---|---|---|
| 1 | 后台/前台全部报 404 | `WebContent/WEB-INF/classes` 残留 Eclipse 旧编译产物，`struts.xml` 被 classpath 加载两遍，Struts 报 package 'liu' 重复 | 删除该 classes 目录 |
| 2 | 首页 500 | `top.jsp` 开头丢失 `<%`，`basePath` 变量未定义，JSP 编译失败 | 已补回脚本块起始标签 |
| 3 | 数据库连不上 | 驱动 mysql-connector 5.0.4（2006 年）不支持 MySQL 8 认证 | 换用本机 `D:\mysql-connector-j-26.7.0` 的 26.7.0 驱动 |
| 4 | Access denied | 配置密码为 root，实际为 123456 | 已改为 123456 |
| 5 | Hibernate 方言错误 | 配置写成 `SQLServerDialect`，库是 MySQL | 改为 `MySQLDialect`，并补充 `useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=Asia/Shanghai` |
| 6 | **会员登录始终失败** | 源码编码不统一：`com\util` 下 4 个文件（PageManager、Pagination、StringFilter、Util）是 GBK，其余 31 个是 UTF-8；IDEA 按系统默认 GBK 编译，导致 `SysuserAction` 中 `type='会员'` 变成乱码 `浼氬憳`，与库中数据不匹配 | 已将 4 个文件转为 UTF-8 并用 `javac -encoding UTF-8` 重新编译，验证字节码已恢复为「会员」 |

> ⚠️ 问题 6 需在 IDEA 中固化，否则重新构建后会复发：
> `设置 → 编辑器 → 文件编码`：全局/项目编码改为 **UTF-8**
> `设置 → 构建、执行、部署 → 编译器 → Java 编译器 → 附加命令行参数`：`-encoding UTF-8`
> Smart Tomcat 运行配置 VM options 建议加：`-Dfile.encoding=UTF-8`

---

## 四、遗留缺陷（建议修复，未改动代码）

| # | 缺陷 | 位置 | 建议 |
|---|---|---|---|
| 1 | 未登录访问受限页面直接抛 500，未跳转登录页 | car.jsp / orders.jsp / memberinfo.jsp / fav.jsp | 页面开头判断 `session.getAttribute("member")==null` 时 `response.sendRedirect("login.jsp")` |
| 2 | 管理员发货报错 | `OrderAction.orderFh()` 第 190-213 行 | 新建的 `Kcrecord` 调用了 `commonDAO.update(kc)`，无主键应改为 `save(kc)`；且 `proinfo.split("-"/",")` 对非标准格式数据会数组越界，需加校验 |
| 3 | 同意退货报错 | `OrderAction.adminOrderTh()` 第 234 行起 | 同上，`update(kc)` 应改为 `save(kc)` |
| 4 | 支付页 bank.jsp 报错 | 付款后跳转 `/bank.jsp` | 需排查页面取值（订单信息传递方式） |
| 5 | 退货管理页 500 | `admin/ordersth.jsp` | 需排查页面在退货订单数据下的渲染逻辑 |
| 6 | 商品新增需上传图片 | `ProductAction.productAdd` | 本次以 GET/表单方式无法覆盖文件上传，建议手工在页面上验证一次 |

---

## 五、测试数据（可清理）

测试过程中在数据库 `db_jspnongchanpin` 中产生了以下数据，如需清理请告知：

- 会员账号：`tester4051`、`tester9579`、`chk268`、`mem225`（密码均为 123456）
- 管理员账号：`adm304`（密码 123456）
- 订单：id=40（已付款/退货申请中）
- 其余：留言、分类、公告均已随删除用例清除

---

## 六、如何启动项目（复现测试）

1. IDEA 中选中 Smart Tomcat 配置 `nongchanpin` 运行（Tomcat 主目录 `D:\apache-tomcat-9.0.122`，部署目录 `E:\nongchanpin\WebContent`，Context `/nongchanpin`）
2. 确保 MySQL 已启动、库 `db_jspnongchanpin` 存在
3. 访问 http://localhost:8080/nongchanpin/
4. 管理员可用库中原有账号 `admin` 登录后台
