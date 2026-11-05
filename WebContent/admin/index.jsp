<%@ page language="java" import="java.util.*" pageEncoding="utf-8"%>
<%@page import="com.dao.CommonDAO"%>
<%@page import="com.util.Info"%>
<%@page import="com.model.Sysuser"%>
<%@page import="com.model.Orders"%>
<%@page import="com.model.Product"%>
<%@page import="com.model.Kcrecord"%>
<%
String path = request.getContextPath();
String basePath = request.getScheme()+"://"+request.getServerName()+":"+request.getServerPort()+path+"/";

// 后台首页同样需要登录：未登录直接回登录页，避免把空数据当成"系统没数据"
Sysuser admin = (Sysuser) session.getAttribute("admin");
if (admin == null) {
	response.sendRedirect(path + "/admin/login.jsp");
	return;
}
// 商家越权访问时的提示标记
boolean denied = "1".equals(request.getParameter("denied"));

CommonDAO dao = (CommonDAO) Info.getDao(request, "CommonDAO");

// ---- 指标 ----
List waitPayList   = dao.findByHql(" from Orders where fkstatus='未付款' ");
List waitSendList  = dao.findByHql(" from Orders where fhstatus='未发货' ");
List backList      = dao.findByHql(" from Orders where fhstatus='退货申请中' ");
List productList   = dao.findByHql(" from Product where delstatus=0 order by id desc ");
List latestOrders  = dao.findByHql(" from Orders order by id desc limit 0,8 ");

// ---- 库存：一次取全部出入库记录，在内存里累计，避免每行两次查询 ----
List kcRecords = dao.findByHql(" from Kcrecord ");
Map stockMap = new HashMap();
for (int i = 0; i < kcRecords.size(); i++) {
	Kcrecord r = (Kcrecord) kcRecords.get(i);
	int num = 0;
	try {
		num = Integer.parseInt(r.getNum().trim());
	} catch (Exception e) {
		num = 0;
	}
	String pid = r.getProductid();
	int cur = stockMap.containsKey(pid) ? ((Integer) stockMap.get(pid)).intValue() : 0;
	if ("in".equals(r.getType())) {
		cur = cur + num;
	} else if ("out".equals(r.getType())) {
		cur = cur - num;
	}
	stockMap.put(pid, Integer.valueOf(cur));
}

// ---- 低库存（<10）排序取前 6 ----
List lowStock = new ArrayList();
for (int i = 0; i < productList.size(); i++) {
	Product p = (Product) productList.get(i);
	Integer s = (Integer) stockMap.get(String.valueOf(p.getId()));
	int stock = (s == null) ? 0 : s.intValue();
	if (stock < 10) {
		lowStock.add(new Object[] { p, Integer.valueOf(stock) });
	}
}
Collections.sort(lowStock, new Comparator() {
	public int compare(Object a, Object b) {
		int sa = ((Integer) ((Object[]) a)[1]).intValue();
		int sb = ((Integer) ((Object[]) b)[1]).intValue();
		return sa - sb;
	}
});
int lowStockShown = lowStock.size() > 6 ? 6 : lowStock.size();
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
  <head>
    <base href="<%=basePath%>">

    <title>农产品电商服务平台后台管理</title>

	<meta name="viewport" content="width=device-width, initial-scale=1">
	<meta name="viewport" content="width=device-width, initial-scale=1">
	<meta http-equiv="pragma" content="no-cache">
	<meta http-equiv="cache-control" content="no-cache">
	<meta http-equiv="expires" content="0">
	<meta http-equiv="keywords" content="keyword1,keyword2,keyword3">
	<meta http-equiv="description" content="农产品电商服务平台后台管理">
	<LINK href="/nongchanpin/admin/css/test.css" rel=stylesheet>
	<script language = "JavaScript" src = "/nongchanpin/admin/js/test.js"></script>
  <link rel="stylesheet" type="text/css" href="/nongchanpin/admin/css/admin-ui.css">
