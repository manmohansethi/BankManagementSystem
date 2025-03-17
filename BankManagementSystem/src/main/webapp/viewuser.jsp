<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<%@ page import="java.sql.*, java.util.*, java.text.NumberFormat" %>


<%
    // Restrict access to admins only
    String loggedInUser = (String) session.getAttribute("user");
    if (loggedInUser == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    String userRole = "user"; // Default role
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/bankdb", "root", "1234");

        pstmt = conn.prepareStatement("SELECT role FROM users WHERE username = ?");
        pstmt.setString(1, loggedInUser);
        rs = pstmt.executeQuery();
        if (rs.next()) {
            userRole = rs.getString("role");
        }
        rs.close();
        pstmt.close();

        if (!"admin".equals(userRole)) {
            response.sendRedirect("dashboard.jsp");
            return;
        }
    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        if (conn != null) conn.close();
    }

    // Search user details
    String searchUsername = request.getParameter("username");
    boolean userFound = false;
    String foundEmail = "", foundRole = "", formattedBalance = "";
    List<Map<String, String>> transactions = new ArrayList<>();

    if (searchUsername != null && !searchUsername.isEmpty()) {
        try {
            conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/bankdb", "root", "1234");

            pstmt = conn.prepareStatement("SELECT email_id, role, balance FROM users WHERE username = ?");
            pstmt.setString(1, searchUsername);
            rs = pstmt.executeQuery();
            if (rs.next()) {
                userFound = true;
                foundEmail = rs.getString("email_id");
                foundRole = rs.getString("role");
                double balance = rs.getDouble("balance");
                NumberFormat formatter = NumberFormat.getInstance();
                formatter.setGroupingUsed(true);
                formattedBalance = formatter.format(balance);
            }
            rs.close();
            pstmt.close();

            // Fetch transaction history with Send/Receive Status
            pstmt = conn.prepareStatement(
                "SELECT t.transaction_id, t.transaction_amount, t.transact_to, t.transaction_time, " +
                "CASE " +
                "WHEN t.user_id = (SELECT userid FROM users WHERE username = ?) THEN 'Sent' " +
                "WHEN t.transact_to = ? THEN 'Received' " +
                "ELSE 'Unknown' END AS transaction_status " +
                "FROM transactions t " +
                "WHERE t.user_id = (SELECT userid FROM users WHERE username = ?) OR t.transact_to = ? " +
                "ORDER BY t.transaction_time DESC"
            );
            pstmt.setString(1, searchUsername);
            pstmt.setString(2, searchUsername);
            pstmt.setString(3, searchUsername);
            pstmt.setString(4, searchUsername);
            rs = pstmt.executeQuery();
            while (rs.next()) {
                Map<String, String> transaction = new HashMap<>();
                transaction.put("id", String.valueOf(rs.getInt("transaction_id")));
                transaction.put("amount", "$" + rs.getDouble("transaction_amount"));
                transaction.put("recipient", rs.getString("transact_to"));
                transaction.put("status", rs.getString("transaction_status"));
                transaction.put("date", rs.getTimestamp("transaction_time").toString());
                transactions.add(transaction);
            }
            rs.close();
            pstmt.close();
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            if (conn != null) conn.close();
        }
    }
%>

<html>
<head>
    <title>View Users</title>
    <script src="https://cdn.tailwindcss.com"></script>
