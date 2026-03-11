# family-map-flutter

以 Flutter 重寫的 Family Map 前端（新資料夾），提供跨平台地圖策略：

- **Android / Web**：使用 **Mapbox tiles**（透過 `flutter_map` 載入 Mapbox style）。
- **iOS**：使用 Apple 內建 **MapKit**（`apple_maps_flutter`）。

> 這版是對齊現有 MVP 功能的 Flutter 版本：載入 `/places`、搜尋、地圖顯示、點位清單與選取。

## 啟動方式

```bash
cd family-map-flutter
flutter pub get
flutter run -d chrome \
  --dart-define=API_BASE_URL=http://localhost:8080 \
  --dart-define=MAPBOX_ACCESS_TOKEN=YOUR_MAPBOX_TOKEN
```

Android：

```bash
flutter run -d android \
  --dart-define=API_BASE_URL=http://10.0.2.2:8080 \
  --dart-define=MAPBOX_ACCESS_TOKEN=YOUR_MAPBOX_TOKEN
```

iOS（MapKit，不需 Mapbox Token 也可顯示）：

```bash
flutter run -d ios --dart-define=API_BASE_URL=http://localhost:8080
```

## 參數

- `API_BASE_URL`：後端 API Base URL（預設 `http://localhost:8080`）
- `MAPBOX_ACCESS_TOKEN`：Mapbox token（Android/Web 必填）

## 後續可擴充

- 新增點位提交流程（對接 `/places` POST）
- 行程規劃頁（對接 `/planner/optimize`）
- 管理端審核流程
