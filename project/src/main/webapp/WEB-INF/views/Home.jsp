<%@ page language="java" contentType="text/html; charset=EUC-KR"
    pageEncoding="EUC-KR"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="EUC-KR">
<title>Insert title here</title>
<script>
	function popupOpen(chat){
		var popUrl = "/project/"+chat+".jsp";	//�˾�â�� ��µ� ������ URL	
		var popOption = "width=418, height=476, resizable=no, scrollbars=no, status=no, toolbar=no, menubar=no,location=no;";	
		//�˾�â �ɼ�(option)		
		window.open(popUrl,"_blank",popOption);
	}
</script>
</head>
<body>
����
<!-- <a href="javascript:popupOpen('b-chat');" title="�����Ϲ�">
�ƹ������� -->
</a>
</body>
</html>