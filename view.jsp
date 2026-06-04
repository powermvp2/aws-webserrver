<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="javax.sql.*" %>
<%@ page import="javax.naming.*" %>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");

String idParam = request.getParameter("id");
String updated = request.getParameter("updated");

if(idParam == null || idParam.trim().isEmpty()) {
    response.sendRedirect("list.jsp");
    return;
}

int postId = 0;
try {
    postId = Integer.parseInt(idParam);
} catch(NumberFormatException e) {
    response.sendRedirect("list.jsp");
    return;
}

String title = "";
String content = "";
String author = "";
String createdAt = "";
String updatedAt = "";
boolean postFound = false;

Connection conn = null;
PreparedStatement pstmt = null;
ResultSet rs = null;

try {
    Context initContext = new InitialContext();
    Context envContext = (Context)initContext.lookup("java:/comp/env");
    DataSource ds = (DataSource)envContext.lookup("jdbc/MyDB");
    conn = ds.getConnection();
    
    String sql = "SELECT * FROM posts WHERE id = ?";
    pstmt = conn.prepareStatement(sql);
    pstmt.setInt(1, postId);
    rs = pstmt.executeQuery();
    
    if(rs.next()) {
        title = rs.getString("title");
        content = rs.getString("content");
        author = rs.getString("author");
        createdAt = new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm").format(rs.getTimestamp("created_at"));
        
        Timestamp updatedTimestamp = rs.getTimestamp("updated_at");
        if(updatedTimestamp != null && !rs.getTimestamp("created_at").equals(updatedTimestamp)) {
            updatedAt = new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm").format(updatedTimestamp);
        }
        postFound = true;
    }
} catch(Exception e) {
    e.printStackTrace();
} finally {
    if(rs != null) try { rs.close(); } catch(Exception e) {}
    if(pstmt != null) try { pstmt.close(); } catch(Exception e) {}
    if(conn != null) try { conn.close(); } catch(Exception e) {}
}

