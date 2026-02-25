# 親子遊玩地圖系統 - 專案規劃書

## 一、系統功能架構

### 1.1 核心功能模組

#### 📍 景點管理模組
- 景點基本資訊（名稱、地址、經緯度、照片）
- 親子屬性（適合年齡、設施標籤、安全等級）
- 建議停留時間
- 營業時間、票價資訊
- 評分與評論系統

#### 🗺️ 地圖展示模組
- 互動式地圖介面（建議使用 Leaflet 或 Google Maps API）
- 景點標記與分類篩選
- 地圖搜尋與定位
- 景點詳情彈窗

#### 🚗 智慧行程規劃模組
- **路徑最佳化算法**
  - 考慮景點間距離
  - 考慮開車時間與休息需求
  - 考慮景點營業時間
  - 考慮用餐時段
- **時間分析**
  - 自動插入用餐時間（11:30-13:30, 17:30-19:30）
  - 每開車2小時建議休息15-30分鐘
  - 考慮景點建議停留時間
- **多日行程支援**
- **行程匯出與分享**

#### 👥 使用者互動模組
- 景點建議提交表單
- 使用者收藏與歷史記錄
- 行程儲存與管理
- 社群分享功能

#### 🔐 後台管理模組
- 景點審核系統（待審核/已通過/已拒絕）
- 景點資訊編輯
- 使用者管理
- 數據統計儀表板

---

## 二、技術架構設計

### 2.1 前端技術棧（Vue 3）

```
vue3-family-map-frontend/
├── src/
│   ├── components/
│   │   ├── map/
│   │   │   ├── MapContainer.vue          # 地圖主容器
│   │   │   ├── PlaceMarker.vue           # 景點標記
│   │   │   └── RouteLayer.vue            # 路線圖層
│   │   ├── planner/
│   │   │   ├── PlannerWizard.vue         # 行程規劃嚮導
│   │   │   ├── PlaceSelector.vue         # 景點選擇器
│   │   │   ├── ScheduleTimeline.vue      # 時間軸視圖
│   │   │   └── RouteOptimizer.vue        # 路徑優化控制
│   │   ├── place/
│   │   │   ├── PlaceCard.vue             # 景點卡片
│   │   │   ├── PlaceDetail.vue           # 景點詳情
│   │   │   ├── PlaceForm.vue             # 景點提交表單
│   │   │   └── AgeFilter.vue             # 年齡篩選器
│   │   └── admin/
│   │       ├── ReviewQueue.vue           # 審核佇列
│   │       └── PlaceEditor.vue           # 景點編輯器
│   ├── views/
│   │   ├── MapView.vue                   # 地圖主頁
│   │   ├── PlannerView.vue               # 行程規劃頁
│   │   ├── PlaceDetailView.vue           # 景點詳情頁
│   │   ├── MyTripsView.vue               # 我的行程
│   │   └── AdminView.vue                 # 後台管理
│   ├── stores/
│   │   ├── mapStore.js                   # 地圖狀態
│   │   ├── placesStore.js                # 景點數據
│   │   ├── plannerStore.js               # 行程規劃
│   │   └── userStore.js                  # 使用者狀態
│   ├── services/
│   │   ├── api.js                        # API 封裝
│   │   ├── mapService.js                 # 地圖服務
│   │   ├── routeOptimizer.js             # 路徑優化算法
│   │   └── geocoding.js                  # 地理編碼
│   └── utils/
│       ├── timeCalculator.js             # 時間計算工具
│       └── distanceCalculator.js         # 距離計算
```

**前端關鍵套件：**
- Vue 3 + Vue Router + Pinia
- Leaflet / Google Maps API
- Turf.js（地理空間計算）
- Day.js（時間處理）
- Vite（建構工具）

---

### 2.2 後端技術棧（Java Spring Boot）

