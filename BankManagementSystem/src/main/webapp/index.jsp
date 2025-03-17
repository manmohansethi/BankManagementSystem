<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    String loggedInUser = (String) session.getAttribute("user");
    if (loggedInUser != null) {
        response.sendRedirect("dashboard.jsp");
        return;
    }
    else
    {
    	  response.sendRedirect("login.jsp");
          return;
    }
%>