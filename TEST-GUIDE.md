# 农产品商城系统（nongchanpin）—— 手工测试操作手册

> 适用：IDEA 社区版 + Smart Tomcat + MySQL 8 + JDK 8
> 建议按顺序执行，每执行完一条在「实际结果」列打 ✓/✗ 并截图（论文写"测试过程"要用）。

---

## 一、测试前准备（必做，跳过会导致测不准）

### 1. 固化 IDEA 编码 —— **最关键的一步**

项目源码里 `com\util` 下的 4 个 java 文件原本是 GBK，其余是 UTF-8，IDEA 默认按系统 GBK 编译会把 `type='会员'` 编译成乱码，**会员登录必定失败**（管理员登录却正常，极具迷惑性）。

已临时用 `javac -encoding UTF-8` 重编译过，但你一点「重新构建」就复发，必须固化：

1. `文件 → 设置 → 编辑器 → 文件编码`：Global / Project / 属性文件默认编码 全部设为 **UTF-8**
2. `文件 → 设置 → 构建、执行、部署 → 编译器 → Java 编译器` → 「附加命令行参数」填：`-encoding UTF-8`
3. `构建 → 重新构建项目`

验证是否生效：用 JDK8 的 `javap` 看字节码里应是「会员」而不是乱码
```
D:\jdk-1.8\bin\javap.exe -p -c -constants E:\nongchanpin\out\production\nongchanpin\com\action\SysuserAction.class | findstr "type="
```

### 2. 确认数据库

```sql
CREATE DATABASE IF NOT EXISTS db_jspnongchanpin DEFAULT CHARACTER SET utf8;
```
表由 Hibernate 的 `hbm2ddl.auto=update` 自动建，不用手动建。账号密码在 `WebContent\WEB-INF\applicationContext.xml` 第 16-17 行（目前是 root/<演示口令>）。

### 3. 启动服务

- 先确认 8080 没被别的项目占用：`netstat -ano | findstr :8080`（你机器上 hospital 项目常占着它）
- 若被占：Smart Tomcat 配置里把 Server port 改成 **8085**，或用任务管理器结束占用进程
- 启动后控制台出现 `Server startup in xxxx ms` 再开始测

浏览器根地址：`http://localhost:8080/nongchanpin/` （端口改成什么就用什么）

### 4. 测试账号（数据库里已存在，直接用）

| 角色 | 账号 | 密码 | 说明 |
|---|---|---|---|
| 管理员 | `admin` | `123` | 后台入口 `/admin/login.jsp` |
| 会员 | `zhangsan` | `123` | 已存在的普通会员（密码哈希 202CB962... = MD5("123")） |
| 商家 | `root` | `root` | 商家角色 |
| 会员（新建） | 自定 | 自定 | 注册流程测试时新建 |

现有初始数据：商品 6 个、分类 6 个、公告 5 条、轮播图 4 张，足够跑通购物流程。

---

## 二、测试用例

### 模块 A：后台基础数据维护（先做，后面流程依赖它）

登录后台：`/admin/login.jsp` → admin / 123

| 编号 | 操作步骤 | 预期结果 | 实际 |
|---|---|---|---|
| A-01 | 后台首页 `/admin/index.jsp` | 正常显示框架页（顶部+左侧菜单+主体） | |
| A-02 | 商品分类 → 新增：填「测试分类A」→ 提交 | 提示成功，分类列表出现该分类 | |
| A-03 | 商品分类 → 修改「测试分类A」为「测试分类A2」 | 列表同步更新 | |
| A-04 | 商品分类 → 删除「测试分类A2」 | 从列表消失 | |
| A-05 | 商品管理 → 新增：编号 P001、名称「测试商品」、**上传一张图片**、价格 30、选择分类、填简介 → 提交 | 商品列表出现该商品，图片可显示 | |
| A-06 | 商品管理 → 修改该商品价格改为 35 | 价格同步更新 | |
| A-07 | 商品管理 → 设为推荐（推荐商品页 `/admin/productsettj.jsp`） | 状态变为推荐，前台「推荐/热卖」能看到 | |
| A-08 | 商品管理 → 取消推荐 | 恢复正常状态 | |
| A-09 | 商品管理 → 删除「测试商品」 | 从列表消失 | |
| A-10 | 公告管理 → 新增：标题「测试公告」+ 内容 → 提交 | 公告列表出现 | |
| A-11 | 公告管理 → 修改 / 删除该公告 | 生效 | |
| A-12 | 轮播图管理 `/admin/imgadv.jsp` → 新增（选位置 HEAD、上传图片） | 前台首页顶部轮播可看到新图 | |
| A-13 | 库存管理 → 入库 `/admin/productrk.jsp`：选商品、数量 100、提交 | 库存记录 `/admin/kcrecord.jsp` 出现入库记录 | |
| A-14 | 库存查看 `/admin/kcview.jsp` | 显示各商品当前库存数 | |
| A-15 | 会员管理 `/admin/member.jsp` | 列出所有会员（含 zhangsan） | |

