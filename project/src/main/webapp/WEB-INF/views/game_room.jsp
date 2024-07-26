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


  
	$(document).ready(function(){
		

	      
		//닉네임가져오기
		var nickname = $("#uId").val();
		
		//만약 session이 null이면 닉네임 입력창 뜨게, 닉네임 입력 안하고 전송하면 입력하라고 유효성 검사
			$.ajax({
	        	type : "get",
	        	url : "/project/getCount",
	        	success :function(data){
	        		writeCount(data);
	        	}
	        });
		connect();
		
		//소켓 연결
		function connect(){
			wsocket = new WebSocket("ws://localhost:8080/project/chat-ws");
			wsocket.onopen = onOpen;
			wsocket.onmessage = onMessage;
			wsocket.onclose = onClose;
		}
		
		var disConnect = false;
		 function disconnect() {
				disConnect = true;
		        let today = new Date(); 
		    	let hours = today.getHours(); // 시
				let minutes = today.getMinutes();  // 분
				let seconds = today.getSeconds(); //초
		    	let msg = "<div class='notice'>*** "+hours+":"+minutes+":"+seconds+" ༺"+nickname+"༻님이 퇴장하였습니다. ***</div>";
		    	wsocket.send(msg);
				//퇴장시 카운트 감소
		    	$.ajax({
		    		type : "get",
		    		url : "/project/deleteNickname/"+nickname,
		    		success:function(data){
		    			wsocket.send("감소count:"+data); //상대방한테 보내는 메세지
		    			writeCount(data); //내 화면 카운트 감소
		    			wsocket.close(); //onclose()호출
		    		}
		    		
		    	});
		    	        
		    }
		 
			
		 window.addEventListener('beforeunload', (event) => {
			  // 표준에 따라 기본 동작 방지
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
					    	wsocket.send(msg);
			    			wsocket.send("감소count:"+data); //상대방한테 보내는 메세지
			    			writeCount(data); //내 화면 카운트 감소
			    		}
			    		
			    	});
			  }
			});
		 
		
		 

		 
			 
		        
		     
		 	//소켓 연결되면 실행됨
		    function onOpen(evt) {
		    	
		    }
		     
		    //상대방한테 메세지 받으면 실행됨
		    function onMessage(evt) {
		        var data = evt.data;
		        var message = data.split(":");
		        var sender = message[0];
		        var content = message[1];
		        let msg = content.trim().charAt(0);
		        if (msg === '/') { //귓속말 
					if(content.match("/"+nickname)){
						var temp = content.replace(("/"+nickname), "[귓속말] "+sender+" : ");
						whisper(temp);
					}
		        }else if (data.match("notice")) {
		        	noticeMessage(data);
		        }else if(sender === 'count'){
		        	writeCount(content);
		        }else if(sender === '감소count'){
		        	writeCount(content);
		        }else{
		        	appendRecvMessage(data);
		        	
		        }
		        
		     
		        

		        
		    }
		    
		    function onClose(evt) {
		    	window.close();   
		      }
		    
		    function writeCount(data){
		    	$(".count").empty();
    			$(".count").append("<span> ("+data+") </span>");
		    }
		    
		    function whisper(msg){
		    	$(".chatt-area").append("<div class='whisper'>"+ msg+"</div>");
		    	scrollTop();
		    }
		    
		     

		    
		   
		    function send() {  
		        var msg = $("#message").val();       
		        
		        
		        wsocket.send(nickname+" : " + msg);        
		        $("#message").val("");
		        
		        //채팅창에 자신이 쓴 메시지 추가 
		        appendSendMessage(msg);
		        
		    }
		    
		    function noticeMessage(msg){
		
		    	$(".chatt-area").append(msg);
		    	scrollTop();	   

		    }

		    
		    //받는 메시지 채팅창에 추가
		    function appendRecvMessage(msg) {
		        $(".chatt-area").append( "<div class=''>" + msg+"</div>");        
		        scrollTop();
		    }

		    
		    function  scrollTop(){
		    	  var chatAreaHeight = $(".chatt-box").height();         
		          var maxScroll = $(".chatt-area").height() - chatAreaHeight;  
		          $(".chatt-box").scrollTop(maxScroll);
		    }
		    
		    //보내는 메시지 채팅창에 추가
		    function appendSendMessage(msg) {  
		        $(".chatt-area").append( "<div class='send' > " + msg+  "</div>"); 
		        scrollTop();
		        
		    }
		    
		    $(document).on("keypress","#message",function(event){
				   var keycode =  event.keyCode  ;		            
					  
			       if(keycode == '13'){	
			    	   event.preventDefault();
			                send(); 
			       }  		 
			            event.stopPropagation();  // 상위로 이벤트 전파 막음
			        });
		   
		    

		       
		    			$(document).on("click","#sendBtn",function(){
		    				send();
		    			});
		    			
		    			$(document).on("keypress","#text27",function(event){
		 				   var keycode =  event.keyCode  ;		            
		 					  
		 			       if(keycode == '13'){	
		 			    	   event.preventDefault();
		 			    	  $('#entrance').click();
		 			       }  		 
		 			            event.stopPropagation();  // 상위로 이벤트 전파 막음
		 			        });
		    			//입장 버튼 눌렀을때
				        $('#entrance').click(function() { 
				        	nickname = $("#text27").val();
				        	if(nickname == ''){
				        		alert("닉네임을 입력해 주세요");
				        	}else{
				        		

						    	//접속자 수 증가
								$.ajax({
						    		type : "get",
						    		url : "/project/checkNickname/"+nickname,
						    		success:function(data){
						    			if(data > 0){
						    				let msg = "<div class='notice'>*** "+hours+":"+minutes+":"+seconds+" ⟣"+nickname+"⟢님이 입장하였습니다. ***</div>";
											wsocket.send(msg);
									    	noticeMessage(msg);
									    	wsocket.send("count:"+data);
							    			writeCount(data);
							    			
							    			$(".open").remove(); /*닉 입력하면 닉 입력양식 제거  */
								        	let str = `<div class="nicknamae-area">
												<span>😊 \${nickname} </span>
												</div>
								        	<div class="text-area">
												<textarea class="ta" id="message"></textarea>
												<button id="sendBtn">전송</button>
											</div>`;
											$(".field-row-stacked").append(str);
											$("#message").focus();
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
        .chatt-box {
            border: 2px solid #000; /* 테두리 추가 */
            background-color: #D2B48C; /* 진한 베이지색 배경 */
            padding: 10px; /* 내부 여백 */
        }

        .chatt-area {
            border: 2px solid #000; /* 테두리 추가 */
            background-color: #F5DEB3; /* 밝은 베이지색 배경 */
            padding: 10px; /* 내부 여백 */
            height: 300px; /* 높이 설정 */
            overflow-y: scroll; /* 내용이 넘칠 경우 스크롤 추가 */
        }
    </style>
</head>
<body>
	<div id="wrap">
		<div class="window active" style="max-width: 400px">
			<div class="window-body has-space">
				<div class="field-row-stacked" style="width: 100%">
					<div class="header">
						<div class="count">
							<span> (0)</span>
						</div>
					</div>
					<div class="chatt-box">
						<div class="chatt-area"></div>
					</div>
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
</body>
</html>