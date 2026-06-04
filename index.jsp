<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>3Tier Architecture Demo</title>
    
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@300;400;500;700&display=swap" rel="stylesheet">
    
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }

        body {
            font-family: 'Noto Sans KR', -apple-system, BlinkMacSystemFont, "Malgun Gothic", "맑은 고딕", sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .container {
            background: rgba(255, 255, 255, 0.95);
            border-radius: 20px;
            padding: 40px;
            box-shadow: 0 20px 40px rgba(0, 0, 0, 0.1);
            text-align: center;
            max-width: 600px;
            width: 90%;
            backdrop-filter: blur(10px);
        }

        .logo { font-size: 48px; font-weight: 700; color: #667eea; margin-bottom: 20px; }

        h1 { color: #333; font-size: 32px; margin-bottom: 10px; font-weight: 700; }

        .subtitle {
            color: #666;
            font-size: 18px;
            margin-bottom: 30px;
            line-height: 1.6;
        }

        .architecture-info {
            background: #f8f9fa;
            border-radius: 15px;
            padding: 25px;
            margin: 30px 0;
            border-left: 5px solid #667eea;
        }

        .architecture-info h3 { color: #333; margin-bottom: 15px; font-size: 20px; }

        .tier-flow-container { margin: 20px 0; }

        .tier-row {
            display: flex;
            justify-content: center;
            align-items: center;
            margin: 15px 0;
            gap: 20px;
        }

        .tier {
            background: white;
            padding: 20px 25px;
            border-radius: 12px;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
            text-align: center;
            border-top: 4px solid #667eea;
        }

        .tier-web, .tier-app { flex: 1; max-width: 180px; }
        .tier-db { flex: 2; max-width: 380px; width: 100%; }

        .tier-title { font-weight: bold; color: #667eea; font-size: 16px; margin-bottom: 8px; }
        .tier-content { color: #333; font-size: 14px; line-height: 1.4; }

        .arrow      { font-size: 28px; color: #667eea; font-weight: bold; }
        .arrow-down { font-size: 28px; color: #667eea; font-weight: bold; }

        .btn-container { margin-top: 30px; }

        .btn {
            display: inline-block;
            background: linear-gradient(45deg, #667eea, #764ba2);
            color: white;
            padding: 15px 30px;
            font-size: 18px;
            font-weight: 600;
            text-decoration: none;
            border-radius: 50px;
            transition: all 0.3s ease;
            box-shadow: 0 4px 15px rgba(102, 126, 234, 0.4);
            margin: 10px;
        }
        .btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 25px rgba(102, 126, 234, 0.6);
        }

        .btn-secondary {
            background: linear-gradient(45deg, #6c757d, #495057);
            box-shadow: 0 4px 15px rgba(108, 117, 125, 0.4);
        }
        .btn-secondary:hover { box-shadow: 0 8px 25px rgba(108, 117, 125, 0.6); }

        /* ── 참고영상 버튼 색상 ── */
        .btn-video {
            background: linear-gradient(45deg, #e74c3c, #c0392b);
            box-shadow: 0 4px 15px rgba(231, 76, 60, 0.4);
        }
        .btn-video:hover { box-shadow: 0 8px 25px rgba(231, 76, 60, 0.6); }

        .features {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(180px, 1fr));
            gap: 20px;
            margin: 30px 0;
        }

        .feature {
            background: white;
            padding: 20px;
            border-radius: 10px;
            box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
            border-top: 3px solid #667eea;
            transition: transform 0.3s ease;
        }
        .feature:hover { transform: translateY(-5px); }


        .feature-icon {
            font-size: 14px;
            font-weight: bold;
            color: #667eea;
            background: #f8f9fa;
            padding: 8px 12px;
            border-radius: 20px;
            margin-bottom: 10px;
            display: inline-block;
        }

        .feature-title { font-weight: bold; color: #333; margin-bottom: 5px; }
        .feature-desc  { color: #666; font-size: 14px; }

        .footer {
            margin-top: 30px;
            padding-top: 20px;
            border-top: 1px solid #eee;
            color: #888;
            font-size: 14px;
        }

        .status {
            display: inline-block;
            padding: 5px 10px;
            background: #28a745;
            color: white;
            border-radius: 15px;
            font-size: 12px;
            margin: 0 5px;
        }

        @media (max-width: 768px) {
            .tier-row { flex-direction: column; gap: 10px; }
            .tier-web, .tier-app, .tier-db { max-width: 280px; width: 100%; }
            .arrow { transform: rotate(90deg); }
            .container { padding: 30px 20px; }
            h1 { font-size: 28px; }
            .logo { font-size: 36px; }
        }

        @keyframes fadeInUp {
            from { opacity: 0; transform: translateY(30px); }
            to   { opacity: 1; transform: translateY(0); }
        }
        .container { animation: fadeInUp 0.8s ease-out; }
    </style>
</head>
<body>
    <div class="container">
        <div class="logo">3TIER</div>
        <h1>3Tier Architecture Demo</h1>
        <p class="subtitle">
            현대적인 웹 애플리케이션 아키텍처를 체험해보세요<br>
            <strong>Nginx + Tomcat + AWS RDS MySQL</strong> 연동 시스템
        </p>

        <div class="architecture-info">
            <h3>시스템 아키텍처</h3>
            <div class="tier-flow-container">
                <div class="tier-row">
                    <div class="tier tier-web">
                        <div class="tier-title">Web Tier</div>
                        <div class="tier-content">Nginx<br><span class="status">ACTIVE</span></div>
                    </div>
                    <div class="arrow">→</div>
                    <div class="tier tier-app">
                        <div class="tier-title">Application Tier</div>
                        <div class="tier-content">Apache Tomcat 9.0<br><span class="status">RUNNING</span></div>
                    </div>
                </div>
                <div class="tier-row">
                    <div class="arrow-down">↓</div>
                </div>
                <div class="tier-row">
                    <div class="tier tier-db">
                        <div class="tier-title">Database Tier</div>
                        <div class="tier-content">AWS RDS MySQL<br><span class="status">CONNECTED</span></div>
                    </div>
                </div>
            </div>
        </div>

        <div class="features">
            <div class="feature">
                <div class="feature-icon">BOARD</div>
                <div class="feature-title">게시판 시스템</div>
                <div class="feature-desc">CRUD 작업을 통한 완전한 데이터베이스 연동 테스트</div>
            </div>
            <div class="feature">
                <div class="feature-icon">SYNC</div>
                <div class="feature-title">실시간 연동</div>
                <div class="feature-desc">Nginx 리버스 프록시를 통한 원활한 요청 처리</div>
            </div>
            <div class="feature">
                <div class="feature-icon">CLOUD</div>
                <div class="feature-title">클라우드 DB</div>
                <div class="feature-desc">AWS RDS를 활용한 확장 가능한 데이터베이스</div>
            </div>
            <div class="feature">
                <div class="feature-icon">FAST</div>
                <div class="feature-title">고성능</div>
                <div class="feature-desc">로드밸런싱과 연결 풀링으로 최적화된 성능</div>
            </div>

        </div>

        <div class="btn-container">
            <a href="list.jsp" class="btn">게시판 시작하기</a>
            <!-- ★ 추가: 참고영상 버튼 -->
            <a href="video.jsp" class="btn btn-video">▶ 참고영상</a>
            <a href="#" class="btn btn-secondary" onclick="alert('3Tier Architecture Demo v1.0')">시스템 정보</a>
        </div>

        <div class="footer">
            <p>
                현재 시간: <%= new java.util.Date() %><br>
                Server: <%= request.getServerName() %>:<%= request.getServerPort() %><br>
                3Tier Architecture: Web Layer → Business Layer → Data Layer
            </p>
        </div>
    </div>
</body>
</html>
