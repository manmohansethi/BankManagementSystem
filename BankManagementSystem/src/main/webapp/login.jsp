<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%
    String loggedInUser = (String) session.getAttribute("user");
    if (loggedInUser != null) {
        response.sendRedirect("dashboard.jsp");
        return;
    }
%>
<html>
<head>
    <title>Login</title>
    <script src="https://cdn.tailwindcss.com"></script>
</head>
<body class="bg-gray-100 flex items-center justify-center min-h-screen">
    <!-- Login Container -->
    <div class="bg-white rounded-lg shadow-lg p-8 w-full max-w-md">
        <h2 class="text-2xl font-bold text-blue-900 text-center mb-6">Login</h2>
        <form action="login" method="post" class="space-y-4">
            <!-- Username Field -->
            <div>
                <label for="username" class="block text-sm font-medium text-gray-700">Username:</label>
                <input type="text" id="username" name="username" required
                       class="mt-1 block w-full px-4 py-2 border border-gray-300 rounded-lg shadow-sm focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500">
            </div>
            <!-- Password Field -->
            <div>
                <label for="password" class="block text-sm font-medium text-gray-700">Password:</label>
                <input type="password" id="password" name="password" required
                       class="mt-1 block w-full px-4 py-2 border border-gray-300 rounded-lg shadow-sm focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500">
            </div>
            <!-- Login Button -->
            <button type="submit"
                    class="w-full bg-blue-900 text-white px-4 py-2 rounded-lg hover:bg-blue-800 transition duration-300">
                Login
            </button>
        </form>
        <!-- Register Link -->
        <p class="mt-4 text-center text-gray-600">
            Don't have an account? <a href="register.jsp" class="text-blue-900 hover:underline">Register here</a>
        </p>
        <!-- Error Message -->
        <c:if test="${not empty error}">
            <p class="mt-4 text-center text-red-600">${error}</p>
        </c:if>
    </div>
</body>
</html>