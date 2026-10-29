<%@ include file="DBConnection.jsp" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page session="true" %>
<%@ page import="java.sql.Connection, java.sql.PreparedStatement, java.sql.ResultSet" %>

<%
    Integer userId = (Integer) session.getAttribute("user_id");
    String userName = (String) session.getAttribute("name");
    String userRole = (String) session.getAttribute("role");
    
    // Enforcement rule 1: User must log in to proceed
    if (userId == null) {
        response.sendRedirect("login.jsp");
        return;
    }
%>

<html>
<head>
    <title>WheelsGo - Next-Gen Transit Matrix</title>
    <style>
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background: #0b0f19; color: #fff; margin: 0; padding: 0; }
        .navbar { background: rgba(15, 23, 42, 0.9); backdrop-filter: blur(10px); padding: 15px 40px; display: flex; justify-content: space-between; align-items: center; border-bottom: 1px solid rgba(255,255,255,0.05); }
        .navbar a { color: #cbd5e0; text-decoration: none; padding: 8px 16px; font-weight: 600; font-size: 14px; transition: 0.3s; border-radius: 6px; }
        .navbar a:hover { color: #00ffff; background: rgba(0,255,255,0.05); }
        .hero { background: linear-gradient(rgba(11,15,25,0.7), rgba(11,15,25,0.85)), url('https://st.redbus.in/Images/India/ContextualLogin/generic_banner_Ind.png') center/cover no-repeat; padding: 80px 20px; text-align: center; }
        .hero h1 { font-size: 42px; color: #00ffff; margin-bottom: 10px; text-shadow: 0 0 20px rgba(0,255,255,0.3); }
        .container { max-width: 800px; margin: -40px auto 40px auto; background: rgba(20, 25, 40, 0.9); backdrop-filter: blur(16px); padding: 35px; border-radius: 16px; border: 1px solid rgba(255, 255, 255, 0.1); box-shadow: 0 10px 40px rgba(0,0,0,0.5); text-align: left; position: relative; z-index: 10; }
        .form-group { margin-bottom: 20px; }
        label { font-weight: 600; display: block; margin-bottom: 8px; color: #a0aec0; }
        select, input[type="date"] { width: 100%; padding: 12px; background: rgba(10, 15, 30, 0.6); border: 1px solid #2d3748; border-radius: 8px; color: #fff; font-size: 15px; }
        .btn { background: linear-gradient(135deg, #007bff 0%, #00ffff 100%); color: #0b0f19; padding: 14px; border: none; cursor: pointer; border-radius: 8px; font-size: 16px; font-weight: bold; width: 100%; transition: 0.3s; }
        .btn:hover { box-shadow: 0 0 20px rgba(0,255,255,0.5); }
        footer { text-align: center; padding: 30px; color: #718096; font-size: 13px; border-top: 1px solid rgba(255,255,255,0.05); margin-top: 50px; }
    </style>
</head>
<body>

    <div class="navbar">
        <div style="font-size: 20px; font-weight: bold; color: #00ffff; letter-spacing: 1px;">WHEELS<span style="color:#fff;">GO</span></div>
        <div>
            <span style="margin-right: 20px; color: #a0aec0;">Welcome, <%= userName %></span>
            <a href="view-bookings.jsp">My Tickets</a>
            <% if("ADMIN".equals(userRole)) { %>
                <a href="admin-dashboard.jsp" style="color: #00ffff;">Admin Console</a>
            <% } %>
            <a href="logout.jsp" style="color: #fc8181;">Logout</a>
        </div>
    </div>

    <div class="hero">
        <h1>Autonomous Transit Matrix</h1>
        <p style="color: #a0aec0; font-size: 18px;">Next-generation high-security booking protocol.</p>
    </div>

    <div class="container">
        <h2 style="color: #fff; margin-top: 0; margin-bottom: 25px;">Route Selector</h2>
        <form action="search.jsp" method="GET">
            <div class="form-group">
                <label>Origin Terminal</label>
                <select name="source" required>
                    <option value="">Select Departure Source</option>
                    <% 
                        Connection con = getConnection();
                        PreparedStatement pstSource = con.prepareStatement("SELECT DISTINCT source FROM routes");
                        ResultSet rsSource = pstSource.executeQuery();
                        while (rsSource.next()) { 
                    %>
                        <option value="<%= rsSource.getString("source") %>"><%= rsSource.getString("source") %></option>
                    <% 
                        }
                        rsSource.close();
                        pstSource.close();
                    %>
                </select>
            </div>

            <div class="form-group">
                <label>Destination Terminal</label>
                <select name="destination" required>
                    <option value="">Select Destination Hub</option>
                    <% 
                        PreparedStatement pstDest = con.prepareStatement("SELECT DISTINCT destination FROM routes");
                        ResultSet rsDest = pstDest.executeQuery();
                        while (rsDest.next()) { 
                    %>
                        <option value="<%= rsDest.getString("destination") %>"><%= rsDest.getString("destination") %></option>
                    <% 
                        }
                        rsDest.close();
                        pstDest.close();
                        con.close();
                    %>
                </select>
            </div>

            <div class="form-group">
                <label>Transit Date</label>
                <input type="date" name="journey_date" required>
            </div>

            <button type="submit" class="btn">Initialize Vector Search</button>
        </form>
    </div>

    <footer>WheelsGo Neural Transit Core © 2026 | High-Security Encrypted Protocol</footer>

</body>
</html>