<%@ page contentType="text/html; charset=UTF-8" trimDirectiveWhitespaces="true"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<title>채팅</title>
<script src="https://ajax.googleapis.com/ajax/libs/jquery/3.5.1/jquery.min.js"></script>
<link rel="stylesheet" href="https://unpkg.com/7.css">
<script type="text/javascript">

var today = new Date();   
var hours = today.getHours(); // 시
var minutes = today.getMinutes();  // 분
var seconds = today.getSeconds(); 
var wsocket;


  
	$(document).ready(function(){
		

	      //창크기 조절
	      window.resizeTo( $('#wrap').width() + (window.outerWidth - window.innerWidth), $('#wrap').height() + (window.outerHeight - window.innerHeight));
	      
	      
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
							    			
							    			$(".header").append("<button id='exitBtn'>나가기</button>");
							    			$(".open").remove();
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
				        $(document).on("click","#exitBtn",function(){
				        	disconnect();
				        });
				        

			   
	});
</script>
<style>
.whisper{
color: #5f9dff;
}
::-webkit-scrollbar {
width: 14px
}

::-webkit-scrollbar:horizontal {
height: 14px
}

::-webkit-scrollbar-corner {
background: #eee
}

::-webkit-scrollbar-track:vertical {
background: linear-gradient(90deg, #e5e5e5, #f0f0f0 20%);
border-radius: 5px; 
}

::-webkit-scrollbar-track:horizontal {
background: linear-gradient(180deg, #e5e5e5, #f0f0f0 20%);
border-radius: 5px; 
}

::-webkit-scrollbar-thumb {
border: 1.5px solid #888;
border-radius: 5px;
box-shadow: inset 0 -1px 1px #fff, inset 0 1px 1px #fff;
}

::-webkit-scrollbar-thumb:vertical {
background: linear-gradient(90deg, #eee 45%, #ddd 0, #bbb);
}

::-webkit-scrollbar-thumb:horizontal {
background: linear-gradient(180deg, #eee 45%, #ddd 0, #bbb);
}

::-webkit-scrollbar-button:horizontal:end:increment,
::-webkit-scrollbar-button:horizontal:start:decrement,
::-webkit-scrollbar-button:vertical:end:increment,
::-webkit-scrollbar-button:vertical:start:decrement {
display: block
}

::-webkit-scrollbar-button:vertical {
height: 15px
}

::-webkit-scrollbar-button:vertical:start:decrement {
background: white;
background: url("https://dl.dropbox.com/s/n9ji42h9hdgdtpc/scroll3.png"), #eee;
background-repeat: no-repeat;
background-position: center;
-moz-background-size: 100% auto, cover;
-webkit-background-size: 100% auto, cover;
-o-background-size: 100% auto, cover;
background-size: 100% auto, cover;
border: 1.5px solid #888;
border-radius: 5px;
}

::-webkit-scrollbar-button:vertical:start:increment {
display: none;
}

::-webkit-scrollbar-button:vertical:end:decrement {
display: none;
}

::-webkit-scrollbar-button:vertical:end:increment {
background: white;
background: url("https://dl.dropbox.com/s/cdcco6pih7n1lae/scroll4.png"), #eee;
background-repeat: no-repeat;
background-position: center;
-moz-background-size: 100% auto, cover;
-webkit-background-size: 100% auto, cover;
-o-background-size: 100% auto, cover;
background-size: 100% auto, cover;
border: 1.5px solid #888;
border-radius: 5px;
}
  
::-webkit-scrollbar-button:horizontal {
width: 14px
}
::-webkit-scrollbar-button:horizontal:start:increment {
display: none;
}
::-webkit-scrollbar-button:horizontal:end:decrement {
display: none;
}

::-webkit-scrollbar-button:horizontal:start:decrement {
background: white;
background: url("https://dl.dropbox.com/s/xcm618ghd823271/scroll5.png"), linear-gradient(180deg, #e5e5e5, #f0f0f0 20%);
background-repeat: no-repeat;
background-position: center;
-moz-background-size: 100% auto, cover;
-webkit-background-size: 100% auto, cover;
-o-background-size: 100% auto, cover;
background-size: 100% auto, cover;
background-position: center;
border-radius: 5px;
border: 1.5px solid #888;
}
  
::-webkit-scrollbar-button:horizontal:end:increment {
background: white;
background: url("https://dl.dropbox.com/s/byeyi7am889ii9m/scroll6.png"), linear-gradient(180deg, #e5e5e5, #f0f0f0 20%);
background-repeat: no-repeat;
background-position: center;
-moz-background-size: 100% auto, cover;
-webkit-background-size: 100% auto, cover;
-o-background-size: 100% auto, cover;
background-size: 100% auto, cover;
background-position: center;
border-radius: 5px;
border: 1.5px solid #888;
}
@font-face{
font-family:'galmuri';
src: url("https://dl.dropbox.com/scl/fi/04xgoywdcv1ur75r0aab9/Galmuri9.ttf?rlkey=8grum6yndvy7f69aeiec5of4r&st=yfhw1a6x");
}
*{
font-family: 'galmuri';
font-size: 10px;
}
.notice{
text-align: center;
    color: red;
}

.send{
    text-align:right;
    color: #ed778c;
    
 }
 
 .recv{
    border:1px solid yellow;
    color:blue;
    text-align:left;
    padding:10px;
 }
 #wrap{
 	width: 400px;
 	
 }
 .window:before{
 	background: linear-gradient(transparent 20%,#ffffffb3 40%,transparent 41%),linear-gradient(90deg,#ffffff66,#0000001a,#ffffff33),#f9a8d1;
 }
 .title-bar{
 	background: linear-gradient(90deg, #ffffff66, #0000001a, #ffffff33), #f9a8d1;
 }
 .title-bar.active .title-bar-controls button.is-maximize:before, .title-bar.active .title-bar-controls button[aria-label=Maximize]:before, .window.active .title-bar .title-bar-controls button.is-maximize:before, .window.active .title-bar .title-bar-controls button[aria-label=Maximize]:before{
 background: url(data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAwAAAAKCAYAAACALL/6AAAACXBIWXMAAAsTAAALEwEAmpwYAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAABsSURBVHgBlZHBCYAwDEVT6YaKbqArOILgBLqBosP1VkhAaQ6S1lKad+ihPy8kxLT9+IACG57r2KqKu2GCBpTYtEMOOQELzrnv4z53I4vDjjJnwXsPJWTOAiJGHVNB5pGwLjPk+AlEBLUY7eFebCosBHOR7vYAAAAASUVORK5CYII=) no-repeat 50%, radial-gradient(circle at bottom, #da2a2a, transparent 65%), linear-gradient(#fdc3d0 50%, #ffa1a9 0);
 box-shadow: 0 0 7px 3px #f05dad, inset 0 0 0 1px #fffa;
 }
 [role=button]:after, button:after{
 background : linear-gradient(180deg, #fce5f9, #f8ade1 30% 50%, #f285c1 50%, #f2498e);
 }
 .window-body{
 background: #ffeded;
 }
 body{
 margin: 0;
 }
 .header{
 	display: flex;
 	justify-content: space-between;
 }
 .chatt-box{
 background-color: #fff;
    border: 1px solid #ccc;
    border-radius: 2px;
    border-top-color: #8e8f8f;
    box-sizing: border-box;
    font: 9pt Segoe UI, SegoeUI, Noto Sans, sans-serif;
    padding: 3px 4px 5px;
 height: 330px;
    overflow-y: auto; }
 .chatt-area{
 	
    
 }
.text-area{
	display: flex;
}
.text-area > textarea{
width: 100%;
resize: none;
}
.text-area > button{
max-height: 100%;
margin: 0;
}
.input-nickname{
display: flex;
align-items: center;
justify-content: space-between;
}
.input-nickname > button{
margin: 0;
}
.open{
background-color: #ffbfe0;
padding: 10px 0;
border-radius: 2px;
border: 1px solid #ccc;
border-top-color: #8e8f8f;
}
.icon{
display: flex;
align-items: center;
}
#exitBtn{
margin: 0;
}
</style>
</head>
<body>
	<div id="wrap">
		<div class="window active" style="max-width: 400px">
			<div class="title-bar">
				<div class="title-bar-text">배드민턴을 사랑하는 사람들의 채팅방</div>
				<div class="title-bar-controls">
					<button aria-label="Minimize"></button>
					<button aria-label="Maximize"></button>
					<button aria-label="Close"></button>
				</div>
			</div>
			<div class="window-body has-space">
				<div class="field-row-stacked" style="width: 100%">
					<div class="header">
						<div class="icon">
							🏸🤍
							<div class="count">
								<span> (0)</span>
							</div>
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