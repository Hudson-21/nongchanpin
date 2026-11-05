<%@ page language="java" import="java.util.*" pageEncoding="utf-8"%>
<%@page import="com.model.Protype"%>
<%@page import="com.dao.CommonDAO"%>
<%@page import="com.util.Info"%>
<%@page import="com.model.Sysuser"%>
<%@page import="com.model.Imgadv"%>
<%
String path = request.getContextPath();
String basePath = request.getScheme()+"://"+request.getServerName()+":"+request.getServerPort()+path+"/";
%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
  <head>
    <base href="<%=basePath%>">
    
    <title>My JSP 'top.jsp' starting page</title>
    
	<meta http-equiv="pragma" content="no-cache">
	<meta http-equiv="cache-control" content="no-cache">
	<meta http-equiv="expires" content="0">    
	<meta http-equiv="keywords" content="keyword1,keyword2,keyword3">
	<meta http-equiv="description" content="This is my page">
	<!--
	<link rel="stylesheet" type="text/css" href="styles.css">
	-->
<LINK rel=stylesheet type=text/css href="files/style.css">
<STYLE type=text/css>.STYLE3 {
	COLOR: #ffffff
}
</STYLE>

<STYLE type=text/css>.STYLE1 {
	FONT-WEIGHT: bold
}
.STYLE2 {
	FONT-WEIGHT: bold
}
BODY {
	BACKGROUND-COLOR: #ffffff
}
</STYLE>

<STYLE type=text/css>.STYLE5 {
	FONT-SIZE: 9px
}
</STYLE>

 <LINK rel=stylesheet type=text/css href="files/css.css">
<STYLE type=text/css>BODY {
	MARGIN: 0px
}
</STYLE>
<script language="javascript"> 
function show(aa)
{  
       document.all.div4.style.display="none";
       aa.style.display="block";

}
		function cleardiv(aa)
		{
		document.all.div4.style.display="none";
		aa.style.display="none";
		}
</script>
  </head>
  <%CommonDAO dao = (CommonDAO)Info.getDao(request,"CommonDAO"); %>
  <%Sysuser member = (Sysuser)session.getAttribute("member");   %> 
  <body>

    <TABLE class="heroWrap" border=0 cellSpacing=0 cellPadding=0 width=1006 align=center 
  height=100><TBODY>
  <TR>
    <TD width=1006>
   <%
   List list = dao.findByHql(" from Imgadv where type='HEAD' ");
