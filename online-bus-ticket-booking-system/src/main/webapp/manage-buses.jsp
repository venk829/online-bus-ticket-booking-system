<%@ include file="DBConnection.jsp" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page session="true" %>
<%@ page import="java.sql.Connection, java.sql.PreparedStatement, java.sql.ResultSet" %>

<%
    Integer adminId = (Integer) session.getAttribute("user_id");
    String role = (String) session.getAttribute("role");

    if (adminId == null || !"ADMIN".equals(role)) {
        response.sendRedirect("login.jsp");
        return;
    }

    Connection con = getConnection();

    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String busName = request.getParameter("bus_name");
        String busNumber = request.getParameter("bus_number");
        int totalSeats = Integer.parseInt(request.getParameter("total_seats"));

        PreparedStatement pstInsert = con.prepareStatement(
            "INSERT INTO buses (bus_name, bus_number, total_seats) VALUES (?, ?, ?)"
        );
        pstInsert.setString(1, busName);
        pstInsert.setString(2, busNumber);
        pstInsert.setInt(3, totalSeats);
        pstInsert.executeUpdate();
        pstInsert.close();
    }

    PreparedStatement pstSelect = con.prepareStatement("SELECT * FROM buses");
    ResultSet rs = pstSelect.executeQuery();
%>

<html>
<head>
    <title>Fleet Management - WheelsGo Admin</title>
    <style>
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background: #0b0f19; color: #fff; text-align: center; margin: 0; padding: 0; }
        .container { max-width: 850px; margin: 40px auto; background: rgba(20, 25, 40, 0.9); backdrop-filter: blur(16px); padding: 35px; border-radius: 16px; border: 1px solid rgba(255, 255, 255, 0.1); text-align: left; }
        h2, h3 { color: #00ffff; text-align: center; }
        table { width: 100%; border-collapse: collapse; margin-top: 20px; }
        th, td { border: 1px solid #2d3748; padding: 12px; text-align: center; color: #cbd5e0; font-size: 14px; }
        th { background: rgba(0, 123, 255, 0.2); color: #00ffff; }
        .form-container { background: rgba(10, 15, 30, 0.6); padding: 25px; border-radius: 12px; margin-top: 25px; border: 1px solid #2d3748; }
        .form-group { margin-bottom: 20px; }
        label { font-weight: 600; display: block; margin-bottom: 8px; color: #a0aec0; }
        input[type="text"], input[type="number"] { width: 100%; padding: 12px; background: rgba(10, 15, 30, 0.6); border: 1px solid #2d3748; border-radius: 8px; color: #fff; font-size: 15px; box-sizing: border-box; }
        input:focus { border-color: #00ffff; outline: none; box-shadow: 0 0 10px rgba(0,255,255,0.2); }
        .btn { background: linear-gradient(135deg, #007bff 0%, #00ffff 100%); color: #0b0f19; padding: 12px; border: none; cursor: pointer; border-radius: 8px; width: 100%; font-size: 16px; font-weight: bold; transition: 0.3s; }
        .btn:hover { box-shadow: 0 0 15px rgba(0,255,255,0.4); }
        .back-link { display: block; text-align: center; margin-top: 25px; text-decoration: none; color: #00ffff; font-weight: bold; font-size: 14px; }
    </style>
</head>
<body>

    <div class="container">
        <h2>Fleet Management Protocol</h2>

        <div class="form-container">
            <h3>Register New Carrier Unit</h3>
            <form method="post">
                <div class="form-group">
                    <label>Carrier Designation Name</label>
                    <input type="text" name="bus_name" required placeholder="e.g., Orange CyberLines">
                </div>
                <div class="form-group">
                    <label>Unit Registration Code</label>
                    <input type="text" name="bus_number" required placeholder="e.g., AP07-NX-9921">
                </div>
                <div class="form-group">
                    <label>Maximum Seat Capacity Matrix</label>
                    <input type="number" name="total_seats" required placeholder="e.g., 40">
                </div>
                <button type="submit" class="btn">Deploy Carrier Unit</button>
            </form>
        </div>

        <h3>Active Fleet Manifest</h3>
        <table>
            <tr>
                <th>Identifier ID</th>
                <th>Designation Name</th>
                <th>Registration Code</th>
                <th>Capacity Matrix</th>
            </tr>
            <% while (rs.next()) { %>
                <tr>
                    <td><%= rs.getInt("bus_id") %></td>
                    <td><%= rs.getString("bus_name") %></td>
                    <td><%= rs.getString("bus_number") %></td>
                    <td><%= rs.getInt("total_seats") %> Seats</td>
                </tr>
            <% } %>
        </table>

        <a href="admin-dashboard.jsp" class="back-link">← Return to Admin Command Matrix</a>
    </div>

</body>
</html>

<%
    rs.close();
    pstSelect.close();
    con.close();
%>