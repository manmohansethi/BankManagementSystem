<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>Register</title>
    <script src="https://cdn.tailwindcss.com"></script>
</head>
<body class="bg-gray-100 flex items-center justify-center min-h-screen">
    <!-- Register Container -->
    <div class="bg-white rounded-lg shadow-lg p-8 w-full max-w-md">
        <h2 class="text-2xl font-bold text-blue-900 text-center mb-6">Register</h2>
        <form action="register" method="post" class="space-y-4">
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
            <!-- Email Field -->
            <div>
                <label for="email" class="block text-sm font-medium text-gray-700">Email:</label>
                <input type="email" id="email" name="email" required
                       class="mt-1 block w-full px-4 py-2 border border-gray-300 rounded-lg shadow-sm focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500">
            </div>
            <!-- First Name Field -->
            <div>
                <label for="firstName" class="block text-sm font-medium text-gray-700">First Name:</label>
                <input type="text" id="firstName" name="firstName" required
                       class="mt-1 block w-full px-4 py-2 border border-gray-300 rounded-lg shadow-sm focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500">
            </div>
            <!-- Middle Name Field -->
            <div>
                <label for="middleName" class="block text-sm font-medium text-gray-700">Middle Name:</label>
                <input type="text" id="middleName" name="middleName"
                       class="mt-1 block w-full px-4 py-2 border border-gray-300 rounded-lg shadow-sm focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500">
            </div>
            <!-- Last Name Field -->
            <div>
                <label for="lastName" class="block text-sm font-medium text-gray-700">Last Name:</label>
                <input type="text" id="lastName" name="lastName" required
                       class="mt-1 block w-full px-4 py-2 border border-gray-300 rounded-lg shadow-sm focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500">
            </div>
            <!-- Date of Birth Field -->
            <div>
                <label for="dob" class="block text-sm font-medium text-gray-700">Date of Birth:</label>
                <input type="date" id="dob" name="dob" required
                       class="mt-1 block w-full px-4 py-2 border border-gray-300 rounded-lg shadow-sm focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500">
            </div>
            <!-- 4-Digit PIN Field -->
            <div>
                <label for="pin" class="block text-sm font-medium text-gray-700">4-Digit PIN:</label>
                <input type="text" id="pin" name="pin" maxlength="4" required
                       class="mt-1 block w-full px-4 py-2 border border-gray-300 rounded-lg shadow-sm focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500">
            </div>
            
            <!-- Register Button -->
            <button type="submit"
                    class="w-full bg-blue-900 text-white px-4 py-2 rounded-lg hover:bg-blue-800 transition duration-300">
                Register
            </button>
        </form>
        <!-- Login Link -->
        <p class="mt-4 text-center text-gray-600">
            Already have an account? <a href="login.jsp" class="text-blue-900 hover:underline">Login here</a>
        </p>
        <!-- Error Message -->
        <c:if test="${not empty error}">
            <p class="mt-4 text-center text-red-600">${error}</p>
        </c:if>
    </div>
</body>
</html>