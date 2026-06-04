<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="javax.sql.*" %>
<%@ page import="javax.naming.*" %>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");

String idParam = request.getParameter("id");
int id = 0;
String errorMsg = null;

if (idParam == null || idParam.trim().isEmpty()) {
    errorMsg = "잘못된 접근입니다. (id 파라미터 없음)";
} else {
    try {
        id = Integer.parseInt(idParam);
    } catch (NumberFormatException e) {
        errorMsg = "잘못된 게시글 번호입니다.";
    }
}

boolean deleted = false;

if (errorMsg == null) {
    Connection conn = null;
    PreparedStatement pstmt = null;
    try {
        Context initContext = new InitialContext();
        Context envContext  = (Context) initContext.lookup("java:/comp/env");
        DataSource ds       = (DataSource) envContext.lookup("jdbc/MyDB");
        conn = ds.getConnection();

        String sql = "DELETE FROM posts WHERE id = ?";
        pstmt = conn.prepareStatement(sql);
        pstmt.setInt(1, id);
        int affected = pstmt.executeUpdate();

        if (affected > 0) {
            deleted = true;
        } else {
            errorMsg = "해당 게시글을 찾을 수 없습니다. (id=" + id + ")";
        }
    } catch (Exception e) {
        errorMsg = "삭제 중 오류가 발생했습니다: " + e.getMessage();
        e.printStackTrace();
    } finally {
        if (pstmt != null) try { pstmt.close(); } catch (Exception e) {}
        if (conn  != null) try { conn.close();  } catch (Exception e) {}
    }
}

// 성공 시 목록으로 바로 리다이렉트
if (deleted) {
    response.sendRedirect("list.jsp");
    return;
}
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>삭제 오류 | 3Tier 게시판</title>

    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@300;400;500;700&display=swap" rel="stylesheet">

    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }

        body {
            font-family: 'Noto Sans KR', -apple-system, BlinkMacSystemFont, "Malgun Gothic", sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .container {
            background: rgba(255, 255, 255, 0.95);
            border-radius: 20px;
            padding: 50px 40px;
            box-shadow: 0 20px 40px rgba(0,0,0,0.1);
            text-align: center;
            max-width: 480px;
            width: 90%;
            backdrop-filter: blur(10px);
            animation: fadeInUp 0.8s ease-out;
        }

        @keyframes fadeInUp {
            from { opacity: 0; transform: translateY(30px); }
            to   { opacity: 1; transform: translateY(0); }
        }

        .error-icon { font-size: 64px; margin-bottom: 20px; }

        h1 { color: #333; font-size: 26px; font-weight: 700; margin-bottom: 16px; }

        .error-box {
            background: linear-gradient(45deg, #f8d7da, #f5c6cb);
            color: #721c24;
            border: 1px solid #f5c6cb;
            border-radius: 12px;
            padding: 18px 22px;
            font-size: 15px;
            font-weight: 500;
            margin-bottom: 30px;
            line-height: 1.6;
        }

        .btn-container { display: flex; gap: 12px; justify-content: center; flex-wrap: wrap; }

        .btn {
            display: inline-block;
            padding: 12px 28px;
            font-size: 15px;
            font-weight: 600;
            text-decoration: none;
            border-radius: 50px;
            transition: all 0.3s ease;
            margin: 4px;
        }
        .btn-primary {
            background: linear-gradient(45deg, #667eea, #764ba2);
            color: white;
            box-shadow: 0 4px 15px rgba(102,126,234,0.4);
        }
        .btn-primary:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 25px rgba(102,126,234,0.6);
        }
        .btn-secondary {
            background: linear-gradient(45deg, #6c757d, #495057);
            color: white;
            box-shadow: 0 4px 15px rgba(108,117,125,0.4);
        }
        .btn-secondary:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 25px rgba(108,117,125,0.6);
        }

        .footer {
            margin-top: 30px;
            padding-top: 18px;
            border-top: 1px solid #eee;
            color: #aaa;
            font-size: 12px;
        }
    </style>
</head>
<body>
<div class="container">
    <div class="error-icon">⚠️</div>
    <h1>삭제 실패</h1>

    <div class="error-box">
        <%= errorMsg %>
    </div>

    <div class="btn-container">
        <% if (id > 0) { %>
        <a href="view.jsp?id=<%= id %>" class="btn btn-secondary">← 게시글로 돌아가기</a>
        <% } %>
        <a href="list.jsp" class="btn btn-primary">목록으로</a>
    </div>

    <div class="footer">
        Server: <%= request.getServerName() %>:<%= request.getServerPort() %><br>
        <%= new java.util.Date() %>
    </div>
</div>
</body>
</html>