```
family-map-backend/
├── src/main/java/com/familymap/
│   ├── controller/
│   │   ├── PlaceController.java          # 景點 CRUD
│   │   ├── PlannerController.java        # 行程規劃
│   │   ├── ReviewController.java         # 審核管理
│   │   └── UserController.java           # 使用者管理
│   ├── service/
│   │   ├── PlaceService.java
│   │   ├── RouteOptimizationService.java # 路徑優化核心
│   │   ├── ScheduleService.java          # 行程排程邏輯
│   │   ├── GeocodingService.java         # 地理編碼
│   │   └── ReviewService.java            # 審核流程
│   ├── repository/
│   │   ├── PlaceRepository.java
│   │   ├── TripRepository.java
│   │   ├── ReviewRepository.java
│   │   └── UserRepository.java
│   ├── model/
│   │   ├── entity/
│   │   │   ├── Place.java                # 景點實體
│   │   │   ├── Trip.java                 # 行程實體
│   │   │   ├── Review.java               # 審核實體
│   │   │   └── User.java                 # 使用者實體
│   │   └── dto/
│   │       ├── PlaceDTO.java
│   │       ├── TripPlanRequest.java
│   │       └── OptimizedRouteResponse.java
│   ├── algorithm/
│   │   ├── TSPSolver.java                # 旅行商問題求解器
│   │   ├── TimeWindowScheduler.java      # 時間窗口排程
│   │   └── BreakTimeCalculator.java      # 休息時間計算
│   └── config/
│       ├── SecurityConfig.java
│       └── CorsConfig.java
```

**後端關鍵技術：**
- Spring Boot 3
- Spring Data JPA
- Spring Security（JWT 認證）
- MapStruct（DTO 映射）
- OR-Tools / JGraphT（路徑優化）
- Hibernate Spatial（地理空間查詢）

---

## 三、資料庫設計

### 3.1 資料庫選擇建議

#### ✅ **推薦：PostgreSQL + PostGIS**

**理由：**
1. **地理空間支援**：PostGIS 是最強大的開源地理空間擴展
   - 支援地理距離計算（ST_Distance）
   - 支援地理範圍查詢（ST_DWithin）
   - 支援路徑計算（pgRouting）
   
2. **關聯數據管理**：景點、使用者、行程、審核等有明確關聯
3. **ACID 保證**：確保數據一致性
4. **成熟穩定**：大量文檔和社群支援
5. **全文搜尋**：內建 Full-Text Search 功能

#### ⚠️ **不推薦：Elasticsearch 作為主資料庫**

**原因：**
- ES 是搜尋引擎，不是關聯型資料庫
- 缺乏事務支援（ACID）
- 不適合頻繁更新的審核流程
- 對複雜關聯查詢支援較弱

**建議使用方式：**
- **主資料庫：PostgreSQL + PostGIS**
- **搜尋加速層：Elasticsearch**（選配，當景點數超過 10,000 筆時考慮）

---

### 3.2 PostgreSQL 資料表設計

