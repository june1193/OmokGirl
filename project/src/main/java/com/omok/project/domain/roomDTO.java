package com.omok.project.domain;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class roomDTO {
    private int user_count;
    private String room_title;
    private String avatar;
    private String user_nickname;
    private int room_id;
}