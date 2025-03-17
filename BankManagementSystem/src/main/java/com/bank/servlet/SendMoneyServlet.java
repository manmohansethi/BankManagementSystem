package com.bank.servlet;

import com.bank.util.DBUtil;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

@WebServlet("/send-money")
public class SendMoneyServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        String sender = (String) session.getAttribute("user");
        String receiver = request.getParameter("receiver");
        double amount = Double.parseDouble(request.getParameter("amount"));

        try (Connection conn = DBUtil.getConnection()) {
            // Check sender's balance
            String checkBalanceSql = "SELECT balance FROM users WHERE username = ?";
            try (PreparedStatement checkBalanceStmt = conn.prepareStatement(checkBalanceSql)) {
                checkBalanceStmt.setString(1, sender);
                try (ResultSet rs = checkBalanceStmt.executeQuery()) {
                    if (rs.next() && rs.getDouble("balance") >= amount) {
                        // Deduct from sender
                        String deductSql = "UPDATE users SET balance = balance - ? WHERE username = ?";
                        try (PreparedStatement deductStmt = conn.prepareStatement(deductSql)) {
                            deductStmt.setDouble(1, amount);
                            deductStmt.setString(2, sender);
                            deductStmt.executeUpdate();
                        }

                        // Add to receiver
                        String addSql = "UPDATE users SET balance = balance + ? WHERE username = ?";
                        try (PreparedStatement addStmt = conn.prepareStatement(addSql)) {
                            addStmt.setDouble(1, amount);
                            addStmt.setString(2, receiver);
                            addStmt.executeUpdate();
                        }

                        // Record transaction
                        String transactionSql = "INSERT INTO transactions (user_id, transaction_amount, transact_to) VALUES ((SELECT userid FROM users WHERE username = ?), ?, ?)";
                        try (PreparedStatement transactionStmt = conn.prepareStatement(transactionSql)) {
                            transactionStmt.setString(1, sender);
                            transactionStmt.setDouble(2, amount);
                            transactionStmt.setString(3, receiver);
                            transactionStmt.executeUpdate();
                        }

                        response.sendRedirect("dashboard.jsp");
                    } else {
                        request.setAttribute("error", "Insufficient balance or receiver not found.");
                        request.getRequestDispatcher("send-money.jsp").forward(request, response);
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Database error. Please try again.");
            request.getRequestDispatcher("send-money.jsp").forward(request, response);
        }
    }
}