<%@ include file="DBConnection.jsp" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.Connection, java.sql.PreparedStatement" %>

<%
    String message = "";
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String name = request.getParameter("name");
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String role = request.getParameter("role");
        String adminPin = request.getParameter("admin_pin");

        if ("ADMIN".equals(role) && (adminPin == null || !adminPin.matches("\\d{6}"))) {
            message = "Error: Administrators require a valid 6-digit numeric PIN.";
        } else {
            try {
                Connection con = getConnection();
                PreparedStatement pst = con.prepareStatement(
                    "INSERT INTO users (name, email, password, role, admin_pin) VALUES (?, ?, ?, ?, ?)"
                );
                pst.setString(1, name);
                pst.setString(2, email);
                pst.setString(3, password);
                pst.setString(4, role);
                pst.setString(5, "ADMIN".equals(role) ? adminPin : null);
                pst.executeUpdate();
                pst.close();
                con.close();

                message = "Registration successful! <a href='login.jsp' style='color:#00ffff;'>Proceed to Login</a>";
            } catch (Exception e) {
                message = "Error: Email might already be registered.";
            }
        }
    }
%>

<html>
<head>
    <title>Register - WheelsGo Futuristic</title>
    <style>
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background: #0b0f19; color: #fff; text-align: center; margin: 0; padding: 0; }
        .container { max-width: 420px; margin: 60px auto; background: rgba(20, 25, 40, 0.85); backdrop-filter: blur(12px); padding: 35px; border-radius: 16px; border: 1px solid rgba(255, 255, 255, 0.1); box-shadow: 0 8px 32px 0 rgba(0, 0, 0, 0.37); text-align: left; }
        h2 { color: #00ffff; text-align: center; margin-bottom: 25px; letter-spacing: 1px; }
        .form-group { margin-bottom: 20px; }
        label { font-weight: 600; display: block; margin-bottom: 8px; font-size: 14px; color: #a0aec0; }
        input, select { width: 100%; padding: 12px; background: rgba(10, 15, 30, 0.6); border: 1px solid #2d3748; border-radius: 8px; color: #fff; font-size: 15px; box-sizing: border-box; }
        input:focus, select:focus { border-color: #00ffff; outline: none; box-shadow: 0 0 10px rgba(0,255,255,0.2); }
        .btn { background: linear-gradient(135deg, #007bff 0%, #00ffff 100%); color: #0b0f19; padding: 12px; border: none; border-radius: 8px; width: 100%; font-size: 16px; font-weight: bold; cursor: pointer; transition: 0.3s; }
        .btn:hover { opacity: 0.9; transform: translateY(-1px); box-shadow: 0 4px 15px rgba(0,255,255,0.4); }
        .msg { text-align: center; color: #48bb78; font-weight: bold; margin-bottom: 20px; }
        .pin-container { display: none; }
    </style>
    <script>
        function toggleAdminPin() {
            var role = document.getElementById('roleSelect').value;
            var pinContainer = document.getElementById('adminPinContainer');
            if (role === 'ADMIN') {
                pinContainer.style.display = 'block';
                document.getElementById('adminPinInput').required = true;
            } else {
                pinContainer.style.display = 'none';
                document.getElementById('adminPinInput').required = false;
            }
        }
    </script>
</head>
<body>

    <div class="container">
        <h2>Create Neural Profile</h2>

        <% if (!message.isEmpty()) { %>
            <div class="msg"><%= message %></div>
        <% } %>

        <form method="post">
            <div class="form-group">
                <label>Full Name</label>
                <input type="text" name="name" required placeholder="Enter your name">
            </div>
            <div class="form-group">
                <label>Email Address</label>
                <input type="email" name="email" required placeholder="user@domain.com">
            </div>
            <div class="form-group">
                <label>Password</label>
                <input type="password" name="password" required placeholder="••••••••">
            </div>
            <div class="form-group">
                <label>Access Role</label>
                <select name="role" id="roleSelect" onchange="toggleAdminPin()">
                    <option value="USER">User / Passenger</option>
                    <option value="ADMIN">Administrator</option>
                </select>
            </div>
            <div class="form-group pin-container" id="adminPinContainer">
                <label>6-Digit Admin Security PIN</label>
                <input type="password" name="admin_pin" id="adminPinInput" maxlength="6" pattern="\d{6}" placeholder="------">
            </div>
            <button type="submit" class="btn">Register Account</button>
        </form>

        <p style="text-align: center; margin-top: 20px; font-size: 14px; color: #a0aec0;">Already have an account? <a href="login.jsp" style="color: #00ffff; text-decoration: none;">Login here</a></p>
    </div>

</body>
</html>