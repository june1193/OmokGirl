package com.omok.project.repository;

import javax.sql.DataSource;

import org.apache.ibatis.session.SqlSession;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;

import com.omok.project.domain.userDTO;

@Repository
public class userRepository {
	@Autowired // root설정파일에 있는 빈을 주입
	private SqlSession session;
	private static String namespace = "com.omok.mapper.";
	
	
    public void insertUser(userDTO user) {
        session.insert(namespace + "insertUser", user);
    }
    
    // 비밀번호를 ID로 찾는 메소드 추가
    public String findPasswordById(String id) {
        return session.selectOne(namespace + "getPasswordById", id);
    }
}
