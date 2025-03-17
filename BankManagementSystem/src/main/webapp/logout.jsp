<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    // Invalidate session to log out user
    session.invalidate();

    // Redirect to index.jsp
    response.sendRedirect("index.jsp");
%>