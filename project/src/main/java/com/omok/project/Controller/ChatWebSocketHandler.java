package com.omok.project.Controller;

import java.io.IOException;
import java.util.Date;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

import org.springframework.web.socket.CloseStatus;
import org.springframework.web.socket.TextMessage;
import org.springframework.web.socket.WebSocketSession;
import org.springframework.web.socket.handler.TextWebSocketHandler;

public class ChatWebSocketHandler extends TextWebSocketHandler {
 
    private Map<String, WebSocketSession> users = new ConcurrentHashMap<>();

    @Override
    public void afterConnectionEstablished(WebSocketSession session) throws Exception {        
        log(session.getId() + "�����"); 
       
        users.put(session.getId(), session);
        
    }

    @Override
    public void afterConnectionClosed(WebSocketSession session, CloseStatus status) throws Exception {
        log(session.getId() + "���� �����");
       
        users.remove(session.getId());
        
    }
    
    @Override
    protected void handleTextMessage(WebSocketSession session, TextMessage message) throws Exception {
        log(session.getId() + "�� ���� �޽��� ����: " + message.getPayload());
        String current = session.getId(); 
        for (WebSocketSession s : users.values()) {   
              if(  !s.getId().equals(current)) { 
            		s.sendMessage(message);		        
		            log(s.getId() + "�� �޽��� �߼�: " + message.getPayload());
              }             
        }
    }

    @Override
    public void handleTransportError(WebSocketSession session, Throwable exception) throws Exception {
        log(session.getId() + " �ͼ��� �߻�: " + exception.getMessage());
    }

    private void log(String logmsg) {
        System.out.println(new Date() + " : " + logmsg);
    }


 
}