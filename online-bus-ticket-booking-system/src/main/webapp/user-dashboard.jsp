<%@ page session="true" %>
<%
    Integer userId = (Integer) session.getAttribute("user_id");
    String userName = (String) session.getAttribute("name");
    String role = (String) session.getAttribute("role");

    if (userId == null || !"USER".equals(role)) {
        response.sendRedirect("login.jsp");
        return;
    }
%>
<html>
<head>
    <title>User Dashboard - Bus Booking System</title>
    <style>
        body { font-family: 'Poppins', sans-serif; background: #f4f4f4; text-align: center; margin: 0; padding: 0; }
        .container { max-width: 600px; margin: 50px auto; background: white; padding: 30px; border-radius: 10px; box-shadow: 0px 0px 10px rgba(0,0,0,0.1); }
        h2 { color: #007bff; }
        .menu { margin-top: 20px; display: flex; justify-content: space-around; }
        .btn { background: #007bff; color: white; padding: 10px 20px; border-radius: 5px; text-decoration: none; font-weight: bold; }
        .btn:hover { background: #0056b3; }
        .logout { background: #dc3545; }
        .logout:hover { background: #c82333; }
    </style>
</head>
<body>
    <div class="container">
        <h2>Welcome, <%= userName %>!</h2>
        <p>Manage your bus bookings and travel plans efficiently.</p>
        
        <div class="menu">
            <a href="index.jsp" class="btn">Book Bus</a>
            <a href="view-bookings.jsp" class="btn">My Bookings</a>
            <a href="logout.jsp" class="btn logout">Logout</a>
        </div>
    </div>
</body>
</html>