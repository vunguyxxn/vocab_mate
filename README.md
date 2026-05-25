# VocabMate

> VocabMate là ứng dụng mobile học từ vựng tiếng Anh theo chủ đề, được xây dựng bằng Flutter.  
> Repo này không bao gồm API key, file cấu hình Firebase và database Supabase thật. Người tải cần tự cấu hình các dịch vụ này trước khi chạy đầy đủ tính năng.

## Giới thiệu

VocabMate là ứng dụng hỗ trợ học từ vựng tiếng Anh bằng flashcard, quiz, theo dõi tiến độ học tập, chatbot AI, notification nhắc học, leaderboard và hệ thống Premium giả lập.

Ứng dụng được phát triển phục vụ đồ án cơ sở 2, tập trung vào việc xây dựng một app học từ vựng có giao diện hiện đại, có xác thực người dùng, lưu dữ liệu thật bằng Supabase và tích hợp Firebase cho các tính năng realtime.

## Trạng thái dự án

**Đã hoàn thành tất cả chức năng chính.**

Các nhóm chức năng đã hoàn thành:

- Authentication
- Home dashboard
- Topic learning
- Flashcard
- Quiz
- Progress tracking
- Personal vocabulary
- Search vocabulary
- Daily streak
- Leaderboard
- Chatbot AI
- Push notification
- Premium mock payment
- Profile screen
- Notification history

## Công nghệ sử dụng

- Flutter
- Dart
- Material 3
- Supabase Auth
- Supabase PostgreSQL
- Firebase Firestore
- Firebase Cloud Messaging
- Gemini API
- flutter_tts
- flutter_local_notifications
- shimmer
- lottie
- http

## Chức năng chi tiết

### Authentication

- Đăng ký tài khoản
- Đăng nhập
- Đăng xuất
- Tự động kiểm tra trạng thái đăng nhập bằng AuthGate
- Tự động tạo profile sau khi người dùng đăng ký

### Home

- Hiển thị thông tin người dùng
- Hiển thị streak học tập
- Hiển thị mục tiêu học hằng ngày
- Hiển thị danh sách chủ đề
- Hiển thị thống kê học tập
- Giao diện gradient hiện đại

### Topic

- Xem danh sách chủ đề
- Xem chi tiết từng chủ đề
- Hiển thị số lượng từ vựng trong mỗi topic
- Hiển thị tiến độ học theo từng topic
- Hỗ trợ topic miễn phí và topic Premium
- Hỗ trợ topic hệ thống và topic cá nhân

### Flashcard

- Học từ vựng bằng flashcard
- Lật thẻ 3D
- Hiển thị từ, phiên âm, nghĩa, ví dụ
- Phát âm từ vựng bằng Text-to-Speech
- Đánh dấu từ đã nhớ
- Đánh dấu từ chưa nhớ
- Lưu tiến độ học vào Supabase
- Hiển thị tổng kết sau khi học xong

### Quiz

- Làm quiz trắc nghiệm theo topic
- Mỗi câu có 4 đáp án
- Random dạng câu hỏi:
  - Từ tiếng Anh → nghĩa tiếng Việt
  - Nghĩa tiếng Việt → từ tiếng Anh
- Tự động highlight đáp án đúng / sai
- Tự động chuyển câu
- Tính điểm
- Tính độ chính xác
- Lưu kết quả quiz
- Lưu chi tiết từng câu trả lời
- Cộng điểm vào profile người dùng
- Hiển thị màn hình kết quả quiz

### Progress Tracking

- Lưu trạng thái từng từ vựng
- Theo dõi số lần đúng / sai
- Theo dõi từ mới, đang học, cần ôn tập, đã thuộc
- Ghi nhận hoạt động học tập hằng ngày
- Hỗ trợ tính daily streak

### Personal Vocabulary

- Tạo topic cá nhân
- Sửa topic cá nhân
- Xóa topic cá nhân
- Thêm từ vựng cá nhân
- Sửa từ vựng cá nhân
- Xóa từ vựng cá nhân
- Phân biệt dữ liệu hệ thống và dữ liệu người dùng

### Search

- Tìm kiếm từ vựng hệ thống
- Tìm kiếm từ vựng cá nhân
- Tìm kiếm theo từ tiếng Anh
- Tìm kiếm theo nghĩa tiếng Việt
- Hiển thị kết quả tìm kiếm rõ ràng

### Daily Streak

- Ghi nhận ngày học
- Tính chuỗi ngày học liên tiếp
- Cập nhật current streak
- Cập nhật longest streak
- Nhắc người dùng duy trì thói quen học tập

### Leaderboard

- Hiển thị bảng xếp hạng người dùng
- Xếp hạng theo tổng điểm quiz
- Hiển thị tên người dùng, điểm, thứ hạng
- Hỗ trợ giới hạn quyền truy cập cho Premium user

### Chatbot AI

- Chatbot hỗ trợ học tiếng Anh
- Tích hợp Gemini API
- Lưu lịch sử chat bằng Firebase Firestore
- Chat realtime
- Hỗ trợ fallback khi chưa cấu hình Gemini API key
- Giới hạn số tin nhắn cho Free user
- Không giới hạn số tin nhắn cho Premium user

### Notification

- Push notification nhắc học
- Nhắc học buổi sáng
- Nhắc học buổi tối nếu chưa học
- Notification chúc mừng khi làm quiz tốt
- Lưu lịch sử notification vào Firestore
- Hiển thị danh sách notification trong app
- Đánh dấu notification đã đọc

### Premium

