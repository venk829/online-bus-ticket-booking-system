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
        String source = request.getParameter("source");
        String destination = request.getParameter("destination");
        int distance = Integer.parseInt(request.getParameter("distance"));

        PreparedStatement pst = con.prepareStatement(
            "INSERT INTO routes (source, destination, distance) VALUES (?, ?, ?)"
        );
        pst.setString(1, source);
        pst.setString(2, destination);
        pst.setInt(3, distance);
        pst.executeUpdate();
        pst.close();
    }

    PreparedStatement pst = con.prepareStatement("SELECT * FROM routes");
    ResultSet rs = pst.executeQuery();
%>

<html>
<head>
    <title>Route Mapping - WheelsGo Admin</title>
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
        input { width: 100%; padding: 12px; background: rgba(10, 15, 30, 0.6); border: 1px solid #2d3748; border-radius: 8px; color: #fff; font-size: 15px; box-sizing: border-box; }
        input:focus { border-color: #00ffff; outline: none; box-shadow: 0 0 10px rgba(0,255,255,0.2); }
        .btn { background: linear-gradient(135deg, #007bff 0%, #00ffff 100%); color: #0b0f19; padding: 12px; border: none; cursor: pointer; border-radius: 8px; width: 100%; font-size: 16px; font-weight: bold; transition: 0.3s; }
        .btn:hover { box-shadow: 0 0 15px rgba(0,255,255,0.4); }
        .back-link { display: block; text-align: center; margin-top: 25px; text-decoration: none; color: #00ffff; font-weight: bold; font-size: 14px; }
    </style>
</head>
<body>

    <div class="container">
        <h2>Transit Vector Mapping</h2>

        <div class="form-container">
            <h3>Establish New Route Vector</h3>
            <form method="post">
                <div class="form-group">
                    <label>Origin Hub</label>
                    <input type="text" name="source" required placeholder="Enter origin terminal">
                </div>
                <div class="form-group">
                    <label>Destination Hub</label>
                    <input type="text" name="destination" required placeholder="Enter destination terminal">
                </div>
                <div class="form-group">
                    <label>Vector Distance (KM)</label>
                    <input type="number" name="distance" required placeholder="Enter metric distance">
                </div>
                <input type="submit" value="Commit Vector Route" class="btn">
            </form>
        </div>

        <h3>Active Corridor Matrix</h3>
        <table>
            <tr>
                <th>Vector ID</th>
                <th>Origin Terminal</th>
                <th>Destination Hub</th>
                <th>Metric Distance</th>
            </tr>
            <% while (rs.next()) { %>
                <tr>
                    <td><%= rs.getInt("route_id") %></td>
                    <td><%= rs.getString("source") %></td>
                    <td><%= rs.getString("destination") %></td>
                    <td><%= rs.getInt("distance") %> KM</td>
                </tr>
            <% } %>
        </table>

        <a href="admin-dashboard.jsp" class="back-link">← Return to Admin Command Matrix</a>
    </div>

</body>
</html>

<%
    rs.close();
    pst.close();
    con.close();
%>