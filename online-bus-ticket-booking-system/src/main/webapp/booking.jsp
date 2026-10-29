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

    String scheduleIdParam = request.getParameter("schedule_id");
    if (scheduleIdParam == null) {
        out.println("<p style='color:red; text-align:center;'>Error: No schedule selected.</p>");
        return;
    }

    int scheduleId = Integer.parseInt(scheduleIdParam);
    Connection con = getConnection();

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
    String source = rs.getString("source");
    String destination = rs.getString("destination");
    String departure = rs.getString("departure_time");
    String arrival = rs.getString("arrival_time");
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
    con.close();
%>

<html>
<head>
    <title>Seat Visualization Matrix - <%= busName %></title>
    <style>
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background: #0b0f19; color: #fff; text-align: center; margin: 0; padding: 0; }
        .container { max-width: 650px; margin: 40px auto; background: rgba(20, 25, 40, 0.9); backdrop-filter: blur(16px); padding: 30px; border-radius: 16px; border: 1px solid rgba(255, 255, 255, 0.1); box-shadow: 0 10px 40px rgba(0,0,0,0.5); }
        h2 { color: #00ffff; }
        
        /* Realistic Bus Cabin Simulator Container */
        .bus-cabin { background: rgba(10, 15, 30, 0.7); border: 2px solid #2d3748; border-radius: 15px; padding: 25px; margin: 20px 0; position: relative; }
        .driver-cabin { text-align: right; border-bottom: 1px dashed #4a5568; padding-bottom: 10px; margin-bottom: 15px; font-size: 12px; color: #a0aec0; letter-spacing: 1px; }
        
        .seat-grid { display: grid; grid-template-columns: repeat(4, 55px); gap: 12px; justify-content: center; }
        .seat { height: 50px; background: #2f855a; color: white; border-radius: 8px; cursor: pointer; font-weight: bold; border: 1px solid #38a169; display: flex; align-items: center; justify-content: center; font-size: 14px; transition: 0.2s; }
        .seat.booked { background: #9b2c2c; border-color: #e53e3e; cursor: not-allowed; opacity: 0.7; }
        .seat.selected { background: #d69e2e; border-color: #ecc94b; color: #0b0f19; box-shadow: 0 0 12px rgba(236,201,75,0.5); }
        
        .legend { display: flex; justify-content: center; gap: 25px; margin: 20px 0; font-size: 13px; color: #cbd5e0; }
        .legend-box { width: 14px; height: 14px; display: inline-block; border-radius: 4px; vertical-align: middle; margin-right: 6px; }
        
        .btn { background: linear-gradient(135deg, #007bff 0%, #00ffff 100%); color: #0b0f19; padding: 12px; border: none; border-radius: 8px; font-size: 16px; font-weight: bold; cursor: pointer; width: 100%; margin-top: 15px; transition: 0.3s; }
        .btn:hover { box-shadow: 0 0 15px rgba(0,255,255,0.4); }
    </style>
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
            document.getElementById('total_fare_display').innerText = values.length * <%= fare %>;
            document.getElementById('amount_input').value = values.length * <%= fare %>;
        }
    </script>
</head>
<body>
    <div class="container">
        <h2>Live Seat Matrix</h2>
        <p style="color: #a0aec0;"><strong><%= busName %></strong> | <strong><%= source %></strong> to <strong><%= destination %></strong></p>
        <p style="color: #00ffff; font-size: 14px;">Unit Tariff: Rs. <%= fare %> per seat</p>

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
    </div>
</body>
</html>