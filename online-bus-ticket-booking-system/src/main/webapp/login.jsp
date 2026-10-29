<%@ include file="DBConnection.jsp" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page session="true" %>
<%@ page import="java.sql.Connection, java.sql.PreparedStatement, java.sql.ResultSet" %>
<html>
<head>
    <title>Secure Login - WheelsGo</title>
    <style>
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background: #0b0f19; color: #fff; text-align: center; margin: 0; padding: 0; }
        .container { max-width: 400px; margin: 80px auto; background: rgba(20, 25, 40, 0.85); backdrop-filter: blur(12px); padding: 35px; border-radius: 16px; border: 1px solid rgba(255, 255, 255, 0.1); box-shadow: 0 8px 32px 0 rgba(0, 0, 0, 0.37); text-align: left; }
        h2 { color: #00ffff; text-align: center; margin-bottom: 25px; letter-spacing: 1px; }
        label { font-weight: 600; display: block; margin-bottom: 8px; font-size: 14px; color: #a0aec0; }
        input, select { width: 100%; padding: 12px; background: rgba(10, 15, 30, 0.6); border: 1px solid #2d3748; border-radius: 8px; color: #fff; font-size: 15px; margin-bottom: 20px; box-sizing: border-box; }
        input:focus, select:focus { border-color: #00ffff; outline: none; box-shadow: 0 0 10px rgba(0,255,255,0.2); }
        .btn { background: linear-gradient(135deg, #007bff 0%, #00ffff 100%); color: #0b0f19; padding: 12px; border: none; border-radius: 8px; width: 100%; font-size: 16px; font-weight: bold; cursor: pointer; transition: 0.3s; }
        .btn:hover { opacity: 0.9; transform: translateY(-1px); box-shadow: 0 4px 15px rgba(0,255,255,0.4); }
        .error { color: #fc8181; background: rgba(252, 129, 129, 0.1); padding: 10px; border-radius: 6px; margin-bottom: 20px; text-align: center; font-size: 14px; }
        .pin-box { display: none; }
    </style>
    <script>
        function checkRoleLogin() {
            var role = document.getElementById('loginRole').value;
            var pinBox = document.getElementById('adminLoginPinBox');
            if (role === 'ADMIN') {
                pinBox.style.display = 'block';
                document.getElementById('loginPinField').required = true;
            } else {
                pinBox.style.display = 'none';
                document.getElementById('loginPinField').required = false;
            }
        }
    </script>
</head>
<body>

    <div class="container">
        <h2>Secure Gateway</h2>

        <% 
            String errorMsg = "";
            if ("POST".equalsIgnoreCase(request.getMethod())) {
                String email = request.getParameter("email");
                String password = request.getParameter("password");
                String role = request.getParameter("role");
                String adminPin = request.getParameter("admin_pin");

                Connection con = getConnection();
                PreparedStatement pst;
                
                if ("ADMIN".equals(role)) {
                    pst = con.prepareStatement("SELECT * FROM users WHERE email = ? AND password = ? AND role = ? AND admin_pin = ?");
                    pst.setString(1, email);
                    pst.setString(2, password);
                    pst.setString(3, role);
                    pst.setString(4, adminPin);
                } else {
                    pst = con.prepareStatement("SELECT * FROM users WHERE email = ? AND password = ? AND role = ?");
                    pst.setString(1, email);
                    pst.setString(2, password);
                    pst.setString(3, role);
                }
                
                ResultSet rs = pst.executeQuery();

                if (rs.next()) {
                    session.setAttribute("user_id", rs.getInt("user_id"));
                    session.setAttribute("name", rs.getString("name"));
                    session.setAttribute("role", rs.getString("role"));

                    if ("ADMIN".equals(role)) {
                        response.sendRedirect("admin-dashboard.jsp");
                    } else {
                        response.sendRedirect("index.jsp");
                    }
                    return;
                } else {
                    errorMsg = "Authentication Failed: Invalid Credentials or incorrect Admin PIN.";
                } 
                rs.close();
                pst.close();
                con.close();
            } 
        %>

        <% if(!errorMsg.isEmpty()) { %>
            <div class="error"><%= errorMsg %></div>
        <% } %>

        <form method="post">
            <label>Email Address</label>
            <input type="email" name="email" required placeholder="user@domain.com">

            <label>Password</label>
            <input type="password" name="password" required placeholder="••••••••">

            <label>Target Portal Role</label>
            <select name="role" id="loginRole" onchange="checkRoleLogin()">
                <option value="USER">User Portal</option>
                <option value="ADMIN">Admin Console</option>
            </select>

            <div class="pin-box" id="adminLoginPinBox">
                <label>6-Digit Admin Security PIN</label>
                <input type="password" name="admin_pin" id="loginPinField" maxlength="6" pattern="\d{6}" placeholder="------">
            </div>

            <button type="submit" class="btn">Authorize Session</button>
        </form>

        <p style="margin-top: 20px; text-align: center; font-size: 14px; color: #a0aec0;">New entity? <a href="register.jsp" style="color: #00ffff; text-decoration: none;">Register profile</a></p>
    </div>

</body>
</html>