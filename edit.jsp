<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="javax.sql.*" %>
<%@ page import="javax.naming.*" %>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");

String id = request.getParameter("id");
if (id == null || id.trim().isEmpty()) {
    response.sendRedirect("list.jsp");
    return;
}

// POST 요청인 경우 (수정 처리)
if ("POST".equals(request.getMethod())) {
    String title = request.getParameter("title");
    String content = request.getParameter("content");
    String author = request.getParameter("author");
    
    if (title != null && content != null && author != null && 
        !title.trim().isEmpty() && !content.trim().isEmpty() && !author.trim().isEmpty()) {
        
        Connection conn = null;
        PreparedStatement pstmt = null;
        
        try {
            Context initContext = new InitialContext();
            Context envContext = (Context)initContext.lookup("java:/comp/env");
            DataSource ds = (DataSource)envContext.lookup("jdbc/MyDB");
            conn = ds.getConnection();
            
            String updateSql = "UPDATE posts SET title=?, content=?, author=?, updated_at=NOW() WHERE id=?";
            pstmt = conn.prepareStatement(updateSql);
            pstmt.setString(1, title);
            pstmt.setString(2, content);
            pstmt.setString(3, author);
            pstmt.setInt(4, Integer.parseInt(id));
            
            int result = pstmt.executeUpdate();
            
            if (result > 0) {
                response.sendRedirect("view.jsp?id=" + id + "&updated=true");
                return;
            }
        } catch(Exception e) {
            e.printStackTrace();
        } finally {
            if(pstmt != null) try { pstmt.close(); } catch(Exception e) {}
            if(conn != null) try { conn.close(); } catch(Exception e) {}
        }
    }
}

// GET 요청인 경우 (수정 폼 표시)
String title = "";
String content = "";
String author = "";
String createdAt = "";
boolean postFound = false;

Connection conn = null;
PreparedStatement pstmt = null;
ResultSet rs = null;

try {
    Context initContext = new InitialContext();
    Context envContext = (Context)initContext.lookup("java:/comp/env");
    DataSource ds = (DataSource)envContext.lookup("jdbc/MyDB");
    conn = ds.getConnection();
    
    String sql = "SELECT title, content, author, created_at FROM posts WHERE id=?";
    pstmt = conn.prepareStatement(sql);
    pstmt.setInt(1, Integer.parseInt(id));
    rs = pstmt.executeQuery();
    
    if(rs.next()) {
        title = rs.getString("title");
        content = rs.getString("content");
        author = rs.getString("author");
        createdAt = new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm").format(rs.getTimestamp("created_at"));
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
    <title>3Tier 게시판 - 글 수정</title>
    
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
            max-width: 800px;
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
            padding: 30px;
            text-align: center;
        }

        .content-title {
            font-size: 28px;
            font-weight: 700;
            margin-bottom: 10px;
        }

        .content-subtitle {
            opacity: 0.9;
            font-size: 16px;
        }

        .post-info {
            background: #f8f9fa;
            padding: 20px 30px;
            border-bottom: 1px solid #dee2e6;
        }

        .post-meta {
            display: flex;
            justify-content: space-between;
            align-items: center;
            font-size: 14px;
            color: #6c757d;
        }

        .post-id {
            background: #667eea;
            color: white;
            padding: 5px 12px;
            border-radius: 15px;
            font-weight: 600;
        }

        .form-container {
            padding: 40px;
        }

        .form-group {
            margin-bottom: 25px;
        }

        .form-label {
            display: block;
            margin-bottom: 8px;
            font-weight: 600;
            color: #333;
            font-size: 16px;
        }

        .form-input {
            width: 100%;
            padding: 15px 20px;
            border: 2px solid #e9ecef;
            border-radius: 12px;
            font-size: 16px;
            font-family: inherit;
            transition: all 0.3s ease;
            background: #fff;
        }

        .form-input:focus {
            outline: none;
            border-color: #667eea;
            box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
        }

        .form-textarea {
            min-height: 300px;
            resize: vertical;
            font-family: inherit;
        }

        .form-buttons {
            display: flex;
            gap: 15px;
            justify-content: center;
            margin-top: 40px;
            flex-wrap: wrap;
        }

        .status {
            padding: 12px 25px;
            margin: 25px 30px;
            border-radius: 12px;
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

            .form-container {
                padding: 25px 20px;
            }

            .content-header {
                padding: 20px;
            }

            .content-title {
                font-size: 24px;
            }

            .post-info {
                padding: 15px 20px;
            }

            .post-meta {
                flex-direction: column;
                gap: 10px;
                align-items: flex-start;
            }

            .form-buttons {
                flex-direction: column;
                align-items: center;
            }
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <div class="logo">3TIER BOARD</div>
            <h1>게시글 수정</h1>
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
            <a href="view.jsp?id=<%= id %>" class="btn">원글 보기</a>
        </div>

        <div class="content-area">
            <div class="content-header">
                <div class="content-title">게시글 수정</div>
                <div class="content-subtitle">기존 게시글을 수정할 수 있습니다</div>
            </div>
            
            <div class="post-info">
                <div class="post-meta">
                    <span class="post-id">게시글 #<%= id %></span>
                    <span>작성일: <%= createdAt %></span>
                </div>
            </div>

            <div class="form-container">
                <form method="post" action="edit.jsp?id=<%= id %>" onsubmit="return validateForm()">
                    <div class="form-group">
                        <label for="title" class="form-label">제목 *</label>
                        <input type="text" id="title" name="title" class="form-input" 
                               value="<%= title %>" required maxlength="200" 
                               placeholder="게시글 제목을 입력하세요">
                    </div>

                    <div class="form-group">
                        <label for="author" class="form-label">작성자 *</label>
                        <input type="text" id="author" name="author" class="form-input" 
                               value="<%= author %>" required maxlength="50" 
                               placeholder="작성자명을 입력하세요">
                    </div>

                    <div class="form-group">
                        <label for="content" class="form-label">내용 *</label>
                        <textarea id="content" name="content" class="form-input form-textarea" 
                                  required placeholder="게시글 내용을 입력하세요"><%= content %></textarea>
                    </div>

                    <div class="form-buttons">
                        <button type="submit" class="btn btn-warning">수정 완료</button>
                        <button type="button" class="btn btn-secondary" onclick="history.back()">취소</button>
                    </div>
                </form>
            </div>
        </div>

        <div class="footer">
            <p>3Tier Architecture: Nginx → Tomcat → AWS RDS MySQL</p>
            <p>현재 서버: <%= request.getServerName() %>:<%= request.getServerPort() %></p>
        </div>
    </div>

    <script>
        function validateForm() {
            const title = document.getElementById('title').value.trim();
            const author = document.getElementById('author').value.trim();
            const content = document.getElementById('content').value.trim();

            if (!title) {
                alert('제목을 입력해주세요.');
                document.getElementById('title').focus();
                return false;
            }

            if (!author) {
                alert('작성자를 입력해주세요.');
                document.getElementById('author').focus();
                return false;
            }

            if (!content) {
                alert('내용을 입력해주세요.');
                document.getElementById('content').focus();
                return false;
            }

            if (title.length > 200) {
                alert('제목은 200자를 초과할 수 없습니다.');
                document.getElementById('title').focus();
                return false;
            }

            if (author.length > 50) {
                alert('작성자명은 50자를 초과할 수 없습니다.');
                document.getElementById('author').focus();
                return false;
            }

            return confirm('게시글을 수정하시겠습니까?');
        }

        // 페이지 로드시 포커스 설정
        window.onload = function() {
            document.getElementById('title').focus();
        };
    </script>
</body>
</html>
