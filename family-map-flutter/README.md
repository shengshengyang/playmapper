# family-map-flutter

以 Flutter 重寫的 Family Map 前端（新資料夾），提供跨平台地圖策略：

- **iOS**：使用 Apple 內建 **MapKit**（`apple_maps_flutter`）。
- **Android / Web / macOS**：使用 **OpenStreetMap**（`flutter_map`）。

> 這版是對齊現有 MVP 功能的 Flutter 版本：載入 `/places`、搜尋、地圖顯示、點位清單與選取。

## 先補齊 Apple 平台專案（iOS / macOS）

如果你看到這個錯誤：

```text
Error: No macOS desktop project configured.
```

代表這個資料夾目前還沒有 Apple 平台 host project。請先執行：

```bash
cd family-map-flutter
./tool/setup_apple_platforms.sh
```

此腳本會呼叫 `flutter create . --platforms=ios,macos`，並嘗試補上 iOS 定位權限描述（MapKit 常見需求）。

## 啟動方式

```bash
cd family-map-flutter
flutter pub get
flutter run -d chrome \
  --dart-define=API_BASE_URL=http://localhost:8080
```

Android：

```bash
flutter run -d android \
  --dart-define=API_BASE_URL=http://10.0.2.2:8080
```

iOS（MapKit）：

```bash
flutter run -d ios --dart-define=API_BASE_URL=http://localhost:8080
```

macOS：

```bash
flutter run -d macos --dart-define=API_BASE_URL=http://localhost:8080
```

## 參數

- `API_BASE_URL`：後端 API Base URL（預設 `http://localhost:8080`）

## 後續可擴充

- 新增點位提交流程（對接 `/places` POST）
- 行程規劃頁（對接 `/planner/optimize`）
- 管理端審核流程
