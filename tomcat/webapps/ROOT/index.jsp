<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Tomcat - EduTech Solutions</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
            margin: 0;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
        }
        .container {
            text-align: center;
            background: rgba(255, 255, 255, 0.1);
            padding: 40px;
            border-radius: 15px;
            box-shadow: 0 8px 32px 0 rgba(31, 38, 135, 0.37);
            backdrop-filter: blur(4px);
            border: 1px solid rgba(255, 255, 255, 0.18);
        }
        h1 {
            margin: 0 0 20px 0;
            font-size: 3em;
        }
        .info {
            margin-top: 30px;
            padding: 20px;
            background: rgba(0, 0, 0, 0.2);
            border-radius: 10px;
        }
        .info p {
            margin: 10px 0;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>Apache Tomcat</h1>
        <p style="font-size: 1.5em;">EduTech Solutions</p>
        
        <div class="info">
            <p><strong>Servidor:</strong> <%= request.getServerName() %></p>
            <p><strong>Puerto:</strong> <%= request.getServerPort() %></p>
            <p><strong>Tomcat Version:</strong> <%= application.getServerInfo() %></p>
            <p><strong>Fecha y Hora:</strong> <%= new java.util.Date() %></p>
        </div>
    </div>
</body>
</html>
