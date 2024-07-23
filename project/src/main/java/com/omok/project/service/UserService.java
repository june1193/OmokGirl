package com.omok.project.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.omok.project.domain.userDTO;
import com.omok.project.repository.userRepository;

@Service
public class UserService {

	@Autowired
	private userRepository r;

	public void registerUser(userDTO u) {
		r.insertUser(u);
	}

	// 사용자 인증
	public boolean checkUser(String id, String password) {
		String storedPassword = r.findPasswordById(id);
		return storedPassword != null && storedPassword.equals(password);//비번 틀리면 false 맞으면 tru
	}
}
