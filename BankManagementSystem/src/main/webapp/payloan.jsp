<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.text.DecimalFormat" %>

<%
    String loggedInUser = (String) session.getAttribute("user");
    if (loggedInUser == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    String userRole = (String) session.getAttribute("role");
    if ("admin".equals(userRole)) {
        response.sendRedirect("dashboard.jsp");
        return;
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Pay Loan</title>
    <script src="https://cdn.tailwindcss.com"></script>
</head>
<body class="bg-gray-100">
    
    <!-- Navigation Bar -->
    <header class="bg-blue-900 text-white shadow-lg sticky top-0 z-50">
        <div class="container mx-auto px-6 py-4 flex justify-between items-center">
            <h1 class="text-2xl font-bold">
                <a href="dashboard.jsp" class="hover:text-gray-300 transition">BANK MANAGEMENT SYSTEM</a>
            </h1>
            <nav class="hidden md:flex space-x-6">
                <a href="dashboard.jsp" class="hover:text-gray-300 transition">Dashboard</a>
                <a href="transaction-history.jsp" class="hover:text-gray-300 transition">Transactions</a>
                <a href="send-money.jsp" class="hover:text-gray-300 transition">Send Money</a>
                <a href="profile.jsp" class="hover:text-gray-300 transition">My Profile</a>
                
                <c:if test="${sessionScope.role eq 'user'}">
                    <div class="relative group">
                        <button class="hover:text-yellow-300 transition">Loan Section ▼</button>
                        <div class="absolute hidden group-hover:block bg-white text-black rounded shadow-lg py-2 w-40">
                            <a href="myloan.jsp" class="block px-4 py-2 hover:bg-gray-200">My Loan</a>
                            <a href="payloan.jsp" class="block px-4 py-2 hover:bg-gray-200">Pay Loan</a>
                        </div>
                    </div>
                </c:if>
                
                <a href="logout.jsp" class="hover:text-red-300 transition">Logout</a>
            </nav>
        </div>
    </header>
    
    <!-- Pay Loan Section -->
    <div class="flex items-center justify-center min-h-screen">
        <div class="bg-white rounded-lg shadow-lg p-8 w-full max-w-4xl">
            <h2 class="text-3xl font-bold text-blue-900 text-center mb-6">Pay Loan</h2>
            <form action="payloan.jsp" method="post" class="mb-6">
                <div class="flex flex-col md:flex-row md:space-x-4">
                    <div class="w-full md:w-1/2">
                        <label for="loanId" class="block text-sm font-medium text-gray-700">Loan ID:</label>
                        <input type="number" id="loanId" name="loanId" required
                               class="mt-1 block w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500">
                    </div>
                    <div class="w-full md:w-1/2">
                        <label for="paymentAmount" class="block text-sm font-medium text-gray-700">Payment Amount:</label>
                        <input type="number" id="paymentAmount" name="paymentAmount" min="1" required
                               class="mt-1 block w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500">
                    </div>
                </div>
                <button type="submit"
                        class="w-full bg-green-600 text-white mt-4 px-4 py-2 rounded-lg hover:bg-green-700 transition">
                    Pay Loan
                </button>
            </form>

            <!-- Display Active Loans -->
            <h3 class="text-2xl font-bold text-gray-800 mb-4">Your Active Loans</h3>
            <table class="min-w-full bg-white border border-gray-200 rounded-lg shadow-sm">
                <thead class="bg-blue-800 text-white">
                    <tr>
                        <th class="py-3 px-4 text-left">Loan ID</th>
                        <th class="py-3 px-4 text-left">Amount</th>
                        <th class="py-3 px-4 text-left">Interest (%)</th>
                        <th class="py-3 px-4 text-left">Repayment (Total)</th>
                        <th class="py-3 px-4 text-left">Balance</th>
                        <th class="py-3 px-4 text-left">Due Date</th>
                        <th class="py-3 px-4 text-left">Status</th>
                    </tr>
                </thead>
                <tbody class="divide-y divide-gray-200">
                    <%
                    Connection conn = null;
                    PreparedStatement pstmt = null;
                    ResultSet rs = null;
                    try {
                        Class.forName("com.mysql.cj.jdbc.Driver");
                        conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/bankdb", "root", "1234");
                        pstmt = conn.prepareStatement("SELECT loan_id, amount, interest, tenure, due_date, balance, status FROM loans WHERE username = ? AND status = 'Active'");
                        pstmt.setString(1, loggedInUser);
                        rs = pstmt.executeQuery();
                        DecimalFormat df = new DecimalFormat("#.00");
                        while (rs.next()) {
                    %>
                    <tr class="hover:bg-gray-50 transition">
                        <td class="py-3 px-4"><%= rs.getInt("loan_id") %></td>
                        <td class="py-3 px-4">$<%= df.format(rs.getDouble("amount")) %></td>
                        <td class="py-3 px-4"><%= df.format(rs.getDouble("interest")) %>%</td>
                        <td class="py-3 px-4">$<%= df.format(rs.getDouble("amount") + (rs.getDouble("amount") * rs.getDouble("interest") / 100)) %></td>
                        <td class="py-3 px-4">$<%= df.format(rs.getDouble("balance")) %></td>
                        <td class="py-3 px-4"><%= rs.getDate("due_date") %></td>
                        <td class="py-3 px-4 text-yellow-500 font-bold"><%= rs.getString("status") %></td>
                    </tr>
                    <%
                        }
                    } catch (Exception e) {
                        e.printStackTrace();
                    } finally {
                        if (rs != null) rs.close();
                        if (pstmt != null) pstmt.close();
                        if (conn != null) conn.close();
                    }
                    %>
                </tbody>
            </table>
        </div>
    </div>
</body>
</html>
