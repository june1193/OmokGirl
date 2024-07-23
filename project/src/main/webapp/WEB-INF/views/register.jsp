<%@ page language="java" contentType="text/html; charset=EUC-KR"
    pageEncoding="EUC-KR"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="EUC-KR">
<title>Insert title here</title>
</head>
<body>
    <h1>회원가입</h1>

    <form action="/project/register" method="post">
        <div>
            <label for="id">ID:</label>
            <input type="text" id="id" name="id" required maxlength="50" />
        </div>
        <div>
            <label for="password">Password:</label>
            <input type="password" id="password" name="password" required maxlength="100" />
        </div>
        <div>
            <label for="email">Email:</label>
            <input type="email" id="email" name="email" required maxlength="100" />
        </div>
        <div>
            <label for="nickname">Nickname:</label>
            <input type="text" id="nickname" name="nickname" required maxlength="50" />
        </div>
        <div>
            <button type="submit">가입</button>
        </div>
    </form>
</body>
</html>