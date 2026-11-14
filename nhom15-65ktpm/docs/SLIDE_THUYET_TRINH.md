# Dàn Ý Slide Thuyết Trình Báo Cáo Đồ Án (Presentation Deck Outline)

**Học phần:** Phát Triển Ứng Dụng Di Động (PTUDDD) - Lớp 65KTPM  
**Đề tài:** Ứng dụng học toán Soroban & Finger Math tương tác 2 bàn tay rèn luyện tư duy cho trẻ 4-6 tuổi kết hợp AI trợ lý giọng nói (Soroban Kids App)  
**Giảng viên hướng dẫn:** Thầy Đỗ Oanh Cường  
**Nhóm thực hiện:** Nhóm 15  
- Dương Nguyên Anh (2351170569) - Nhóm trưởng
- Phạm Duy Thái (2351060487) - Thành viên
- Nguyễn Thị Thu Hoài (2351170594) - Thành viên
- Nguyễn Thị Cẩm Ly (2351170605) - Thành viên  

---

### SLIDE 1: TRANG TIÊU ĐỀ (TITLE SLIDE)
- **Tiêu đề chính:** Finger Math APP
- **Tiêu đề phụ:** Ứng dụng học toán Finger Math tương tác hai bàn tay kết hợp AI trợ lý giọng nói tiếng Việt cho trẻ 4–6 tuổi.
- **Thông tin báo cáo:**
  - Giảng viên hướng dẫn: **Thầy Đỗ Oanh Cường**
  - Lớp học phần: **65KTPM**
  - Đơn vị thực hiện: **Nhóm 15**
- **Hình ảnh gợi ý:** Logo gấu trúc Panda thân thiện, bàn tính Soroban ảo và đôi bàn tay Finger Math rực rỡ sắc màu.

---

### SLIDE 2: BỐI CẢNH & TÍNH CẤP THIẾT
- **Đặc thù lứa tuổi 4–6:** Giai đoạn vàng phát triển bán cầu não; tuy nhiên trẻ chưa biết đọc/viết chữ và khả năng tập trung có hạn.
- **Bất cập của cách học truyền thống:** Sách giáo khoa khô khan, bàn tính gỗ cồng kềnh, thiếu phản hồi tức thì và thiếu người đồng hành tương tác.
- **Giải pháp của Nhóm 15:** 
  - Số hóa phương pháp **Toán ngón tay Finger Math** và **Bàn tính Soroban** trên cùng một ứng dụng.
  - Triết lý **Giao diện Không chữ (Zero-Text UI)**: Biểu tượng lớn, âm thanh vui nhộn, không rào cản chữ viết.
  - Tích hợp **AI Trợ lý giọng nói tiếng Việt** lắng nghe và chấm điểm tự nhiên.

---

### SLIDE 3: MỤC TIÊU & NGUYÊN TẮC THIẾT KẾ CỐT LÕI
1. **Phạm vi toán học:** Giới hạn độc quyền ở **phép Cộng và phép Trừ** (phạm vi $0 \to 99$, kết quả không âm), tuyệt đối không quá tải cho lứa tuổi mầm non.
2. **Hệ thống tương tác kép:** Vừa có bàn tính Soroban ảo 60fps, vừa có đôi bàn tay Finger Math chạm đa điểm.
3. **Chuẩn hóa công thức toán tư duy:** Hiện thực hóa đầy đủ hai bộ công thức kinh điển: **Anh bạn nhỏ (tổng = 5)** và **Anh bạn lớn (tổng = 10)**.
4. **AI giọng nói tiếng Việt:** Tự động lọc từ đệm dạ thưa và trích xuất đáp án chính xác của trẻ.
5. **Gia sư thích ứng (Adaptive Learning):** Đo lường thời gian phản hồi và độ chính xác để tự động điều chỉnh tốc độ Flash Anzan.
6. **Kỷ luật thói quen:** Xây dựng chuỗi Streak và cổng báo cáo trực quan cho phụ huynh.

