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

	// ����
	@RequestMapping("/home")
	public String main(Model model) {
		return "Home";
	}

	// ����
	@RequestMapping("/R_list")
	public String R_list(Model model) {
		
		List<roomDTO> r_data = us.selectAll();
	    model.addAttribute("r_data", r_data);
	    System.out.println(r_data);
		return "room_list";
		
	}

	// ���ӹ�
	@RequestMapping("/G_room")
	public String G_room(Model model) {
		return "game_room";
	}

	// ȸ������ ������
	@GetMapping("/register")
	public String showRegistrationForm() {
		return "register"; // ȸ������ ���� �����ִ� �� �̸�
	}

	// ȸ������ db�� ����
	@PostMapping("/register")
	public String registerUser(@ModelAttribute userDTO userDTO, Model model) {
		us.registerUser(userDTO);
		return "login"; // �α��� �������� �̵�
	}

	
	//�α��� ������
	@GetMapping("/login")
	public String showLoginForm() {
		return "login"; // �α��� ������ JSP
	}

	//�α��� ���� �´��� üũ
	@PostMapping("/login")
	public String loginUser(@ModelAttribute("userDto") userDTO userDto, Model model) {
		try {
			boolean checked = us.checkUser(userDto.getId(), userDto.getPassword());
			if (checked) {
				return "redirect:/R_list"; // �α��� ���� �� ��������
			} else {
				model.addAttribute("error", "���̵� ��й�ȣ�� Ʋ�Ƚ��ϴ�.");
				return "login"; // �α��� ���� �� �α��� �������� ���ư���
			}
		} catch (Exception e) {
			model.addAttribute("error", e.getMessage());
			return "login"; // �α��� �������� ���ư���
		}
	}
	
	


}