- Giao diện giới thiệu Premium
- Hiển thị các gói Premium:
  - Gói tháng
  - Gói 3 tháng
  - Gói năm
- Mock payment bằng form thẻ giả
- Loading khi thanh toán
- Thanh toán thành công
- Lưu subscription vào Supabase
- Mở khóa tính năng Premium
- Kiểm tra trạng thái Premium theo hạn sử dụng

### Profile

- Hiển thị thông tin người dùng
- Hiển thị avatar / initials
- Hiển thị tổng điểm
- Hiển thị số quiz đã làm
- Hiển thị streak hiện tại
- Hiển thị streak cao nhất
- Hiển thị trạng thái Premium
- Hỗ trợ đăng xuất

## Free và Premium

| Tính năng | Free | Premium |
|---|---|---|
| Topic học | Giới hạn topic miễn phí | Tất cả topic |
| Quiz | Giới hạn số câu | Không giới hạn |
| Chatbot AI | Giới hạn tin nhắn mỗi ngày | Không giới hạn |
| Leaderboard | Không | Có |
| Badge Premium | Không | Có |
| Notification | Có | Có |
| Flashcard | Có | Có |
| Progress tracking | Có | Có |

## Yêu cầu môi trường

Trước khi chạy project, cần cài:

- Flutter SDK
- Android Studio
- Android Emulator hoặc thiết bị Android thật
- Git
- Supabase project
- Firebase project
- Gemini API key

Kiểm tra Flutter:

```bash
flutter doctor
```

## Cách tải project

```bash
git clone https://github.com/vunguyxxn/vocab_mate.git
cd vocab_mate
```

## Cài đặt thư viện

```bash
flutter pub get
```

## Cách chạy project

Project không hardcode API key trực tiếp trong source code.

Khi chạy app, cần truyền biến môi trường bằng `--dart-define`.

PowerShell:

```powershell
flutter run `
  --dart-define=SUPABASE_URL=YOUR_SUPABASE_URL `
  --dart-define=SUPABASE_ANON_KEY=YOUR_SUPABASE_ANON_KEY `
  --dart-define=GEMINI_API_KEY=YOUR_GEMINI_API_KEY
```

Ví dụ:

```powershell
flutter run `
  --dart-define=SUPABASE_URL=https://your-project.supabase.co `
  --dart-define=SUPABASE_ANON_KEY=your_supabase_anon_key `
  --dart-define=GEMINI_API_KEY=your_gemini_api_key
```

## Cấu hình Supabase

Project sử dụng Supabase cho:

- Authentication
- Database chính
- Profile người dùng
- Topic
- Vocabulary
- Progress tracking
- Quiz attempts
- Quiz answers
- Learning activities
- Subscription Premium

Các bảng chính:

- profiles
- topics
- vocabularies
- user_word_progress
- quiz_attempts
- quiz_answers
- learning_activities
- subscriptions

RPC function cần có:

- increment_score

Trigger cần có:

- Tự động tạo profile sau khi user đăng ký

Nếu chưa tạo database schema trong Supabase, app sẽ không thể sử dụng đầy đủ các chức năng liên quan đến đăng nhập, topic, quiz, progress và Premium.

## Cấu hình Firebase

Project sử dụng Firebase cho:

- Firestore realtime chat
- Notification history
- Firebase Cloud Messaging

Cần thêm file Firebase config vào:

```text
android/app/google-services.json
```

File này không được commit lên GitHub public repo.

## Cấu hình Gemini API

Gemini API dùng cho chatbot AI.

API key được truyền khi chạy app:

```powershell
--dart-define=GEMINI_API_KEY=YOUR_GEMINI_API_KEY
```

Không hardcode Gemini API key trong source code.

## File không được commit

Không đưa các file chứa key, thông tin máy cá nhân hoặc thông tin nhạy cảm lên GitHub:

```text
.env
android/local.properties
android/app/google-services.json
*.jks
key.properties
```

Nên kiểm tra file `.gitignore` để chắc chắn các file trên đã được bỏ qua.

## Cấu trúc thư mục

```text
lib/
├─ main.dart
├─ app.dart
├─ core/
│  ├─ theme/
│  ├─ constants/
│  ├─ utils/
│  └─ widgets/
├─ services/
└─ features/
   ├─ auth/
   ├─ home/
   ├─ topics/
   ├─ vocabulary/
   ├─ flashcard/
   ├─ quiz/
   ├─ progress/
   ├─ chatbot/
   ├─ premium/
   ├─ notification/
   └─ profile/
```

## Lưu ý khi chạy Text-to-Speech

Nếu chạy trên Android Emulator API 34 và gặp lỗi Text-to-Speech `ERROR_OUTPUT (-4)`, nên test lại trên thiết bị Android thật.

Lỗi này có thể do emulator, không nhất thiết là lỗi code.

## Giao diện

Ứng dụng sử dụng phong cách Material 3 với:

- Gradient header
- Card bo góc
- Shadow mềm
- Button gradient
- Loading shimmer
- Empty state
- Animation khi chuyển màn hình
- Progress bar động
- Bottom navigation

## Tài khoản test

Repo không cung cấp sẵn tài khoản test.

Người dùng có thể đăng ký tài khoản mới trực tiếp trong app.

## Ghi chú cho người tải repo

Sau khi clone repo, người tải cần tự cấu hình:

- Supabase project
- Supabase database schema
- Supabase anon key
- Firebase project
- `google-services.json`
- Gemini API key

Sau khi cấu hình đầy đủ, app có thể chạy và sử dụng toàn bộ chức năng.

## Tác giả

Nguyen Tuan Vu

GitHub: vunguyxxn