---

### SLIDE 4: TỔNG QUAN KIẾN TRÚC HỆ THỐNG & DATA CONTRACT
- **Mô hình kiến trúc:** Feature-First Clean Architecture chia 4 tầng rõ ràng:
  - `core/`: Hạ tầng dùng chung (Constants, Theme, AudioService, StorageService).
  - `shared/`: Giao ước dữ liệu (**Data Contract**) khóa cứng 3 Entity chung ngay từ đầu (`ChildProfile`, `SorobanQuestion`, `AttemptLog`).
  - `features/`: 4 module tính năng tương ứng với ma trận phân công 4 thành viên.
  - `test/`: Bộ kiểm thử tự động toàn diện.
- **Ý nghĩa:** Cho phép 4 thành viên code độc lập song song bằng mock data mà không bao giờ xung đột mã nguồn.

---

### SLIDE 5: MODULE 1 - BÀN TAY FINGER MATH & BÀN TÍNH SOROBAN (Dương Nguyên Anh)
- **Công nghệ lập trình đồ họa:** Sử dụng `CustomPainter` tối ưu 60fps, không dùng ảnh tĩnh.
- **Quy ước chuẩn Hai Bàn Tay (Phạm vi $0 \to 99$):**
  - **Tay Phải (Hàng đơn vị: $0 \to 9$):** Ngón cái = $5$, mỗi ngón dài = $1$.
    - $6 = 5 \text{ (cái)} + 1 \text{ (trỏ)}$
    - $7 = 5 + 2$
    - $8 = 5 + 3$
    - $9 = 5 + 4$ (cả bàn tay)
  - **Tay Trái (Hàng chục: $10 \to 90$):** Ngón cái = $50$, mỗi ngón dài = $10$.
  - Kết hợp 2 tay: Biểu diễn từ $0 \to 99$ linh hoạt.
- **Bàn tính Soroban ảo:**
  - Hạt trên (5), 4 hạt dưới (1) hình quả trám 3D.
  - Phản hồi rung xúc giác (Haptic Feedback) và âm thanh gảy hạt chân thực.
- **Tính năng chuyển đổi kép:** Trẻ tự do chuyển đổi giữa ✋ Finger Math và 🧮 Soroban ngay trong màn hình luyện tập.

---

### SLIDE 6: BẢNG CÔNG THỨC TOÁN TƯ DUY (ANH BẠN NHỎ & ANH BẠN LỚN)
- **Công thức Anh Bạn Nhỏ (Cặp số có tổng bằng 5: 1-4, 2-3):**
  - Dùng khi cộng/trừ trong phạm vi 5 trên cùng 1 bàn tay (thiếu ngón dài):
    - Phép cộng: $+4 = +5 - 1$ | $+3 = +5 - 2$ | $+2 = +5 - 3$ | $+1 = +5 - 4$ *(Xòe ngón cái 5, gập bạn nhỏ)*
    - Phép trừ: $-4 = -5 + 1$ | $-3 = -5 + 2$ | $-2 = -5 + 3$ | $-1 = -5 + 4$ *(Gập ngón cái 5, bung bạn nhỏ)*
- **Công thức Anh Bạn Lớn (Cặp số có tổng bằng 10: 9-1, 8-2, 7-3, 6-4, 5-5):**
  - Dùng khi phép tính vượt qua 10 (phối hợp Tay Trái & Tay Phải):
    - Phép cộng qua 10 (+): **Bung 1 ngón Tay Trái (+10)**, **Gập bạn lớn ở Tay Phải (- bạn lớn)**.  
      *(Ví dụ: $6 + 7 = 13 \rightarrow +10 \text{ tay trái, } -3 \text{ tay phải}$)*
    - Phép trừ qua 10 (-): **Gập 1 ngón Tay Trái (-10)**, **Bung bạn lớn ở Tay Phải (+ bạn lớn)**.  
      *(Ví dụ: $12 - 5 = 7 \rightarrow -10 \text{ tay trái, } +5 \text{ tay phải}$)*

