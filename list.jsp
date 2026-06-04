<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="javax.sql.*" %>
<%@ page import="javax.naming.*" %>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>3Tier 게시판 - 목록</title>
    
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
            max-width: 1000px;
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

        .content-area {
            background: rgba(255, 255, 255, 0.95);
            border-radius: 20px;
            backdrop-filter: blur(15px);
            box-shadow: 0 20px 40px rgba(0, 0, 0, 0.1);
            overflow: hidden;
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

        .status {
            padding: 12px 25px;
            margin: 25px;
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

        .posts-container {
            padding: 30px;
        }

        .post-grid {
            display: grid;
            gap: 20px;
            grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
        }

        .post-card {
            background: white;
            border-radius: 15px;
            padding: 25px;
            box-shadow: 0 8px 25px rgba(0, 0, 0, 0.08);
            transition: all 0.3s ease;
            border-top: 4px solid #667eea;
            position: relative;
            overflow: hidden;
        }

        .post-card::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            height: 4px;
            background: linear-gradient(45deg, #667eea, #764ba2);
            transform: scaleX(0);
            transition: transform 0.3s ease;
        }

        .post-card:hover {
            transform: translateY(-8px);
            box-shadow: 0 20px 40px rgba(0, 0, 0, 0.15);
        }

        .post-card:hover::before {
            transform: scaleX(1);
        }

        .post-number {
            position: absolute;
            top: 15px;
            right: 15px;
            background: linear-gradient(45deg, #667eea, #764ba2);
            color: white;
            width: 35px;
            height: 35px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: 700;
            font-size: 14px;
        }

        .post-title {
            font-size: 20px;
            font-weight: 700;
            color: #333;
            margin-bottom: 15px;
            line-height: 1.4;
            padding-right: 50px;
        }

        .post-title a {
            color: inherit;
            text-decoration: none;
            transition: color 0.3s ease;
        }

        .post-title a:hover {
            color: #667eea;
        }

        .post-meta {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
            font-size: 14px;
            color: #6c757d;
        }

        .post-author {
            background: #f8f9fa;
            padding: 6px 12px;
            border-radius: 20px;
            font-weight: 500;
            color: #495057;
        }

        .post-date {
            font-size: 13px;
        }

        .post-actions {
            display: flex;
            gap: 8px;
            justify-content: center;
        }

        .action-btn {
            padding: 8px 16px;
            border-radius: 20px;
            text-decoration: none;
            font-size: 13px;
            font-weight: 500;
            transition: all 0.3s ease;
            border: 2px solid transparent;
        }

        .btn-view {
            background: linear-gradient(45deg, #007bff, #0056b3);
            color: white;
        }

        .btn-edit {
            background: linear-gradient(45deg, #ffc107, #ffb300);
            color: #212529;
        }

        .btn-delete {
            background: linear-gradient(45deg, #dc3545, #c82333);
            color: white;
        }

        .action-btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(0, 0, 0, 0.2);
        }

        .empty-state {
            text-align: center;
            padding: 60px 40px;
            color: #6c757d;
        }

        .empty-icon {
            font-size: 64px;
            margin-bottom: 20px;
            opacity: 0.5;
        }

        .empty-title {
            font-size: 24px;
            font-weight: 600;
            margin-bottom: 10px;
        }

        .empty-desc {
            margin-bottom: 30px;
            line-height: 1.6;
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

        .post-card {
            animation: fadeInUp 0.6s ease-out;
        }

        .post-card:nth-child(odd) {
            animation-delay: 0.1s;
        }

        .post-card:nth-child(even) {
            animation-delay: 0.2s;
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

            .post-grid {
                grid-template-columns: 1fr;
            }

            .post-card {
                padding: 20px;
            }

            .post-title {
                font-size: 18px;
            }

            .post-meta {
                flex-direction: column;
                gap: 10px;
                align-items: flex-start;
            }

            .posts-container {
                padding: 20px;
            }

            .content-header {
                padding: 20px;
            }

            .content-title {
                font-size: 24px;
            }
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <div class="logo">3TIER BOARD</div>
            <h1>게시판 목록</h1>
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
            <a href="index.jsp" class="btn btn-secondary">홈으로</a>
            <a href="write.jsp" class="btn btn-primary">새 글 작성</a>
        </div>

        <div class="content-area">
            <div class="content-header">
                <div class="content-title">전체 게시글</div>
                <div class="content-subtitle">3Tier 아키텍처로 구현된 게시판 시스템</div>
            </div>
            
            <%
            Connection conn = null;
            PreparedStatement pstmt = null;
            ResultSet rs = null;
            
            try {
                Context initContext = new InitialContext();
                Context envContext = (Context)initContext.lookup("java:/comp/env");
                DataSource ds = (DataSource)envContext.lookup("jdbc/MyDB");
                conn = ds.getConnection();
                
                out.println("<div class='status success'>✅ 데이터베이스 연결 성공!</div>");
                
                String sql = "SELECT id, title, author, created_at FROM posts ORDER BY created_at DESC";
                pstmt = conn.prepareStatement(sql);
                rs = pstmt.executeQuery();
            %>
            
            <div class="posts-container">
                <div class="post-grid">
                <%
                boolean hasData = false;
                while(rs.next()) {
                    hasData = true;
                %>
                    <div class="post-card">
                        <div class="post-number"><%= rs.getInt("id") %></div>
                        <div class="post-title">
                            <a href="view.jsp?id=<%= rs.getInt("id") %>"><%= rs.getString("title") %></a>
                        </div>
                        <div class="post-meta">
                            <div class="post-author"><%= rs.getString("author") %></div>
                            <div class="post-date"><%= new java.text.SimpleDateFormat("MM-dd HH:mm").format(rs.getTimestamp("created_at")) %></div>
                        </div>
                        <div class="post-actions">
                            <a href="view.jsp?id=<%= rs.getInt("id") %>" class="action-btn btn-view">보기</a>
                            <a href="edit.jsp?id=<%= rs.getInt("id") %>" class="action-btn btn-edit">수정</a>
                            <a href="delete.jsp?id=<%= rs.getInt("id") %>" class="action-btn btn-delete" onclick="return confirm('정말 삭제하시겠습니까?')">삭제</a>
                        </div>
                    </div>
                <%
                }
                
                if (!hasData) {
                %>
                    <div class="empty-state">
                        <div class="empty-icon">📝</div>
                        <div class="empty-title">게시글이 없습니다</div>
                        <div class="empty-desc">
                            아직 등록된 게시글이 없습니다.<br>
                            첫 번째 게시글을 작성해보세요!
                        </div>
                        <a href="write.jsp" class="btn btn-primary">첫 글 작성하기</a>
                    </div>
                <%
                }
                %>
                </div>
            </div>
            
            <%
            } catch(Exception e) {
                out.println("<div class='status error'>❌ 데이터베이스 연결 실패: " + e.getMessage() + "</div>");
                e.printStackTrace();
            } finally {
                if(rs != null) try { rs.close(); } catch(Exception e) {}
                if(pstmt != null) try { pstmt.close(); } catch(Exception e) {}
                if(conn != null) try { conn.close(); } catch(Exception e) {}
            }
            %>
        </div>

        <div class="footer">
            <p>3Tier Architecture: Nginx → Tomcat → AWS RDS MySQL</p>
            <p>현재 서버: <%= request.getServerName() %>:<%= request.getServerPort() %></p>
        </div>
    </div>
</body>
</html>
