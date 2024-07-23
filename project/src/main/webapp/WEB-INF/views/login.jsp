<%@ page language="java" contentType="text/html; charset=EUC-KR"
    pageEncoding="EUC-KR"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="EUC-KR">
<title>Insert title here</title>
</head>
<body>
<form action="/project/login" method="post">
        <div>
            <label for="id">ID:</label>
            <input type="text" id="id" name="id" required maxlength="50" />
        </div>
        <div>
            <label for="password">Password:</label>
            <input type="password" id="password" name="password" required maxlength="100" />
        </div>
        <div>
            <button type="submit">로그인</button>
        </div>
        <c:if test="${not empty error}">
            <p style="color:red;">${error}</p>
        </c:if>
    </form>

</body>
</html>