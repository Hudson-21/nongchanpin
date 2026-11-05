<%--
  adminauth.jsp —— 后台访问控制片段（静态包含）
  用法：放在页面最上方、pageEncoding 指令之后
        <%@ include file="/WEB-INF/jspf/adminauth.jsp" %>
  作用：1) 未登录 -> 跳登录页；2) 商家账号访问仅限管理员的页面 -> 回首页并提示。
  注意：片段被静态包含时按包含页的编码解析，中文常量统一用 Unicode 转义，
        避免不同编码环境下比较失败（管理员=\u7BA1\u7406\u5458）。
--%>
<%
    com.model.Sysuser adminUser = (com.model.Sysuser) session.getAttribute("admin");
    if (adminUser == null) {
        response.sendRedirect(request.getContextPath() + "/admin/login.jsp");
        return;
    }

    String authPath = request.getServletPath();
    boolean adminOnly =
            "/admin/member.jsp".equals(authPath)
         || "/admin/cwtj.jsp".equals(authPath)
         || "/admin/adminPwdEdit.jsp".equals(authPath)
         || authPath.startsWith("/admin/imgadv");

    if (adminOnly && !"\u7BA1\u7406\u5458".equals(adminUser.getType())) {
        response.sendRedirect(request.getContextPath() + "/admin/index.jsp?denied=1");
        return;
    }
%>
