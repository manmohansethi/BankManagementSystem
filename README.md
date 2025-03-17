# Bank Management System

This project is a web-based Bank Management System developed using JSP, Servlets, and MySQL. It provides a secure and user-friendly platform for online banking operations, including user authentication, fund transfers, loan management, and transaction history tracking.

## Features

* **User Authentication:** Secure user registration and login with password hashing.
* **Fund Transfers:** Real-time fund transfers between registered users.
* **Loan Management:** Loan application, approval, and status tracking.
* **Transaction History:** Detailed transaction records for users.
* **Admin Panel:** Comprehensive administrative tools for user and loan management.
* **Database:** MySQL for data storage.
* **Security:** Prevention of SQL injection, secure session management, and SHA-256 for password hashing.

## Technologies Used

* **Frontend:** JSP, HTML, CSS, JavaScript
* **Backend:** Java Servlets, JDBC
* **Database:** MySQL
* **Security:** SHA-256

## Prerequisites

Before running the application, ensure you have the following installed:

* Java Development Kit (JDK)
* MySQL
* Apache Tomcat server
* Git

## Installation

1.  **Clone the Repository:**

    ```bash
    git clone [https://github.com/YourUsername/BankManagementSystem.git](https://github.com/YourUsername/BankManagementSystem.git)
    ```

2.  **Database Setup:**

    * Create a MySQL database named `bank_system`.
    * Run the SQL scripts located in the `database/` directory to create the tables.
    * Update the `DBUtil.java` file with your MySQL database credentials (username, password, URL).

3.  **Import Project:**

    * Import the project into your preferred IDE (e.g., Eclipse, IntelliJ IDEA).

4.  **Configure Tomcat:**

    * Configure your IDE or standalone Tomcat server to deploy the web application.

5.  **Build and Deploy:**

    * Build the project and deploy the WAR file to your Tomcat server.

6.  **Run the Application:**

    * Open your web browser and navigate to `http://localhost:8080/BankManagementSystem/`.

## Database Configuration

* Update the following database connection details in `src/DBUtil.java`:

    ```java
    private static final String URL = "jdbc:mysql://localhost:3306/bank_system";
    private static final String USER = "your_mysql_username";
    private static final String PASSWORD = "your_mysql_password";
    ```

## Usage

* **User Registration:** Navigate to the registration page and create a new account.
* **User Login:** Log in with your username and password.
* **Fund Transfer:** Use the "Send Money" page to transfer funds to other users.
* **Loan Application:** Apply for loans using the "Loan" page.
* **Admin Panel:** Access the admin panel for user and loan management.

## Contributing

Contributions are welcome! Please feel free to submit pull requests or open issues for bug fixes and feature requests.

## License

This project is licensed under the [MIT License](LICENSE) (if applicable).

## Security Notes

* **Important:** Ensure you change the default MySQL credentials and do not commit sensitive information (like database passwords) to the repository.
* The system implements SHA-256 password hashing and prevents SQL injection, but always follow security best practices.
