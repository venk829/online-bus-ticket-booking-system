<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.Connection, java.sql.PreparedStatement, java.sql.ResultSet" %>
<%@ include file="DBConnection.jsp" %>
<%@ page session="true" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Encrypted Checkout - WheelsGo</title>
    <style>
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; text-align: center; background-color: #0b0f19; color: #fff; margin: 0; padding: 0; }
        .container { max-width: 600px; margin: 40px auto; padding: 30px; background: rgba(20, 25, 40, 0.9); backdrop-filter: blur(16px); border-radius: 16px; border: 1px solid rgba(255, 255, 255, 0.1); box-shadow: 0 10px 40px rgba(0,0,0,0.5); text-align: left; }
        h1 { color: #48bb78; text-align: center; }
        .ticket { border: 2px dashed #00ffff; padding: 25px; border-radius: 12px; margin-top: 20px; background: rgba(10, 15, 30, 0.6); }
        .btn { display: inline-block; padding: 12px 24px; font-size: 16px; text-decoration: none; background: linear-gradient(135deg, #007bff 0%, #00ffff 100%); color: #0b0f19; font-weight: bold; border-radius: 8px; border: none; cursor: pointer; text-align: center; margin-top: 15px; width: 100%; transition: 0.3s; }
        .btn:hover { box-shadow: 0 0 15px rgba(0,255,255,0.4); }
        select { width: 100%; padding: 12px; margin-bottom: 20px; border-radius: 8px; border: 1px solid #2d3748; background: rgba(10, 15, 30, 0.6); color: #fff; font-size: 15px; }
        @media print {
            body { background: white; color: black; }
            .no-print { display: none; }
            .container { box-shadow: none; margin: 0; width: 100%; background: white; border: none; color: black; }
            .ticket { border: 2px dashed #333; background: #fff; color: black; }
        }
    </style>
</head>
<body>

<div class="container">
    <%
        String scheduleIdParam = request.getParameter("schedule_id");
        String seatCountParam = request.getParameter("seat_count");
        String amountParam = request.getParameter("amount");
        String pnr = request.getParameter("pnr");
        String paymentMethod = request.getParameter("payment_method");

        int userId = (Integer) session.getAttribute("user_id");

        if (paymentMethod != null && pnr != null) {
            Connection con = getConnection();
            PreparedStatement pstPay = con.prepareStatement(
                "INSERT INTO payments (user_id, schedule_id, seat_count, amount, payment_method, payment_status) VALUES (?, ?, ?, ?, ?, 'Completed')"
            );
            pstPay.setInt(1, userId);
            pstPay.setInt(2, Integer.parseInt(scheduleIdParam));
            pstPay.setInt(3, Integer.parseInt(seatCountParam));
            pstPay.setDouble(4, Double.parseDouble(amountParam));
            pstPay.setString(5, paymentMethod);
            pstPay.executeUpdate();
            pstPay.close();
            con.close();
    %>
            <h1>Transaction Verified!</h1>
            <p style="text-align:center; color:#a0aec0;">Funds escrowed and matrix allocations committed.</p>

            <div class="ticket">
                <h3 style="text-align:center; color:#00ffff; margin-top:0; letter-spacing: 1px;">WHEELSGO DIGITAL MANIFEST</h3>
                <p><strong>PNR Identification:</strong> <%= pnr %></p>
                <p><strong>Passenger Name:</strong> <%= session.getAttribute("name") %></p>
                <p><strong>Allocated Quantity:</strong> <%= seatCountParam %> Seats</p>
                <p><strong>Total Settlement:</strong> Rs. <%= amountParam %></p>
                <p><strong>Gateway Protocol:</strong> <%= paymentMethod %></p>
            </div>

            <div style="text-align:center;" class="no-print">
                <button onclick="window.print();" class="btn">Print / Export Digital Pass</button>
                <br><br>
                <a href="index.jsp" style="color: #00ffff; text-decoration: none; font-size: 14px; font-weight: bold;">← Return to Main Radar</a>
            </div>
    <%
            return;
        }
    %>

    <h2 style="text-align:center; color: #00ffff;">Secure Payment Gateway</h2>
    <form method="POST">
        <input type="hidden" name="schedule_id" value="<%= scheduleIdParam %>">
        <input type="hidden" name="seat_count" value="<%= seatCountParam %>">
        <input type="hidden" name="amount" value="<%= amountParam %>">
        <input type="hidden" name="pnr" value="<%= pnr %>">

        <p style="color: #a0aec0;"><strong>Target PNR:</strong> <%= pnr %></p>
        <p style="color: #a0aec0; margin-bottom: 25px;"><strong>Payable Balance:</strong> Rs. <%= amountParam %></p>
        
        <label>Select Financial Channel</label>
        <select name="payment_method" required>
            <option value="Credit Card">Credit / Debit Matrix Card</option>
            <option value="UPI">Instant Unified Payment Interface (UPI)</option>
            <option value="Net Banking">Encrypted Net Banking Core</option>
        </select>

        <button type="submit" class="btn">Execute Secure Payment</button>
    </form>
</div>

</body>
</html>