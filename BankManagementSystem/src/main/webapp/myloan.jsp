<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.text.DecimalFormat, java.util.Calendar" %>

<%
    String loggedInUser = (String) session.getAttribute("user");
    if (loggedInUser == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    String userRole = (String) session.getAttribute("role");
    if (!"user".equals(userRole)) {
        response.sendRedirect("dashboard.jsp");
        return;
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Loans</title>
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

    <!-- My Loans Section -->
    <div class="flex items-center justify-center min-h-screen">
        <div class="bg-white rounded-lg shadow-lg p-8 w-full max-w-4xl">
            <h2 class="text-3xl font-bold text-blue-900 text-center mb-6">My Loans</h2>
            <table class="min-w-full bg-white border border-gray-200 rounded-lg shadow-sm">
                <thead class="bg-blue-800 text-white">
                    <tr>
                        <th class="py-3 px-4 text-left">Loan ID</th>
                        <th class="py-3 px-4 text-left">Amount</th>
                        <th class="py-3 px-4 text-left">Interest (%)</th>
                        <th class="py-3 px-4 text-left">To Be Paid</th>
                        <th class="py-3 px-4 text-left">Due Date</th>
                        <th class="py-3 px-4 text-left">Status</th>
                        <th class="py-3 px-4 text-left">Schedule</th>
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
                        pstmt = conn.prepareStatement("SELECT loan_id, amount, interest, tenure, due_date, balance, status FROM loans WHERE username = ?");
                        pstmt.setString(1, loggedInUser);
                        rs = pstmt.executeQuery();
                        DecimalFormat df = new DecimalFormat("#.00");
                        while (rs.next()) {
                            int loanId = rs.getInt("loan_id");
                            double amount = rs.getDouble("amount");
                            double interest = rs.getDouble("interest");
                            int tenure = rs.getInt("tenure");
                            double balance = rs.getDouble("balance");
                            String status = rs.getString("status");

                            // EMI Calculation
                            double monthlyInterestRate = (interest / 100) / 12;
                            double emi = tenure > 0 ? (balance * monthlyInterestRate + balance / tenure) : 0;
                    %>
                    <tr class="hover:bg-gray-50 transition">
                        <td class="py-3 px-4"><%= loanId %></td>
                        <td class="py-3 px-4">$<%= df.format(amount) %></td>
                        <td class="py-3 px-4"><%= df.format(interest) %>%</td>
                        <td class="py-3 px-4 text-red-500 font-bold">$<%= df.format(balance) %></td>
                        <td class="py-3 px-4"><%= rs.getDate("due_date") %></td>
                        <td class="py-3 px-4 <%= "Completed".equals(status) ? "text-green-500 font-bold" : "text-gray-600" %>"><%= status %></td>
                        <td class="py-3 px-4">
                            <button class="bg-blue-600 text-white px-3 py-1 rounded-md transition hover:bg-blue-700" 
                                onclick="toggleSchedule('<%= loanId %>')">View Schedule</button>
                        </td>
                    </tr>
                    <tr id="schedule-<%= loanId %>" class="hidden">
                        <td colspan="7">
                            <div class="p-4 bg-gray-100 rounded-md shadow-md mt-2">
                                <h3 class="text-lg font-semibold mb-2 text-gray-800">Repayment Schedule</h3>
                                <table class="w-full text-left bg-white shadow-md rounded-lg">
                                    <thead class="bg-gray-300">
                                        <tr>
                                            <th class="py-2 px-4">Installment</th>
                                            <th class="py-2 px-4">Due Date</th>
                                            <th class="py-2 px-4">EMI Amount</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <%
                                        Calendar cal = Calendar.getInstance();
                                        cal.setTime(rs.getDate("due_date"));
                                        for (int i = 1; i <= tenure; i++) {
                                            cal.add(Calendar.MONTH, 1);
                                        %>
                                        <tr class="border-b">
                                            <td class="py-2 px-4"><%= i %></td>
                                            <td class="py-2 px-4"><%= new java.sql.Date(cal.getTimeInMillis()) %></td>
                                            <td class="py-2 px-4 text-green-600 font-bold">$<%= df.format(emi) %></td>
                                        </tr>
                                        <%
                                        }
                                        %>
                                    </tbody>
                                </table>
                            </div>
                        </td>
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

    <script>
        function toggleSchedule(loanId) {
            var row = document.getElementById("schedule-" + loanId);
            if (row) {
                row.classList.toggle("hidden");
            }
        }
    </script>

</body>
</html>
