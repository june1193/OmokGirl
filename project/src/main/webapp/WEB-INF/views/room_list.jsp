<%@ page contentType="text/html; charset=UTF-8"
	trimDirectiveWhitespaces="true"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<title>채팅</title>
<script
	src="https://ajax.googleapis.com/ajax/libs/jquery/3.5.1/jquery.min.js"></script>
<script type="text/javascript">

var today = new Date();   
var hours = today.getHours(); // 시
var minutes = today.getMinutes();  // 분
var seconds = today.getSeconds(); 
var wsocket;


  
	$(document).ready(function(){ // 페이지가 로드되었을 때 실행
		

	      
		//닉네임가져오기
		var nickname = $("#uId").val();
		
		//만약 session이 null이면 닉네임 입력창 뜨게, 닉네임 입력 안하고 전송하면 입력하라고 유효성 검사
			$.ajax({
	        	type : "get",
	        	url : "/project/getCount",
	        	success :function(data){
	        		writeCount(data); // 현재 접속자 수 표시
	        	}
	        });
		connect(); // 웹소켓 연결
		
		//소켓 연결 함수
		function connect(){
			wsocket = new WebSocket("ws://localhost:8080/project/chat-lobby");
			wsocket.onopen = onOpen; // 연결이 열렸을 때 호출
			wsocket.onmessage = onMessage; // 메시지를 받을 때 호출
			wsocket.onclose = onClose; // 연결이 닫혔을 때 호출
		}
		
		var disConnect = false; // 연결 종료 상태 변수
		
		// 소켓 연결 종료 함수
		 function disconnect() {
				disConnect = true;  // 연결 종료 상태로 설정
		        let today = new Date(); 
		    	let hours = today.getHours(); // 현재 시
				let minutes = today.getMinutes();  // 현재 분
				let seconds = today.getSeconds(); // 현재 초
		    	let msg = "<div class='notice'>*** "+hours+":"+minutes+":"+seconds+" ༺"+nickname+"༻님이 퇴장하였습니다. ***</div>";
		    	wsocket.send(msg); // 퇴장 메시지 전송
		    	
				//퇴장시 카운트 감소
		    	$.ajax({
		    		type : "get",
		    		url : "/project/deleteNickname/"+nickname,
		    		success:function(data){
		    			wsocket.send("감소count:"+data); //상대방한테 보내는 메세지
		    			writeCount(data); //내 화면 카운트 감소
		    			wsocket.close(); // 웹소켓 연결 종료 (onclose() 호출)
		    		}
		    		
		    	});
		    	        
		    }
		 
		 // 브라우저 창 닫힐 때 이벤트 처리
		 window.addEventListener('beforeunload', (event) => {
			  // 기본 동작 방지
			  event.preventDefault();
			  console.log(nickname);
			  if(!disConnect && nickname != undefined){
				  $.ajax({
			    		type : "get",
			    		url : "/project/deleteNickname/"+nickname,
			    		success:function(data){
			    			let today = new Date(); 
					    	let hours = today.getHours(); // 시
							let minutes = today.getMinutes();  // 분
							let seconds = today.getSeconds(); //초
					    	let msg = "<div class='notice'>*** "+hours+":"+minutes+":"+seconds+" ༺"+nickname+"༻님이 퇴장하였습니다. ***</div>";
					    	wsocket.send(msg); // 퇴장 메시지 전송
			    			wsocket.send("감소count:"+data); //상대방한테 보내는 메세지
			    			writeCount(data); //내 화면 카운트 감소
			    		}
			    		
			    	});
			  }
			});
		 
		
		 

		 
			 
		        
		     
		 	//소켓 연결되면 실행됨
		    function onOpen(evt) {
		    	
		    }
		     
		    // 메시지를 받을 때 호출되는 함수
		    function onMessage(evt) {
		        var data = evt.data; // 받은 데이터
		        var message = data.split(":"); // 메시지를 ':'로 분리
		        var sender = message[0]; // 메시지 보낸 사람
		        var content = message[1]; // 메시지 내용
		        let msg = content.trim().charAt(0); // 메시지 첫 글자
		        if (msg === '/') { //귓속말 
					if(content.match("/"+nickname)){
						var temp = content.replace(("/"+nickname), "[귓속말] "+sender+" : ");
						whisper(temp);
					}
		        }else if (data.match("notice")) {
		        	noticeMessage(data); // 공지 메시지인 경우
		        }else if(sender === 'count'){
		        	writeCount(content); // 접속자 수 증가 메시지인 경우
		        }else if(sender === '감소count'){
		        	writeCount(content); // 접속자 수 감소 메시지인 경우
		        }else{
		        	appendRecvMessage(data); // 일반 메시지인 경우
		        	
		        }
		        
		     
		        

		        
		    }
		    
		    // 소켓 연결이 닫혔을 때 호출되는 함수
		    function onClose(evt) {
		    	window.close();   // 창 닫기
		      }
		    
		    // 접속자 수 표시 함수
		    function writeCount(data){
		    	$(".count").empty();
    			$(".count").append("<span> ("+data+") </span>");
		    }
		    
		    // 귓속말 표시 함수
		    function whisper(msg){
		    	$(".chatt-area").append("<div class='whisper'>"+ msg+"</div>");
		    	scrollTop(); // 스크롤바 아래로 이동
		    }
		    
		     

		    
		    // 메시지 전송 함수
		    function send() {  
		        var msg = $("#message").val(); // 메시지 입력 값    
		        
		        
		        wsocket.send(nickname+" : " + msg); // 서버로 메시지 전송    
		        $("#message").val(""); // 입력 창 비우기
		        
		        //채팅창에 자신이 쓴 메시지 추가 
		        appendSendMessage(msg);
		        
		    }
		    
	    	 // 공지 메시지 표시 함수
		    function noticeMessage(msg){
		
		    	$(".chatt-area").append(msg);
		    	scrollTop(); //스크롤바 아래로 이동

		    }

		    
		    //받은 메시지 채팅창에 추가
		    function appendRecvMessage(msg) {
		        $(".chatt-area").append( "<div class=''>" + msg+"</div>");        
		        scrollTop(); // 스크롤바 아래로 이동
		    }

		    
		    // 스크롤바 아래로 이동 함수
		    function  scrollTop(){
		    	  var chatAreaHeight = $(".chatt-box").height();         
		          var maxScroll = $(".chatt-area").height() - chatAreaHeight;  
		          $(".chatt-box").scrollTop(maxScroll);
		    }
		    
		    //보내는 메시지 채팅창에 추가
		    function appendSendMessage(msg) {  
		        $(".chatt-area").append( "<div class='send' > " + msg+  "</div>"); 
		        scrollTop(); // 스크롤바 아래로 이동
		        
		    }
		    
		    // 메시지 입력 창에서 Enter 키를 눌렀을 때 메시지 전송
		    $(document).on("keypress","#message",function(event){
				   var keycode =  event.keyCode  ;		            
					  
			       if(keycode == '13'){	 // Enter 키 코드
			    	   event.preventDefault(); // 기본 동작 방지
			                send();  // 메시지 전송
			       }  		 
			            event.stopPropagation();  // 상위로 이벤트 전파 막음
			        });
		   
		    

		                // 전송 버튼 클릭 시 메시지 전송
		    			$(document).on("click","#sendBtn",function(){
		    				send();
		    			});
		    			
		    			// 닉네임 입력 창에서 Enter 키를 눌렀을 때 입장 버튼 클릭
		    			$(document).on("keypress","#text27",function(event){
		 				   var keycode =  event.keyCode  ;		            
		 					  
		 			       if(keycode == '13'){	 // Enter 키 코드
		 			    	   event.preventDefault(); // 기본 동작 방지
		 			    	  $('#entrance').click(); // 입장 버튼 클릭
		 			       }  		 
		 			            event.stopPropagation();  // 상위로 이벤트 전파 막음
		 			        });
		    			//입장 버튼 눌렀을때
				        $('#entrance').click(function() { 
				        	nickname = $("#text27").val(); // 닉네임 입력 값
				        	if(nickname == ''){
				        		alert("닉네임을 입력해 주세요"); // 닉네임 미입력 시 경고
				        	}else{
				        		

						    	//접속자 수 증가
								$.ajax({
						    		type : "get",
						    		url : "/project/checkNickname/"+nickname, //닉 중복확인 요청
						    		success:function(data){
						    			if(data > 0){
						    				let msg = "<div class='notice'>*** "+hours+":"+minutes+":"+seconds+" ⟣"+nickname+"⟢님이 입장하였습니다. ***</div>";
											wsocket.send(msg); // 입장 메시지 전송
									    	noticeMessage(msg); // 입장 메시지 표시
									    	wsocket.send("count:"+data);  // 접속자 수 증가 메시지 전송
							    			writeCount(data); // 접속자 수 표시
							    			
							    			$(".open").remove(); /*닉 입력하면 닉 입력양식 제거  */
								        	let str = `<div class="nicknamae-area">
												<span>😊 \${nickname} </span>
												</div>
								        	<div class="text-area">
												<textarea class="ta" id="message"></textarea>
												<button id="sendBtn">전송</button>
											</div>`; /* 채팅입력 인터페이스를 생성후 이를 HTML에 추가 */
											$(".field-row-stacked").append(str);
											$("#message").focus(); //메세지 입력
											window.resizeTo( $('#wrap').width() + (window.outerWidth - window.innerWidth), $('#wrap').height() + (window.outerHeight - window.innerHeight));
							    			
						    			}else{
						    				alert("중복된 닉네임 입니다.");
						    			}
						    			
						    		}
						    		
						    	});
						    	
						    	
						    	
				        	}				        	
				        });

	});
	
