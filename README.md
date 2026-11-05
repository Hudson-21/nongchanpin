# 农产品电商服务平台

一个基于 **JSP + Struts2 + Spring + Hibernate** 的农产品在线销售系统，包含前台商城与后台管理两部分，实现从商品浏览、购物车、下单、支付到发货、退货的完整业务闭环。

> 课程/毕业设计项目，技术栈较为传统（Struts2 2.0.9 + Hibernate 3），主要用于演示 JavaWeb 分层开发与常见业务流程。

## 功能

**前台**
- 商品浏览、分类检索、商品详情
- 会员注册 / 登录（图形验证码）
- 购物车、下单、在线支付（模拟）、订单查询
- 退货申请、收藏夹、个人信息维护
- 新闻公告、留言板、帮助中心

**后台**
- 商品管理（增删改查、特价设置、入库）
- 订单管理（发货、同意/拒绝退货）
- 库存记录、销售统计、财务统计
- 会员管理、类别管理、公告与留言管理、图片广告管理

## 技术栈

| 层次 | 技术 |
|---|---|
| 表现层 | JSP、Struts2 2.0.9 |
| 业务层 | Spring 2.5（Action 由 Spring 托管） |
| 持久层 | Hibernate 3 + HQL |
| 数据库 | MySQL 8 |
| 运行环境 | JDK 8、Tomcat 9 |

## 目录结构

```
nongchanpin/
├── src/                     Java 源码（action / dao / model / util / filter）
├── WebContent/              JSP 页面、静态资源、WEB-INF 配置与依赖 jar
│   ├── admin/               后台页面
│   └── WEB-INF/
│       ├── applicationContext.xml   Spring 配置
│       ├── struts.xml              Struts 路由
│       └── jdbc.properties.example 数据库配置模板
├── jmeter/                  JMeter 压测计划（.jmx）
├── TEST-*.md                测试方案、用例、缺陷与执行报告
└── UI-REVIEW.md             界面评审与改版记录
```

## 本地运行

1. **准备环境**：JDK 8、Tomcat 9、MySQL 8。
2. **建库**：创建数据库 `db_jspnongchanpin`（字符集 `utf8mb4`），表结构由 Hibernate 的 `hbm2ddl.auto=update` 在首次启动时自动创建。
3. **配置数据库连接**：
   ```bash
   cd WebContent/WEB-INF
   cp jdbc.properties.example jdbc.properties
   # 编辑 jdbc.properties，填入本机数据库账号与口令
   ```
   `jdbc.properties` 已被 `.gitignore` 排除，不会提交到仓库。
4. **部署**：把 `WebContent` 作为 Web 应用部署到 Tomcat（推荐 IDEA + Smart Tomcat，Context Path 设为 `/nongchanpin`，类目录指向 `out/production/nongchanpin`）。
5. **访问**：前台 `http://localhost:8080/nongchanpin/index.jsp`，后台 `http://localhost:8080/nongchanpin/admin/login.jsp`。

## 演示账号

数据库初始化后存在以下账号，**口令请自行在数据库 `sysuser` 表中设置**（仓库不包含任何口令）：

| 账号 | 角色 | 入口 |
|---|---|---|
| `admin` | 管理员 | `/admin/login.jsp` |
| `root` | 商家 | `/admin/login.jsp` |
| `mem225` / `zhangsan` | 会员 | `/login.jsp` |

> 口令在库中以 MD5 存储；如需重置，可在数据库中写入对应口令的 MD5 大写值。

## 测试与文档

| 文件 | 内容 |
|---|---|
| `TEST-PLAN-2026-11-05.md` | 测试方案：20 类测试覆盖矩阵与执行计划 |
| `TEST-RESULT-2026-11-05.md` | 执行报告：P0 链路、压测数据、门禁结论 |
| `TEST-CASES-BUGS.md` | 32 条平台录入用例 + 7 张 Bug 单 |
| `TEST-GUIDE.md` | 手工测试指南 |
| `UI-REVIEW.md` | 界面评审与三轮改版记录 |

## 已知问题

- 口令为 MD5 无盐存储，登录接口的 HQL 仍为字符串拼接，生产使用前需改为参数化查询与 BCrypt。
- 后台权限控制在 JSP 层与登录时校验，`*.action` 接口层尚未统一拦截。
- 发货 / 退货接口无幂等保护，重复提交会二次变更库存。

## 许可

本项目仅用于学习与技术演示。