Imgadv imgadv = null;
if(list!=null && list.size()>0){
    imgadv = (Imgadv)list.get(0);
}
%>
<% if(imgadv!=null){ %>
<img class="heroImg" src="/nongchanpin/upfile/<%=imgadv.getImgurl() %>" width="100%" height="130">
<% } %>
    </TD></TR></TBODY></TABLE>
    
    <TABLE class="navWrap" border=0 cellSpacing=0 cellPadding=0 width=1006 align=center>
  <TBODY>
  <TR>
    <TD height=5 width=5><IMG src="files/new_top_li01.bmp" width=5 
      height=5></TD>
    <TD height=5 background=files/new_top_li01_1.gif width=985></TD>
    <TD width=5><IMG src="files/new_top_li03.gif"></TD></TR>
  <TR>
    <TD background=files/new_top_li01_2.gif width=5></TD>
    <TD vAlign=top>
    <form action="/nongchanpin/search.jsp" method="post">
      <TABLE border=0 cellSpacing=0 cellPadding=0 width="100%" 
      background=files/bgtop.gif height=37>
        <TBODY>
        <TR>
          <TD vAlign=center width="75%">
            
            <TABLE class=9 border=0 cellSpacing=0 cellPadding=0 width="100%" 
            align=center>
              <TBODY>
              <TR>
                <TD class=b vAlign=top width="96%" align=left>
                  <DIV align=center>
                  <A href="index.jsp" class="menu" onmouseover="cleardiv(div4)" ><FONT color=#ffffff>首页</FONT></A>
                  | <A href="/nongchanpin/notices.jsp" onmouseover="cleardiv(div4)"><FONT color=#ffffff>新闻公告</FONT></A>
                  | <A href="" id="nav4" class="menu" onmouseover="show(div4)"><FONT color=#ffffff>商品目录</FONT></A>
                  | <A href="/nongchanpin/hotsales.jsp" onmouseover="cleardiv(div4)"><FONT color=#ffffff>热销商品</FONT></A> 
                  | <A href="/nongchanpin/producttj.jsp" onmouseover="cleardiv(div4)"><FONT color=#ffffff>公益售卖</FONT></A><!--
                  | <A href="/nongchanpin/otherinfo.jsp" onmouseover="cleardiv(div4)"><FONT color=#ffffff>其它信息</FONT></A> --> 
                  | <A href="/nongchanpin/msg.jsp" onmouseover="cleardiv(div4)"><FONT color=#ffffff>留言板</FONT></A>
                  | <A href="/nongchanpin/help.jsp" onmouseover="cleardiv(div4)"><FONT color=#ffffff>帮助中心</FONT></A>
                  &nbsp;&nbsp;&nbsp;&nbsp;
                  <input type="text" id="proname" name="proname" />
                  &nbsp;<input type="submit" value="搜索">&nbsp;&nbsp;
                   </DIV></TD></TR></TBODY></TABLE>
                   
                   </TD>
          <TD width="125%">
            </TD></TR>
        <TR>
          <TD height=4 vAlign=center colSpan=3></TD></TR></TBODY></TABLE>
          </form>
          <table height="15" border="0" cellpadding="0" cellspacing="0">
          		<tr>
          			<td>
          				<DIV style="PADDING-RIGHT: 10px; DISPLAY: none" id="div4" >
          				<%ArrayList<Protype> protypelist = (ArrayList<Protype>)dao.findByHql(" from Protype where delstatus=0 order by id desc"); 
                  		for(Protype protype:protypelist){
                  		%>
          				·<A class="navm" href="/nongchanpin/search.jsp?protype=<%=protype.getId() %>"><%=protype.getTypename() %></A> 
      					<%} %>
      					</DIV>
          			</td>
          		</tr>
          </table>
          </TD>
    <TD background=files/new_top_li01_3.gif width=5></TD></TR>
  <TR>
    <TD height=5 background=files/new_top_li02.gif></TD>
    <TD>
      <TABLE border=0 cellSpacing=0 cellPadding=0 width="100%">
        <TBODY>
        <TR>
          <TD height=5 
      background=files/new_top_li01-4.gif></TD></TR></TBODY></TABLE></TD>
    <TD><IMG src="files/new_top_li01_4.gif" width=5 
  height=5></TD></TR></TBODY></TABLE>
  <TABLE class="topbar" border=0 cellSpacing=0 cellPadding=0 width=1006 align=center >
  	<tr>
  		<td>
			<DIV align=right>
            <%if(member==null){ %>
            <A class="tbLink" href="/nongchanpin/login.jsp"><FONT color=#000000>登录</FONT></A>
            <A class="tbBtn" href="/nongchanpin/register.jsp"><FONT color=#ffffff>注册帐号</FONT></A>
            <%}else{ %>
            <A class="tbLink" href="/nongchanpin/orders.jsp"><FONT color=#000000>我的订单</FONT></A>
            <A class="tbLink" href="/nongchanpin/car.jsp"><FONT color=#000000>购物车</FONT></A>
            <A class="tbLink" href="/nongchanpin/fav.jsp"><FONT color=#000000>收藏夹</FONT></A>
            <A class="tbLink" href="/nongchanpin/ordersTh.jsp"><FONT color=#000000>退货记录</FONT></A>
            <A class="tbLink" href="/nongchanpin/memberinfo.jsp"><FONT color=#000000>个人信息</FONT></A>
            <A class="tbLink" href="memberExit.action"><FONT color=#000000>安全退出</FONT></A>
            <%} %>
            <A class="tbAdmin" href="/nongchanpin/admin/login.jsp" target="_blank" rel="noopener">后台管理</A>
             </DIV>
		</td>
  	</tr>
  </table>
  
  </body>
</html>
