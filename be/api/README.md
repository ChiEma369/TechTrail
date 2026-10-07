# Custom Backend API Server

Thư mục dành cho API server riêng (ví dụ: Node.js Express, NestJS, hoặc Python FastAPI) khi dự án cần các tác vụ backend đặc thù (thanh toán, webhook, background worker, v.v.).

### Cấu trúc gợi ý khi triển khai:
- `src/`: Chứa mã nguồn controller, routes, middleware, services.
- `package.json` / `requirements.txt`: Khai báo thư viện phụ thuộc.
- `.env`: Cấu hình biến môi trường (port, secret key, kết nối database).
