# Family Map Backend

親子遊玩地圖系統後端服務

## 技術棧

- Java 17
- Spring Boot 3.2.x
- Spring Data JPA
- Spring Security
- PostgreSQL + PostGIS
- Flyway (資料庫遷移)
- Lombok
- MapStruct

## 快速開始

### 環境需求

- JDK 17+
- Maven 3.8+
- PostgreSQL 14+ (含 PostGIS 擴展)

### 資料庫設定

1. 建立資料庫：
```sql
CREATE DATABASE family_map;
```

2. 啟用 PostGIS 擴展：
```sql
\c family_map;
CREATE EXTENSION IF NOT EXISTS postgis;
```

### 啟動應用

```bash
# 編譯
mvn clean compile

# 執行
mvn spring-boot:run
```

應用將在 http://localhost:8080/api 啟動

### API 文件

啟動後訪問：
- Swagger UI: http://localhost:8080/api/swagger-ui.html
- OpenAPI JSON: http://localhost:8080/api/docs

## 專案結構

```
src/main/java/com/familymap/
├── controller/          # REST API 控制器
├── service/             # 商業邏輯層
├── repository/          # 資料存取層
├── model/
│   ├── entity/          # JPA 實體
│   └── dto/             # 資料傳輸物件
├── config/              # 配置類別
└── algorithm/           # 演算法實作
```

## 資料庫遷移

Flyway 遷移腳本位於 `src/main/resources/db/migration/`

- V1: 使用者表
- V2: 景點表 (含 PostGIS)
- V3: 行程表
- V4: 行程景點關聯表
- V5: 審核記錄表
- V6: 使用者評論表

## 主要 API

### 景點
- `GET /api/places` - 獲取所有已審核景點
- `GET /api/places/{id}` - 獲取景點詳情
- `GET /api/places/nearby` - 附近景點查詢
- `POST /api/places` - 提交新景點

### 行程規劃
- `POST /api/planner/optimize` - 智慧行程規劃

### 審核管理
- `GET /api/admin/reviews/pending` - 待審核列表
- `POST /api/admin/reviews/{id}/approve` - 通過審核
- `POST /api/admin/reviews/{id}/reject` - 拒絕審核

## 配置

編輯 `src/main/resources/application.yml`：

```yaml
spring:
  datasource:
    url: jdbc:postgresql://localhost:5432/family_map
    username: postgres
    password: your_password
```
