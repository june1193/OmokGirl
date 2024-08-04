package com.omok.project.domain;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

//���� 
@Data
@AllArgsConstructor
@NoArgsConstructor
public class userDTO {
	private int userNum;
    private String id;
    private String password;
    private String email;
    private String nickname;
    private String avatar = "����"; // �⺻�� ����
    private int wins = 0; // �⺻�� ����
}
