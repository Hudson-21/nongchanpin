<%--
  auth.jsp —— 会员登录拦截片段（静态包含，勿直接访问）
  用法（放在页面最上方、pageEncoding 指令之后）：
      <%@ include file="/WEB-INF/jspf/auth.jsp" %>
  作用：未登录时记录来源地址并跳转登录页，登录成功后由 login.jsp 原路返回；
        已登录时不做任何输出，仅暴露 authMember 变量。
  注意：必须使用静态包含 <%@ include %>，因为 return 需要作用在调用页的 _jspService 中。
--%>
<%
    com.model.Sysuser authMember = (com.model.Sysuser) session.getAttribute("member");
    if (authMember == null) {
        String authBack = request.getRequestURI();
        if (request.getQueryString() != null) {
            authBack = authBack + "?" + request.getQueryString();
        }
        response.sendRedirect(request.getContextPath() + "/login.jsp?from="
                + java.net.URLEncoder.encode(authBack, "UTF-8"));
        return;
    }
%>
