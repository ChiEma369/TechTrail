# TechTrail

Dự án TechTrail với kiến trúc phân tách rõ ràng giữa Frontend và Backend.

## Cấu trúc thư mục dự án

```text
TechTrail/
├── fe/                  # Frontend: Ứng dụng Flutter di động
│   ├── android/         # Cấu hình Android native
│   ├── lib/             # Mã nguồn chính (Dart/Flutter)
│   │   ├── config/      # Cấu hình app & Supabase client
│   │   ├── models/      # Data models
│   │   ├── screens/     # Giao diện màn hình
│   │   ├── services/    # Logic gọi API & Auth
│   │   └── widgets/     # Component UI dùng chung
│   ├── test/            # Unit & widget tests
│   └── pubspec.yaml     # Quản lý dependencies Flutter
│
├── be/                  # Backend: Cơ sở dữ liệu & API Server
│   ├── supabase/        # Supabase config, SQL & functions
│   │   ├── migrations/  # Quản lý lịch sử migrations DB
│   │   ├── functions/   # Supabase Edge Functions
│   │   ├── schema.sql   # Lược đồ database ban đầu
│   │   └── seed.sql     # Dữ liệu mẫu khởi tạo
│   └── api/             # Khung Custom API Server (Node.js/Python nếu cần)
│       ├── src/         # Mã nguồn API server
│       └── .env.example # Mẫu biến môi trường
│
└── .gitignore           # File ignore chung cho toàn bộ dự án
```

## Khởi chạy nhanh

### Frontend (Flutter)
```bash
cd fe
flutter pub get
flutter run
```

### Backend (Supabase & API)
- **Supabase**: Thiết lập bảng bằng cách chạy lệnh SQL trong `be/supabase/schema.sql` trên Supabase SQL Editor.
- **API Server** (nếu dùng): Cấu hình biến môi trường dựa theo `be/api/.env.example`.
