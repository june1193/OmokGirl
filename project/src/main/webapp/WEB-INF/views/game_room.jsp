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
		
		//소켓 연결
		function connect(){
			wsocket = new WebSocket("ws://localhost:8080/project/chat-tem");
			wsocket.onopen = onOpen; //기본적으로 웹소켓에서 제공하나보다.
			wsocket.onmessage = onStone;
			wsocket.onclose = onClose;
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

/* 채팅 끝 */





/* ********** 상수 선언 ********** */
const STONE_NONE = 0;         // 아무돌도 없는 상태
const STONE_BLACK = 1;        // 흑돌 상태
const STONE_WHITE = 2;        // 백돌 상태

const BOARD_SIZE = 15;        // 게임 사이즈
const CANVAS_SIZE = 500;      // 캔버스 사이즈
const CANVAS_ID = "mycanvas"; // 캔버스 DOM ID
const CANVAS_MARGIN = 20;     // 캔버스 내 판 여백 값(px)
const CANVAS_GAME_SIZE = CANVAS_SIZE - CANVAS_MARGIN*2; // 실제 판 크기(여백 뺀 값)

var board;                        // 판 상태 2차원 배열
var board_stack = new Array();    // 판 착수 순서 스택

var stone_black_color = "black";  // 흑돌 출력용 CSS 색깔 문자열
var stone_white_color = "white";  // 백돌 출력용 CSS 색깔 문자열

var gamestart = false;            // 게임 시작 여부
var blackturn = true;             // 게임 턴 차례
var whitefirst = false;           // 백돌 선수 여부
var gamestart_time = '';          // 게임 시작 시간 저장용
var gameend_time = '';            // 게임 종료 시간 저장용



// 현재 시간 알아오는 함수
function getTimeStamp() {
var d = new Date();
var s =
    leadingZeros(d.getFullYear(), 4) + '-' +
    leadingZeros(d.getMonth() + 1, 2) + '-' +
    leadingZeros(d.getDate(), 2) + ' ' +

    leadingZeros(d.getHours(), 2) + ':' +
    leadingZeros(d.getMinutes(), 2) + ':' +
    leadingZeros(d.getSeconds(), 2);

return s;
}
// 현재 시간 알아오는 함수 문자열 보조 처리
function leadingZeros(n, digits) {
var zero = '';
n = n.toString();

if (n.length < digits) {
    for (i = 0; i < digits - n.length; i++)
    zero += '0';
}
return zero + n;
}



/* ********** 게임 초기화 관련 ********** */
// 판 초기화
function init_board(){
// 게임판 2차원 배열 및 스택 선언
board = new Array();
board_stack = new Array();

// board 2차원 배열 초기화
for(var i=0; i<BOARD_SIZE; i++){
    board[i] = new Array();
    for(var j=0; j<BOARD_SIZE; j++){
    board[i][j] = STONE_NONE; // 각 칸을 돌며 돌이 없는 상태로 초기화
    }
}
}
// 게임 상태 초기화
function init_game(){
blackturn = true;
}



/* ********** 게임 상태 질의 관련 ********** */
// 디버그 모드 질의
function is_debugmode(){
return false; // 디버그 모드인지 여부를 반환 (현재는 항상 false를 반환)
}
// 게임 시작 여부 질의
function is_gamestart(){
return gamestart; // 게임이 시작되었는지 여부를 반환
}
// 선수 색깔 질의
function is_whitefirst(){
return whitefirst; // 흰 돌이 먼저 시작하는지 여부를 반환
}
// 게임 턴 차례 질의
function is_blackturn(){
return blackturn; // 현재 턴이 검은 돌 차례인지 여부를 반환
}



/* ********** 게임 상태 관련 ********** */
// 선수 바꾸기 루틴
function change_first(){
whitefirst = !whitefirst; // whitefirst 변수를 반전시켜 첫 번째 플레이어를 바꿈
if(whitefirst){
    stone_white_color = "black";
    stone_black_color = "white";
}else{
    stone_white_color = "white";
    stone_black_color = "black";
}
}


// 게임 승리 루틴
function win_game(_stone){  // 게임 승리 관련 처리 루틴
gameend_time = getTimeStamp(); // 게임이 끝난 시간을 기록
print_winmsg(_stone); // 승리 메시지를 출력
end_game(); //게임을 종료
}



/* ********** 이벤트 핸들러, 인터페이스 ********** */
// 게임 시작 처리 루틴
function start_game(){
document.getElementById("start_button").disabled = true; // "start_button" 버튼을 비활성화
document.getElementById("retire_button").disabled = false;  // "retire_button" 버튼을 활성화
document.getElementById("blackfirst").disabled = true;  // "blackfirst" 라디오 버튼을 비활성화
document.getElementById("whitefirst").disabled = true; // "whitefirst" 라디오 버튼을 비활성화
init_board(); // 게임판을 초기화
init_game(); // 게임 상태를 초기화
stroke_board(); // 보드를 그리기
gamestart = true; // 게임 시작 상태를 true로 설정
gamestart_time = getTimeStamp(); // 게임 시작 시간을 기록
}
// 게임 기권 처리 루틴
function retire_game(){
if(is_blackturn())
    win_game(STONE_WHITE);
else
    win_game(STONE_BLACK);
}
// 게임 종료 처리 루틴
function end_game(){
gamestart = false; // 게임 시작 상태를 false로 설정
gamestart_time = ''; // 게임 시작 시간을 빈 문자열로 초기화
gameend_time = ''; // 게임 종료 시간을 빈 문자열로 초기화
document.getElementById("start_button").disabled = false; //각종 버튼 초기화
document.getElementById("back_button").disabled = true;
document.getElementById("retire_button").disabled = true;
document.getElementById("blackfirst").disabled = false;
document.getElementById("whitefirst").disabled = false;
};



//보내는 돌 좌표 채팅창에 추가
function appendSendStone(msg) {  
    $(".chatt-area").append( "<div class='send' > " + msg+  "</div>");   
}


// 백돌 로그 전송 함수
function send_white(y,x) {  
    var msg = "white " + y + "," + x; // 매개변수로 받은 좌표 정보 
    wsocket.send(msg); // 서버로 메시지 전송    
    //채팅창에 로그 메시지 추가 
    appendSendStone(msg);
    
}

// 흑돌 로그 전송 함수
function send_black(y,x) {  
    var msg = "black " + y + "," + x; // 매개변수로 받은 좌표 정보 
    wsocket.send(msg); // 서버로 메시지 전송    
    //채팅창에 로그 메시지 추가 
    appendSendStone(msg);
    
}




// 착수 루틴 (나중에 상대턴에는 돌을 둘 수 없게 만들어야 함)
function put_stone(e){
if(!is_gamestart()) // 게임이 진행 중이지 않을 경우 함수 종료
    return;

var x = 0;
var y = 0;
// 좌표계에서의 판 한칸 크기 저장용 변수
var sz = (CANVAS_GAME_SIZE / (BOARD_SIZE-1));

// 가장 가까운 교점에서 떨어진 좌표 오프셋 구하기
var a = (e.offsetX - CANVAS_MARGIN) % sz;
var b = (e.offsetY - CANVAS_MARGIN) % sz;

// 가장 가까운 교점 좌표로 조정 시켜주는 로직
if(a <= sz/2){
    x = e.offsetX - a - 1;
}else{
    x = e.offsetX + (sz-a) - 1;
}
if(b <= sz/2){
    y = e.offsetY - b - 1;
}else{
    y = e.offsetY + (sz-b) - 1;
}

// 소수점 반올림 처리
x = Math.round(x / sz);
y = Math.round(y / sz);

// 판 넘어가기 방지용 루틴
if(x > BOARD_SIZE)
    x = BOARD_SIZE;
if(y > BOARD_SIZE)
    y = BOARD_SIZE;

// 좌표계와 배열인덱스 차이 빼주기
if(x-1 >= 0)
    x = x-1;
if(y-1 >= 0)
    y = y-1;

// 디버그 모드 비활성화 이면서 놓은 자리에 돌이 없을 경우
if(!is_debugmode() && board[y][x] == STONE_NONE){
    var tmp_color = -1;

    // 현재 턴 차례에 맞게 흑백 구분
    if(blackturn)
    tmp_color = STONE_BLACK;
    else
    tmp_color = STONE_WHITE;

    // 금수 판정 위해 일단 판에 착수 시행
    board[y][x] = tmp_color;
    
    //여기에 메세지를 전송하는 로직을 넣어야 할듯?
    if(blackturn)
    send_black(y,x);
    else
    send_white(y,x);
		  
		  
    // 돌이 한개라도 판에 놓여진 순간 무르기 버튼 활성화

    if(board_stack.length != 0)
    document.getElementById("back_button").disabled = false;

    var result = check_pointer(x, y, tmp_color, board);
    
    
    // 정상적인 착수 판정 받았을 경우
    if(result == null){
    blackturn = !blackturn; //턴이 넘어감
    board_stack.push([x, y, tmp_color]); // 돌순서 스택에 푸시
    }
    // 금수 판정 받았을 경우
    else if(result == false){
    board[y][x] = STONE_NONE;
    appendSendStone("6목은 금수 입니다.");
    }
    // 승리 판정 받았을 경우
    else if(result == true){
    board_stack.push([x, y, tmp_color]); // 돌순서 스택에 푸시
    if(is_blackturn())
        win_game(STONE_BLACK);
    else
        win_game(STONE_WHITE);
    }
    
    
    // 보드판 재 표시
    print_board(board);
}
}



//서버에서 온 돌 착수 함수
function placeServerStone(command, x, y) {
	 // 좌표가 범위 내에 있는지 확인
    if (x < 0 || x >= BOARD_SIZE || y < 0 || y >= BOARD_SIZE) {
        console.error("Invalid coordinates:", x, y);
        return;
    }

    var stoneColor = (command === 'black') ? STONE_BLACK : STONE_WHITE;

    // 해당 좌표에 돌을 놓습니다
    if (board[y][x] === STONE_NONE) { // 빈 자리에만 놓을 수 있음
        board[y][x] = stoneColor;

        // 보드에 돌을 놓은 후 게임 진행 상황을 업데이트합니다
        var result = check_pointer(x, y, stoneColor, board);
        
        if (result === null) {
            // 정상적인 착수
            blackturn = !blackturn; // 턴을 전환합니다
            board_stack.push([x, y, stoneColor]); // 돌 순서 스택에 푸시
        } else if (result === false) {
            // 금수
            board[y][x] = STONE_NONE; // 착수한 돌을 제거합니다
            appendSendStone("6목은 금수 입니다.");
        } else if (result === true) {
            // 승리
            board_stack.push([x, y, stoneColor]); // 돌 순서 스택에 푸시
            if (stoneColor === STONE_BLACK) {
                win_game(STONE_BLACK);
            } else {
                win_game(STONE_WHITE);
            }
        }

        // 보드판을 다시 표시합니다
        print_board(board);
    }
}



 //착수 메세지 수신 함수
function onStone(evt) {
    var data = evt.data; // 받은 데이터
    var message = data.split(" "); // 메시지를 공백으로 분리
    var command = message[0]; // 명령어 (예: "white", "black")
    
    if (command === 'white' || command === 'black') {
        // 좌표를 추출합니다
        var coordinates = message.slice(1).join(" "); // 나머지 부분을 좌표로 합칩니다
        var coords = coordinates.split(","); // 좌표를 ','로 분리
        var y = parseInt(coords[0].trim()); // y 좌표
        var x = parseInt(coords[1].trim()); // x 좌표

        // 해당 좌표에 돌을 놓습니다
        placeServerStone(command, x, y);
    }else {
        appendRecvMessage(data); // 일반 메시지인 경우
    }
}







// 무르기 루틴
function delete_stone(e){
if(confirm('한수 물러주시겠습니까?')){
    // 기보 스택에서 수 제거
    node = board_stack.pop();
    // 판 배열에서 수 제거
    board[node[1]][node[0]] = STONE_NONE;
    blackturn = !blackturn;
    print_board(board);
}
}
// 브라우저 종료 루틴
function exit_game(e){
window.close();
}



/* ********** 게임 표시 관련 ********** */
// 판 그리기 루틴
function stroke_board(){
var mycanvas = document.getElementById(CANVAS_ID);
var context = mycanvas.getContext("2d");

// 판 배경색 그리기
context.fillStyle = "#e0e0e0";
context.fillRect(0, 0, CANVAS_SIZE, CANVAS_SIZE);
// 칸 경계선들 그리기
context.strokeStyle = "#6e6e6e";
context.lineWidth = 1.5; // 선의 두께 설정
for(var x=CANVAS_MARGIN; x<=CANVAS_SIZE - CANVAS_MARGIN*2; x+=(CANVAS_GAME_SIZE/(BOARD_SIZE - 1))) {
    for(var y=CANVAS_MARGIN; y<=CANVAS_SIZE - CANVAS_MARGIN*2; y+=(CANVAS_GAME_SIZE/(BOARD_SIZE - 1))) {
    context.strokeRect(x, y, ((CANVAS_SIZE - CANVAS_MARGIN)/(BOARD_SIZE - 1)), ((CANVAS_SIZE - CANVAS_MARGIN)/(BOARD_SIZE - 1)));
    }
}

// 바둑판 외곽선을 그립니다.
context.strokeStyle = "#000000"; // 외곽선 색상
context.lineWidth = 2; // 외곽선 두께

// 전체 바둑판의 외곽선을 그립니다.
context.beginPath();
context.rect(CANVAS_MARGIN - 1, CANVAS_MARGIN - 1, CANVAS_GAME_SIZE + 2, CANVAS_GAME_SIZE + 2);
context.stroke();

context.beginPath();
context.closePath();
/* context.fillStyle = "#000000";
context.fill(); */
}
// 돌 그리기 루틴
function fillStone2(_x,_y,_stone){
var mycanvas = document.getElementById(CANVAS_ID);
var context = mycanvas.getContext("2d");

context.beginPath();
var stone_size = (CANVAS_GAME_SIZE/(BOARD_SIZE - 1));
// 돌 그릴 좌표에 판 끄트머리 여백 좌표 만큼 더하는 처리들
var x=_x*stone_size+CANVAS_MARGIN;
var y=_y*stone_size+CANVAS_MARGIN;

context.arc(x, y, stone_size/2.2, 0, Math.PI*2);
context.closePath();

// 선수 변경시 사용자에게 보이는 색깔만 변경
if(_stone==STONE_BLACK)
    context.fillStyle = stone_black_color;
else if(_stone==STONE_WHITE)
    context.fillStyle = stone_white_color;

context.fill();

// 하이라이트 추가 (오리지널)
var radius = stone_size / 2;
context.beginPath();
context.arc(x, y, radius * 0.7, Math.PI * 0.7, Math.PI * 1.3); // 하이라이트의 영역
context.lineWidth = 2; // 하이라이트 두께
context.strokeStyle = 'rgb(203, 203, 203)'; // 하이라이트 색상
context.stroke();

};
// 판 출력 인터페이스
function print_board(_board){
stroke_board(); 	 // 칸 경계선 그리기

var mycanvas = document.getElementById("mycanvas");
var context = mycanvas.getContext("2d");

context.beginPath();
context.closePath();
/* context.fillStyle = "#000000"; */
context.fill();

// 현재 판 상태 배열을 참조하여 판에 돌들 그려주는 루틴
for(var _x=0;_x<BOARD_SIZE;_x++)
    for(var _y=0;_y<BOARD_SIZE;_y++)
    {
        if(_board[_x][_y]==STONE_BLACK)
        fillStone2(_y,_x, STONE_BLACK);
        else if(_board[_x][_y]==STONE_WHITE)
        fillStone2(_y,_x, STONE_WHITE);
    }
};
// 승리 메시지 출력 인터페이스
function print_winmsg(_stone){
if(_stone == STONE_BLACK){
    if(is_whitefirst()){  // 백이 선수 일 경우(흑백 색깔 바뀌었을 경우)
    print_gamelog('(' + gamestart_time + ' ~ ' + gameend_time + ') 백 ' + board_stack.length + ' 수만에 승리');
    }else{ // 흑이 선수 일 경우(흑백 색깔 그대로)
    print_gamelog('(' + gamestart_time + ' ~ ' + gameend_time + ') 흑 ' + board_stack.length + ' 수만에 승리');
    }
}else if(_stone == STONE_WHITE){
    if(is_whitefirst()){  // 백이 선수 일 경우(흑백 색깔 바뀌었을 경우)
    print_gamelog('(' + gamestart_time + ' ~ ' + gameend_time + ') 흑 ' + board_stack.length + ' 수만에 승리');
    }else{ // 흑이 선수 일 경우(흑백 색깔 그대로)
    print_gamelog('(' + gamestart_time + ' ~ ' + gameend_time + ') 백 ' + board_stack.length + ' 수만에 승리');
    }
}
}
// 게임 로그 출력 함수
function print_gamelog(message){
document.querySelector("textarea[name=gamelog]").value += message + '\r\n';
};








/* ********** 게임 로직 관련 ********** */
// 착수,금수 처리 루틴
function check_pointer(x, y, stoneColor, board) {
    // 좌표가 보드의 범위 내에 있는지 확인
    if (x < 0 || x >= BOARD_SIZE || y < 0 || y >= BOARD_SIZE) {
        return false;
    }

    // 현재 돌의 색상으로 체크할 방향 설정
    const directions = [
        { dx: 1, dy: 0 },   // 가로
        { dx: 0, dy: 1 },   // 세로
        { dx: 1, dy: 1 },   // 대각선 하향
        { dx: 1, dy: -1 }   // 대각선 상향
    ];

    // 4 방향으로 5목/6목 체크
    for (const dir of directions) {
        const { dx, dy } = dir;

        // 현재 돌을 기준으로 좌우로 5목, 6목 체크
        let count = 1;

        // 왼쪽 방향으로 돌 수 세기
        for (let step = 1; step < 6; step++) {
            const nx = x - step * dx;
            const ny = y - step * dy;
            if (nx < 0 || nx >= BOARD_SIZE || ny < 0 || ny >= BOARD_SIZE || board[ny][nx] !== stoneColor) {
                break; //이동한 좌표 (nx, ny)가 보드의 경계를 벗어나거나, 돌의 색상이 다른 경우에는 루프를 종료
            }
            count++;
        }

        // 오른쪽 방향으로 돌 수 세기
        for (let step = 1; step < 6; step++) {
            const nx = x + step * dx;
            const ny = y + step * dy;
            if (nx < 0 || nx >= BOARD_SIZE || ny < 0 || ny >= BOARD_SIZE || board[ny][nx] !== stoneColor) {
                break;
            }
            count++;
        }

        // 6목 이상이면 금수
        if (count >= 6) {
            return false;
        }

        // 5목이면 승리
        if (count === 5) {
            return true;
        }
    }

    // 5목도, 6목도 아니면 정상 착수
    return null;
}
</script>
<!-- 간단한 선행 처리 자바스크립트 -->
<script>
window.onload = function() {
stroke_board(); // 보드 그리기
// 이벤트 핸들러 등록
document.getElementById("mycanvas").onclick = put_stone;       // 캔버스 클릭 핸들러 등록
document.getElementById("start_button").onclick = start_game;  // 시작 버튼 클릭 핸들러 등록
document.getElementById("retire_button").onclick = retire_game;// 기권 버튼 클릭 핸들러 등록
document.getElementById("back_button").onclick = delete_stone; // 무르기 버튼 클릭 핸들러 등록
document.getElementById("exit_button").onclick = exit_game;    // 종료 버튼 클릭 핸들러 등록
// 선수 변경 라디오 버튼 핸들러 등록
document.querySelectorAll("input[type=radio][name=who_first]")[0].onchange = function(){
    change_first();
};
// 선수 변경 라디오 버튼 핸들러 등록
document.querySelectorAll("input[type=radio][name=who_first]")[1].onchange = function(){
    change_first();
};

// 엘리먼트 초기 상태 지정
document.getElementById("back_button").disabled = true;        // 무르기 버튼 비활성화
document.getElementById("retire_button").disabled = true;      // 기권 버튼 비활성화

}

/* 오목 끝 */


	
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
	height: 780px; /* 원래 높이는 530이다. */
	background-color: #ffffff;
	border: 1px solid #ccc;
	box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
	box-sizing: border-box; /* 박스 사이징 설정 */
}

