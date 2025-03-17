<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.text.NumberFormat, java.util.Locale" %>

<%
    String loggedInUser = (String) session.getAttribute("user");
    if (loggedInUser == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    // User details
    String firstName = "";
    String middleName = "";
    String lastName = "";
    String email = "";
    String dob = "";
    double balance = 0.0;
    String role = "";

    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/bankdb", "root", "1234");

        pstmt = conn.prepareStatement("SELECT first_name, middle_name, last_name, email_id, dob, balance, role FROM users WHERE username = ?");
        pstmt.setString(1, loggedInUser);
        rs = pstmt.executeQuery();

        if (rs.next()) {
            firstName = rs.getString("first_name");
            middleName = rs.getString("middle_name") != null ? rs.getString("middle_name") : "";
            lastName = rs.getString("last_name");
            email = rs.getString("email_id");
            dob = rs.getString("dob");
            balance = rs.getDouble("balance");
            role = rs.getString("role");
        }
    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        if (rs != null) rs.close();
        if (pstmt != null) pstmt.close();
        if (conn != null) conn.close();
    }

    // Format balance with commas and .00
    NumberFormat formatter = NumberFormat.getInstance(Locale.US);
    formatter.setGroupingUsed(true);
    String formattedBalance = formatter.format(balance);
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Profile</title>
    <script src="https://cdn.tailwindcss.com"></script>
</head>
<body class="bg-gray-100">

    <!-- Navigation Bar -->
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
                 <% if ("user".equalsIgnoreCase(role)) { %>
                    <div class="relative group">
                        <button class="hover:text-yellow-300 focus:outline-none transition">
                            Loan Section ▼
                        </button>
                        <div class="absolute hidden group-hover:block bg-white text-black rounded shadow-lg py-2 w-40">
                            <a href="myloan.jsp" class="block px-4 py-2 hover:bg-gray-200">My Loan</a>
                            <a href="payloan.jsp" class="block px-4 py-2 hover:bg-gray-200">Pay Loan</a>
                        </div>
                    </div>
                <%} %>

                <!-- Admin Panel (Dropdown for Admin) -->
                 <% if ("admin".equalsIgnoreCase(role)) { %>
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
                <%} %>

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

            <c:if test="${sessionScope.role eq 'user'}">
                <a href="myloan.jsp" class="block px-6 py-2 hover:bg-blue-700">My Loan</a>
                <a href="payloan.jsp" class="block px-6 py-2 hover:bg-blue-700">Pay Loan</a>
            </c:if>

            <c:if test="${sessionScope.role eq 'admin'}">
                <a href="loan.jsp" class="block px-6 py-2 hover:bg-blue-700">Issue Loan</a>
                <a href="admin-loan.jsp" class="block px-6 py-2 hover:bg-blue-700">View Loans</a>
                <a href="viewuser.jsp" class="block px-6 py-2 hover:bg-blue-700">View Users</a>
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

    <!-- Profile Section -->
    <main class="container mx-auto px-4 py-8">
        <section class="bg-white rounded-lg shadow-lg p-6 max-w-lg mx-auto">
            <h2 class="text-xl font-semibold text-blue-900 mb-4">Profile Details</h2>

            <div class="mb-4">
                <label class="font-medium">Full Name:</label>
                <p class="text-gray-700"><%= firstName %> <%= middleName %> <%= lastName %></p>
            </div>

            <div class="mb-4">
                <label class="font-medium">Username:</label>
                <p class="text-gray-700"><%= loggedInUser %></p>
            </div>

            <div class="mb-4">
                <label class="font-medium">Email:</label>
                <p class="text-gray-700"><%= email %></p>
            </div>

            <div class="mb-4">
                <label class="font-medium">Balance:</label>
                <p class="text-green-700 font-bold">$<%= formattedBalance %>.00</p>
            </div>
        </section>
    </main>

</body>
</html>