> ⚠️ A-05 商品图片必须上传，否则前台商品详情页图片裂开；这是脚本测不了、必须手工点的项。

### 模块 B：前台浏览（无需登录）

| 编号 | 操作步骤 | 预期结果 | 实际 |
|---|---|---|---|
| B-01 | 打开 `/index.jsp` | 首页正常显示：轮播图、商品列表、公告栏、无 500 错误 | |
| B-02 | 点击首页某商品 → 商品详情 `/productDetail.jsp?id=x` | 显示商品名称/价格/图片/简介 | |
| B-03 | 商品列表页 `/productmore.jsp` | 分页显示商品，翻页正常 | |
| B-04 | 热卖/推荐 `/hotsales.jsp`、`/producttj.jsp` | 显示对应商品 | |
| B-05 | 公告列表 `/notices.jsp` → 点标题进 `/noticeDetail.jsp?id=x` | 公告正文正常显示 | |
| B-06 | 留言板 `/msg.jsp` | 显示已有留言及管理员回复 | |
| B-07 | 帮助中心 `/help.jsp` | 正常显示 | |
| B-08 | 搜索：搜索框输入「大葱」→ 提交 | `/search.jsp` 列出含「大葱」的商品 | |
| B-09 | 搜索：输入不存在的商品名「zzzz」 | 显示空结果或提示，不应报错 | |

### 模块 C：会员注册 / 登录 / 权限

| 编号 | 操作步骤 | 预期结果 | 实际 |
|---|---|---|---|
| C-01 | `/register.jsp` 填账号 test01、密码 123456、确认密码一致、姓名/性别/年龄/电话/地址 → 提交 | 提示注册成功 | |
| C-02 | 用同名账号 test01 再注册一次 | 提示账号已存在（用户名校验 `/check.action`） | |
| C-03 | 注册时两次密码输入不一致 | 前端提示，不允许提交 | |
| C-04 | 注册时留空必填项 | 前端提示必填，不允许提交 | |
| C-05 | `/login.jsp` 输入 test01 + 错误密码 | 提示「用户名或密码错误」 | |
| C-06 | `/login.jsp` 输入 test01 + 123456 | 登录成功，跳回首页，顶部显示用户名/退出 | |
| C-07 | 登录后点「个人资料」`/memberinfo.jsp` | 显示注册时填写的信息 | |
| C-08 | 修改个人资料（改电话/地址）→ 保存 | 提示成功，重新进入可见新值 | |
| C-09 | 点「退出登录」`/memberExit.action` | 回到首页，顶部恢复未登录状态 | |
| C-10 | **未登录**直接访问 `/car.jsp` | 应跳转登录页（当前是 500 报错，见缺陷 D-01） | |
| C-11 | **未登录**直接访问 `/orders.jsp` | 应跳转登录页（同上） | |
| C-12 | 会员账号尝试登录后台 `/admin/login.jsp` | 应拒绝（当前可执行，见缺陷 D-04） | |

> C-06 若失败，99% 是第一节的编码没固化，回去重做。

### 模块 D：购物车与订单（核心业务流，重点测）

前置：用会员账号登录（zhangsan / 123）