if (!postFound) {
    response.sendRedirect("list.jsp");
    return;
}
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>3Tier 게시판 - 게시글 보기</title>
    
    <!-- 한글 웹 폰트 추가 -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@300;400;500;700&display=swap" rel="stylesheet">
    
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Noto Sans KR', -apple-system, BlinkMacSystemFont, "Malgun Gothic", "맑은 고딕", sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            padding: 20px;
        }

        .container {
            max-width: 900px;
            margin: 0 auto;
        }

        .header {
            background: rgba(255, 255, 255, 0.95);
            border-radius: 20px;
            padding: 40px;
            margin-bottom: 30px;
            text-align: center;
            backdrop-filter: blur(15px);
            box-shadow: 0 20px 40px rgba(0, 0, 0, 0.1);
        }

        .logo {
            font-size: 32px;
            font-weight: 700;
            color: #667eea;
            margin-bottom: 15px;
        }

        h1 {
            color: #333;
            font-size: 32px;
            font-weight: 700;
            margin-bottom: 20px;
        }

        .system-info {
            background: linear-gradient(135deg, #f8f9fa 0%, #e9ecef 100%);
            padding: 20px;
            border-radius: 15px;
            margin-top: 20px;
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 15px;
            font-size: 14px;
        }

        .info-item {
            display: flex;
            align-items: center;
            gap: 8px;
            color: #495057;
        }

        .info-label {
            font-weight: 600;
            color: #667eea;
        }

        .nav-buttons {
            display: flex;
            justify-content: center;
            gap: 15px;
            margin-bottom: 30px;
            flex-wrap: wrap;
        }

        .btn {
            background: linear-gradient(45deg, #667eea, #764ba2);
            color: white;
            padding: 15px 30px;
            text-decoration: none;
            border-radius: 25px;
            font-weight: 600;
            font-size: 16px;
            transition: all 0.3s ease;
            box-shadow: 0 8px 25px rgba(102, 126, 234, 0.3);
            border: none;
            cursor: pointer;
            display: inline-flex;
            align-items: center;
            justify-content: center;
        }

        .btn:hover {
            transform: translateY(-3px);
            box-shadow: 0 15px 35px rgba(102, 126, 234, 0.4);
        }

        .btn-primary {
            background: linear-gradient(45deg, #28a745, #20c997);
            box-shadow: 0 8px 25px rgba(40, 167, 69, 0.3);
        }

        .btn-primary:hover {
            box-shadow: 0 15px 35px rgba(40, 167, 69, 0.4);
        }

        .btn-secondary {
            background: linear-gradient(45deg, #6c757d, #495057);
            box-shadow: 0 8px 25px rgba(108, 117, 125, 0.3);
        }

        .btn-secondary:hover {
            box-shadow: 0 15px 35px rgba(108, 117, 125, 0.4);
        }

        .btn-warning {
            background: linear-gradient(45deg, #ffc107, #ffb300);
            color: #212529;
            box-shadow: 0 8px 25px rgba(255, 193, 7, 0.3);
        }

        .btn-warning:hover {
            box-shadow: 0 15px 35px rgba(255, 193, 7, 0.4);
        }

        .btn-danger {
            background: linear-gradient(45deg, #dc3545, #c82333);
            box-shadow: 0 8px 25px rgba(220, 53, 69, 0.3);
        }

        .btn-danger:hover {
            box-shadow: 0 15px 35px rgba(220, 53, 69, 0.4);
        }

        .content-area {
            background: rgba(255, 255, 255, 0.95);
            border-radius: 20px;
            backdrop-filter: blur(15px);
            box-shadow: 0 20px 40px rgba(0, 0, 0, 0.1);
            overflow: hidden;
            margin-bottom: 30px;
        }

        .content-header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 40px;
            position: relative;
        }

        .post-id-badge {
            position: absolute;
            top: 20px;
            right: 20px;
            background: rgba(255, 255, 255, 0.2);
            padding: 8px 16px;
            border-radius: 20px;
            font-size: 14px;
            font-weight: 600;
            backdrop-filter: blur(10px);
        }

        .post-title {
            font-size: 36px;
            font-weight: 700;
            margin-bottom: 20px;
            line-height: 1.3;
            padding-right: 100px;
        }

        .post-meta {
            display: flex;
            flex-wrap: wrap;
            gap: 20px;
            font-size: 16px;
            opacity: 0.9;
        }

        .meta-item {
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .meta-icon {
            font-size: 14px;
            font-weight: 600;
        }

        .author-badge {
            background: rgba(255, 255, 255, 0.2);
            padding: 6px 15px;
            border-radius: 20px;
            backdrop-filter: blur(10px);
        }

        .post-content {
            padding: 50px;
            font-size: 18px;
            line-height: 1.8;
            color: #333;
            min-height: 300px;
        }

        .post-content p {
            margin-bottom: 20px;
        }

        .action-buttons {
            padding: 30px 50px;
            border-top: 1px solid #e9ecef;
            display: flex;
            justify-content: center;
            gap: 15px;
            flex-wrap: wrap;
        }

        .status {
            padding: 15px 30px;
            margin: 25px 50px;
            border-radius: 15px;
            font-weight: 600;
            text-align: center;
            font-size: 16px;
        }

        .success {
            background: linear-gradient(45deg, #d4edda, #c3e6cb);
            color: #155724;
            border: 1px solid #c3e6cb;
        }

        .error {
            background: linear-gradient(45deg, #f8d7da, #f5c6cb);
            color: #721c24;
            border: 1px solid #f5c6cb;
        }

        .footer {
            text-align: center;
            margin-top: 40px;
            padding: 25px;
            background: rgba(255, 255, 255, 0.1);
            border-radius: 15px;
            color: white;
            backdrop-filter: blur(10px);
        }

        /* 애니메이션 효과 */
        @keyframes fadeInUp {
            from {
                opacity: 0;
                transform: translateY(30px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        .content-area {
            animation: fadeInUp 0.6s ease-out;
        }

        @keyframes slideInRight {
            from {
                opacity: 0;
                transform: translateX(20px);
            }
            to {
                opacity: 1;
                transform: translateX(0);
            }
        }

        .status {
            animation: slideInRight 0.5s ease-out;
        }

        @media (max-width: 768px) {
            body {
                padding: 10px;
            }

            .header {
                padding: 25px 20px;
            }

            .system-info {
                grid-template-columns: 1fr;
                text-align: left;
            }

            .nav-buttons {
                flex-direction: column;
                align-items: center;
            }

            .btn {
                width: 100%;
                max-width: 300px;
            }

            .content-header {
                padding: 30px 25px;
            }

            .post-id-badge {
                position: static;
                margin-bottom: 15px;
                display: inline-block;
            }

            .post-title {
                font-size: 28px;
                padding-right: 0;
            }

            .post-meta {
                flex-direction: column;
                gap: 10px;
            }

            .post-content {
                padding: 30px 25px;
                font-size: 16px;
            }

            .action-buttons {
                padding: 20px 25px;
                flex-direction: column;
                align-items: center;
            }

            .status {
                margin: 20px 25px;
            }
        }

        /* 콘텐츠 스타일링 */
        .post-content {
            white-space: pre-wrap;
            word-wrap: break-word;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <div class="logo">3TIER BOARD</div>
            <h1>게시글 보기</h1>
            <div class="system-info">
                <div class="info-item">
                    <span class="info-label">Web:</span>
                    <span>Nginx Reverse Proxy</span>
                </div>
                <div class="info-item">
                    <span class="info-label">WAS:</span>
                    <span>Apache Tomcat 9.0</span>
                </div>
                <div class="info-item">
                    <span class="info-label">DB:</span>
                    <span>AWS RDS MySQL</span>
                </div>
                <div class="info-item">
                    <span class="info-label">Time:</span>
                    <span><%= new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm").format(new java.util.Date()) %></span>
                </div>
            </div>
        </div>

        <div class="nav-buttons">
            <a href="list.jsp" class="btn btn-secondary">목록으로</a>
            <a href="write.jsp" class="btn btn-primary">새 글 작성</a>
        </div>

        <% if ("true".equals(updated)) { %>
        <div class="status success">
            게시글이 성공적으로 수정되었습니다!
        </div>
        <% } %>

        <div class="content-area">
            <div class="content-header">
                <div class="post-id-badge">#<%= postId %></div>
                <div class="post-title"><%= title %></div>
                <div class="post-meta">
                    <div class="meta-item">
                        <span class="meta-icon">작성자:</span>
                        <span class="author-badge"><%= author %></span>
                    </div>
                    <div class="meta-item">
                        <span class="meta-icon">작성일:</span>
                        <span><%= createdAt %></span>
                    </div>
                    <% if (!updatedAt.isEmpty()) { %>
                    <div class="meta-item">
                        <span class="meta-icon">수정일:</span>
                        <span><%= updatedAt %></span>
                    </div>
                    <% } %>
                </div>
            </div>

            <div class="post-content"><%= content %></div>

            <div class="action-buttons">
                <a href="list.jsp" class="btn btn-secondary">목록</a>
                <a href="edit.jsp?id=<%= postId %>" class="btn btn-warning">수정</a>
                <a href="delete.jsp?id=<%= postId %>" class="btn btn-danger" 
                   onclick="return confirm('정말 삭제하시겠습니까?')">삭제</a>
            </div>
        </div>

        <div class="footer">
            <p>3Tier Architecture: Nginx → Tomcat → AWS RDS MySQL</p>
            <p>현재 서버: <%= request.getServerName() %>:<%= request.getServerPort() %></p>
        </div>
    </div>

    <script>
        // 페이지 로드 애니메이션 효과
        document.addEventListener('DOMContentLoaded', function() {
            const contentArea = document.querySelector('.content-area');
            if (contentArea) {
                contentArea.style.opacity = '0';
                contentArea.style.transform = 'translateY(30px)';
                
                setTimeout(() => {
                    contentArea.style.transition = 'all 0.6s ease-out';
                    contentArea.style.opacity = '1';
                    contentArea.style.transform = 'translateY(0)';
                }, 100);
            }
        });
    </script>
</body>
</html>