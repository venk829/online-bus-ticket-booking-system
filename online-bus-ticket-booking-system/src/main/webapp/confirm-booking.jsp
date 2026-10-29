<%@ include file="DBConnection.jsp" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page session="true" %>
<%@ page import="java.sql.Connection, java.sql.PreparedStatement, java.sql.ResultSet, java.util.UUID" %>

<%
    Integer userId = (Integer) session.getAttribute("user_id");
    if (userId == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    String scheduleIdParam = request.getParameter("schedule_id");
    String seatsParam = request.getParameter("seat_numbers");
    String amountParam = request.getParameter("amount");

    if (scheduleIdParam == null || seatsParam == null || seatsParam.isEmpty() || amountParam == null) {
        out.println("<p style='color:red; text-align:center;'>Error: No seats targeted. <a href='javascript:history.back()'>Go Back</a></p>");
        return;
    }

    int scheduleId = Integer.parseInt(scheduleIdParam);
    double totalAmount = Double.parseDouble(amountParam);
    String[] seatArray = seatsParam.split(",");
    int seatCount = seatArray.length;

    String pnr = "PNR-" + UUID.randomUUID().toString().substring(0, 6).toUpperCase();

    Connection con = getConnection();
    boolean conflict = false;

    for (String seatStr : seatArray) {
        int seatNum = Integer.parseInt(seatStr.trim());
        PreparedStatement chk = con.prepareStatement("SELECT 1 FROM bookings WHERE schedule_id = ? AND seat_number = ? AND status = 'BOOKED'");
        chk.setInt(1, scheduleId);
        chk.setInt(2, seatNum);
        ResultSet rs = chk.executeQuery();
        if (rs.next()) {
            conflict = true;
        }
        rs.close();
        chk.close();
    }

    if (conflict) {
        con.close();
        out.println("<h3 style='color:#fc8181; text-align:center;'>Collision Error: One or more selected slots were instantly claimed by another terminal user. <a href='javascript:history.back()'>Re-try Selection</a></h3>");
        return;
    }

    for (String seatStr : seatArray) {
        int seatNum = Integer.parseInt(seatStr.trim());
        PreparedStatement ins = con.prepareStatement(
            "INSERT INTO bookings (user_id, schedule_id, seat_number, status, pnr) VALUES (?, ?, ?, 'BOOKED', ?)"
        );
        ins.setInt(1, userId);
        ins.setInt(2, scheduleId);
        ins.setInt(3, seatNum);
        ins.setString(4, pnr);
        ins.executeUpdate();
        ins.close();
    }
    con.close();

    response.sendRedirect("confirm-payment.jsp?schedule_id=" + scheduleId + "&seat_count=" + seatCount + "&amount=" + totalAmount + "&pnr=" + pnr);
%>