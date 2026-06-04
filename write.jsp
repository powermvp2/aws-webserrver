<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="javax.sql.*" %>
<%@ page import="javax.naming.*" %>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>

<%
// POST 요청 처리 (게시글 저장)
if("POST".equals(request.getMethod())) {
    String title = request.getParameter("title");
    String content = request.getParameter("content");
    String author = request.getParameter("author");
    
    if(title != null && content != null && author != null && 
       !title.trim().isEmpty() && !content.trim().isEmpty() && !author.trim().isEmpty()) {
        
        Connection conn = null;
        PreparedStatement pstmt = null;
        
        try {
            Context initContext = new InitialContext();
            Context envContext = (Context)initContext.lookup("java:/comp/env");
            DataSource ds = (DataSource)envContext.lookup("jdbc/MyDB");
            conn = ds.getConnection();
            
            String sql = "INSERT INTO posts (title, content, author) VALUES (?, ?, ?)";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, title);
            pstmt.setString(2, content);
            pstmt.setString(3, author);
            
            int result = pstmt.executeUpdate();
            if(result > 0) {
                response.sendRedirect("list.jsp");
                return;
            }
        } catch(Exception e) {
            out.println("<script>alert('게시글 저장 중 오류가 발생했습니다: " + e.getMessage() + "'); history.back();</script>");
        } finally {
            if(pstmt != null) try { pstmt.close(); } catch(Exception e) {}
            if(conn != null) try { conn.close(); } catch(Exception e) {}
        }
    } else {
        out.println("<script>alert('모든 필드를 입력해주세요.'); history.back();</script>");
    }
}
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>새 글 작성 - 3Tier 게시판</title>
    
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
            margin-bottom: 10px;
        }

        .subtitle {
            color: #6c757d;
            font-size: 16px;
            margin-top: 10px;
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
            font-family: inherit;
        }

        .btn:hover {
            transform: translateY(-3px);
            box-shadow: 0 15px 35px rgba(102, 126, 234, 0.4);
        }

        .btn-secondary {
            background: linear-gradient(45deg, #6c757d, #495057);
            box-shadow: 0 8px 25px rgba(108, 117, 125, 0.3);
        }

        .btn-secondary:hover {
            box-shadow: 0 15px 35px rgba(108, 117, 125, 0.4);
        }

        .btn-success {
            background: linear-gradient(45deg, #28a745, #20c997);
            box-shadow: 0 8px 25px rgba(40, 167, 69, 0.3);
        }

        .btn-success:hover {
            box-shadow: 0 15px 35px rgba(40, 167, 69, 0.4);
        }

        .content-area {
            background: rgba(255, 255, 255, 0.95);
            border-radius: 20px;
            backdrop-filter: blur(15px);
            box-shadow: 0 20px 40px rgba(0, 0, 0, 0.1);
            overflow: hidden;
        }

        .form-header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 30px;
            text-align: center;
        }

        .form-title {
            font-size: 28px;
            font-weight: 700;
            margin-bottom: 10px;
        }

        .form-subtitle {
            opacity: 0.9;
            font-size: 16px;
        }

        .form-container {
            padding: 40px;
        }

        .form-group {
            margin-bottom: 30px;
            position: relative;
        }

        .form-label {
            display: block;
            font-size: 16px;
            font-weight: 600;
            color: #333;
            margin-bottom: 12px;
            position: relative;
        }

        .form-label::after {
            content: ' *';
            color: #dc3545;
            font-weight: 700;
        }

        .form-input, .form-textarea {
            width: 100%;
            padding: 16px 20px;
            border: 2px solid #e9ecef;
            border-radius: 12px;
            font-size: 16px;
            font-family: inherit;
            transition: all 0.3s ease;
            background: #fff;
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);
        }

        .form-input:focus, .form-textarea:focus {
            outline: none;
            border-color: #667eea;
            box-shadow: 0 0 0 4px rgba(102, 126, 234, 0.1);
            transform: translateY(-2px);
        }

        .form-textarea {
            resize: vertical;
            min-height: 200px;
            line-height: 1.6;
        }

        .char-counter {
            position: absolute;
            bottom: -25px;
            right: 0;
            font-size: 13px;
            color: #6c757d;
        }

        .form-help {
            font-size: 14px;
            color: #6c757d;
            margin-top: 8px;
            display: flex;
            align-items: center;
            gap: 5px;
        }

        .help-icon {
            color: #667eea;
            font-size: 16px;
        }

        .button-group {
            display: flex;
            justify-content: center;
            gap: 20px;
            margin-top: 40px;
            padding-top: 30px;
            border-top: 1px solid #e9ecef;
        }

        .writing-tips {
            background: linear-gradient(135deg, #f8f9fa 0%, #e9ecef 100%);
            border-radius: 15px;
            padding: 25px;
            margin-bottom: 30px;
            border-left: 4px solid #667eea;
        }

        .tips-title {
            font-size: 18px;
            font-weight: 600;
            color: #333;
            margin-bottom: 15px;
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .tips-list {
            list-style: none;
            padding: 0;
        }

        .tips-list li {
            padding: 8px 0;
            color: #495057;
            position: relative;
            padding-left: 20px;
        }

        .tips-list li::before {
            content: '✓';
            position: absolute;
            left: 0;
            color: #28a745;
            font-weight: bold;
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

        .content-area, .writing-tips {
            animation: fadeInUp 0.8s ease-out;
        }

        .form-group {
            animation: fadeInUp 0.6s ease-out;
        }

        .form-group:nth-child(1) { animation-delay: 0.1s; }
        .form-group:nth-child(2) { animation-delay: 0.2s; }
        .form-group:nth-child(3) { animation-delay: 0.3s; }

        /* 폼 유효성 검사 스타일 */
        .form-input:valid, .form-textarea:valid {
            border-color: #28a745;
        }

        .form-input:invalid:not(:placeholder-shown), 
        .form-textarea:invalid:not(:placeholder-shown) {
            border-color: #dc3545;
        }

        @media (max-width: 768px) {
            body {
                padding: 10px;
            }

            .header {
                padding: 25px 20px;
            }

            .form-container {
                padding: 25px 20px;
            }

            .nav-buttons {
                flex-direction: column;
                align-items: center;
            }

            .button-group {
                flex-direction: column;
                align-items: center;
            }

            .btn {
                width: 100%;
                max-width: 300px;
                text-align: center;
            }

            .form-title {
                font-size: 24px;
            }

            .writing-tips {
                padding: 20px;
            }
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <div class="logo">3TIER BOARD</div>
            <h1>새 글 작성</h1>
            <div class="subtitle">당신의 생각을 자유롭게 표현해보세요</div>
        </div>

        <div class="nav-buttons">
            <a href="index.jsp" class="btn btn-secondary">홈으로</a>
            <a href="list.jsp" class="btn btn-secondary">목록으로</a>
        </div>

        <div class="writing-tips">
            <div class="tips-title">
                <span>💡</span> 글쓰기 가이드
            </div>
            <ul class="tips-list">
                <li>제목은 글의 핵심 내용을 간결하게 표현해주세요</li>
                <li>내용은 읽기 쉽게 문단을 나누어 작성하면 좋습니다</li>
                <li>정확하고 예의바른 언어 사용을 권장합니다</li>
                <li>작성 후에는 한 번 더 검토해보세요</li>
            </ul>
        </div>

        <div class="content-area">
            <div class="form-header">
                <div class="form-title">게시글 작성</div>
                <div class="form-subtitle">3Tier 아키텍처 게시판에 새로운 글을 작성합니다</div>
            </div>

            <div class="form-container">
                <form method="post" action="write.jsp" accept-charset="UTF-8" id="writeForm">
                    <div class="form-group">
                        <label for="title" class="form-label">제목</label>
                        <input type="text" id="title" name="title" class="form-input" 
                               required maxlength="200" 
                               placeholder="게시글 제목을 입력하세요"
                               oninput="updateCharCounter('title', 200)">
                        <div class="char-counter" id="titleCounter">0/200</div>
                        <div class="form-help">
                            <span class="help-icon">ℹ️</span>
                            <span>제목은 200자 이내로 작성해주세요</span>
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="author" class="form-label">작성자</label>
                        <input type="text" id="author" name="author" class="form-input" 
                               required maxlength="50" 
                               placeholder="작성자 이름을 입력하세요"
                               oninput="updateCharCounter('author', 50)">
                        <div class="char-counter" id="authorCounter">0/50</div>
                        <div class="form-help">
                            <span class="help-icon">👤</span>
                            <span>작성자명은 50자 이내로 입력해주세요</span>
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="content" class="form-label">내용</label>
                        <textarea id="content" name="content" class="form-textarea" 
                                  required placeholder="게시글 내용을 입력하세요&#10;&#10;여러 줄에 걸쳐 자유롭게 작성할 수 있습니다."
                                  oninput="updateCharCounter('content', 5000)"></textarea>
                        <div class="char-counter" id="contentCounter">0/5000</div>
                        <div class="form-help">
                            <span class="help-icon">✏️</span>
                            <span>내용은 5000자 이내로 작성해주세요</span>
                        </div>
                    </div>

                    <div class="button-group">
                        <button type="submit" class="btn btn-success">게시글 저장</button>
                        <a href="list.jsp" class="btn btn-secondary">취소</a>
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
        // 글자수 카운터 업데이트
        function updateCharCounter(fieldId, maxLength) {
            const field = document.getElementById(fieldId);
            const counter = document.getElementById(fieldId + 'Counter');
            const currentLength = field.value.length;
            counter.textContent = currentLength + '/' + maxLength;
            
            // 글자수에 따른 색상 변경
            if (currentLength > maxLength * 0.9) {
                counter.style.color = '#dc3545';
            } else if (currentLength > maxLength * 0.7) {
                counter.style.color = '#ffc107';
            } else {
                counter.style.color = '#6c757d';
            }
        }

        // 페이지 로드 시 카운터 초기화
        document.addEventListener('DOMContentLoaded', function() {
            updateCharCounter('title', 200);
            updateCharCounter('author', 50);
            updateCharCounter('content', 5000);
        });

        // 폼 제출 전 유효성 검사
        document.getElementById('writeForm').addEventListener('submit', function(e) {
            const title = document.getElementById('title').value.trim();
            const author = document.getElementById('author').value.trim();
            const content = document.getElementById('content').value.trim();

            if (!title || !author || !content) {
                e.preventDefault();
                alert('모든 필드를 입력해주세요.');
                return false;
            }

            // 제출 버튼 비활성화 (중복 제출 방지)
            const submitBtn = e.target.querySelector('button[type="submit"]');
            submitBtn.disabled = true;
            submitBtn.textContent = '저장 중...';
        });

        // 뒤로가기 시 폼 리셋
        window.addEventListener('pageshow', function(event) {
            if (event.persisted) {
                document.getElementById('writeForm').reset();
            }
        });
    </script>
</body>
</html>
