<%@ include file="DBConnection.jsp" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page session="true" %>
<%@ page import="java.sql.Connection, java.sql.PreparedStatement, java.sql.ResultSet, java.util.HashSet" %>

<%
    Integer userId = (Integer) session.getAttribute("user_id");
    if (userId == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    Connection con = getConnection();
    String scheduleIdParam = request.getParameter("schedule_id");
    String source = request.getParameter("source");
    String destination = request.getParameter("destination");
    String journeyDate = request.getParameter("journey_date");
%>

<html>
<head>
    <title>Transit Search & Seat Matrix - WheelsGo</title>
    <style>
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background: #0b0f19; color: #fff; text-align: center; margin: 0; padding: 0; }
        .container { max-width: 750px; margin: 40px auto; background: rgba(20, 25, 40, 0.9); backdrop-filter: blur(16px); padding: 30px; border-radius: 16px; border: 1px solid rgba(255, 255, 255, 0.1); box-shadow: 0 10px 40px rgba(0,0,0,0.5); text-align: left; }
        h2 { color: #00ffff; text-align: center; }
        table { width: 100%; border-collapse: collapse; margin-top: 20px; }
        th, td { border: 1px solid #2d3748; padding: 12px; text-align: center; font-size: 14px; color: #cbd5e0; }
        th { background: rgba(0, 123, 255, 0.2); color: #00ffff; }
        .btn-select { background: #007bff; color: white; padding: 6px 12px; border-radius: 4px; text-decoration: none; font-weight: bold; }
        .btn-select:hover { background: #0056b3; }
        
        /* Bus Cabin Simulator Styles */
        .bus-cabin { background: rgba(10, 15, 30, 0.7); border: 2px solid #2d3748; border-radius: 15px; padding: 25px; margin: 20px 0; position: relative; text-align: center; }
        .driver-cabin { text-align: right; border-bottom: 1px dashed #4a5568; padding-bottom: 10px; margin-bottom: 15px; font-size: 12px; color: #a0aec0; letter-spacing: 1px; }
        .seat-grid { display: grid; grid-template-columns: repeat(4, 55px); gap: 12px; justify-content: center; }
        .seat { height: 50px; background: #2f855a; color: white; border-radius: 8px; cursor: pointer; font-weight: bold; border: 1px solid #38a169; display: flex; align-items: center; justify-content: center; font-size: 14px; transition: 0.2s; }
        .seat.booked { background: #9b2c2c; border-color: #e53e3e; cursor: not-allowed; opacity: 0.7; }
        .seat.selected { background: #d69e2e; border-color: #ecc94b; color: #0b0f19; box-shadow: 0 0 12px rgba(236,201,75,0.5); }
        .legend { display: flex; justify-content: center; gap: 25px; margin: 20px 0; font-size: 13px; color: #cbd5e0; }
        .legend-box { width: 14px; height: 14px; display: inline-block; border-radius: 4px; vertical-align: middle; margin-right: 6px; }
        .btn { background: linear-gradient(135deg, #007bff 0%, #00ffff 100%); color: #0b0f19; padding: 12px; border: none; border-radius: 8px; font-size: 16px; font-weight: bold; cursor: pointer; width: 100%; margin-top: 15px; transition: 0.3s; }
        .btn:hover { box-shadow: 0 0 15px rgba(0,255,255,0.4); }
        .back-link { display: block; text-align: center; margin-top: 20px; color: #00ffff; text-decoration: none; font-weight: bold; }
    </style>
    <% if (scheduleIdParam != null) { %>
    <script>
        function toggleSeat(button, seatNum) {
            if (button.classList.contains('booked')) return;
            button.classList.toggle('selected');
            
            let selectedInput = document.getElementById('selected_seats');
            let checkboxes = document.querySelectorAll('.seat.selected');
            let values = [];
            checkboxes.forEach(function(el) {
                values.push(el.getAttribute('data-seat'));
            });
            selectedInput.value = values.join(',');
            document.getElementById('seat_count_display').innerText = values.length;
            document.getElementById('total_fare_display').innerText = values.length * window.fareAmount;
            document.getElementById('amount_input').value = values.length * window.fareAmount;
        }
    </script>
    <% } %>
</head>
<body>
    <div class="container">
    <% if (scheduleIdParam == null) { 
        // --- VIEW 1: DISPLAY AVAILABLE SCHEDULES FOR ROUTE ---
        if (source == null || destination == null) {
            out.println("<p style='color:red; text-align:center;'>Error: Origin or Destination not specified.</p>");
            return;
        }

        PreparedStatement pstSchedules = con.prepareStatement(
            "SELECT s.schedule_id, b.bus_name, s.departure_time, s.arrival_time, s.fare, b.total_seats " +
            "FROM schedules s " +
            "JOIN buses b ON s.bus_id = b.bus_id " +
            "JOIN routes r ON s.route_id = r.route_id " +
            "WHERE r.source = ? AND r.destination = ?"
        );
        pstSchedules.setString(1, source);
        pstSchedules.setString(2, destination);
        ResultSet rsSchedules = pstSchedules.executeQuery();
    %>
        <h2>Available Transit Units</h2>
        <p style="color: #a0aec0; text-align:center;">Route: <strong><%= source %></strong> to <strong><%= destination %></strong> | Date: <strong><%= journeyDate != null ? journeyDate : "Any" %></strong></p>
        
        <table>
            <tr>
                <th>Carrier Unit</th>
                <th>Departure</th>
                <th>Arrival</th>
                <th>Tariff (Rs.)</th>
                <th>Action</th>
            </tr>
            <% 
                boolean hasResults = false;
                while (rsSchedules.next()) { 
                    hasResults = true;
            %>
                <tr>
                    <td><%= rsSchedules.getString("bus_name") %></td>
                    <td><%= rsSchedules.getString("departure_time") %></td>
                    <td><%= rsSchedules.getString("arrival_time") %></td>
                    <td>Rs. <%= rsSchedules.getDouble("fare") %></td>
                    <td><a href="search.jsp?schedule_id=<%= rsSchedules.getInt("schedule_id") %>" class="btn-select">Select Seats</a></td>
                </tr>
            <% 
                } 
                if (!hasResults) {
            %>
                <tr><td colspan="5" style="color: #fc8181;">No carrier units available for this route vector.</td></tr>
            <% } %>
        </table>
        <a href="index.jsp" class="back-link">← Return to Route Selector</a>

    <% 
        rsSchedules.close();
        pstSchedules.close();
    } else { 
        // --- VIEW 2: DISPLAY SEAT MATRIX FOR SELECTED SCHEDULE ---
        int scheduleId = Integer.parseInt(scheduleIdParam);
        PreparedStatement pst = con.prepareStatement(
            "SELECT b.bus_name, r.source, r.destination, s.departure_time, s.arrival_time, s.fare, b.total_seats " +
            "FROM schedules s " +
            "JOIN buses b ON s.bus_id = b.bus_id " +
            "JOIN routes r ON s.route_id = r.route_id " +
            "WHERE s.schedule_id = ?"
        );
        pst.setInt(1, scheduleId);
        ResultSet rs = pst.executeQuery();

        if (!rs.next()) {
            out.println("<p style='color:red; text-align:center;'>Error: Schedule not found.</p>");
            return;
        }

        String busName = rs.getString("bus_name");
        String src = rs.getString("source");
        String dest = rs.getString("destination");
        double fare = rs.getDouble("fare");
        int totalSeats = rs.getInt("total_seats");
        rs.close();
        pst.close();

        HashSet<Integer> bookedSeats = new HashSet<>();
        PreparedStatement pstBooked = con.prepareStatement("SELECT seat_number FROM bookings WHERE schedule_id = ? AND status = 'BOOKED'");
        pstBooked.setInt(1, scheduleId);
        ResultSet rsBooked = pstBooked.executeQuery();
        while(rsBooked.next()) {
            bookedSeats.add(rsBooked.getInt("seat_number"));
        }
        rsBooked.close();
        pstBooked.close();
    %>
        <script>window.fareAmount = <%= fare %>;</script>
        <h2>Live Seat Matrix</h2>
        <p style="color: #a0aec0; text-align:center;"><strong><%= busName %></strong> | <strong><%= src %></strong> to <strong><%= dest %></strong></p>
        <p style="color: #00ffff; font-size: 14px; text-align:center;">Unit Tariff: Rs. <%= fare %> per seat</p>

        <div class="legend">
            <span><span class="legend-box" style="background:#2f855a;"></span> Open</span>
            <span><span class="legend-box" style="background:#d69e2e;"></span> Reserved</span>
            <span><span class="legend-box" style="background:#9b2c2c;"></span> Occupied</span>
        </div>

        <div class="bus-cabin">
            <div class="driver-cabin">FRONT DECK / PILOT CABIN</div>
            <div class="seat-grid">
                <% for(int i=1; i<=totalSeats; i++) { 
                    boolean isBooked = bookedSeats.contains(i);
                %>
                    <button type="button" class="seat <%= isBooked ? "booked" : "" %>" data-seat="<%= i %>" onclick="toggleSeat(this, <%= i %>)"><%= i %></button>
                <% } %>
            </div>
        </div>

        <form action="confirm-booking.jsp" method="POST">
            <input type="hidden" name="schedule_id" value="<%= scheduleId %>">
            <input type="hidden" name="seat_numbers" id="selected_seats" required>
            <input type="hidden" name="amount" id="amount_input" value="0">

            <p style="font-size: 14px; color: #a0aec0;">Selected Matrix Count: <span id="seat_count_display" style="color:#fff; font-weight:bold;">0</span></p>
            <p style="font-size: 16px;">Total Settlement Sum: Rs. <span id="total_fare_display" style="color:#00ffff; font-weight:bold;">0</span></p>

            <button type="submit" class="btn">Lock Allocation & Proceed</button>
        </form>
        <a href="index.jsp" class="back-link">← Cancel & Return</a>
    <% } 
        con.close();
    %>
    </div>
</body>
</html>