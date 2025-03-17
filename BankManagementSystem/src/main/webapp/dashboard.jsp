<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ page import="java.text.NumberFormat" %>

<%
    String loggedInUser = (String) session.getAttribute("user");
    if (loggedInUser == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    // Fetch user details (Full Name, Role, and Balance)
    String fullName = "User";
    String userRole = "user"; // Default role
    double balance = 0.0;

    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/bankdb", "root", "1234");

        pstmt = conn.prepareStatement("SELECT first_name, role, balance FROM users WHERE username = ?");
        pstmt.setString(1, loggedInUser);
        rs = pstmt.executeQuery();
        if (rs.next()) {
            fullName = rs.getString("first_name");
            userRole = rs.getString("role");
            balance = rs.getDouble("balance");
            
            // Store role in session for access control
            session.setAttribute("role", userRole);
        }
    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        if (rs != null) rs.close();
        if (pstmt != null) pstmt.close();
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard - Bank Management System</title>
    <script src="https://cdn.tailwindcss.com"></script>
</head>
<body class="bg-gray-100">
    <!-- Modern Navigation Menu -->
 <header class="bg-blue-900 text-white shadow-lg sticky top-0 z-50">
    <div class="container mx-auto px-6 py-4 flex justify-between items-center">
        <h1 class="text-2xl font-bold">
            <a href="dashboard.jsp" class="hover:text-gray-300 transition">BANK MANAGEMENT SYSTEM</a>
        </h1>
        
        <!-- Desktop Navigation -->
        <nav class="hidden md:flex space-x-6">
            <a href="dashboard.jsp" class="hover:text-gray-300 transition">Dashboard</a>
            <a href="transaction-history.jsp" class="hover:text-gray-300 transition">Transactions</a> 
            <a href="send-money.jsp" class="hover:text-gray-300 transition">Send Money</a>
            <a href="profile.jsp" class="hover:text-gray-300 transition">My Profile</a>

            <!-- Loan Section (Dropdown for Users) -->
            <c:if test="${sessionScope.role != null && sessionScope.role eq 'user'}">
                <div class="relative group">
                    <button class="hover:text-yellow-300 focus:outline-none transition">
                        Loan Section ▼
                    </button>
                    <div class="absolute hidden group-hover:block bg-white text-black rounded shadow-lg py-2 w-40">
                        <a href="myloan.jsp" class="block px-4 py-2 hover:bg-gray-200">My Loan</a>
                        <a href="payloan.jsp" class="block px-4 py-2 hover:bg-gray-200">Pay Loan</a>
                    </div>
                </div>
            </c:if>

            <!-- Admin Panel (Dropdown for Admin) -->
            <c:if test="${sessionScope.role != null && sessionScope.role eq 'admin'}">
                <div class="relative group">
                    <button class="hover:text-yellow-300 focus:outline-none transition">
                        Admin Panel ▼
                    </button>
                    <div class="absolute hidden group-hover:block bg-white text-black rounded shadow-lg py-2 w-40">
                        <a href="loan.jsp" class="block px-4 py-2 hover:bg-gray-200">Issue Loan</a>
                        <a href="admin-loan.jsp" class="block px-4 py-2 hover:bg-gray-200">View Loans</a>
                        <a href="viewuser.jsp" class="block px-4 py-2 hover:bg-gray-200">View Users</a>
                    </div>
                </div>
            </c:if>

            <a href="logout.jsp" class="hover:text-red-300 transition">Logout</a>
        </nav>

        <!-- Mobile Menu Button -->
        <button id="menu-toggle" class="md:hidden focus:outline-none">
            <svg class="w-6 h-6" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" d="M4 6h16M4 12h16m-7 6h7"></path>
            </svg>
        </button>
    </div>

    <!-- Mobile Navigation (Hidden by Default) -->
    <div id="mobile-menu" class="hidden bg-blue-800 md:hidden text-white py-2">
        <a href="dashboard.jsp" class="block px-6 py-2 hover:bg-blue-700">Dashboard</a>
        <a href="transaction-history.jsp" class="block px-6 py-2 hover:bg-blue-700">Transactions</a>
        <a href="send-money.jsp" class="block px-6 py-2 hover:bg-blue-700">Send Money</a>
        <a href="profile.jsp" class="block px-6 py-2 hover:bg-blue-700">My Profile</a>

        <!-- Loan Section for Users -->
        <c:if test="${sessionScope.role != null && sessionScope.role eq 'user'}">
            <div class="group">
                <button class="block px-6 py-2 w-full text-left focus:outline-none hover:bg-blue-700">Loan Section ▼</button>
                <div class="hidden group-hover:block bg-blue-700">
                    <a href="myloan.jsp" class="block px-6 py-2 hover:bg-blue-600">My Loan</a>
                    <a href="payloan.jsp" class="block px-6 py-2 hover:bg-blue-600">Pay Loan</a>
                </div>
            </div>
        </c:if>

        <!-- Admin Panel for Admin -->
        <c:if test="${sessionScope.role != null && sessionScope.role eq 'admin'}">
            <div class="group">
                <button class="block px-6 py-2 w-full text-left focus:outline-none hover:bg-blue-700">Admin Panel ▼</button>
                <div class="hidden group-hover:block bg-blue-700">
                    <a href="loan.jsp" class="block px-6 py-2 hover:bg-blue-600">Issue Loan</a>
                    <a href="admin-loan.jsp" class="block px-6 py-2 hover:bg-blue-600">View Loans</a>
                    <a href="viewuser.jsp" class="block px-6 py-2 hover:bg-blue-600">View Users</a>
                </div>
            </div>
        </c:if>

        <a href="logout.jsp" class="block px-6 py-2 hover:bg-red-600">Logout</a>
    </div>
</header>

<!-- JavaScript for Mobile Menu Toggle -->
<script>
    document.getElementById("menu-toggle").addEventListener("click", function() {
        var menu = document.getElementById("mobile-menu");
        menu.classList.toggle("hidden");
    });
</script>


    <!-- Main Dashboard Section -->
    <main class="container mx-auto px-4 py-8">
        <section class="bg-white rounded-lg shadow-lg p-6">
        <%
        if (fullName != null && !fullName.isEmpty()) {
            fullName = fullName.substring(0, 1).toUpperCase() + fullName.substring(1).toLowerCase();
        }
        %>
            <h1 class="text-3xl font-semibold text-blue-900 mb-4">
                Hello, <%= fullName %>
            </h1>

            <!-- Balance Section -->
             <h3 class="font-bold text-2xl mb-4">
             	<%
                NumberFormat formatter = NumberFormat.getInstance();
                formatter.setGroupingUsed(true);
                String formattedBalance = formatter.format(balance);
                %>
                <%
                    if ("admin".equals(userRole)) {
                %>
                    Total Bank Balance: $<%= formattedBalance %>.00
                <%
                    } else {
                %>
                    Your Balance: $<%= formattedBalance %>.00
                <%
                    }
                %>
            </h3>
            
              <!-- Recent Transactions Section -->
            <h3 class="text-lg font-medium mb-4">Recent Transactions</h3>
            <div class="overflow-x-auto">
                <table class="min-w-full bg-white border border-gray-200 rounded-lg">
                    <thead class="bg-blue-800 text-white">
                        <tr>
                            <th class="py-3 px-4 text-left">SL. NO.</th>
                            <th class="py-3 px-4 text-left">Transaction ID</th>
                            <th class="py-3 px-4 text-left">Amount</th>
                            <th class="py-3 px-4 text-left">Recipient</th>
                            <% if ("admin".equals(userRole)) { %>
                                <th class="py-3 px-4 text-left">Sender</th> <!-- For Admin -->
                            <% } else { %>
                                <th class="py-3 px-4 text-left">Status</th> <!-- For User -->
                            <% } %>
                            <th class="py-3 px-4 text-left">Date & Time</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                        try {
                            if (conn == null) {
                                conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/bankdb", "root", "1234");
                            }
                            String sql;
                            if ("admin".equals(userRole)) {
                                // Admin query: Fetch all transactions with sender username
                                sql = "SELECT t.transaction_id, t.transaction_amount, t.transact_to, t.transaction_time, u.username AS sender " +
                                      "FROM transactions t " +
                                      "JOIN users u ON t.user_id = u.userid " +
                                      "ORDER BY t.transaction_time DESC LIMIT 5";
                                pstmt = conn.prepareStatement(sql);
                            } else {
                                // User query: Fetch transactions and hide "Unknown" status
                                
                                sql = "SELECT t.transaction_id, t.transaction_amount, t.transact_to, t.transaction_time, " +
                            		      "CASE " +
                            		      "WHEN t.user_id = (SELECT userid FROM users WHERE username = ?) THEN 'Sent' " +
                            		      "WHEN (SELECT username FROM users WHERE userid = t.user_id) = 'admin' THEN 'Deposit' " +  // Correctly identify deposits from admin
                            		      "WHEN t.transact_to = ? THEN 'Received' " +
                            		      "ELSE 'Unknown' END AS transaction_status " +
                            		      "FROM transactions t " +
                            		      "HAVING transaction_status != 'Unknown' " +
                            		      "ORDER BY t.transaction_time DESC LIMIT 5";

                                pstmt = conn.prepareStatement(sql);
                                pstmt.setString(1, loggedInUser);
                                pstmt.setString(2, loggedInUser);
                            }

                            rs = pstmt.executeQuery();
                            int i = 1;
                            while (rs.next()) {
                        %>
                       <tr class="hover:bg-gray-50">
                            <td class="py-3 px-4 border-b"><%= i++ %></td>
                            <td class="py-3 px-4 border-b"><%= rs.getString("transaction_id") %></td>
                            <td class="py-3 px-4 border-b">$<%= String.format("%.2f", rs.getDouble("transaction_amount")) %></td>
                            <td class="py-3 px-4 border-b"><%= rs.getString("transact_to") %></td>
                            
                            <td class="py-3 px-4 border-b">
                                <% if ("admin".equals(userRole)) { %>
                                    <%= rs.getString("sender") %> <!-- Admin sees sender -->
                                <% } else { %>
                                    <%= "Deposit".equals(rs.getString("transaction_status")) ? 
                                        "<span class='text-green-500 font-bold'>Deposit</span>" : 
                                        rs.getString("transaction_status") %>
                                <% } %>
                            </td>

                            <td class="py-3 px-4 border-b"><%= rs.getTimestamp("transaction_time") %></td>
                        </tr>
                        <%
                                i++;
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
            
        </section>
    </main>
</body>
</html>
