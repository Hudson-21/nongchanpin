<%@ page language="java" import="java.util.*" pageEncoding="utf-8"%>
<%@page import="com.dao.CommonDAO"%>
<%@page import="com.util.Info"%>
<%@page import="com.model.Product"%>
<%@page import="com.model.Sysuser"%>
<%@page import="com.model.Fav"%>
<%@page import="com.model.Kcrecord"%>
<%
String path = request.getContextPath();
String basePath = request.getScheme()+"://"+request.getServerName()+":"+request.getServerPort()+path+"/";
%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
  <head>
    <base href="<%=basePath%>">
    
    <title>农产品电商服务平台</title>
    
	<meta name="viewport" content="width=device-width, initial-scale=1">
	<meta http-equiv="pragma" content="no-cache">
	<meta http-equiv="cache-control" content="no-cache">
	<meta http-equiv="expires" content="0">    
	<meta http-equiv="keywords" content="keyword1,keyword2,keyword3">
	<meta http-equiv="description" content="freeshop">
	<!--
	<link rel="stylesheet" type="text/css" href="styles.css">
	-->
	<style type="text/css">
/* 商品主图：原写法是 position:absolute + 写死 top:295px/left:400px，
   元素脱离文档流后按整张页面定位，不跟随所在单元格，
   窗口一窄就压到左侧"信息栏"上。这里改为正常流式布局。 */
