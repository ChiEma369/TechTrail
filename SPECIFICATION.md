# TÀI LIỆU ĐẶC TẢ KIẾN TRÚC & QUY CHUẨN LẬP TRÌNH (TECHTRAIL)

Tài liệu này là chuẩn mực bắt buộc dành cho tất cả thành viên trong nhóm phát triển ứng dụng **TechTrail** nhằm đảm bảo mã nguồn đồng nhất, sạch sẽ, không lỗi cú pháp và dễ dàng mở rộng.

---

## 1. Cấu trúc thư mục chuẩn (Project Structure)

Toàn bộ dự án được phân tách rõ ràng giữa Frontend di động và Backend:

```text
TechTrail/
├── SPECIFICATION.md             # Tài liệu đặc tả kiến trúc & quy chuẩn (File này)
├── README.md                    # Giới thiệu & hướng dẫn chạy nhanh
├── be/                          # BACKEND
│   ├── api/                     # Custom API Server (nếu mở rộng thêm microservices)
│   └── supabase/                # Cơ sở dữ liệu Supabase PostgreSQL
│       ├── schema.sql           # Cấu trúc bảng (DDL)
│       ├── seed.sql             # Dữ liệu hạt giống khởi tạo
│       ├── migrations/          # Lịch sử cập nhật DB
│       └── functions/           # Supabase Edge Functions
│
└── fe/                          # FRONTEND (FLUTTER)
    ├── android/                 # Cấu hình native Android
    ├── web/                     # Cấu hình web demo/preview
    ├── test/                    # Kiểm thử tự động (Unit / Widget Test)
    ├── pubspec.yaml             # Quản lý dependencies & assets
    └── lib/                     # MÃ NGUỒN CHÍNH
        ├── config/              # Cấu hình ứng dụng (Supabase URL, API Key, constants môi trường)
        ├── models/              # Các Data Models (DTO, mapping JSON <-> Object)
        ├── screens/             # Các màn hình chính (Page/Screen Widgets)
        ├── services/            # Tầng giao tiếp backend, gọi API, xác thực
        ├── widgets/             # Các UI Components tái sử dụng (Buttons, Cards, Inputs, Dialogs)
        └── main.dart            # Điểm khởi chạy ứng dụng (Entry Point)
```

### Nhiệm vụ cụ thể từng thư mục trong `fe/lib`:
- **`config/`**: Chỉ chứa cấu hình tĩnh, hằng số môi trường (ví dụ: `supabase_config.dart`, `app_constants.dart`). Tuyệt đối không viết logic giao diện ở đây.
- **`models/`**: Mỗi đối tượng dữ liệu là 1 file riêng biệt (ví dụ: `trail_model.dart`, `user_profile_model.dart`). Phải có constructor đầy đủ cùng `fromJson` và `toJson`.
- **`screens/`**: Mỗi màn hình là một file kết thúc bằng `_screen.dart` (ví dụ: `home_screen.dart`, `login_screen.dart`). Màn hình chỉ chịu trách nhiệm ghép nối các widget và điều phối dữ liệu.
- **`services/`**: Tầng xử lý logic nghiệp vụ và truy xuất cơ sở dữ liệu (ví dụ: `supabase_service.dart`, `auth_service.dart`, `trail_service.dart`). Không chứa code giao diện (`Widget`, `BuildContext`).
- **`widgets/`**: Các thành phần UI dùng chung cho 2 màn hình trở lên (ví dụ: `custom_text_field.dart`, `primary_button.dart`, `auth_gate.dart`).

---

## 2. Quy ước đặt tên (Naming Conventions)

Tuân thủ nghiêm ngặt chuẩn chính thức của **Dart Style Guide**:

| Đối tượng | Quy tắc | Ví dụ chuẩn | Sai (Cần tránh) |
| :--- | :--- | :--- | :--- |
| **Tên file & thư mục** | `snake_case` | `home_screen.dart`, `user_service.dart` | `HomeScreen.dart`, `userService.dart` |
| **Class, Enum, Typedef** | `PascalCase` | `HomeScreen`, `AuthService`, `UserRole` | `home_screen`, `authService` |
| **Tên biến & tham số** | `camelCase` | `isLoading`, `userData`, `currentIndex` | `IsLoading`, `user_data` |
| **Tên hàm & phương thức** | `camelCase` | `signInWithEmail()`, `fetchTrailList()` | `SignIn()`, `fetch_trail_list()` |
| **Hằng số (const/final static)**| `lowerCamelCase` | `defaultPadding`, `primaryColor` | `DEFAULT_PADDING` (tránh dùng) |
| **Widget Private** | `_PascalCase` | `_UserCardState`, `_HeaderSection` | `_userCardState` |

---

## 3. Quy chuẩn viết Code Dart & Flutter (Clean Code Rules)

