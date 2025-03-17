package com.bank.servlet;

import com.bank.util.DBUtil;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;

@WebServlet("/register")
public class RegisterServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String username = request.getParameter("username");
        String password = request.getParameter("password");
        String email = request.getParameter("email");
        String firstName = request.getParameter("firstName");
        String middleName = request.getParameter("middleName");
        String lastName = request.getParameter("lastName");
        String dob = request.getParameter("dob");
        String pin = request.getParameter("pin");

        try (Connection conn = DBUtil.getConnection()) {
            String sql = "INSERT INTO users (username, password_hash, email_id, first_name, middle_name, last_name, dob, pin, role) VALUES (?, ?, ?, ?, ?, ?, ?, ?, 'user')";
            PreparedStatement stmt = conn.prepareStatement(sql);
            stmt.setString(1, username);
            stmt.setString(2, password); // Hash the password in real projects
            stmt.setString(3, email);
            stmt.setString(4, firstName);
            stmt.setString(5, middleName);
            stmt.setString(6, lastName);
            stmt.setString(7, dob);
            stmt.setString(8, pin);
            stmt.executeUpdate();

            response.sendRedirect("login.jsp");
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Registration failed. Please try again.");
            request.getRequestDispatcher("register.jsp").forward(request, response);
        }
    }
}