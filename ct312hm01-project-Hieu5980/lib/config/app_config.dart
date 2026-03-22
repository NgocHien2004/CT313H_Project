class AppConfig {
  // Nếu chạy trên Android Emulator:
  static const String apiBaseUrl = 'http://10.0.2.2:3000/api';

  // Nếu chạy trên thiết bị thật (dùng IP máy tính):
  //static const String apiBaseUrl = 'http://192.168.x.x:3000/api';

  // Nếu chạy trên iOS Simulator:
  //static const String apiBaseUrl = 'http://127.0.0.1:3000/api';
}