</head>
<body class="bg-gray-100">

    <!-- Navigation Bar -->
    
    <!-- Full Navigation Bar -->
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

                <!-- Loan Section (For Users) -->
                  <% if ("user".equalsIgnoreCase(userRole)) { %>
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
                 <% if ("admin".equalsIgnoreCase(userRole)) { %>
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

        <!-- Mobile Navigation -->
        <div id="mobile-menu" class="hidden bg-blue-800 md:hidden text-white py-2">
            <a href="dashboard.jsp" class="block px-6 py-2 hover:bg-blue-700">Dashboard</a>
            <a href="transaction-history.jsp" class="block px-6 py-2 hover:bg-blue-700">Transactions</a>
            <a href="send-money.jsp" class="block px-6 py-2 hover:bg-blue-700">Send Money</a>
            <a href="profile.jsp" class="block px-6 py-2 hover:bg-blue-700">My Profile</a>

            <% if ("user".equalsIgnoreCase(userRole)) { %>
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
                 <% if ("admin".equalsIgnoreCase(userRole)) { %>
                    <div class="relative group">
                        <button class="hover:text-yellow-300 focus:outline-none transition">
                            Admin Panel 
                        </button>
                        <div class="absolute hidden group-hover:block bg-white text-black rounded shadow-lg py-2 w-40">
                            <a href="loan.jsp" class="block px-4 py-2 hover:bg-gray-200">Issue Loan</a>
                            <a href="admin-loan.jsp" class="block px-4 py-2 hover:bg-gray-200">View Loans</a>
                            <a href="viewuser.jsp" class="block px-4 py-2 hover:bg-gray-200">View Users</a>
                        </div>
                    </div>
                <%} %>


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


    <!-- Search Section -->
    <% if (!userFound) { %>
    <section class="bg-white rounded-lg shadow-lg p-6 max-w-lg mx-auto mt-6">
        <h2 class="text-xl font-semibold text-blue-900 mb-4 text-center">Search User</h2>
        <form method="GET" action="viewusers.jsp">
            <input type="text" name="username" placeholder="Enter username..." required
                class="w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500">
            <button type="submit" class="w-full bg-blue-800 text-white py-2 mt-2 rounded-lg hover:bg-blue-900 transition">
                Fetch User
            </button>
        </form>
    </section>
    
        <!-- All Users Table -->
    <section id="userTable" class="bg-white rounded-lg shadow-lg p-6 mt-6">
        <h3 class="text-lg font-semibold text-blue-900 mb-4 text-center">All Users</h3>
        <div class="overflow-x-auto">
            <table class="min-w-full bg-white border border-gray-200 rounded-lg">
                <thead class="bg-blue-800 text-white">
                    <tr>
                        <th class="py-3 px-4 text-left">Username</th>
                        <th class="py-3 px-4 text-left">Email</th>
                        <th class="py-3 px-4 text-left">Role</th>
                        <th class="py-3 px-4 text-left">Balance</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                        try {
                            conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/bankdb", "root", "1234");
                            pstmt = conn.prepareStatement("SELECT username, email_id, role, balance FROM users ORDER BY role DESC");
                            rs = pstmt.executeQuery();
                            NumberFormat formatter = NumberFormat.getInstance();
                            formatter.setGroupingUsed(true);

                            while (rs.next()) {
                                String username = rs.getString("username");
                                String email = rs.getString("email_id");
                                String role = rs.getString("role");
                                double balance = rs.getDouble("balance");
                                String formattedBalanceUserList = formatter.format(balance); // FIX: Renamed variable
                    %>
                    <tr class="hover:bg-gray-50 cursor-pointer">
                        <td class="py-3 px-4 border-b text-blue-700 underline">
                            <a href="viewusers.jsp?username=<%= username %>"><%= username %></a>
                        </td>
                        <td class="py-3 px-4 border-b"><%= email %></td>
                        <td class="py-3 px-4 border-b"><%= role %></td>
                        <td class="py-3 px-4 border-b">$<%= formattedBalanceUserList %>.00</td>
                    </tr>
                    <%
                            }
                            rs.close();
                            pstmt.close();
                            conn.close();
                        } catch (Exception e) {
                            e.printStackTrace();
                        }
                    %>
                </tbody>
            </table>
        </div>
    </section>
    
        <% } %>
    
   

    <!-- User Details Section -->
    <% if (userFound) { %>
    <section class="bg-white rounded-lg shadow-lg p-6 max-w-2xl mx-auto mt-6">
        <h3 class="text-lg font-semibold text-blue-900 mb-4">User Details</h3>
        <p><strong>Username:</strong> <%= searchUsername %></p>
        <p><strong>Email:</strong> <%= foundEmail %></p>
        <p><strong>Role:</strong> <%= foundRole %></p>
        <p><strong>Balance:</strong> <span class="font-bold text-green-600">$<%= formattedBalance %>.00</span></p>

        <h3 class="text-lg font-semibold text-blue-900 mt-6">Transaction History</h3>
        <div class="overflow-x-auto">
            <table class="w-full bg-white border border-gray-200 rounded-lg mt-4">
                <thead class="bg-blue-800 text-white">
                    <tr>
                        <th class="py-3 px-4 text-left">Transaction ID</th>
                        <th class="py-3 px-4 text-left">Amount</th>
                        <th class="py-3 px-4 text-left">Recipient</th>
                        <th class="py-3 px-4 text-left">Status</th>
                        <th class="py-3 px-4 text-left">Date & Time</th>
                    </tr>
                </thead>
                <tbody>
                    <% for (Map<String, String> transaction : transactions) { %>
                    <tr class="hover:bg-gray-50">
                        <td class="py-3 px-4 border-b"><%= transaction.get("id") %></td>
                        <td class="py-3 px-4 border-b"><%= transaction.get("amount") %></td>
                        <td class="py-3 px-4 border-b"><%= transaction.get("recipient") %></td>
                        <td class="py-3 px-4 border-b font-bold <%= transaction.get("status").equals("Sent") ? "text-red-600" : "text-green-600" %>">
                            <%= transaction.get("status") %>
                        </td>
                        <td class="py-3 px-4 border-b"><%= transaction.get("date") %></td>
                    </tr>
                    <% } %>
                </tbody>
            </table>
        </div>

        <button onclick="window.location.href='viewusers.jsp';" class="mt-4 bg-gray-500 text-white px-4 py-2 rounded-lg hover:bg-gray-600 transition">
            Back
        </button>
    </section>
    <% } %>

</body>
</html>
