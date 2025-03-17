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

@WebServlet("/add-funds")
public class AddFundsServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String username = request.getParameter("username");
        double amount = Double.parseDouble(request.getParameter("amount"));

        try (Connection conn = DBUtil.getConnection()) {
            // Add funds to the user's account
            String sql = "UPDATE users SET balance = balance + ? WHERE username = ?";
            PreparedStatement stmt = conn.prepareStatement(sql);
            stmt.setDouble(1, amount);
            stmt.setString(2, username);
            int rowsUpdated = stmt.executeUpdate();

            if (rowsUpdated > 0) {
                response.sendRedirect("dashboard.jsp");
            } else {
                request.setAttribute("error", "User not found.");
                request.getRequestDispatcher("add-funds.jsp").forward(request, response);
            }
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Database error. Please try again.");
            request.getRequestDispatcher("dashboard.jsp").forward(request, response);
        }
    }
}