</head>

  <body class="ui-a" topmargin="0" leftmargin="0" rightmargin="0" bottommargin="0">
        <jsp:include page="top.jsp"></jsp:include>

		<table cellspacing=1 cellpadding=3 align=center class=tableBorder2>
		<tr>
		<td height=25 valign=middle>
                  <img src="/nongchanpin/admin/images/Forum_nav.gif" align="absmiddle" alt="">
                  <a href="/nongchanpin/index.jsp" target="_blank">电子商务门户</a> → 管理首页
                  &nbsp;欢迎，<b><%=admin.getRealname() == null || admin.getRealname().equals("") ? admin.getUname() : admin.getRealname()%></b>
                </td>
                </tr>
		</table>

		<% if (denied) { %>
		<div class="dashNotice">这个页面只有管理员可以访问，已带你回到首页。</div>
		<% } %>

		<%-- 关键指标：等待处理的订单优先，一眼看出今天该干什么 --%>
		<table class="dashKpi" cellpadding="0" cellspacing="0">
		<tr>
			<td>
				<div class="num"><a href="/nongchanpin/admin/orders.jsp"><%=waitPayList.size()%></a></div>
				<div class="lbl">待付款订单</div>
			</td>
			<td class="<%=waitSendList.size() > 0 ? "warn" : ""%>">
				<div class="num"><a href="/nongchanpin/admin/orders.jsp"><%=waitSendList.size()%></a></div>
				<div class="lbl">待发货订单</div>
			</td>
			<td class="<%=backList.size() > 0 ? "warn" : ""%>">
				<div class="num"><a href="/nongchanpin/admin/ordersth.jsp"><%=backList.size()%></a></div>
				<div class="lbl">退货申请</div>
			</td>
			<td>
				<div class="num"><a href="/nongchanpin/admin/product.jsp"><%=productList.size()%></a></div>
				<div class="lbl">在售商品</div>
			</td>
		</tr>
		</table>

		<table class="dashGrid" width="97%" align="center" cellpadding="0" cellspacing="0">
		<tr>
		<td width="58%" valign="top">
			<div class="dashPanel">
			<h3>最新订单 <span>最近 8 笔</span></h3>
			<table cellpadding=4 cellspacing=1 width="100%" class=tableborder1>
			<tr>
				<td height=25 background="/nongchanpin/admin/images/bg2.gif" align="center"><font color="#ffffff"><b>订单号</b></font></td>
				<td height=25 background="/nongchanpin/admin/images/bg2.gif" align="center"><font color="#ffffff"><b>会员</b></font></td>
				<td height=25 background="/nongchanpin/admin/images/bg2.gif" align="center"><font color="#ffffff"><b>金额</b></font></td>
				<td height=25 background="/nongchanpin/admin/images/bg2.gif" align="center"><font color="#ffffff"><b>付款</b></font></td>
				<td height=25 background="/nongchanpin/admin/images/bg2.gif" align="center"><font color="#ffffff"><b>发货</b></font></td>
			</tr>
			<%
			if (latestOrders.size() == 0) {
			%>
			<tr><td colspan="5" class="dashEmpty">暂无订单</td></tr>
			<%
			} else {
				for (int i = 0; i < latestOrders.size(); i++) {
					Orders o = (Orders) latestOrders.get(i);
					Sysuser buyer = null;
					try {
						buyer = (Sysuser) dao.findById(o.getMemberid(), "Sysuser");
					} catch (Exception e) {
						buyer = null;
					}
					String buyerName = (buyer == null) ? "已注销用户" : buyer.getUname();
			%>
			<tr>
				<td class=tablebody1 align="center"><%=o.getOrderid()%></td>
				<td class=tablebody1 align="center"><%=buyerName%></td>
				<td class=tablebody1 align="center"><%=o.getPrice()%> 元</td>
				<td class=tablebody2 align="center"><%=o.getFkstatus()%></td>
				<td class=tablebody2 align="center"><%=o.getFhstatus()%></td>
			</tr>
			<%
				}
			}
			%>
			</table>
			</div>
		</td>
		<td width="42%" valign="top">
			<div class="dashPanel">
			<h3>库存预警 <span>低于 10 件，共 <%=lowStock.size()%> 款</span></h3>
			<table cellpadding=4 cellspacing=1 width="100%" class=tableborder1>
			<tr>
				<td height=25 background="/nongchanpin/admin/images/bg2.gif" align="center"><font color="#ffffff"><b>商品</b></font></td>
				<td height=25 background="/nongchanpin/admin/images/bg2.gif" align="center" width="60"><font color="#ffffff"><b>库存</b></font></td>
			</tr>
			<%
			if (lowStockShown == 0) {
			%>
			<tr><td colspan="2" class="dashEmpty">库存充足，暂无预警</td></tr>
			<%
			} else {
				for (int i = 0; i < lowStockShown; i++) {
					Object[] row = (Object[]) lowStock.get(i);
					Product p = (Product) row[0];
					int stock = ((Integer) row[1]).intValue();
					String pname = p.getProname();
					if (pname != null && pname.length() > 14) {
						pname = pname.substring(0, 14) + "...";
					}
			%>
			<tr>
				<td class=tablebody1 title="<%=p.getProname().replace('"', ' ')%>">
					<a href="/nongchanpin/admin/productrk.jsp?id=<%=p.getId()%>" target="_blank"><%=pname%></a>
				</td>
				<td class=tablebody2 align="center"><%=stock%></td>
			</tr>
			<%
				}
			}
			%>
			</table>
			</div>
		</td>
		</tr>
		</table>

		<div class="dashActions">
			<b>快捷入口：</b>
			<a href="/nongchanpin/admin/productadd.jsp">新增商品</a> ·
			<a href="/nongchanpin/admin/orders.jsp">订单管理</a> ·
			<a href="/nongchanpin/admin/kcrecord.jsp">库存记录</a> ·
			<a href="/nongchanpin/admin/kcview.jsp">库存盘点</a> ·
			<a href="/nongchanpin/admin/saletj.jsp">销售统计</a> ·
			<a href="/nongchanpin/admin/noticeadd.jsp">发布公告</a>
		</div>

        <jsp:include page="foot.jsp"></jsp:include>
  </body>
</html>