```sql
-- 安裝 PostGIS 擴展
CREATE EXTENSION IF NOT EXISTS postgis;

-- 1. 景點表
CREATE TABLE places (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(200) NOT NULL,
    description TEXT,
    address VARCHAR(500),
    location GEOGRAPHY(POINT, 4326) NOT NULL, -- PostGIS 地理類型
    min_age INT DEFAULT 0,                     -- 最小適合年齡
    max_age INT DEFAULT 18,                    -- 最大適合年齡
    suggested_duration_minutes INT,            -- 建議停留時間（分鐘）
    opening_hours JSONB,                       -- 營業時間 JSON
    facilities JSONB,                          -- 設施標籤 ["遊樂場", "餐廳", "停車場"]
    ticket_price DECIMAL(10,2),
    phone VARCHAR(20),
    website VARCHAR(500),
    images TEXT[],                             -- 照片 URL 陣列
    rating DECIMAL(3,2) DEFAULT 0,
    review_count INT DEFAULT 0,
    status VARCHAR(20) DEFAULT 'pending',      -- pending, approved, rejected
    submitter_id BIGINT,                       -- 提交者 ID
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT check_age_range CHECK (min_age <= max_age),
    CONSTRAINT check_status CHECK (status IN ('pending', 'approved', 'rejected'))
);

-- 地理空間索引
CREATE INDEX idx_places_location ON places USING GIST(location);
CREATE INDEX idx_places_status ON places(status);
CREATE INDEX idx_places_age_range ON places(min_age, max_age);

-- 2. 使用者表
CREATE TABLE users (
    id BIGSERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role VARCHAR(20) DEFAULT 'user',          -- user, admin
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 3. 行程表
CREATE TABLE trips (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT REFERENCES users(id),
    name VARCHAR(200) NOT NULL,
    start_date DATE,
    end_date DATE,
    child_age INT,                             -- 同行孩童年齡
    preferences JSONB,                         -- 偏好設定
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 4. 行程景點關聯表
CREATE TABLE trip_places (
    id BIGSERIAL PRIMARY KEY,
    trip_id BIGINT REFERENCES trips(id) ON DELETE CASCADE,
    place_id BIGINT REFERENCES places(id),
    day_number INT NOT NULL,                   -- 第幾天
    visit_order INT NOT NULL,                  -- 當天的順序
    scheduled_arrival TIME,                    -- 預計到達時間
    scheduled_departure TIME,                  -- 預計離開時間
    notes TEXT,
    
    UNIQUE(trip_id, day_number, visit_order)
);

-- 5. 審核記錄表
CREATE TABLE place_reviews (
    id BIGSERIAL PRIMARY KEY,
    place_id BIGINT REFERENCES places(id) ON DELETE CASCADE,
    reviewer_id BIGINT REFERENCES users(id),
    action VARCHAR(20) NOT NULL,               -- approved, rejected, pending
    comment TEXT,
    reviewed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 6. 使用者評論表
CREATE TABLE place_ratings (
    id BIGSERIAL PRIMARY KEY,
    place_id BIGINT REFERENCES places(id) ON DELETE CASCADE,
    user_id BIGINT REFERENCES users(id),
    rating INT CHECK (rating >= 1 AND rating <= 5),
    comment TEXT,
    visit_date DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    UNIQUE(place_id, user_id)
);
```

---

## 四、核心算法設計

### 4.1 路徑優化算法

**問題類型：** 帶時間窗口的旅行商問題（TSP with Time Windows）

**算法選擇：**

1. **小規模（< 10 個景點）：** 貪心算法 + 2-opt 優化
2. **中規模（10-20 個景點）：** 遺傳算法
3. **大規模（> 20 個景點）：** 使用 Google OR-Tools 的 CP-SAT 求解器

**考慮因素：**
```java
public class RouteOptimizationService {
    
    // 優化目標權重
    private static final double DISTANCE_WEIGHT = 0.4;      // 總距離
    private static final double TIME_WEIGHT = 0.3;          // 總時間
    private static final double AGE_MATCH_WEIGHT = 0.2;     // 年齡適配度
    private static final double RATING_WEIGHT = 0.1;        // 景點評分
    
    public OptimizedRoute optimizeRoute(List<Place> places, 
                                       TripConstraints constraints) {
        // 1. 計算景點間距離矩陣
        double[][] distanceMatrix = calculateDistanceMatrix(places);
        
        // 2. 計算景點間開車時間矩陣
        int[][] drivingTimeMatrix = calculateDrivingTime(distanceMatrix);
        
        // 3. 應用時間窗口約束（營業時間）
        TimeWindow[] timeWindows = extractTimeWindows(places);
        
        // 4. 執行 TSP 求解
        List<Integer> route = solveTSP(
            distanceMatrix, 
            drivingTimeMatrix, 
            timeWindows,
            constraints
        );
        
        // 5. 插入用餐和休息時間
        Schedule schedule = insertBreaksAndMeals(route, drivingTimeMatrix);
        
        return new OptimizedRoute(route, schedule);
    }
}
```

### 4.2 時間排程邏輯

