# TECHTRAIL - DATA ACCESS LAYER & BACKEND SERVICE

Tài liệu hướng dẫn cấu trúc dữ liệu, quy chuẩn code và cách phát triển mở rộng tính năng cho nhóm phát triển.

---

## 1. Cấu trúc thư mục hiện tại
- `mockData.json`: Chứa dữ liệu hạt giống (Seed Data) chuẩn hóa theo đúng sơ đồ bảng Supabase.
- `mockDataAccessLayer.js`: Tầng truy xuất dữ liệu (Data Access Layer - DAL). Mọi nghiệp vụ đọc/ghi hiện tại đi qua file này.
- `testDAL.js`: File kịch bản chạy thử nghiệm luồng nghiệp vụ.
- `README.md`: Hướng dẫn kỹ thuật và quy chuẩn đóng góp code.

---

## 2. Quy tắc về dữ liệu (Data Conventions)
Để đảm bảo dữ liệu tương thích 100% khi chuyển sang Supabase:
1. **Khóa chính & Khóa ngoại:** Bắt buộc dùng định dạng **UUIDv4** (ví dụ: `crypto.randomUUID()`). Không tự ý đặt ID dạng chuỗi ngắn như `branch_1`, `user_1`.
2. **Quy tắc đặt tên trường (Database Schema):** 
   - Dùng kiểu `snake_case` khớp tuyệt đối với tên cột trên Supabase (ví dụ: `activity_name`, `branch_id`, `created_at`).
   - Tuyệt đối không tự ý đổi tên cột trong `mockData.json` mà chưa thống nhất với cả nhóm.
3. **Kiểu dữ liệu đặc thù:**
   - Trường điểm số `interest_rating`: số nguyên (1 đến 5).
   - Trường mảng/object (như `roadmap`, `track_scores`): ánh xạ vào kiểu `jsonb` trên Supabase.

---

## 3. Hướng dẫn bổ sung tính năng mới (Feature Extension Workflow)

Khi bạn muốn thêm một bảng mới hoặc một chức năng mới:
- **Bước 1 (Dữ liệu):** Thêm dữ liệu mẫu vào `mockData.json` theo đúng cấu trúc bảng đã vẽ trên Supabase.
- **Bước 2 (DAL/Service):** Viết thêm hàm xử lý tương ứng vào `mockDataAccessLayer.js`. 
  - Hàm luôn trả về `Promise` (sử dụng từ khóa `async/await`).
  - Xử lý kiểm tra dữ liệu đầu vào (Validation) trước khi ghi.
- **Bước 3 (Test):** Viết một hàm test kịch bản trong `testDAL.js` và chạy `node testDAL.js` để đảm bảo code không phát sinh lỗi trước khi commit.

---

## 4. Lộ trình chuyển đổi sang Supabase (Migration Guide)
Sau này khi tích hợp Supabase:
- **Không sửa giao diện mobile hay các tầng controller phía trên.**
- Tạo một file mới tên `supabaseDataAccessLayer.js` có các tên hàm y hệt như `mockDataAccessLayer.js` (`getAllCareerBranches`, `createJournalEntry`,...).
- Chỉ thay thế phần thân hàm từ đọc JSON sang gọi `@supabase/supabase-js`.