---

### SLIDE 7: MODULE 2 - ZERO-TEXT UI, GAMIFICATION & CỔNG PHỤ HUYNH (Phạm Duy Thái)
- **Triết lý Zero-Text UI:**
  - Màu sắc đạt chuẩn WCAG tương phản cho trẻ em (Cam đất, Vàng chuối, Tím mộng mơ).
  - Tối ưu vùng chạm tối thiểu $48 \times 48\text{dp}$ chống bấm trượt cho ngón tay nhỏ của trẻ.
- **Cơ chế Gamification:**
  - Chuỗi ngày học liên tiếp (**Streak**): Duy trì thói quen học mỗi ngày, mở khóa huy hiệu ngôi sao.
  - Tự động reset chuỗi về 1 nếu ngắt quãng quá 1 ngày.
- **Khu vực Phụ huynh (Parent Dashboard):**
  - **Cổng bảo vệ (Parental Gate):** Khóa bằng phép tính ngẫu nhiên ngăn trẻ bấm nhầm.
  - Biểu đồ cột trực quan (`fl_chart`): Thống kê số bài tập và tỷ lệ chính xác trong tuần.
  - Lịch nhắc học cố định lúc 19:00 hàng ngày.

---

### SLIDE 8: MODULE 3 - LOGIC BÀI HỌC CỘNG TRỪ & FLASH ANZAN (Nguyễn Thị Thu Hoài)
- **Bộ sinh đề thông minh (Question Generator):**
  - Cam kết độc quyền **chỉ phép Cộng và Trừ**, không ra số âm ($0 \le \text{kết quả} \le 99$).
  - Phân cấp 4 lộ trình học:
    - *Cấp 1:* Làm quen số đếm ngón tay từ 0 đến 9.
    - *Cấp 2:* Phép cộng trừ trực tiếp (không dùng công thức).
    - *Cấp 3:* Phép tính áp dụng Công thức Anh Bạn Nhỏ (tổng = 5).
    - *Cấp 4:* Phép tính áp dụng Công thức Anh Bạn Lớn (tổng = 10 qua 2 bàn tay).
- **Siêu trí tuệ Flash Anzan:**
  - Chớp số siêu tốc từ 0.5s đến 1.5s kích thích tư duy hình dung não phải.
  - Khoảng nghỉ trắng mắt 180ms giữa các số giúp tăng khả năng tập trung cao độ.

---

### SLIDE 9: MODULE 4 - AI TRỢ LÝ GIỌNG NÓI & GIA SƯ THÍCH ỨNG (Nguyễn Thị Cẩm Ly)
- **Nhận dạng giọng nói tiếng Việt (`speech_to_text`):**
  - Thu âm âm vực cao của trẻ em 4–6 tuổi.
  - Trẻ không cần gõ bàn phím, chỉ cần bấm nút Micro và nói tự nhiên.
- **Bộ xử lý NLP tiếng Việt (Vietnamese Number Extractor):**
  - Loại bỏ các từ đệm: *"dạ", "thưa", "kết quả là", "bằng"* $\rightarrow$ trích xuất số chính xác.
  - Xử lý các từ phương ngữ: *"hai mươi mốt"*, *"lăm"*, *"nhăm"*.
  - Từ chối các câu phủ định: *"con không biết"*, *"chưa tính ra"* $\rightarrow$ trả về null.
- **Thuật toán Gia sư thích ứng (Adaptive Learning):**
  - Đánh giá cửa sổ trượt 5 bài tập gần nhất.
  - Làm đúng nhanh $\ge 80\% \rightarrow$ tự động tăng độ khó và đẩy tốc độ Flash Anzan nhanh hơn 200ms.
  - Làm sai nhiều $< 50\% \rightarrow$ tự động giảm nhịp độ và chuyển sang chế độ thị phạm từng ngón tay.

---

