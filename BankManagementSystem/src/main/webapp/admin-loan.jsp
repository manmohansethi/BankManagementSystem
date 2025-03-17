<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.text.DecimalFormat, java.util.Calendar" %>

<%
    // Check if the user is logged in and is an admin
    String loggedInUser = (String) session.getAttribute("user");
    String userRole = (String) session.getAttribute("role");

    if (loggedInUser == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    if (!"admin".equals(userRole)) {
        response.sendRedirect("dashboard.jsp"); // Redirect if not admin
        return;
    }

    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Loan Management</title>
    <script src="https://cdn.tailwindcss.com"></script>
</head>
<body>

    <!-- Full Navigation Bar -->
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
                <a href="loan.jsp" class="hover:text-gray-300 transition">Issue Loan</a>
                <a href="admin-loan.jsp" class="hover:text-gray-300 transition">View Loans</a>
                <a href="viewuser.jsp" class="hover:text-gray-300 transition">View Users</a>
                <a href="logout.jsp" class="hover:text-red-300 transition">Logout</a>
            </nav>
        </div>
    </header>

    <main class="container mx-auto px-4 py-8">        
        <h2 class="text-3xl font-bold text-blue-900 text-center mb-6">Loan Management (Admin)</h2>

        <table class="min-w-full bg-white border border-gray-200 rounded-lg shadow-sm">
            <thead class="bg-blue-800 text-white">
                <tr>
                    <th class="py-3 px-4 text-left">Loan ID</th>
                    <th class="py-3 px-4 text-left">User</th>
                    <th class="py-3 px-4 text-left">Amount</th>
                    <th class="py-3 px-4 text-left">Interest (%)</th>
                    <th class="py-3 px-4 text-left">To Be Paid</th>
                    <th class="py-3 px-4 text-left">Due Date</th>
                    <th class="py-3 px-4 text-left">Status</th>
                    <th class="py-3 px-4 text-left">Details</th>
                </tr>
            </thead>
            <tbody class="divide-y divide-gray-200">
                <%
                try {
                    Class.forName("com.mysql.cj.jdbc.Driver");
                    conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/bankdb", "root", "1234");

                    pstmt = conn.prepareStatement(
                        "SELECT loan_id, username, amount, interest, tenure, due_date, balance, status FROM loans"
                    );
                    rs = pstmt.executeQuery();

                    DecimalFormat df = new DecimalFormat("#.00");

                    while (rs.next()) {
                        int loanId = rs.getInt("loan_id");
                        String username = rs.getString("username");
                        double amount = rs.getDouble("amount");
                        double interest = rs.getDouble("interest");
                        int tenure = rs.getInt("tenure");
                        double remainingBalance = Math.max(0, rs.getDouble("balance"));

                        String status = rs.getString("status");
                        String statusColor = "text-gray-600";
                        if ("Completed".equals(status)) statusColor = "text-green-500 font-bold";
                        if ("Defaulted".equals(status)) statusColor = "text-red-500 font-bold";

                        double monthlyInterestRate = (interest / 100) / 12;
                        double newEmi = tenure > 0 ? (remainingBalance * monthlyInterestRate + remainingBalance / tenure) : 0;
                %>
                <tr class="hover:bg-gray-50 transition">
                    <td class="py-3 px-4"><%= loanId %></td>
                    <td class="py-3 px-4"><%= username %></td>
                    <td class="py-3 px-4">$<%= df.format(amount) %></td>
                    <td class="py-3 px-4"><%= df.format(interest) %>%</td>
                    <td class="py-3 px-4 text-red-500 font-bold">$<%= df.format(remainingBalance) %></td>
                    <td class="py-3 px-4"><%= rs.getDate("due_date") %></td>
                    <td class="py-3 px-4 <%= statusColor %>"><%= status %></td>
                    <td class="py-3 px-4">
                        <button class="bg-blue-600 text-white px-3 py-1 rounded-md transition hover:bg-blue-700" 
                            onclick="toggleSchedule('<%= loanId %>')">View Schedule</button>
                    </td>
                </tr>
                <tr id="schedule-<%= loanId %>" class="hidden">
                    <td colspan="8">
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
                                        <td class="py-2 px-4 text-green-600 font-bold">$<%= df.format(newEmi) %></td>
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
                }
                %>
            </tbody>
        </table>
    </main>

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
