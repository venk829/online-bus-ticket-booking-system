<%@ include file="DBConnection.jsp" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page session="true" %>
<%@ page import="java.sql.Connection, java.sql.PreparedStatement, java.sql.ResultSet" %>

<%
    Integer userId = (Integer) session.getAttribute("user_id");
    String userRole = (String) session.getAttribute("role");

    if (userId == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    Connection con = getConnection();
    PreparedStatement pst;

    // If admin, show all bookings; if regular user, show only their specific bookings
    if ("ADMIN".equals(userRole)) {
        pst = con.prepareStatement(
            "SELECT b.booking_id, u.name AS user_name, bus.bus_name, r.source, r.destination, " +
            "s.departure_time, b.seat_number, s.fare AS amount, b.status FROM bookings b " +
            "JOIN users u ON b.user_id = u.user_id " +
            "JOIN schedules s ON b.schedule_id = s.schedule_id " +
            "JOIN buses bus ON s.bus_id = bus.bus_id " +
            "JOIN routes r ON s.route_id = r.route_id " +
            "ORDER BY b.booking_id DESC"
        );
    } else {
        pst = con.prepareStatement(
            "SELECT b.booking_id, bus.bus_name, r.source, r.destination, " +
            "s.departure_time, b.seat_number, s.fare AS amount, b.status FROM bookings b " +
            "JOIN schedules s ON b.schedule_id = s.schedule_id " +
            "JOIN buses bus ON s.bus_id = bus.bus_id " +
            "JOIN routes r ON s.route_id = r.route_id " +
            "WHERE b.user_id = ? ORDER BY b.booking_id DESC"
        );
        pst.setInt(1, userId);
    }

    ResultSet rs = pst.executeQuery();
%>

<html>
<head>
    <title>View Bookings - WheelsGo</title>
    <style>
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background: #0b0f19; color: #fff; margin: 0; padding: 0; text-align: center; }
        .container { max-width: 950px; margin: 40px auto; background: rgba(20, 25, 40, 0.9); backdrop-filter: blur(16px); padding: 35px; border-radius: 16px; border: 1px solid rgba(255, 255, 255, 0.1); box-shadow: 0 10px 40px rgba(0,0,0,0.5); text-align: left; }
        h2 { color: #00ffff; text-align: center; margin-bottom: 25px; }
        table { width: 100%; border-collapse: collapse; margin-top: 20px; }
        th, td { border: 1px solid #2d3748; padding: 12px; text-align: center; font-size: 14px; color: #cbd5e0; }
        th { background: rgba(0, 123, 255, 0.2); color: #00ffff; }
        .back-link { display: inline-block; margin-top: 25px; text-decoration: none; color: #00ffff; font-weight: bold; font-size: 14px; }
        .back-link:hover { text-decoration: underline; }
    </style>
</head>
<body>

    <div class="container">
        <h2>Booking Manifest & History</h2>
        <table>
            <tr>
                <th>Booking ID</th>
                <% if ("ADMIN".equals(userRole)) { %>
                    <th>Passenger Name</th>
                <% } %>
                <th>Carrier Unit</th>
                <th>Route Vector</th>
                <th>Departure</th>
                <th>Seat Index</th>
                <th>Fare (Rs.)</th>
                <th>Status</th>
            </tr>
            <% while (rs.next()) { %>
                <tr>
                    <td><%= rs.getInt("booking_id") %></td>
                    <% if ("ADMIN".equals(userRole)) { %>
                        <td><%= rs.getString("user_name") %></td>
                    <% } %>
                    <td><%= rs.getString("bus_name") %></td>
                    <td><%= rs.getString("source") %> to <%= rs.getString("destination") %></td>
                    <td><%= rs.getString("departure_time") %></td>
                    <td><%= rs.getInt("seat_number") %></td>
                    <td><%= rs.getDouble("amount") %></td>
                    <td style="color: <%= "BOOKED".equals(rs.getString("status")) ? "#48bb78" : "#fc8181" %>;"><%= rs.getString("status") %></td>
                </tr>
            <% } %>
        </table>

        <div style="text-align: center;">
            <a href="<%= "ADMIN".equals(userRole) ? "admin-dashboard.jsp" : "user-dashboard.jsp" %>" class="back-link">← Return to Dashboard</a>
        </div>
    </div>

</body>
</html>

<%
    rs.close();
    pst.close();
    con.close();
%>