</script>
<style>
body {
	font-family: Arial, sans-serif;
	margin: 0;
	padding: 0;
	display: flex;
	justify-content: center;
	background-color: #f0f0f0;
}

#wrap {
	display: flex;
	width: 860px;
	height: 530px;
	background-color: #ffffff;
	border: 1px solid #ccc;
	box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
}

.g-rooms-container, .chat-main {
	display: flex;
	flex-direction: column;
	justify-content: space-between;
}

.g-rooms-container {
	flex: 2;
	display: flex;
	flex-direction: column;
	border-right: 1px solid #ccc;
}





.chat-main {
	flex: 1;
	padding: 10px;
}

.chatt-area {
	border: 2px solid #000; /* 테두리 추가 */
	background-color: #F5DEB3; /* 밝은 베이지색 배경 */
	padding: 10px; /* 내부 여백 */
	overflow-y: scroll; /* 내용이 넘칠 경우 스크롤 추가 */
	height: 100px;
}



.ccu {
	width: 150px;
	padding: 10px;
	border-left: 1px solid #ccc;
}

.ccu-header {
	margin-top: 0;
}

.ccu-list {
	list-style-type: none;
	padding: 0;
	margin: 0;
}

.ccu-list-item {
	padding: 5px 0;
	border-bottom: 1px solid #ccc;
}