### SLIDE 10: QUY TRÌNH PHỐI HỢP & QUẢN TRỊ GIT (NHÓM 15)
- **Chiến lược phân nhánh chuẩn mực:**
  - Nhánh chính của nhóm: `nhom15-65ktpm` (tạo Pull Request nộp bài).
  - 4 nhánh tính năng thành viên: `feature/nhom15/duong-nguyen-anh-2351170569`, `pham-duy-thai`, `nguyen-thi-thu-hoai`, `nguyen-thi-cam-ly`.
- **Nguyên tắc "Nhà ai nấy ở":**
  - 100% tệp tin nằm trọn trong thư mục `nhom15-65ktpm/`.
  - Không sửa file ngoài phạm vi, tránh xung đột 100%.
- **Pull Request #4:**
  - Đã mở nộp bài thành công về kho gốc `oanhcuongdo/project-ptuddd:main`.
  - Tự động cập nhật mọi commit mới nhất của nhóm.

---

### SLIDE 11: KẾT QUẢ KIỂM THỬ CHẤT LƯỢNG (TESTING & QA)
- **Bộ kiểm thử tự động (Unit Test):** **22/22 ca kiểm thử vượt qua 100% (Passed)**
  - *Module 1:* 6 ca test bàn tính Soroban + 5 ca test Finger Math 2 bàn tay & công thức Anh bạn nhỏ, Anh bạn lớn.
  - *Module 2:* 3 ca test thuật toán chuỗi ngày học Streak.
  - *Module 3:* 1 ca test giao diện nút bấm KidButton + bộ sinh đề cộng trừ.
  - *Module 4:* 4 ca test NLP trích xuất số tiếng Việt + 3 ca test gia sư thích ứng AI.
- **Chất lượng mã nguồn:**
  - `dart analyze lib test` đạt chuẩn: **0 Errors, 0 Warnings**.
  - Đã biên dịch thành công cả 2 nền tảng: **Web Chrome** và **Windows Desktop (`.exe`)**.

---

### SLIDE 12: ĐÁNH GIÁ ĐÓNG GÓP THÀNH VIÊN (NHÓM 15)
| MSSV | Họ Tên | Vai Trò & Phụ Trách Module | Mức Độ Hoàn Thành |
| :---: | :--- | :--- | :---: |
| **2351170569** | **Dương Nguyên Anh** | **Nhóm trưởng / Tech Lead**<br>Phụ trách Module 1: Soroban & Finger Math Engine | **100%** |
| **2351060487** | **Phạm Duy Thái** | **Thành viên**<br>Phụ trách Module 2: UI/UX Zero-Text, Gamification Streak & Parent Dashboard | **100%** |
| **2351170594** | **Nguyễn Thị Thu Hoài** | **Thành viên**<br>Phụ trách Module 3: Bộ sinh đề cộng trừ & Flash Anzan siêu tốc | **100%** |
| **2351170605** | **Nguyễn Thị Cẩm Ly** | **Thành viên**<br>Phụ trách Module 4: AI Speech-to-Text tiếng Việt & Gia sư thích ứng | **100%** |

---

### SLIDE 13: KẾT LUẬN & HƯỚNG PHÁT TRIỂN
- **Kết luận:**
  - Đồ án đáp ứng xuất sắc mọi yêu cầu của môn học Phát triển ứng dụng đa thiết bị.
  - Ứng dụng mang tính thực tiễn cao, giao diện hấp dẫn, giúp trẻ mầm non yêu thích môn toán tư duy.
- **Hướng phát triển tương lai:**
  - Tích hợp nhận diện cử chỉ bàn tay qua Camera (Computer Vision) để theo dõi động tác ngón tay ngoài đời thực.
  - Mở rộng đấu trường thi đấu tính nhẩm Flash Anzan trực tuyến nhiều người chơi (Multiplayer).
- **Lời cảm ơn:**
  - *"Nhóm 15 xin trân trọng cảm ơn Thầy Đỗ Oanh Cường đã nhiệt tình giảng dạy và định hướng cho nhóm trong suốt học phần!"*