```java
public class TimeWindowScheduler {
    
    public Schedule createSchedule(List<Place> orderedPlaces, 
                                  LocalDateTime startTime) {
        Schedule schedule = new Schedule();
        LocalDateTime currentTime = startTime;
        int continuousDrivingMinutes = 0;
        
        for (int i = 0; i < orderedPlaces.size(); i++) {
            Place place = orderedPlaces.get(i);
            
            // 檢查是否需要午餐/晚餐
            currentTime = checkAndInsertMealTime(schedule, currentTime);
            
            // 計算到下一個景點的開車時間
            if (i > 0) {
                int drivingTime = calculateDrivingTime(
                    orderedPlaces.get(i-1), 
                    place
                );
                continuousDrivingMinutes += drivingTime;
                
                // 每開車 2 小時休息 20 分鐘
                if (continuousDrivingMinutes >= 120) {
                    schedule.addBreak(currentTime, 20);
                    currentTime = currentTime.plusMinutes(20);
                    continuousDrivingMinutes = 0;
                }
                
                currentTime = currentTime.plusMinutes(drivingTime);
            }
            
            // 檢查景點是否營業
            if (!place.isOpenAt(currentTime)) {
                currentTime = place.getNextOpeningTime(currentTime);
            }
            
            // 安排景點停留
            schedule.addPlace(
                place, 
                currentTime, 
                place.getSuggestedDuration()
            );
            currentTime = currentTime.plusMinutes(place.getSuggestedDuration());
        }
        
        return schedule;
    }
    
    private LocalDateTime checkAndInsertMealTime(Schedule schedule, 
                                                 LocalDateTime time) {
        LocalTime timeOfDay = time.toLocalTime();
        
        // 午餐時段 11:30-13:30
        if (timeOfDay.isAfter(LocalTime.of(11, 30)) && 
            timeOfDay.isBefore(LocalTime.of(13, 30)) &&
            !schedule.hasLunchToday()) {
            schedule.addMeal("午餐", time, 60);
            return time.plusMinutes(60);
        }
        
        // 晚餐時段 17:30-19:30
        if (timeOfDay.isAfter(LocalTime.of(17, 30)) && 
            timeOfDay.isBefore(LocalTime.of(19, 30)) &&
            !schedule.hasDinnerToday()) {
            schedule.addMeal("晚餐", time, 60);
            return time.plusMinutes(60);
        }
        
        return time;
    }
}
```

---

## 五、API 設計

### 5.1 景點相關 API

```
GET    /api/places                    # 獲取景點列表（支援地理範圍篩選）
GET    /api/places/{id}               # 獲取景點詳情
POST   /api/places                    # 提交新景點（需登入）
PUT    /api/places/{id}               # 更新景點（管理員）
DELETE /api/places/{id}               # 刪除景點（管理員）

GET    /api/places/nearby             # 附近景點
  ?lat=24.1477&lng=120.6736&radius=10000&minAge=3&maxAge=8

GET    /api/places/search             # 搜尋景點
  ?keyword=動物園&age=5&facilities=停車場
```

### 5.2 行程規劃 API

```
POST   /api/planner/optimize          # 智慧行程規劃
  Request Body:
  {
    "placeIds": [1, 5, 8, 12],
    "childAge": 5,
    "startTime": "2024-03-20T09:00:00",
    "preferences": {
      "includeRestaurants": true,
      "maxDrivingTimePerSegment": 60
    }
  }
  
  Response:
  {
    "optimizedRoute": [1, 8, 5, 12],
    "totalDistance": 45.2,
    "totalDuration": 420,
    "schedule": [
      {
        "type": "place",
        "placeId": 1,
        "arrivalTime": "09:00",
        "departureTime": "10:30",
        "duration": 90
      },
      {
        "type": "driving",
        "duration": 25,
        "distance": 12.3
      },
      {
        "type": "meal",
        "mealType": "lunch",
        "startTime": "12:00",
        "duration": 60
      }
    ]
  }

POST   /api/trips                     # 儲存行程
GET    /api/trips                     # 我的行程列表
GET    /api/trips/{id}                # 行程詳情
PUT    /api/trips/{id}                # 更新行程
DELETE /api/trips/{id}                # 刪除行程
```

