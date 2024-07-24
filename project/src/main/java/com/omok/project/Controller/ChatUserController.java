package com.omok.project.Controller;

import java.util.ArrayList;
import java.util.List;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.ResponseBody;

@Controller
public class ChatUserController {
	private List<String> user = new ArrayList<>();
	private int count = 0;
	//채팅방 회원 중복검사
	@ResponseBody
	@RequestMapping(value = "/checkNickname/{name}", method = RequestMethod.GET)
	public int checkNickname(@PathVariable String name) {
		
		if(user.size() > 0) {
			for(String u : user) {
				if(name.equals(u)) {
					return -1;
				}
			}
			user.add(name);
		}else {
			user.add(name);
		}
		updateCount();
		return count;
	}
	
	@ResponseBody
	@RequestMapping(value = "/deleteNickname/{name}", method = RequestMethod.GET)
	public int deleteCount(@PathVariable String name) {
		for(int i=0;i<user.size();i++) {
			if(name.equals(user.get(i))) {
				user.remove(i);
			}
		}
		deleteCount();
		return count;
	}
	
	//카운트 증가
	@ResponseBody
	@RequestMapping("/countPlus")
	public int updateCount() {
		count++;
		return count;
	}
	
	//카운트 감소
	@ResponseBody
	@RequestMapping("/countMinus")
	public int deleteCount() {
		count--;
		return count;
	}
	
	//카운트 가져오기
	@ResponseBody
	@RequestMapping("/getCount")
	public int getCount() {
		return count;
	}
}