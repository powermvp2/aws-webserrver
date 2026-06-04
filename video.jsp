<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="javax.naming.*" %>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");

String CLOUDFRONT_DOMAIN = "";
try {
    Context initCtx = new InitialContext();
    Context envCtx  = (Context) initCtx.lookup("java:/comp/env");
    String val = (String) envCtx.lookup("CLOUDFRONT_DOMAIN");
    if (val != null) CLOUDFRONT_DOMAIN = val.trim();
} catch (NamingException e) {
    // context.xml에 설정 없으면 빈값 유지 → 미연결 상태로 표시
}

boolean isCloudfrontConnected = !CLOUDFRONT_DOMAIN.isEmpty();
String YOUTUBE_VIDEO_ID = "EtWKnwedEmM";
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>참고영상 | 3Tier Architecture Demo</title>

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
            padding: 40px;
            box-shadow: 0 20px 40px rgba(0,0,0,0.1);
            text-align: center;
            max-width: 720px;
            width: 90%;
            backdrop-filter: blur(10px);
            animation: fadeInUp 0.8s ease-out;
        }

        @keyframes fadeInUp {
            from { opacity: 0; transform: translateY(30px); }
            to   { opacity: 1; transform: translateY(0); }
        }

        .logo { font-size: 42px; font-weight: 700; color: #667eea; margin-bottom: 10px; }
        h1 { color: #333; font-size: 26px; font-weight: 700; margin-bottom: 8px; }
        .subtitle { color: #666; font-size: 15px; margin-bottom: 30px; line-height: 1.6; }

        .cf-status {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            padding: 8px 18px;
            border-radius: 30px;
            font-size: 13px;
            font-weight: 600;
            margin-bottom: 28px;
        }
        .cf-status.connected    { background: #d4edda; color: #155724; border: 1px solid #c3e6cb; }
        .cf-status.disconnected { background: #f8d7da; color: #721c24; border: 1px solid #f5c6cb; }
        .cf-status .dot { width: 8px; height: 8px; border-radius: 50%; animation: blink 1.4s infinite; }
        .cf-status.connected .dot    { background: #28a745; }
        .cf-status.disconnected .dot { background: #dc3545; animation: none; }

        @keyframes blink {
            0%, 100% { opacity: 1; }
            50%       { opacity: 0.3; }
        }

        .video-wrapper {
            position: relative;
            width: 100%;
            padding-top: 56.25%;
            border-radius: 14px;
            overflow: hidden;
            box-shadow: 0 8px 24px rgba(0,0,0,0.15);
            margin-bottom: 24px;
        }
        .video-wrapper iframe {
            position: absolute;
            top: 0; left: 0;
            width: 100%; height: 100%;
            border: none;
        }

        .no-video {
            background: #f8f9fa;
            border: 2px dashed #dee2e6;
            border-radius: 14px;
            padding: 60px 30px;
            margin-bottom: 24px;
        }
        .no-video .icon { font-size: 56px; margin-bottom: 16px; }
        .no-video h2 { color: #495057; font-size: 20px; margin-bottom: 10px; }
        .no-video p  { color: #868e96; font-size: 14px; line-height: 1.7; }

        .guide-box {
            background: #f0f4ff;
            border-left: 5px solid #667eea;
            border-radius: 10px;
            padding: 20px 24px;
            text-align: left;
            margin-bottom: 24px;
        }
        .guide-box h3 { color: #333; font-size: 15px; margin-bottom: 12px; }
        .guide-box ol { padding-left: 18px; color: #555; font-size: 14px; line-height: 2; }
        .guide-box code {
            background: #e8ecff;
            color: #667eea;
            padding: 2px 7px;
            border-radius: 5px;
            font-family: 'Courier New', monospace;
            font-size: 13px;
        }

        .cf-info-box {
            background: #f8f9fa;
            border-radius: 10px;
            padding: 16px 20px;
            text-align: left;
            margin-bottom: 24px;
            font-size: 13px;
            color: #555;
            line-height: 1.8;
        }
        .cf-info-box strong { color: #333; }
        .cf-info-box .cf-domain {
            font-family: 'Courier New', monospace;
            background: #e8ecff;
            color: #667eea;
            padding: 2px 8px;
            border-radius: 5px;
        }

        .cache-tip {
            background: #fff3cd;
            border: 1px solid #ffc107;
            border-radius: 10px;
            padding: 14px 18px;
            font-size: 13px;
            color: #856404;
            text-align: left;
            margin-bottom: 24px;
            line-height: 1.7;
        }

        .btn-container { margin-top: 10px; }
        .btn {
            display: inline-block;
            background: linear-gradient(45deg, #667eea, #764ba2);
            color: white;
            padding: 12px 26px;
            font-size: 15px;
            font-weight: 600;
            text-decoration: none;
            border-radius: 50px;
            transition: all 0.3s ease;
            box-shadow: 0 4px 15px rgba(102,126,234,0.4);
            margin: 6px;
        }
        .btn:hover { transform: translateY(-2px); box-shadow: 0 8px 25px rgba(102,126,234,0.6); }
        .btn-secondary { background: linear-gradient(45deg, #6c757d, #495057); box-shadow: 0 4px 15px rgba(108,117,125,0.4); }
        .btn-secondary:hover { box-shadow: 0 8px 25px rgba(108,117,125,0.6); }

        .footer { margin-top: 28px; padding-top: 18px; border-top: 1px solid #eee; color: #aaa; font-size: 12px; line-height: 1.8; }

        @media (max-width: 600px) {
            .container { padding: 28px 18px; }
            h1 { font-size: 22px; }
        }
    </style>
</head>
<body>
<div class="container">

    <div class="logo">▶ VIDEO</div>
    <h1>참고영상</h1>
    <p class="subtitle">
        CloudFront CDN을 통해 콘텐츠를 빠르게 전달합니다.<br>
        CloudFront가 연결되어야 영상을 재생할 수 있습니다.
    </p>

    <% if (isCloudfrontConnected) { %>
    <div class="cf-status connected">
        <span class="dot"></span>
        CloudFront 연결됨 &nbsp;|&nbsp; <%= CLOUDFRONT_DOMAIN %>
    </div>
    <% } else { %>
    <div class="cf-status disconnected">
        <span class="dot"></span>
        CloudFront 미연결
    </div>
    <% } %>

    <% if (isCloudfrontConnected) { %>

    <div class="video-wrapper">
        <iframe
            src="https://www.youtube.com/embed/<%= YOUTUBE_VIDEO_ID %>?rel=0&modestbranding=1"
            title="참고영상"
            allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
            allowfullscreen>
        </iframe>
    </div>

    <div class="cf-info-box">
        <strong>CloudFront 도메인</strong><br>
        <span class="cf-domain">https://<%= CLOUDFRONT_DOMAIN %></span><br><br>
        영상 콘텐츠가 CloudFront 엣지 로케이션에 캐싱되어<br>
        사용자와 가장 가까운 서버에서 빠르게 전달되고 있습니다.
    </div>

    <div class="cache-tip">
        💡 <strong>캐시 확인 방법</strong><br>
        브라우저 개발자도구(F12) → Network 탭 → 영상 요청 선택<br>
        응답 헤더에서 <code>X-Cache: Hit from cloudfront</code> 확인 시 캐시 적중!
    </div>

    <% } else { %>

    <div class="no-video">
        <div class="icon">🎬</div>
        <h2>재생할 영상이 없습니다</h2>
        <p>
            CloudFront가 연결되지 않아 영상을 불러올 수 없습니다.<br>
            아래 가이드를 참고하여 CloudFront를 설정해주세요.
        </p>
    </div>

    <div class="guide-box">
        <h3>🔧 CloudFront 연결 방법</h3>
        <ol>
            <li>AWS Console → <strong>CloudFront</strong> → <strong>Create Distribution</strong></li>
            <li>Origin Domain: 커스텀 오리진 입력</li>
            <li>배포 완료 후 발급된 도메인 복사 <code>xxxx.cloudfront.net</code></li>
            <li>Tomcat 서버의 <code>conf/context.xml</code> 에 아래 내용 추가</li>
            <li>Tomcat 재시작 후 이 페이지 새로고침</li>
        </ol>
        <br>
        <code>&lt;Environment name="CLOUDFRONT_DOMAIN" value="xxxx.cloudfront.net" type="java.lang.String"/&gt;</code>
    </div>

    <% } %>

    <div class="btn-container">
        <a href="index.jsp" class="btn btn-secondary">← 메인으로</a>
        <% if (isCloudfrontConnected) { %>
        <a href="video.jsp" class="btn">새로고침</a>
        <% } %>
    </div>

    <div class="footer">
        현재 시간: <%= new java.util.Date() %><br>
        Server: <%= request.getServerName() %>:<%= request.getServerPort() %><br>
        CloudFront Status: <%= isCloudfrontConnected ? "CONNECTED → " + CLOUDFRONT_DOMAIN : "NOT CONNECTED" %>
    </div>

</div>
</body>
</html>