#img {
	display: block;
	width: 100%;
	max-width: 300px;
	height: auto;
	margin: 0 auto;
	border: 1px solid #E5E5E5;
	padding: 4px;
	background: #ffffff;
	box-sizing: border-box;
}
.picBox {
	padding: 6px;
	text-align: center;
}
</style>
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
<LINK rel=stylesheet type=text/css href="files/ui.css">
<STYLE type=text/css>BODY {
	MARGIN: 0px
}
</STYLE>
  </head>
  <%CommonDAO dao = (CommonDAO)Info.getDao(request,"CommonDAO"); 
  String id = request.getParameter("id");
  // 缺少或非法 id 时不再抛 500，回到商品列表
  if (id == null || id.trim().equals("")) {
	  response.sendRedirect(request.getContextPath() + "/productmore.jsp");
	  return;
  }
  Product product = (Product)dao.findById(id,"Product");
  if (product == null) {
	  response.sendRedirect(request.getContextPath() + "/productmore.jsp");
	  return;
  }
  Sysuser member = (Sysuser)session.getAttribute("member");
  
  String method = request.getParameter("method");
  if(method!=null){
	  String memberid = request.getParameter("memberid");
  if(method.equals("favadd")){
	  Fav f = new Fav();
	  f.setMemberid(memberid);
	  f.setProductid(id);
	  dao.save(f);
  }if(method.equals("favdel")){
	  Fav f = (Fav)dao.findByHql(" from Fav where memberid='"+memberid+"' and productid='"+id+"' ").get(0);
	  dao.delete(f.getId(),"Fav");
  }
  }
  %>
  <body class="ui-v2">
    <jsp:include page="top.jsp"></jsp:include>
    <center>
    <TABLE border=0 cellSpacing=0 cellPadding=0 width=1006 align=center>
  <TBODY>
  <TR>
    <TD vAlign=top width=188>
    <jsp:include page="left.jsp"></jsp:include>
      </TD>
    <TD vAlign=top width=787>
      <TABLE border=0 cellSpacing=0 cellPadding=0 width="100%" height=5>
        <TBODY>
        <TR>
          <TD height=5></TD></TR></TBODY></TABLE>
      <TABLE border=0 cellSpacing=0 cellPadding=0 width="100%">
        <TBODY>
        <TR>
          <TD height=10 width=787></TD></TR>
        <TR>
          <TD height=25 background=files/bgtop.gif>
            <TABLE width="100%">
              <TBODY>
              <TR>
                <TD width="90%" align=left><STRONG>　<FONT color=#ffffff>商品详情</FONT></STRONG></TD>
                <TD width="10%" align=right>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</TD></TR></TBODY></TABLE></TD></TR>
        <TR>
          <TD height=180 vAlign=top>
            <STYLE type=text/css>.style4 {
	COLOR: #ff0000
}
</STYLE>

            <TABLE border=0 cellSpacing=0 cellPadding=0 width="99%" align=center>
              <TBODY>
              <TR>
                <TD height=10 vAlign=top></TD></TR>
              <TR>
                <TD>
                  <DIV style="WIDTH: 800px">
                  <table width="100%" border="0">
  <tr>
    <td align="center" width="320" valign="top">
      <div class="picBox">
        <img src="/nongchanpin/upfile/<%=product.getImg() %>" alt="<%=product.getProname() %>" id="img" />
      </div>
    </td>
    <td colspan="3" valign="top">
    <table width="100%" border="0">
      <tr>
        <td class="pmeta">商品编号：<%=product.getProno() %></td>
        <td align="right">
        <%if(member!=null){ 
        ArrayList<Fav> favlist = (ArrayList<Fav>)dao.findByHql(" from Fav where memberid='"+member.getId()+"' and productid='"+id+"' ");
        if(favlist.size()==0){
        %>
        <a class="pbtn-ghost" href="/nongchanpin/productDetail.jsp?memberid=<%=member.getId() %>&id=<%=product.getId() %>&method=favadd">收藏</a>
        <%
        }else{%>
        <a class="pbtn-ghost" href="/nongchanpin/productDetail.jsp?memberid=<%=member.getId() %>&id=<%=product.getId() %>&method=favdel">取消收藏</a>
        <%}
        } %>
        </td>
        </tr>
      <tr>
        <td colspan="2"><h1 class="pdetail-name"><%=product.getProname() %></h1></td>
        </tr>
      <tr>
        <td colspan="2">
        <p class="pdetail-price">
          <%if(product.getField7().equals("yes")){ %>
          <span class="now"><%=product.getField8() %><i>元</i></span><span class="was">定价 <%=product.getPrice() %> 元</span>
          <%}else{ %>
          <span class="now"><%=product.getPrice() %><i>元</i></span>
          <%} %>
        </p>
        </td>
      </tr>
      <tr>
        <td colspan="2">库存:
        <%
			ArrayList<Kcrecord> inlist = (ArrayList<Kcrecord>)dao.findByHql("  from Kcrecord where productid='"+product.getId()+"' and type='in' ");
			ArrayList<Kcrecord> outlist = (ArrayList<Kcrecord>)dao.findByHql("  from Kcrecord where productid='"+product.getId()+"' and type='out' ");
			int kc;
			if(inlist.size()!=0){
			int innum = 0;
			int outnum = 0;
			for(Kcrecord in:inlist){
				innum+=Integer.parseInt(in.getNum());
			}
			for(Kcrecord kout:outlist){
				outnum+=Integer.parseInt(kout.getNum());
			}
			kc = innum-outnum;
			}else{
				kc = 0;
			}
			%>
			<%=kc %>
        
        </td>
      </tr>
      <tr>
        <td colspan="2">品牌:<%=product.getField1() %></td>
      </tr>
      <tr>
        <td colspan="2">产品类型:<%=product.getField2() %></td>
      </tr>
      <tr>
        <td colspan="2">口味:<%=product.getField3() %></td>
      </tr>
      <tr>
        <td colspan="2">包装方式:<%=product.getField4() %></td>
      </tr>
      <%if(member!=null){ %>
      <tr>
        <td valign="top" colspan="2">
        <input type="hidden" id="kc" name="kc" value="<%=kc%>" />
        <div class="pbuy">
          <label class="pbuy-label" for="num">数量</label>
          <input type="text" id="num" name="num" value="1" size="2" class="pbuy-num" onkeyup="value=value.replace(/[^\d]/g,'') " onbeforepaste="clipboardData.setData('text',clipboardData.getData('text').replace(/[^\d]/g,''))">
          <a class="btn-buy" href="javascript:tocar('<%=member.getId() %>','<%=product.getId() %>')">加入购物车</a>
        </div>
        </td>
      </tr>
      <%}else{ %>
      <tr>
        <td colspan="2">
        <div class="pbuy">
          <a class="btn-buy" href="/nongchanpin/login.jsp?from=<%=java.net.URLEncoder.encode(request.getRequestURI() + "?id=" + product.getId(), "UTF-8")%>">登录后购买</a>
        </div>
        </td>
      </tr>
      <%} %>
    </table></td>
  </tr>
