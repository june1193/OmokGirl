package com.omok.project.domain;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

//유저 
@Data
@AllArgsConstructor
@NoArgsConstructor
public class userDTO {
	private Integer userNum; // AUTO_INCREMENT 필드
	private String id;
	private String password;
	private String email;
	private String nickname;
}
