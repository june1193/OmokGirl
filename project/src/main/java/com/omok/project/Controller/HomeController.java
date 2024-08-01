package com.omok.project.Controller;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;

import com.omok.project.domain.roomDTO;
import com.omok.project.domain.userDTO;
import com.omok.project.service.UserService;

@Controller
public class HomeController {

	@Autowired
	private UserService us;

	// 메인
	@RequestMapping("/home")
	public String main(Model model) {
		return "Home";
	}

	// 방목록
	@RequestMapping("/R_list")
	public String R_list(Model model) {
		
		List<roomDTO> r_data = us.selectAll();
	    model.addAttribute("r_data", r_data);
	    System.out.println(r_data);
		return "room_list";
		
	}

	// 게임방
	@RequestMapping("/G_room")
	public String G_room(Model model) {
		return "game_room";
	}

	// 회원가입 페이지
	@GetMapping("/register")
	public String showRegistrationForm() {
		return "register"; // 회원가입 폼을 보여주는 뷰 이름
	}

	// 회원정보 db에 저장
	@PostMapping("/register")
	public String registerUser(@ModelAttribute userDTO userDTO, Model model) {
		us.registerUser(userDTO);
		return "login"; // 로그인 페이지로 이동
	}

	
	//로그인 페이지
	@GetMapping("/login")
	public String showLoginForm() {
		return "login"; // 로그인 페이지 JSP
	}

	//로그인 계정 맞는지 체크
	@PostMapping("/login")
	public String loginUser(@ModelAttribute("userDto") userDTO userDto, Model model) {
		try {
			boolean checked = us.checkUser(userDto.getId(), userDto.getPassword());
			if (checked) {
				return "redirect:/R_list"; // 로그인 성공 시 방목록으로
			} else {
				model.addAttribute("error", "아이디나 비밀번호가 틀렸습니다.");
				return "login"; // 로그인 실패 시 로그인 페이지로 돌아가기
			}
		} catch (Exception e) {
			model.addAttribute("error", e.getMessage());
			return "login"; // 로그인 페이지로 돌아가기
		}
	}
	
	


}