#checkerboard {
	width: 500px;
	height: 500px;
	border: 1px solid #ccc;
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
	width: 360px;
	padding: 10px;
	border-left: 1px solid #ccc;
}
</style>
</head>
<body>
	<div id="wrap">
		<div class="g-rooms-container">
			<div id="checkerboard">
				<canvas id="mycanvas" width="500" height="500"></canvas>
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
		<!-- 채팅창 및 버튼들 -->
		<div class="ccu">
			<div class="right">
				<div class="boxframe">
					<div class=box>
						<form>
							<input id="blackfirst" type="radio" name="who_first"
								value="black" checked /> 흑 선수<br> <input id="whitefirst"
								type="radio" name="who_first" value="white" /> 백 선수 <input
								id="back_button" type="button"
								class="btn yellow small text-color-reverse" value="무르기" />
						</form>
					</div>
					<div class=box2>
						<input id="start_button" type="button" class="btn blue"
							value="시 작" />
					</div>
					<div class=box3>
						<input id="retire_button" type="button" class="btn gray"
							value="기 권" />
					</div>
					<div class=box4>
						<!-- 	    게임 로그 출력용 textarea -->
						<textarea name="gamelog" rows="19" cols="35" readonly></textarea>
					</div>
					<div class=box5>
						<input id="exit_button" type="button" class="btn red" value="종 료" />
					</div>
				</div>
			</div>
		</div>
	</div>
</body>
</html>