</table>
                  
                  </DIV></TD></TR></TBODY></TABLE></TD></TR>
      </TBODY></TABLE></TD></TR></TBODY></TABLE>
    </center>
    
    <jsp:include page="foot.jsp"></jsp:include>
    <script type="text/javascript">
    //定义一个变量用于存放XMLHttpRequest对象
	var xmlHttp; 
	
	//该函数用于创建一个XMLHttpRequest对象
	function createXMLHttpRequest() {
		if (window.ActiveXObject) {
			xmlHttp = new ActiveXObject("Microsoft.XMLHTTP");
		} 
		else if (window.XMLHttpRequest) {
			xmlHttp = new XMLHttpRequest();
		}
	}
		//这是一个启动AJAX异步通信的方法
	function tocar(memberid,productid)
	{
	if(document.getElementById("num").value=="")
		{
		alert("购买数量不能为空");
		return false;
		}else if(parseInt(document.getElementById("num").value)>parseInt(document.getElementById("kc").value)){
			alert("购买数量不能大于库存数量");
			return false;
			location.href("/nongchanpin/productDetail.jsp");
		}
		
		//创建一个XMLHttpRequest对象
		createXMLHttpRequest();
		//将状态触发器绑定到一个函数
		

		xmlHttp.onreadystatechange = processor;
		//通过GET方法向指定的URL建立服务器的调用
		
		xmlHttp.open("GET", "carAdd.action?num="+document.getElementById('num').value+"&memberid="+memberid+"&productid="+productid);
		
		//发送请求
		xmlHttp.send(null);
		

	}
	function processor () 
	{
		//定义一个变量用于存放从服务器返回的响应结果
		var responseContext;
		if(xmlHttp.readyState == 4) 
		{ //如果响应完成
		
			if(xmlHttp.status == 200) 
			{//如果返回成功
				//取出服务器的响应内容
				responseContext = xmlHttp.responseText;
				alert("商品已放入购物车");

			}
		}
	}
	
	function InitAjax() 
{ 
　var ajax=false; 
　try { 
　　ajax = new ActiveXObject("Msxml2.XMLHTTP"); 
　} catch (e) { 
　　try { 
　　　ajax = new ActiveXObject("Microsoft.XMLHTTP"); 
　　} catch (E) { 
　　　ajax = false; 
　　} 
　} 
　if (!ajax && typeof XMLHttpRequest!='undefined') { 
　　ajax = new XMLHttpRequest(); 
　} 
　return ajax; 
} 
    </script>
  </body>
</html>
<script type="text/javascript">

function getEventObject(W3CEvent) {            //事件标准化函数
    return W3CEvent || window.event;
}


function getPointerPosition(e) {            //兼容浏览器的鼠标x,y获得函数
    e = e || getEventObject(e);
    var x = e.pageX || (e.clientX + (document.documentElement.scrollLeft || document.body.scrollLeft));
    var y = e.pageY || (e.clientY + (document.documentElement.scrollTop || document.body.scrollTop));
    
    return { 'x':x,'y':y };
}

function setOpacity(elem,level) {            //兼容浏览器设置透明值
    if(elem.filters) {
        elem.style.filter = 'alpha(opacity=' + level * 100 + ')';
    } else {
        elem.style.opacity = level;
    }
}

function css(elem,prop) {                //css设置函数,方便设置css值,并且兼容设置透明值
    for(var i in prop) {
        if(i == 'opacity') {
            setOpacity(elem,prop[i]);
        } else {
            elem.style[i] = prop[i];
        }
    }
    return elem;
}