| 编号 | 操作步骤 | 预期结果 | 实际 |
|---|---|---|---|
| D-01 | 商品详情页 → 选数量 2 → 点「加入购物车」 | 提示成功，`/car.jsp` 出现该商品，数量 2 | |
| D-02 | 购物车再加另一件商品 | 购物车两行记录 | |
| D-03 | 修改购物车某商品数量 | 小计金额同步变化 | |
| D-04 | 购物车删除其中一件 | 该行消失 | |
| D-05 | 购物车点「结算」→ `/orderSubmit.jsp` 填收货人/电话/地址 → 提交 | 生成订单，跳 `/orders.jsp` 可见新订单，状态：未付款、未发货 | |
| D-06 | 查库确认：`SELECT * FROM orders ORDER BY id DESC LIMIT 1;` | 订单已落库，`proinfo` 含商品与数量 | |
| D-07 | 查库确认：`SELECT COUNT(*) FROM car WHERE memberid=<会员id>;` | 购物车已清空（下单后清除） | |
| D-08 | 订单列表点「付款」`/orderFk.action?id=x` | 跳 `/bank.jsp` 模拟支付页；订单状态变「已付款」（**当前 500，见缺陷 D-02**） | |
| D-09 | 订单列表点「货到付款」`/orderHdFk.action?id=x` | 订单 fkstatus 变「货到付款」 | |
| D-10 | 后台管理员 → 订单管理 `/admin/orders.jsp` → 点「发货」 | 订单 fhstatus 变「已发货」，库存扣减，**销售统计新增记录**（**当前 500，见缺陷 D-02**） | |
| D-11 | 会员在 `/orders.jsp` 点「申请退货」 | 订单 fhstatus 变「退货申请中」，出现在后台 `/admin/ordersth.jsp` | |
| D-12 | 会员点「取消退货」`/orderThQx.action?id=x` | 状态回到「已发货」 | |
| D-13 | 重新申请退货 → 后台 `/admin/ordersth.jsp` 点「同意退货」 | 状态变「退货成功」，库存回补（**当前 500，见缺陷 D-03**） | |
| D-14 | 后台订单管理 → 删除某订单 | 订单从列表消失 | |
| D-15 | 会员删除自己的订单 `/orderDel.action?id=x` | 订单消失 | |

### 模块 E：留言与公告

| 编号 | 操作步骤 | 预期结果 | 实际 |
|---|---|---|---|
| E-01 | 登录后在 `/msg.jsp` 输入留言内容 → 提交 | 留言出现在列表顶部 | |
| E-02 | 未登录提交留言 | 应提示先登录 | |
| E-03 | 后台 → 留言管理 `/admin/msg.jsp` → 点「回复」→ 输入回复内容 → 提交 | 前台该留言下方显示「管理员回复：xxx」 | |
| E-04 | 后台 → 删除留言 | 前台同步消失 | |
| E-05 | 前台公告详情浏览计数 | 每次打开点击数递增（若页面有该功能） | |

### 模块 F：统计报表

| 编号 | 操作步骤 | 预期结果 | 实际 |
|---|---|---|---|
| F-01 | 后台 → 销售统计 `/admin/saletj.jsp` | 显示销售明细/汇总，发货后有数据 | |
| F-02 | 后台 → 财务统计 `/admin/cwtj.jsp` | 显示金额统计 | |
| F-03 | 后台 → 商品销量统计 `/admin/productsettj.jsp` | 显示商品销量排行 | |

### 模块 G：异常与安全测试（边界）

| 编号 | 操作步骤 | 预期结果 | 实际 |
|---|---|---|---|
| G-01 | 地址栏直接输入不存在的 jsp：`/xxx.jsp` | 404 页面，不应暴露源码 | |
| G-02 | 商品详情传不存在 id：`/productDetail.jsp?id=99999` | 友好提示或空页，不应 500 | |
| G-03 | 订单操作传别人的订单 id | 应校验归属，不能操作他人订单（当前无校验，见缺陷 D-05） | |
| G-04 | 注册输入超长字符串 / 特殊字符 `<script>` | 正常存储，页面不执行脚本 | |
| G-05 | 商品价格输入负数或非数字 | 前端拦截（price 输入框已限制只能数字） | |
| G-06 | 后台登录密码错误 | 提示错误，不进入后台 | |
| G-07 | 管理员修改密码 `/admin/adminPwdEdit.jsp` | 修改成功后用新密码能登录 | |