.g-rooms {
    flex: 2; /* 가용 공간의 2/3을 차지하도록 설정 */
    padding: 10px;
    display: flex;
    flex-direction: column; /* 세로로 정렬 */
    overflow: hidden; /* 기본적으로 스크롤바 숨김 */
    border-right: 1px solid #ccc; /* 오른쪽 테두리 */
}

.g-header {
    margin: 0; /* 상단 여백 제거 */
}

.room-list-container {
    flex-grow: 1; /* 남은 공간을 차지하도록 설정 */
    overflow-y: auto; /* 내용이 넘칠 때 세로 스크롤바 표시 */
    border: 1px solid #ccc; /* 테두리 추가 */
    padding: 10px; /* 여백 추가 */
    background-color: #f9f9f9; /* 배경색 */
}

/* 기본 ul 스타일 제거 */
.room-list-ul {
    list-style-type: none; /* 왼쪽 점 제거 */
    padding: 0; /* 기본 여백 제거 */
    margin: 0; /* 기본 마진 제거 */
}

/* 각 li 스타일링 */
.room-list-ul li {
    border-bottom: 1px solid #ccc; /* 항목 간 경계선 추가 */
    padding: 9px; /* 안쪽 여백 */
    display: flex; /* 플렉스 레이아웃 사용 */
    align-items: center; /* 수직 정렬 */
}

/* 마지막 항목의 아래 경계선 제거 */
.room-list-ul li:last-child {
    border-bottom: none; /* 마지막 항목의 경계선 제거 */
}

/* room-info의 flex 컨테이너 스타일 */
.room-info {
    display: flex; /* 항목을 가로로 배치 */
    width: 100%; /* 전체 너비 사용 */
    justify-content: space-between; /* 각 항목 간에 공간을 고르게 배치 */
    font-size: 14px;
}

/* 각 항목 스타일 */
.room-count,
.room-title,
.room-character,
.room-nickname {
    padding: 0 10px; /* 좌우 여백 추가 */
}

