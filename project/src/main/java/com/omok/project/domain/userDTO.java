package com.omok.project.domain;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

//유저 
@Data
@AllArgsConstructor
@NoArgsConstructor
public class userDTO {
	private int userNum;
    private String id;
    private String password;
    private String email;
    private String nickname;
    private String avatar = "나코"; // 기본값 설정
    private int wins = 0; // 기본값 설정
}
