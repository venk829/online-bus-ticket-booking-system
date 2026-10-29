<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page session="true" %>
<%
    session.invalidate(); 
%>
<html>
<head>
    <title>Session Terminated - WheelsGo</title>
    <style>
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background: #0b0f19; color: #fff; text-align: center; margin: 0; padding: 0; }
        .container { max-width: 400px; margin: 100px auto; background: rgba(20, 25, 40, 0.9); padding: 35px; border-radius: 16px; border: 1px solid rgba(255, 255, 255, 0.1); }
        h2 { color: #00ffff; margin-bottom: 15px; }
        .message { font-size: 15px; color: #48bb78; margin-bottom: 25px; }
        .btn { background: linear-gradient(135deg, #007bff 0%, #00ffff 100%); color: #0b0f19; padding: 10px 20px; border-radius: 8px; text-decoration: none; display: inline-block; font-weight: bold; }
    </style>
</head>
<body>
    <div class="container">
        <h2>Session Terminated</h2>
        <p class="message">Your clearance token has been successfully revoked.</p>
        <a href="login.jsp" class="btn">Re-authenticate</a>
    </div>
</body>
</html>