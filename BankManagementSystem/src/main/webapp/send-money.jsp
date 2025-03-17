<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>

<%
    // Get the logged-in user's username
    String loggedInUser = (String) session.getAttribute("user");
    if (loggedInUser == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    // Fetch user role
    String userRole = "user"; // Default role
    String role;
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
    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        if (rs != null) rs.close();
        if (pstmt != null) pstmt.close();
        if (conn != null) conn.close();
        role = userRole;
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Send Money</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script> <!-- jQuery for AJAX -->
</head>
<body class="bg-gray-100">
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

        <!-- Mobile Navigation -->
        <div id="mobile-menu" class="hidden bg-blue-800 md:hidden text-white py-2">
            <a href="dashboard.jsp" class="block px-6 py-2 hover:bg-blue-700">Dashboard</a>
            <a href="transaction-history.jsp" class="block px-6 py-2 hover:bg-blue-700">Transactions</a>
            <a href="send-money.jsp" class="block px-6 py-2 hover:bg-blue-700">Send Money</a>
            <a href="profile.jsp" class="block px-6 py-2 hover:bg-blue-700">My Profile</a>

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

    <!-- Main Content -->
    <main class="container mx-auto px-4 py-8">
        <section class="bg-white rounded-lg shadow-lg p-6 max-w-lg mx-auto">
            <h2 class="text-xl font-semibold text-blue-900 mb-4">Send Money</h2>

            <form id="sendMoneyForm" action="send-money" method="post" class="space-y-4">
                <div>
                    <label for="receiver" class="block text-gray-700 font-medium">Receiver Username:</label>
                    <input type="text" id="receiver" name="receiver" required autocomplete="off"
                        class="w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500">
                    <div id="userDropdown" class="absolute bg-white border rounded-md shadow-lg hidden"></div>
                </div>

                <div>
                    <label for="amount" class="block text-gray-700 font-medium">Amount:</label>
                    <input type="number" id="amount" name="amount" required min="1"
                        class="w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500">
                </div>

                <input type="hidden" id="pinInput" name="pin">

                <p id="errorMsg" class="text-red-600 hidden"></p>

                <button type="button" onclick="validateAndOpenPinPopup()" 
                    class="w-full bg-blue-800 text-white py-2 rounded-lg hover:bg-blue-900 transition">
                    Send
                </button>
            </form>

            <p class="text-red-600 mt-4 text-center">${error}</p>

            <!-- Back Button -->
            <div class="mt-6 text-center">
                <a href="dashboard.jsp" 
                    class="bg-gray-500 text-white px-4 py-2 rounded-lg hover:bg-gray-600 transition">
                    Back
                </a>
            </div>
        </section>
    </main>

    <!-- PIN Popup -->
    <div id="pinPopup" class="fixed inset-0 flex items-center justify-center bg-black bg-opacity-50 hidden">
        <div class="bg-white p-6 rounded-lg shadow-lg max-w-sm text-center">
            <h2 class="text-xl font-semibold text-blue-900 mb-4">Enter PIN</h2>
            <input type="password" id="pin" maxlength="4" required
                class="w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500">
            <div class="mt-4">
                <button onclick="submitForm()" class="bg-green-600 text-white px-6 py-2 rounded-lg hover:bg-green-700 transition">
                    Confirm
                </button>
                <button onclick="closePinPopup()" class="bg-red-600 text-white px-6 py-2 rounded-lg hover:bg-red-700 transition ml-4">
                    Cancel
                </button>
            </div>
        </div>
    </div>

    <!-- JavaScript for PIN Popup & User Search -->
    <script>
        let loggedInUser = "<%= loggedInUser %>";

        function validateAndOpenPinPopup() {
            let receiver = document.getElementById("receiver").value.trim();
            let amount = document.getElementById("amount").value.trim();
            let errorMsg = document.getElementById("errorMsg");

            if (receiver === "") {
                errorMsg.innerText = "Please enter a receiver username.";
                errorMsg.classList.remove("hidden");
                return;
            }

            if (receiver.toLowerCase() === loggedInUser.toLowerCase()) {
                errorMsg.innerText = "You cannot send money to yourself!";
                errorMsg.classList.remove("hidden");
                return;
            }

            if (amount <= 0) {
                errorMsg.innerText = "Amount must be greater than 0.";
                errorMsg.classList.remove("hidden");
                return;
            }

            errorMsg.classList.add("hidden");
            document.getElementById("pinPopup").classList.remove("hidden");
        }

        function closePinPopup() {
            document.getElementById("pinPopup").classList.add("hidden");
        }

        function submitForm() {
            let pin = document.getElementById("pin").value.trim();
            if (pin.length !== 4) {
                alert("PIN must be 4 digits.");
                return;
            }
            document.getElementById("pinInput").value = pin;
            closePinPopup();
            document.getElementById("sendMoneyForm").submit();
        }

        $(document).ready(function () {
            function fetchUsers(query = "") {
                $.ajax({
                    url: "searchUser",
                    type: "GET",
                    data: { query: query },
                    dataType: "json",
                    success: function (data) {
                        let dropdown = $("#userDropdown");
                        dropdown.empty().removeClass("hidden");

                        if (Array.isArray(data) && data.length > 0) {
                            data.forEach(user => {
                                let username = user.username || "Unknown";
                                dropdown.append(`<div class="px-4 py-2 hover:bg-gray-200 cursor-pointer" onclick="selectUser('${username}')">${username}</div>`);
                            });
                        } else {
                            dropdown.append('<div class="px-4 py-2 text-gray-500">No users found</div>');
                        }
                    }
                });
            }

            $("#receiver").on("input", function () {
                fetchUsers($(this).val().trim());
            });
        });

        function selectUser(username) {
            $("#receiver").val(username);
            $("#userDropdown").addClass("hidden");
        }
    </script>

</body>
</html>
