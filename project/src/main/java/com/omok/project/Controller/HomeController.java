package com.omok.project.Controller;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
public class HomeController {
	
	//수정테스트123
	
	   // 매칭 메인
	   @RequestMapping("/home")
	   public String main(Model model) {
			/*
			 * // 인기랭킹 List<Club> r_clubs = nr.selectTopClubs(5);
			 * model.addAttribute("r_data", r_clubs); // 클럽 게시판 int pageSize = 8; // 페이지당
			 * 보여줄 데이터 수 설정 int totRecords = nr.getTotalCount(); PageHandler handler = new
			 * PageHandler(currentPage, totRecords, pageSize); List<Club> list =
			 * nr.selectAll(currentPage, pageSize); model.addAttribute("data", list);
			 * model.addAttribute("handler", handler); // 매치 뷰 List<MatchViewDTO> list2 =
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
