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
        int busId = Integer.parseInt(request.getParameter("bus_id"));
        int routeId = Integer.parseInt(request.getParameter("route_id"));
        String departureTime = request.getParameter("departure_time");
        String arrivalTime = request.getParameter("arrival_time");
        double fare = Double.parseDouble(request.getParameter("fare"));

        PreparedStatement pst = con.prepareStatement(
        	    "INSERT INTO schedules (bus_id, route_id, departure_time, arrival_time, fare) VALUES (?, ?, ?::timestamp, ?::timestamp, ?)"
        	);
        	pst.setInt(1, busId);
        	pst.setInt(2, routeId);
        	pst.setString(3, departureTime); // e.g., "2026-06-01 10:30:00"
        	pst.setString(4, arrivalTime);   // e.g., "2026-06-01 18:30:00"
        	pst.setDouble(5, fare);
        	pst.executeUpdate();
        	pst.close();
    }

    PreparedStatement pst = con.prepareStatement(
        "SELECT s.schedule_id, b.bus_name, r.source, r.destination, s.departure_time, s.arrival_time, s.fare " +
        "FROM schedules s " +
        "JOIN buses b ON s.bus_id = b.bus_id " +
        "JOIN routes r ON s.route_id = r.route_id"
    );
    ResultSet rs = pst.executeQuery();

    PreparedStatement busStmt = con.prepareStatement("SELECT * FROM buses");
    ResultSet busRs = busStmt.executeQuery();

    PreparedStatement routeStmt = con.prepareStatement("SELECT * FROM routes");
    ResultSet routeRs = routeStmt.executeQuery();
%>

<html>
<head>
    <title>Schedule Chronology - WheelsGo Admin</title>
    <style>
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background: #0b0f19; color: #fff; text-align: center; margin: 0; padding: 0; }
        .container { max-width: 950px; margin: 40px auto; background: rgba(20, 25, 40, 0.9); backdrop-filter: blur(16px); padding: 35px; border-radius: 16px; border: 1px solid rgba(255, 255, 255, 0.1); text-align: left; }
        h2, h3 { color: #00ffff; text-align: center; }
        table { width: 100%; border-collapse: collapse; margin-top: 20px; }
        th, td { border: 1px solid #2d3748; padding: 12px; text-align: center; color: #cbd5e0; font-size: 14px; }
        th { background: rgba(0, 123, 255, 0.2); color: #00ffff; }
        .form-container { background: rgba(10, 15, 30, 0.6); padding: 25px; border-radius: 12px; margin-top: 25px; border: 1px solid #2d3748; }
        .form-group { margin-bottom: 20px; }
        label { font-weight: 600; display: block; margin-bottom: 8px; color: #a0aec0; }
        input, select { width: 100%; padding: 12px; background: rgba(10, 15, 30, 0.6); border: 1px solid #2d3748; border-radius: 8px; color: #fff; font-size: 15px; box-sizing: border-box; }
        input:focus, select:focus { border-color: #00ffff; outline: none; box-shadow: 0 0 10px rgba(0,255,255,0.2); }
        .btn { background: linear-gradient(135deg, #007bff 0%, #00ffff 100%); color: #0b0f19; padding: 12px; border: none; cursor: pointer; border-radius: 8px; width: 100%; font-size: 16px; font-weight: bold; transition: 0.3s; }
        .btn:hover { box-shadow: 0 0 15px rgba(0,255,255,0.4); }
        .back-link { display: block; text-align: center; margin-top: 25px; text-decoration: none; color: #00ffff; font-weight: bold; font-size: 14px; }
    </style>
</head>
<body>

    <div class="container">
        <h2>Schedule Chronology Matrix</h2>

        <div class="form-container">
            <h3>Publish New Schedule Event</h3>
            <form method="post">
                <div class="form-group">
                    <label>Assigned Carrier Unit</label>
                    <select name="bus_id" required>
                        <option value="">Select Deployed Carrier</option>
                        <% while (busRs.next()) { %>
                            <option value="<%= busRs.getInt("bus_id") %>"><%= busRs.getString("bus_name") %></option>
                        <% } %>
                    </select>
                </div>

                <div class="form-group">
                    <label>Target Route Vector</label>
                    <select name="route_id" required>
                        <option value="">Select Route Corridor</option>
                        <% while (routeRs.next()) { %>
                            <option value="<%= routeRs.getInt("route_id") %>">
                                <%= routeRs.getString("source") %> to <%= routeRs.getString("destination") %>
                            </option>
                        <% } %>
                    </select>
                </div>

                <div class="form-group">
                    <label>Departure Timestamp</label>
                    <input type="datetime-local" name="departure_time" required>
                </div>

                <div class="form-group">
                    <label>Arrival Timestamp</label>
                    <input type="datetime-local" name="arrival_time" required>
                </div>

                <div class="form-group">
                    <label>Tariff Valuation (Rs.)</label>
                    <input type="number" name="fare" required placeholder="Enter tariff amount">
                </div>

                <input type="submit" value="Publish Schedule Event" class="btn">
            </form>
        </div>

        <h3>Active Timelines</h3>
        <table>
            <tr>
                <th>Schedule ID</th>
                <th>Carrier Name</th>
                <th>Route Corridor</th>
                <th>Departure</th>
                <th>Arrival</th>
                <th>Tariff</th>
            </tr>
            <% while (rs.next()) { %>
                <tr>
                    <td><%= rs.getInt("schedule_id") %></td>
                    <td><%= rs.getString("bus_name") %></td>
                    <td><%= rs.getString("source") %> to <%= rs.getString("destination") %></td>
                    <td><%= rs.getString("departure_time") %></td>
                    <td><%= rs.getString("arrival_time") %></td>
                    <td>Rs. <%= rs.getDouble("fare") %></td>
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