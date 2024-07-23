package com.omok.project.repository;

import javax.sql.DataSource;

import org.apache.ibatis.session.SqlSession;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;

import com.omok.project.domain.userDTO;

@Repository
public class userRepository {
	@Autowired // root�������Ͽ� �ִ� ���� ����
	private SqlSession session;
	private static String namespace = "com.omok.mapper.";
	
	
    public void insertUser(userDTO user) {
        session.insert(namespace + "insertUser", user);
    }
    
    // ��й�ȣ�� ID�� ã�� �޼ҵ� �߰�
    public String findPasswordById(String id) {
        return session.selectOne(namespace + "getPasswordById", id);
    }
}
