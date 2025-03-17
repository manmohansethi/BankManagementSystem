<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ page import="java.text.NumberFormat" %>

<%
    // Check if user is logged in
    String loggedInUser = (String) session.getAttribute("user");
    if (loggedInUser == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    // Ensure only admins can issue loans
    String userRole = (String) session.getAttribute("role");
    if (!"admin".equals(userRole)) {
        response.sendRedirect("dashboard.jsp");
        return;
    }

    // Prevent form resubmission on refresh
    if (session.getAttribute("loanIssued") != null) {
        session.removeAttribute("loanIssued");
        response.sendRedirect("loan.jsp");
        return;
    }

    String msg = null;
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            // Database connection
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/bankdb", "root", "1234");

            String username = request.getParameter("username");
            String amount = request.getParameter("amount");
            String interest = request.getParameter("interest");
            String tenure = request.getParameter("tenure");

            if (username != null && amount != null && interest != null && tenure != null) {
                // Check if user already has an active loan
                String checkLoanQuery = "SELECT loan_id FROM loans WHERE username = ? AND status = 'Active'";
                pstmt = conn.prepareStatement(checkLoanQuery);
                pstmt.setString(1, username);
                rs = pstmt.executeQuery();

                if (rs.next()) {
                    msg = "User already has an active loan!";
                } else {
                    // Insert loan into the loans table
                    String insertLoanQuery = "INSERT INTO loans (username, amount, interest, tenure, status, balance, admin_username) VALUES (?, ?, ?, ?, 'Active', ?, ?)";
                    pstmt = conn.prepareStatement(insertLoanQuery);
                    pstmt.setString(1, username);
                    pstmt.setDouble(2, Double.parseDouble(amount));
                    pstmt.setDouble(3, Double.parseDouble(interest));
                    pstmt.setInt(4, Integer.parseInt(tenure));
                    pstmt.setDouble(5, Double.parseDouble(amount)); // Balance = Loan Amount
                    pstmt.setString(6, loggedInUser); // Admin issuing the loan

                    int rowsInserted = pstmt.executeUpdate();
                    if (rowsInserted > 0) {
                        session.setAttribute("loanIssued", "true");
                        msg = "Loan issued successfully!";
                    } else {
                        msg = "Failed to issue loan.";
                    }
                }
            } else {
                msg = "All fields are required!";
            }

        } catch (Exception e) {
            msg = "Error: " + e.getMessage();
        } finally {
            try {
                if (rs != null) rs.close();
                if (pstmt != null) pstmt.close();
                if (conn != null) conn.close();
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Issue Loan</title>
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

                <c:if test="${sessionScope.role eq 'admin'}">
                    <div class="relative group">
                        <button class="hover:text-yellow-300 transition">Admin Panel ▼</button>
                        <div class="absolute hidden group-hover:block bg-white text-black rounded shadow-lg py-2 w-40">
                            <a href="loan.jsp" class="block px-4 py-2 hover:bg-gray-200">Issue Loan</a>
                            <a href="admin-loan.jsp" class="block px-4 py-2 hover:bg-gray-200">View Loans</a>
                            <a href="viewuser.jsp" class="block px-4 py-2 hover:bg-gray-200">View Users</a>
                        </div>
                    </div>
                </c:if>
                
                <a href="logout.jsp" class="hover:text-red-300 transition">Logout</a>
            </nav>
        </div>
    </header>
    
    <!-- Loan Form -->
    <div class="flex items-center justify-center min-h-screen">
        <div class="bg-white rounded-lg shadow-lg p-8 w-full max-w-md">
            <h2 class="text-2xl font-bold text-blue-900 text-center mb-6">Issue Loan to User</h2>
            
            <%-- Display Message --%>
            <% if (msg != null) { %>
                <p class="mb-4 text-center font-semibold <%= msg.contains("successfully") ? "text-green-600" : "text-red-600" %>">
                    <%= msg %>
                </p>
            <% } %>
            
            <form action="loan.jsp" method="post" class="space-y-4">
                <div>
                    <label for="username" class="block text-sm font-medium text-gray-700">Username:</label>
                    <input type="text" id="username" name="username" required
                           class="mt-1 block w-full px-4 py-2 border border-gray-300 rounded-lg shadow-sm focus:ring-2 focus:ring-blue-500">
                </div>

                <div>
                    <label for="amount" class="block text-sm font-medium text-gray-700">Loan Amount:</label>
                    <input type="number" id="amount" name="amount" min="1" required
                           class="mt-1 block w-full px-4 py-2 border border-gray-300 rounded-lg shadow-sm focus:ring-2 focus:ring-blue-500">
                </div>

                <div>
                    <label for="interest" class="block text-sm font-medium text-gray-700">Interest Rate (% per year):</label>
                    <input type="number" id="interest" name="interest" min="1" max="100" required
                           class="mt-1 block w-full px-4 py-2 border border-gray-300 rounded-lg shadow-sm focus:ring-2 focus:ring-blue-500">
                </div>

                <div>
                    <label for="tenure" class="block text-sm font-medium text-gray-700">Loan Tenure (Months):</label>
                    <input type="number" id="tenure" name="tenure" min="1" required
                           class="mt-1 block w-full px-4 py-2 border border-gray-300 rounded-lg shadow-sm focus:ring-2 focus:ring-blue-500">
                </div>

                <button type="submit" class="w-full bg-blue-900 text-white px-4 py-2 rounded-lg hover:bg-blue-800">
                    Issue Loan
                </button>
            </form>
        </div>
    </div>
    
</body>
</html>
