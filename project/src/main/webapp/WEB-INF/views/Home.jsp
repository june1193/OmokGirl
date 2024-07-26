<%@ page language="java" contentType="text/html; charset=EUC-KR"
    pageEncoding="EUC-KR"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="EUC-KR">
<title>Insert title here</title>
<script>
	function popupOpen(chat){
		var popUrl = "/project/"+chat+".jsp";	//팝업창에 출력될 페이지 URL	
		var popOption = "width=418, height=476, resizable=no, scrollbars=no, status=no, toolbar=no, menubar=no,location=no;";	
		//팝업창 옵션(option)		
		window.open(popUrl,"_blank",popOption);
	}
</script>
</head>
<body>
메인
<!-- <a href="javascript:popupOpen('b-chat');" title="배드민턴방">
아무맒말말 -->
</a>
</body>
</html>