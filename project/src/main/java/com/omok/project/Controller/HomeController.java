package com.omok.project.Controller;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
public class HomeController {
	
	//�����׽�Ʈ123
	
	   // ��Ī ����
	   @RequestMapping("/home")
	   public String main(Model model) {
			/*
			 * // �αⷩŷ List<Club> r_clubs = nr.selectTopClubs(5);
			 * model.addAttribute("r_data", r_clubs); // Ŭ�� �Խ��� int pageSize = 8; // ��������
			 * ������ ������ �� ���� int totRecords = nr.getTotalCount(); PageHandler handler = new
			 * PageHandler(currentPage, totRecords, pageSize); List<Club> list =
			 * nr.selectAll(currentPage, pageSize); model.addAttribute("data", list);
			 * model.addAttribute("handler", handler); // ��ġ �� List<MatchViewDTO> list2 =
			 * ms.mainMatchViewSV(); model.addAttribute("main", list2);
			 * 
			 * HttpSession session = request.getSession(); UserLoginDTO user =
			 * (UserLoginDTO) session.getAttribute("loggedInUser");
			 * 
			 * model.addAttribute("user", user);
			 */
	      
	      return "Home";
	   }

}
