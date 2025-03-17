package com.bank.listener;

import com.mysql.cj.jdbc.AbandonedConnectionCleanupThread;
import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;
import java.sql.Driver;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.Enumeration;

public class ContextListener implements ServletContextListener {
    @Override
    public void contextInitialized(ServletContextEvent sce) {
        // No action needed
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        // Deregister JDBC drivers
        Enumeration<Driver> drivers = DriverManager.getDrivers();
        while (drivers.hasMoreElements()) {
            Driver driver = drivers.nextElement();
            try {
                DriverManager.deregisterDriver(driver);
                System.out.println("Deregistered JDBC driver: " + driver);
            } catch (SQLException e) {
                System.out.println("Error deregistering JDBC driver: " + driver);
                e.printStackTrace();
            }
        }

        // Shutdown the abandoned connection cleanup thread
        AbandonedConnectionCleanupThread.checkedShutdown();
        System.out.println("Abandoned connection cleanup thread shutdown.");
    }
}