---

## 三、数据库校验（页面成功 ≠ 数据正确，必须查库）

用命令行客户端（本机在 `D:\Mysql\bin\mysql.exe`）：

```bash
D:\Mysql\bin\mysql.exe -uroot -p123456 -D db_jspnongchanpin
```

常用校验 SQL：

```sql
-- 用户是否写入
SELECT id,uname,type,realname,tel FROM sysuser ORDER BY id DESC LIMIT 5;

-- 商品/分类
SELECT id,proname,price,protype,delstatus FROM product ORDER BY id DESC LIMIT 5;
SELECT * FROM protype;

-- 购物车（下单后应为空）
SELECT * FROM car WHERE memberid=<会员id>;

-- 订单全状态
SELECT id,orderid,memberid,price,proinfo,fkstatus,fhstatus,type FROM orders ORDER BY id DESC LIMIT 5;

-- 库存流水（发货=out，退货=in）
SELECT * FROM kcrecord ORDER BY id DESC LIMIT 5;

-- 销售记录
SELECT * FROM sales ORDER BY id DESC LIMIT 5;

-- 留言
SELECT id,content,reply FROM msg ORDER BY id DESC LIMIT 5;
```

表名清单（Hibernate 自动建的 12 张）：`sysuser, product, protype, notice, msg, car, orders, kcrecord, sales, imgadv, fav`（收藏）等，用 `SHOW TABLES;` 查看。

---

## 四、已知缺陷清单（测到即可记录，不用重复排查）

| 编号 | 缺陷 | 位置 | 影响 |
|---|---|---|---|
| D-01 | 未登录访问 car.jsp/orders.jsp/memberinfo.jsp 直接 500，未跳登录页 | 各 jsp 顶部取 session 未判空 | 中 |
| D-02 | 发货 `orderFh()` 报 500 | `src\com\action\OrderAction.java` 第 202 行：新建的 `Kcrecord` 用了 `commonDAO.update(kc)`，应改为 `save(kc)`；且 `proinfo.split(",")` 无越界校验 | 高（发货功能不可用） |
| D-03 | 后台同意退货 `adminOrderTh()` 报 500 | `OrderAction.java` 第 246 行，同样是 `update(kc)` 应为 `save(kc)` | 高 |
| D-04 | 支付页 `bank.jsp` 报 500 | `WebContent\bank.jsp`（付款后跳转的目标页） | 中 |
| D-05 | 订单未做归属校验，改 id 可操作他人订单 | `OrderAction` 各方法直接 `findById(id)` | 高（安全） |
| D-06 | 源码编码混乱（GBK/UTF-8 混合）导致中文 HQL 查询失败 | `src\com\util\*.java` 4 个文件 | 已修复，需固化 IDEA 编码 |

---

## 五、测试完成后清理测试数据

```sql
DELETE FROM sysuser WHERE uname IN ('test01','tester4051','tester9579','diag501','chk268','mem225','adm304');
DELETE FROM orders WHERE proinfo LIKE '%测试%';
DELETE FROM msg WHERE content LIKE '%自动化测试%';
DELETE FROM protype WHERE typename LIKE '测试分类%';
DELETE FROM notice WHERE title LIKE '测试公告%';
DELETE FROM product WHERE proname LIKE '测试商品%';
DELETE FROM car;
```

---

## 六、建议的执行顺序（省得来回切换账号）

1. 第一节环境准备 → 构建 → 启动
2. **模块 A**（admin 登录，把分类/商品/公告/轮播/库存数据备齐）
3. **模块 B**（退出 admin，未登录状态逛前台）
4. **模块 C**（注册新会员 → 登录 → 权限验证）
5. **模块 D**（加购 → 下单 → 付款 → 后台发货 → 退货）
6. **模块 E、F**（留言、统计）
7. **模块 G**（异常边界）

每测完一个大模块就查一次库（第三节 SQL），并截图保存页面 + 数据库结果，写报告时直接引用。
