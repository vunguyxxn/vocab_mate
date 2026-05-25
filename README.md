# VocabMate

VocabMate là ứng dụng mobile học từ vựng tiếng Anh theo chủ đề, được xây dựng bằng Flutter.

Ứng dụng hỗ trợ học từ vựng bằng flashcard, làm quiz trắc nghiệm, lưu tiến độ học tập, thống kê điểm số, lịch sử quiz, premium mock, chatbot AI và notification.

## Công nghệ sử dụng

- Flutter
- Dart
- Supabase Auth
- Supabase PostgreSQL
- Firebase Firestore
- Firebase Cloud Messaging
- Gemini API
- flutter_tts

## Tính năng chính

- Đăng ký, đăng nhập, đăng xuất
- Học từ vựng theo chủ đề
- Flashcard có lật thẻ
- Phát âm từ vựng bằng Text-to-Speech
- Đánh dấu từ đã nhớ / chưa nhớ
- Quiz trắc nghiệm 4 đáp án
- Lưu điểm quiz
- Theo dõi tiến độ học từng từ
- Daily streak
- Premium mock
- Chatbot AI
- Notification nhắc học

## Trạng thái hiện tại

Đã hoàn thành:

- Authentication
- Home screen
- Topic list
- Topic detail
- Flashcard
- Quiz
- Quiz result
- Progress tracking
- Lưu kết quả quiz vào Supabase

Đang phát triển:

- Từ vựng cá nhân
- Tìm kiếm từ vựng
- Leaderboard
- Chatbot Gemini
- Push notification
- Premium payment mock
- Profile screen đầy đủ

## Yêu cầu cài đặt

Trước khi chạy project, cần cài:

- Flutter SDK
- Android Studio
- Android Emulator hoặc thiết bị Android thật
- Git
- Supabase project
- Firebase project nếu muốn dùng chat / notification
- Gemini API key nếu muốn dùng chatbot AI

Kiểm tra Flutter:

```bash
flutter doctor
```

## Cách tải project

```bash
git clone https://github.com/vunguyxxn/vocab_mate.git
cd vocab_mate
```

## Cài thư viện

```bash
flutter pub get
```

## Cách chạy project

Project này không hardcode API key trong source code.

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

Nếu chưa dùng chatbot AI thì vẫn có thể để trống `GEMINI_API_KEY`, nhưng chatbot thật sẽ không hoạt động.

## Cấu hình Supabase

Project cần các bảng sau trong Supabase:

- profiles
- topics
- vocabularies
- user_word_progress
- quiz_attempts
- quiz_answers
- learning_activities
- subscriptions

Project cũng cần RPC function:

- increment_score

Và trigger tự tạo profile sau khi người dùng đăng ký.

Nếu database chưa được tạo, app có thể chạy nhưng các màn hình đăng nhập, topic, quiz, progress sẽ lỗi.

## Cấu hình Firebase

Firebase dùng cho:

- Firestore realtime chat
- Notification history
- Firebase Cloud Messaging

Cần đặt file cấu hình Firebase tại:

```text
android/app/google-services.json
```

File này không nên commit lên GitHub public repository.

Nếu chưa cấu hình Firebase, các tính năng chat và notification có thể chưa hoạt động.

## File không được commit

Không đưa các file chứa thông tin cá nhân hoặc key thật lên GitHub:

```text
.env
android/local.properties
android/app/google-services.json
*.jks
key.properties
```

Các key nên truyền bằng `--dart-define` khi chạy app.

## Lưu ý khi chạy Text-to-Speech

Nếu chạy trên Android Emulator API 34 và gặp lỗi Text-to-Speech `ERROR_OUTPUT (-4)`, nên test lại trên thiết bị Android thật.

Đây có thể là lỗi do emulator, không nhất thiết là lỗi code.

## Cấu trúc thư mục

```text
lib/
├─ main.dart
├─ app.dart
├─ core/
│  ├─ theme/
│  ├─ constants/
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

## Ghi chú cho người tải repo

Repo này chưa kèm database Supabase hoàn chỉnh và chưa kèm file Firebase config.

Để chạy đầy đủ, người tải cần tự tạo Supabase project, tạo database schema, thêm sample data, cấu hình Firebase và truyền API key khi chạy.

## Tác giả

Nguyen Tuan Vu

GitHub: vunguyxxn
