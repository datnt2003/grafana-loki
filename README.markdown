# Hệ thống giám sát Log với Loki, Promtail và Grafana

Hệ thống này sử dụng **Loki** để lưu trữ log, **Promtail** để thu thập log và **Grafana** để trực quan hóa log. Các dịch vụ được triển khai bằng **Docker Compose**.

## Yêu cầu

- **Docker** và **Docker Compose** được cài đặt trên máy chủ.
- Quyền truy cập vào các thư mục để lưu trữ dữ liệu (`loki-data`, `grafana-data`, `logs`).
- Đảm bảo các cổng `3100` (Loki) và `3000` (Grafana) không bị chiếm dụng.

## Cấu trúc thư mục

```
.
├── .env
├── Makefile
├── docker-compose.yaml
├── loki-config/
│   └── loki-config.yaml
├── promtail-config/
│   └── promtail-config.yaml
├── grafana-config/
│   └── datasources.yaml
└── logs/
```

## Các thành phần

1. **Loki**: Lưu trữ và quản lý log.
2. **Promtail**: Thu thập log từ các file trong thư mục `/var/log` và đẩy đến Loki.
3. **Grafana**: Giao diện trực quan để xem và phân tích log từ Loki.

## Hướng dẫn thiết lập

### Bước 1: Cấu hình biến môi trường

Tệp `.env` chứa các biến cấu hình:

- `HOST_NAME`: Địa chỉ IP hoặc tên miền của máy chủ chạy Loki (mặc định: `192.168.1.10`).
- `GF_SECURITY_ADMIN_USER`: Tên người dùng quản trị Grafana (mặc định: `admin`).
- `GF_SECURITY_ADMIN_PASSWORD`: Mật khẩu quản trị Grafana (mặc định: `admin123`).

Ví dụ nội dung `.env`:

```
HOST_NAME=192.168.1.10
GF_SECURITY_ADMIN_USER=admin
GF_SECURITY_ADMIN_PASSWORD=admin123
```

**Lưu ý**: Thay đổi `HOST_NAME` nếu máy chủ của bạn có địa chỉ khác.

### Bước 2: Chuẩn bị thư mục log

Tạo thư mục `logs` để chứa các file log mà Promtail sẽ thu thập:

```bash
mkdir logs
```

Bạn có thể thêm các file log mẫu (ví dụ: `app.log`) vào thư mục `logs` để kiểm tra.

### Bước 3: Triển khai hệ thống

Sử dụng lệnh sau để khởi động các dịch vụ:

```bash
make up
```

Lệnh này sẽ:
- Khởi động Loki, Promtail (profile `log`) và Grafana (profile `monitoring`).
- Sử dụng tệp `.env` để cung cấp biến môi trường.

### Bước 4: Kiểm tra dịch vụ

- **Loki**: Truy cập `http://<HOST_NAME>:3100` để kiểm tra trạng thái Loki.
- **Grafana**: Mở trình duyệt tại `http://<HOST_NAME>:3000`.
  - Đăng nhập với thông tin:
    - Tên người dùng: `admin` (hoặc giá trị trong `GF_SECURITY_ADMIN_USER`).
    - Mật khẩu: `admin123` (hoặc giá trị trong `GF_SECURITY_ADMIN_PASSWORD`).
  - Nguồn dữ liệu Loki đã được cấu hình tự động tại `http://<HOST_NAME>:3100`.

### Bước 5: Xem log trong Grafana

1. Trong Grafana, vào **Explore**.
2. Chọn nguồn dữ liệu **Loki**.
3. Sử dụng truy vấn LogQL, ví dụ: `{job="dev_logs"}` để xem log từ các file trong thư mục `/var/log`.
4. Nhấn **Run query** để xem kết quả.

## Tùy chỉnh

- **Thêm log mới**: Đặt các file log vào thư mục `./logs/` với đuôi `.log`. Promtail sẽ tự động thu thập.
- **Thay đổi cấu hình Loki**: Chỉnh sửa `loki-config/loki-config.yaml` và khởi động lại dịch vụ.
- **Thay đổi cấu hình Promtail**: Chỉnh sửa `promtail-config/promtail-config.yaml` để thay đổi đường dẫn log hoặc nhãn.

## Dừng hệ thống

Để dừng các dịch vụ:

```bash
docker compose down
```

## Xử lý sự cố

- **Loki không hoạt động**: Kiểm tra log container bằng `docker logs loki`.
- **Promtail không gửi log**: Đảm bảo thư mục `./logs` có file log và quyền đọc/ghi phù hợp.
- **Grafana không kết nối được với Loki**: Kiểm tra biến `HOST_NAME` trong `.env` và đảm bảo Loki đang chạy.

## Lưu ý

- Tệp cấu hình Loki (`loki-config.yaml`) sử dụng lưu trữ `filesystem`. Đảm bảo dung lượng đĩa đủ cho thư mục `/loki`.
- Grafana lưu dữ liệu trong volume `grafana-data`. Sao lưu volume này nếu cần.