.room-count{
    flex: 0.7; 
}

.room-title{
	flex: 3;
	white-space: nowrap; /* 텍스트를 한 줄로 표시 */
    overflow: hidden; /* 넘치는 텍스트를 숨김 */
    text-overflow: ellipsis; /* 넘치는 텍스트를 '...'으로 표시 */
}

.room-character{
	flex: 1;
}

.room-nickname{
	flex: 1;
}





/* 항목에 마우스를 올렸을 때 배경색 변경 */
.room-list-ul li:hover {
    background-color: #f0f0f0; /* 마우스 오버 시 배경색 변경 */
}

/* *************상단바  */

 /* 검색창 스타일 */
 
 		.top-bar {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 10px;
        }
 
        #roomSearch {
            flex: 1;
            padding: 8px;
            border: 2px solid #d6b45b;
            border-radius: 4px;
            margin-right: 10px;
        }

        /* 방 만들기 버튼 스타일 */
        #topButtons {
            padding: 6px 10px;
            border: none;
            border-radius: 4px;
            background-color: #d6b45b;
            color: #fff;
            cursor: pointer;
            transition: background-color 0.3s;
            margin-right: 5px;
        }

        /* 버튼 hover 효과 */
        #topButtons:hover {
            background-color: #6f4f28;
        }


        
        
        
        
.room-info-header {
    display: flex;
    justify-content: space-between;
    padding: 4px 10px; /* 상하 4px, 좌우 10px 패딩 설정 */
    width: 645px;
    box-sizing: border-box;
    margin-left: 10px;
    font-size: 14px;
}

.header-room-count,
.header-room-title,
.header-room-character,
.header-room-nickname {
	flex: 1;
    color: #5D3A1F; /* 진갈색 글자 색상 설정 */
    padding: 0 10px;

}

.header-room-count {
    flex: 0.7; 
}

.header-room-title {
    flex: 3; 
}

.header-room-character {
    flex: 1; 
}

.header-room-nickname {
    flex: 1; 
}
    
        
</style>
</head>
<body>
	<div id="wrap">
			<div class="g-rooms-container">
				<div class="g-rooms">
					<div class="top-bar">
			            <input type="text" id="roomSearch" placeholder="방 검색" />
			            <button id="topButtons">방 만들기</button>
			            <button id="topButtons">새로고침</button>
			            <button id="topButtons">내 정보</button>
			        </div>
			         <div class="room-info-header">
		                <span class="header-room-count">인원수</span>
		                <span class="header-room-title">방 제목</span>
		                <span class="header-room-character">아바타</span>
		                <span class="header-room-nickname">닉네임</span>
		            </div>
					<div class="room-list-container">
					<ul class="room-list-ul">
				            <c:forEach items="${r_data}" var="room">
				                <li>
				                    <div class="room-info" onclick="goToRoomDetail(${room.room_id})">
				                        <span class="room-count">${room.user_count}/2</span>
				                        <span class="room-title">${room.room_title}</span>
				                        <span class="room-character">${room.avatar}</span>
				                        <span class="room-nickname">${room.user_nickname}</span>
				                    </div>
				                </li>
				            </c:forEach>
					</ul>
					</div>
				</div>
				<div class="chat-main">
					<div class="window">
						<div class="field-row-stacked" style="width: 100%">
							<!-- 접속자 수 -->
							<div class="count">
								<span> (0)</span>
							</div>
							<div class="chatt-box">
								<div class="chatt-area"></div>
							</div>
							<!-- 닉 입력창 (입력하면 사라짐) -->
							<div class="open">
								<div class="field-row-stacked"
									style="width: 233px; margin: 0 auto;">
									<label for="text27">닉네임</label>
									<div class="input-nickname">
										<input id="text27" type="text" />
										<button type="button" id="entrance">입장</button>
									</div>
								</div>
							</div>
						</div>
					</div>
				</div>
			</div>
			<!-- 접속자 목록 -->
			<div class="ccu">
				<h2 class="ccu-header">접속자</h2>
				<ul class="ccu-list">
					<li class="ccu-list-item">사용자1</li>
					<li class="ccu-list-item">사용자2</li>
					<li class="ccu-list-item">사용자3</li>
				</ul>
			</div>
	</div>
	
	<script>
    function goToRoomDetail(roomId) {
        window.location.href = `roomDetail?id=${roomId}`;
    }
    </script>
</body>
</html>