var magnifier = {
    m : null,
    
    init:function(magni){
        var m = this.m = magni || {
            cont : null,        //装载原始图像的div
            img : null,            //放大的图像
            mag : null,            //放大框
            scale : 15            //比例值,设置的值越大放大越大,但是这里有个问题就是如果不可以整除时,会产生些很小的白边,目前不知道如何解决
        }
        
        css(m.img,{    
            'position' : 'absolute',
            'width' : (m.cont.clientWidth * m.scale) + 'px',                //原始图像的宽*比例值    
            'height' : (m.cont.clientHeight * m.scale) + 'px'                //原始图像的高*比例值
            })
        
        css(m.mag,{
            'display' : 'none',
            'width' : m.cont.clientWidth + 'px',            //m.cont为原始图像,与原始图像等宽
            'height' : m.cont.clientHeight + 'px',
            'position' : 'absolute',
            'left' : m.cont.offsetLeft + m.cont.offsetWidth + 10 + 'px',        //放大框的位置为原始图像的右方远10px
            'top' : m.cont.offsetTop + 'px'
            })
        
        var borderWid = m.cont.getElementsByTagName('div')[0].offsetWidth - m.cont.getElementsByTagName('div')[0].clientWidth;        //获取border的宽
        
        css(m.cont.getElementsByTagName('div')[0],{            //m.cont.getElementsByTagName('div')[0]为浏览框
            'display' : 'none',                                //开始设置为不可见
            'width' : m.cont.clientWidth / m.scale - borderWid + 'px',            //原始图片的宽/比例值 - border的宽度
            'height' : m.cont.clientHeight / m.scale - borderWid + 'px',         //原始图片的高/比例值 - border的宽度
            'opacity' : 0.5                    //设置透明度
            })
        
        m.img.src = m.cont.getElementsByTagName('img')[0].src;            //让原始图像的src值给予放大图像
        m.cont.style.cursor = 'crosshair';
        
        m.cont.onmouseover = magnifier.start;
        
    },
    
    start:function(e){
        
        if(document.all){                //只在IE下执行,主要避免IE6的select无法覆盖
            magnifier.createIframe(magnifier.m.img);
        }
        
        this.onmousemove = magnifier.move;        //this指向m.cont
        this.onmouseout = magnifier.end;
    },
    
    move:function(e){
        var pos = getPointerPosition(e);        //事件标准化
        
        this.getElementsByTagName('div')[0].style.display = '';
        
        css(this.getElementsByTagName('div')[0],{
            'top' : Math.min(Math.max(pos.y - this.offsetTop - parseInt(this.getElementsByTagName('div')[0].style.height) / 2,0),this.clientHeight - this.getElementsByTagName('div')[0].offsetHeight) + 'px',
            'left' : Math.min(Math.max(pos.x - this.offsetLeft - parseInt(this.getElementsByTagName('div')[0].style.width) / 2,0),this.clientWidth - this.getElementsByTagName('div')[0].offsetWidth) + 'px'            //left=鼠标x - this.offsetLeft - 浏览框宽/2,Math.max和Math.min让浏览框不会超出图像
            })
        
        magnifier.m.mag.style.display = '';
        
        css(magnifier.m.img,{
            'top' : - (parseInt(this.getElementsByTagName('div')[0].style.top) * magnifier.m.scale) + 'px',
            'left' : - (parseInt(this.getElementsByTagName('div')[0].style.left) * magnifier.m.scale) + 'px'
            })
        
    },
    
    end:function(e){
        this.getElementsByTagName('div')[0].style.display = 'none';
        magnifier.removeIframe(magnifier.m.img);        //销毁iframe
        
        magnifier.m.mag.style.display = 'none';
    },
    
    createIframe:function(elem){
        var layer = document.createElement('iframe');
        layer.tabIndex = '-1';
        layer.src = 'javascript:false;';
        elem.parentNode.appendChild(layer);
        
        layer.style.width = elem.offsetWidth + 'px';
        layer.style.height = elem.offsetHeight + 'px';
    },
    
    removeIframe:function(elem){
        var layers = elem.parentNode.getElementsByTagName('iframe');
        while(layers.length >0){
            layers[0].parentNode.removeChild(layers[0]);
        }
    }
}

/* 原窗口加载时初始化放大镜，但 #magnifierImg / #mag 在页面里并不存在，
   每次打开详情页都会抛 TypeError 并中断其他 onload 逻辑，故移除。 */
</script>