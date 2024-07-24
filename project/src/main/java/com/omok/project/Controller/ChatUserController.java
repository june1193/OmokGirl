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
	//ä�ù� ȸ�� �ߺ��˻�
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
	
	//ī��Ʈ ����
	@ResponseBody
	@RequestMapping("/countPlus")
	public int updateCount() {
		count++;
		return count;
	}
	
	//ī��Ʈ ����
	@ResponseBody
	@RequestMapping("/countMinus")
	public int deleteCount() {
		count--;
		return count;
	}
	
	//ī��Ʈ ��������
	@ResponseBody
	@RequestMapping("/getCount")
	public int getCount() {
		return count;
	}
}