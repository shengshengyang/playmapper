# 親子遊玩地圖系統 (Family Map)

一個以「親子基礎設施點位」為核心的地圖平台，MVP 先聚焦建立與管理設施點（如親子廁所、尿布台、哺乳室），後續再導入 AI 規劃。

## 系統架構

```
┌─────────────────────────────────────────────────────────────┐
│                        Nginx (反向代理)                      │
├─────────────────┬─────────────────┬─────────────────────────┤
│  前端 (Vue 3)   │  管理後台       │   後端 API              │
│  :80           │  :8081          │   :8080                 │
│  family-map-   │  family-map-    │   family-map-           │
│  frontend      │  admin          │   backend               │
└─────────────────┴─────────────────┴───────────┬─────────────┘
                                                │
                                        ┌───────▼───────┐
                                        │  PostgreSQL   │
                                        │  + PostGIS    │
                                        │  :5432        │
                                        └───────────────┘
```

## 技術棧

### 後端
- Java 17
- Spring Boot 3.2.x
- Spring Data JPA
- Spring Security (JWT)
- PostgreSQL + PostGIS
- Flyway (資料庫遷移)

### 前端
- Vue 3 + Vite（既有版本）
- Flutter（新版本，位於 `family-map-flutter/`）
- Vue Router + Pinia
- Tailwind CSS
- Leaflet (地圖)
- Turf.js (地理計算)

## 快速開始

### 使用 Docker Compose（推薦）

#### 1. 完整部署（含 PostgreSQL）

```bash
# 建立環境變數檔
cp .env.example .env
# 編輯 .env 設定密碼

# 啟動所有服務
docker-compose -f docker-compose.full.yml up -d

# 查看日誌
docker-compose -f docker-compose.full.yml logs -f
```

#### 2. 開發模式（含 pgAdmin）

```bash
docker-compose -f docker-compose.dev.yml up -d
```

#### 3. 生產部署（��用外部資料庫）

```bash
# 設定外部資料庫連線
export DATABASE_URL=jdbc:postgresql://your-db-host:5432/family_map
export DATABASE_USERNAME=your_username
export DATABASE_PASSWORD=your_password
export JWT_SECRET=your_secure_secret

# 啟動服務
docker-compose up -d
```

### 本地開發

#### 後端

```bash
cd family-map-backend

# 確保 PostgreSQL 已啟動
# 建立資料庫
psql -U postgres -c "CREATE DATABASE family_map;"

# 啟動應用
mvn spring-boot:run
```

#### 前端

```bash
cd family-map-frontend
npm install
npm run dev
```

#### 管理後台

```bash
cd family-map-admin
npm install
npm run dev
```

## 服務網址

| 服務 | 網址 | 說明 |
|------|------|------|
| 前端 | http://localhost | 使用者端 |
| 管理後台 | http://localhost:8081 | 管理員登入 |
| 後端 API | http://localhost:8080/api | REST API |
| Swagger | http://localhost:8080/api/swagger-ui.html | API 文件 |
| pgAdmin | http://localhost:5050 | 資料庫管理 (開發模式) |

### 預設帳號

| 服務 | 帳號 | 密碼 |
|------|------|------|
| 管理後台 | admin | admin123 |
| pgAdmin | admin@familymap.com | admin123 |
| PostgreSQL | postgres | postgres123 |

## 專案結構

```
playmaker/
├── family-map-backend/       # Spring Boot 後端
│   ├── src/main/java/
│   │   └── com/familymap/
│   │       ├── controller/   # REST 控制器
│   │       ├── service/      # 商業邏輯
│   │       ├── repository/   # 資料存取
│   │       ├── model/        # 實體與 DTO
│   │       ├── config/       # 配置類別
│   │       └── algorithm/    # TSP 演算法
│   ├── src/main/resources/
│   │   ├── application.yml
│   │   └── db/migration/     # Flyway 遷移
│   ├── Dockerfile
│   └── pom.xml
│
├── family-map-frontend/      # Vue 3 前端
│   ├── src/
│   │   ├── components/       # 組件
│   │   ├── views/            # 頁面
│   │   ├── stores/           # Pinia 狀態
│   │   ├── services/         # API 服務
│   │   └── router/           # 路由
│   ├── Dockerfile
│   ├── nginx.conf
│   └── package.json
│
├── family-map-flutter/       # Flutter 前端（跨平台地圖：Android/Web Mapbox、iOS MapKit）
│   ├── lib/
│   ├── pubspec.yaml
│   └── README.md
│
├── family-map-admin/         # 管理後台
│   ├── src/
│   │   ├── views/            # 頁面
│   │   ├── stores/           # 狀態管理
│   │   └── services/         # API
│   ├── Dockerfile
│   ├── nginx.conf
│   └── package.json
│
├── docker-compose.yml        # 精簡版 (外部資料庫)
├── docker-compose.full.yml   # 完整版 (含 PostgreSQL)
├── docker-compose.dev.yml    # 開發版 (含 pgAdmin)
└── .env.example              # 環境變數範本
```

## 主要功能

### 現階段 MVP（點位優先）
- 🗺️ 地圖探索與親子基礎設施點搜尋
- 🧷 以「親子廁所／尿布台／哺乳室」等類型建立點位
- ✅ 前後台點位審核與管理

### 下一階段
- 🤖 AI 行程規劃（依家庭需求與設施可用性推薦）
- 🚗 路線優化與停留時間建議

## Docker 指令

```bash
# 建構所有映像
docker-compose build

# 啟動服務
docker-compose up -d

# 停止服務
docker-compose down

# 查看日誌
docker-compose logs -f backend

# 進入容器
docker-compose exec backend sh

# 清理（包含 volumes）
docker-compose down -v
```

## 環境變數

| 變數 | 說明 | 預設值 |
|------|------|--------|
| SPRING_DATASOURCE_URL | 資料庫連線 | jdbc:postgresql://postgres:5432/family_map |
| SPRING_DATASOURCE_USERNAME | 資料庫帳號 | postgres |
| SPRING_DATASOURCE_PASSWORD | 資料庫密碼 | postgres |
| JWT_SECRET | JWT 金鑰 | (需變更) |
| JAVA_OPTS | JVM 參數 | -Xms256m -Xmx512m |

## 開發注意事項

1. **PostGIS**: 確保 PostgreSQL 已安裝 PostGIS 擴展
2. **Flyway**: 資料庫遷移腳本在 `db/migration/` 目錄
3. **CORS**: 開發環境已配置允許 localhost
4. **JWT**: 生產環境請更換安全的 JWT_SECRET

## License

MIT