### 3.1. Tối ưu hiệu năng với `const`
- Luôn thêm từ khóa `const` trước các Widget hoặc constructor bất biến để tránh Flutter phải dựng lại (rebuild) không cần thiết.
- Khuyến nghị kích hoạt quy tắc lint `prefer_const_constructors`.

### 3.2. An toàn kiểu dữ liệu & Xử lý Null (Sound Null-Safety)
- **Tuyệt đối không lạm dụng toán tử `!` (Force Unwrap)** trừ khi có kiểm tra chắc chắn 100% trước đó.
- Sử dụng toán tử điều kiện `?.` và giá trị mặc định `??`:
  ```dart
  // Chuẩn:
  final displayName = user?.fullName ?? 'Khách';
  
  // Sai (Dễ gây crash app):
  final displayName = user!.fullName!;
  ```

### 3.3. Xử lý Bất đồng bộ (Async / Await & Mounted check)
- Luôn kiểm tra `mounted` trước khi gọi `setState()` hoặc sử dụng `context` sau một thao tác bất đồng bộ (Network/DB call):
  ```dart
  Future<void> _handleLoadData() async {
    final data = await trailService.getTrails();
    if (!mounted) return; // Bắt buộc kiểm tra để tránh crash khi user đã chuyển màn hình
    setState(() {
      _trails = data;
    });
  }
  ```
- Mọi hàm gọi Supabase/API đều phải được bọc trong khối `try-catch` để bắt và hiển thị thông báo lỗi thân thiện.

### 3.4. Nguyên tắc thiết kế Widget
- **Không viết một file Widget quá 250 dòng.** Khi một file phình to, hãy bóc tách các phần con thành các Widget riêng trong thư mục `widgets/` hoặc các Widget class ở cuối file.
- Tránh viết các hàm trả về widget kiểu `Widget _buildHeader()`, thay vào đó hãy tạo class `class _HeaderWidget extends StatelessWidget` để tối ưu cơ chế caching của Flutter Engine.

---

## 4. Quy ước kết nối Backend Supabase

### 4.1. Khởi tạo và sử dụng Client
- Cấu hình thông tin kết nối tại `lib/config/supabase_config.dart`.
- Khởi tạo 1 lần duy nhất tại `main.dart` thông qua `SupabaseService.init()`.
- Lấy client trong các service bằng:
  ```dart
  final supabase = SupabaseService.client;
  // Hoặc: Supabase.instance.client
  ```

### 4.2. Chuẩn hóa Mapping Dữ liệu (Models)
- Tên cột trong cơ sở dữ liệu Supabase PostgreSQL: **`snake_case`** (ví dụ: `created_at`, `user_id`, `avatar_url`).
- Tên thuộc tính trong Dart Model: **`camelCase`** (ví dụ: `createdAt`, `userId`, `avatarUrl`).
- Mẫu chuẩn Model:
  ```dart
  class TrailModel {
    final String id;
    final String title;
    final String? description;
    final DateTime createdAt;

    const TrailModel({
      required this.id,
      required this.title,
      this.description,
      required this.createdAt,
    });

    factory TrailModel.fromJson(Map<String, dynamic> json) {
      return TrailModel(
        id: json['id'] as String,
        title: json['title'] as String? ?? '',
        description: json['description'] as String?,
        createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
      );
    }

    Map<String, dynamic> toJson() {
      return {
        'id': id,
        'title': title,
        'description': description,
        'created_at': createdAt.toIso8601String(),
      };
    }
  }
  ```

---

## 5. Quy chuẩn Hệ thống Giao diện (Design Tokens)

 **đã được thiết kế và code theo như trong figma**
---

## 6. Quy trình làm việc nhóm với Git (Team Git Workflow)

### 6.1. Tiêu chuẩn Commit Message
Sử dụng chuẩn **Conventional Commits**:
- `feat: <nội dung>`: Thêm tính năng mới (ví dụ: `feat: thêm màn hình đăng ký`).
- `fix: <nội dung>`: Sửa lỗi (ví dụ: `fix: sửa lỗi validate email`).
- `refactor: <nội dung>`: Tái cấu trúc code mà không thay đổi tính năng.
- `docs: <nội dung>`: Cập nhật tài liệu, README.
- `style: <nội dung>`: Định dạng code, format khoảng trắng (không ảnh hưởng logic).

### 6.2. Kiểm tra trước khi Commit
Mỗi thành viên trước khi commit bắt buộc chạy các lệnh kiểm tra trong thư mục `fe/`:
1. `dart format .` (Tự động format code theo chuẩn Dart)
2. `flutter analyze` (Đảm bảo không còn lỗi syntax hoặc cảnh báo nghiêm trọng)
3. `flutter test` (Đảm bảo toàn bộ test case vượt qua)