### 5.3 審核管理 API

```
GET    /api/admin/reviews/pending     # 待審核景點列表
POST   /api/admin/reviews/{id}/approve # 通過審核
POST   /api/admin/reviews/{id}/reject  # 拒絕審核
GET    /api/admin/reviews/history     # 審核歷史
```

---

## 六、開發階段規劃

### Phase 1: 基礎架構（2-3 週）
- [ ] 專案環境建置
- [ ] 資料庫設計與建立
- [ ] 基礎 API 框架
- [ ] Vue 專案架構
- [ ] 地圖元件整合

### Phase 2: 核心功能（3-4 週）
- [ ] 景點 CRUD 功能
- [ ] 地圖展示與搜尋
- [ ] 使用者認證系統
- [ ] 基礎行程規劃（手動排序）

### Phase 3: 智慧規劃（2-3 週）
- [ ] 路徑優化算法實作
- [ ] 時間排程邏輯
- [ ] 用餐時間自動插入
- [ ] 休息時間計算

### Phase 4: 審核系統（1-2 週）
- [ ] 景點提交功能
- [ ] 後台審核介面
- [ ] 審核流程邏輯
- [ ] 通知機制

### Phase 5: 優化與上線（2 週）
- [ ] 效能優化
- [ ] 測試與 Bug 修復
- [ ] 文檔撰寫
- [ ] 部署上線

**總開發時間預估：10-14 週**

---

## 七、技術挑戰與解決方案

### 挑戰 1: 路徑優化性能
**解決方案：**
- 使用成熟的優化庫（OR-Tools）
- 對大量景點設定上限（建議單日不超過 8 個）
- 實作快取機制

### 挑戰 2: 地理計算準確性
**解決方案：**
- 使用 PostGIS 的地理類型（考慮地球曲率）
- 整合 Google Directions API 獲取實際路況
- 開車時間考慮交通尖峰時段

### 挑戰 3: 即時性與資料一致性
**解決方案：**
- 營業時間變更：定期更新機制
- 景點資訊：版本控制與審核歷史
- 使用樂觀鎖處理並發更新

---

## 八、部署建議

### 8.1 基礎設施

```
架構：
[ 使用者 ]
    ↓
[ Nginx (反向代理) ]
    ↓
[ Spring Boot (後端) ] ←→ [ PostgreSQL + PostGIS ]
    ↓
[ Vue 3 (前端靜態檔) ]

可選增強：
- Redis (快取熱門查詢結果)
- Elasticsearch (全文搜尋)
- MinIO / S3 (圖片儲存)
```

### 8.2 建議雲服務

- **AWS:** EC2 + RDS PostgreSQL + S3
- **GCP:** Compute Engine + Cloud SQL + Cloud Storage
- **Azure:** VM + Azure Database for PostgreSQL

---

## 九、延伸功能（未來版本）

1. **社群功能**
   - 使用者遊記分享
   - 景點照片上傳
   - 行程範本庫

2. **進階規劃**
   - 天氣預報整合
   - 即時路況查詢
   - 預算估算

3. **個人化推薦**
   - 基於歷史行程的 AI 推薦
   - 相似使用者的行程參考

4. **多人協作**
   - 共同編輯行程
   - 投票決定景點

---

## 十、參考資源

### 開發文檔
- PostGIS: https://postgis.net/documentation/
- Leaflet: https://leafletjs.com/
- OR-Tools: https://developers.google.com/optimization
- Turf.js: https://turfjs.org/

### 演算法參考
- TSP 演算法: https://en.wikipedia.org/wiki/Travelling_salesman_problem
- Vehicle Routing Problem: https://en.wikipedia.org/wiki/Vehicle_routing_problem

---

**專案負責人：**  
**建立日期：** 2026-02-25  
**版本：** v1.0
