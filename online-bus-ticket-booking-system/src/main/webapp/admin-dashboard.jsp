<%@ include file="DBConnection.jsp" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page session="true" %>
<%@ page import="java.sql.Connection, java.sql.PreparedStatement, java.sql.ResultSet" %>

<%
    Integer adminId = (Integer) session.getAttribute("user_id");
    String adminName = (String) session.getAttribute("name");
    String role = (String) session.getAttribute("role");

    // Enforcement rule 2 & 3: Strict role evaluation. If not admin, block entry immediately.
    if (adminId == null || !"ADMIN".equals(role)) {
        response.sendRedirect("login.jsp");
        return;
    }
%>

<html>
<head>
    <title>Admin Control Matrix - WheelsGo</title>
    <style>
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background: #0b0f19; color: #fff; margin: 0; padding: 0; }
        header { background: rgba(15, 23, 42, 0.95); padding: 20px 40px; font-size: 20px; font-weight: bold; color: #00ffff; border-bottom: 1px solid rgba(255,255,255,0.05); display: flex; justify-content: space-between; align-items: center; }
        .container { max-width: 1000px; margin: 40px auto; background: rgba(20, 25, 40, 0.9); backdrop-filter: blur(16px); padding: 35px; border-radius: 16px; border: 1px solid rgba(255, 255, 255, 0.1); box-shadow: 0 10px 40px rgba(0,0,0,0.5); }
        .dashboard-menu { display: flex; justify-content: space-around; background: rgba(10, 15, 30, 0.6); padding: 15px; border-radius: 10px; margin-top: 25px; border: 1px solid #2d3748; }
        .dashboard-menu a { text-decoration: none; color: #00ffff; font-weight: 600; padding: 10px 18px; border: 1px solid rgba(0,255,255,0.3); border-radius: 6px; transition: 0.3s; }
        .dashboard-menu a:hover { background: #00ffff; color: #0b0f19; box-shadow: 0 0 15px rgba(0,255,255,0.4); }
        .dashboard-section { margin-top: 35px; text-align: left; }
        .dashboard-section h3 { color: #00ffff; border-bottom: 1px solid #2d3748; padding-bottom: 8px; }
        table { width: 100%; border-collapse: collapse; margin-top: 15px; }
        th, td { border: 1px solid #2d3748; padding: 12px; text-align: center; font-size: 14px; color: #cbd5e0; }
        th { background: rgba(0, 123, 255, 0.2); color: #00ffff; }
        .btn-logout { background: #fc8181; color: #0b0f19; padding: 8px 16px; border-radius: 6px; text-decoration: none; font-weight: bold; font-size: 14px; }
        .btn-logout:hover { opacity: 0.8; }
    </style>
</head>
<body>

    <header>
        <span>ADMIN CONSOLE // SECURITY LEVEL 5</span>
        <a href="logout.jsp" class="btn-logout">Terminate Session</a>
    </header>

    <div class="container">
        <h2>Command Center: <%= adminName %></h2>
        <p style="color: #a0aec0;">Authorized administrative interface isolated from standard user traffic.</p>

        <div class="dashboard-menu">
            <a href="manage-buses.jsp">Manage Fleet</a>
            <a href="manage-routes.jsp">Manage Routes</a>
            <a href="manage-schedules.jsp">Manage Schedules</a>
            <a href="view-bookings.jsp">Audit Bookings</a>
        </div>

        <div class="dashboard-section">
            <h3>Recent System Manifests</h3>
            <table>
                <tr>
                    <th>Booking ID</th>
                    <th>Operator User</th>
                    <th>Bus Assigned</th>
                    <th>Route Vector</th>
                    <th>Seat Index</th>
                    <th>Status</th>
                </tr>
                <%
                    Connection con = getConnection();
                    PreparedStatement pst = con.prepareStatement(
                        "SELECT b.booking_id, u.name AS user_name, bus.bus_name, r.source, r.destination, " +
                        "b.seat_number, b.status FROM bookings b " +
                        "JOIN users u ON b.user_id = u.user_id " +
                        "JOIN schedules s ON b.schedule_id = s.schedule_id " +
                        "JOIN buses bus ON s.bus_id = bus.bus_id " +
                        "JOIN routes r ON s.route_id = r.route_id " +
                        "ORDER BY b.booking_id DESC LIMIT 5"
                    );
                    ResultSet rs = pst.executeQuery();
                    while (rs.next()) { 
                %>
                    <tr>
                        <td><%= rs.getInt("booking_id") %></td>
                        <td><%= rs.getString("user_name") %></td>
                        <td><%= rs.getString("bus_name") %></td>
                        <td><%= rs.getString("source") %> to <%= rs.getString("destination") %></td>
                        <td><%= rs.getInt("seat_number") %></td>
                        <td><%= rs.getString("status") %></td>
                    </tr>
                <% 
                    }
                    rs.close();
                    pst.close();
                    con.close();
                %>
            </table>
        </div>
        
        <br><br>
        <a href="index.jsp" style="color: #a0aec0; text-decoration: none; font-size: 14px;">← Return to Client Matrix</a>
    </div>

</body>
</html>