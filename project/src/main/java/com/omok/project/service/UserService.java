package com.omok.project.service;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.omok.project.domain.roomDTO;
import com.omok.project.domain.userDTO;
import com.omok.project.repository.userRepository;

@Service
public class UserService {

	@Autowired
	private userRepository r;

	
	
	public void registerUser(userDTO u) {
		r.insertUser(u);
	}

	// ����� ����
	public boolean checkUser(String id, String password) {
		String storedPassword = r.findPasswordById(id);
		return storedPassword != null && storedPassword.equals(password);//��� Ʋ���� false ������ tru
	}
	
    // ��� �� ���� ��ȸ
    public List<roomDTO> selectAll() {
        return r.selectAll();
    }
}
