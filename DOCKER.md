# Docker 操作指南

## 映像建構

### 建構所有映像
```bash
# 含 PostgreSQL（完整版）
docker-compose -f docker-compose.full.yml build

# 不含 PostgreSQL（需外部資料庫）
docker-compose -f docker-compose.yml build

# 清除快取重新建構
docker-compose -f docker-compose.full.yml build --no-cache
```

### 單獨建構特定服務
```bash
docker-compose -f docker-compose.full.yml build backend
docker-compose -f docker-compose.full.yml build frontend
docker-compose -f docker-compose.full.yml build admin
```

---

## 啟動服務

### 完整版（含 PostgreSQL + PostGIS）
```bash
# 啟動所有服務
docker-compose -f docker-compose.full.yml up -d

# 查看服務狀態
docker-compose -f docker-compose.full.yml ps

# 查看日誌
docker-compose -f docker-compose.full.yml logs -f
```

### 指定服務日誌
```bash
docker-compose -f docker-compose.full.yml logs -f backend
docker-compose -f docker-compose.full.yml logs -f frontend
docker-compose -f docker-compose.full.yml logs -f admin
docker-compose -f docker-compose.full.yml logs -f db
```

### 外部資料庫版
```bash
# 先確保外部資料庫已啟動，然後
docker-compose up -d
```

### 開發模式（含 pgAdmin）
```bash
docker-compose -f docker-compose.dev.yml up -d
```

---

## 停止服務

```bash
# 停止但保留容器
docker-compose -f docker-compose.full.yml stop

# 停止並移除容器
docker-compose -f docker-compose.full.yml down

# 停止並移除容器及 volumes（資料庫資料會刪除）
docker-compose -f docker-compose.full.yml down -v
```

---

## 服務埠號

| 服務 | 埠號 | 說明 |
|------|------|------|
| frontend | 80 | 前端使用者介面 |
| admin | 81 | 後台管理介面 |
| backend | 8080 | Spring Boot API |
| db | 5432 | PostgreSQL |
| pgadmin | 5050 | pgAdmin 管理介面（僅 dev 模式） |

---

## 環境變數

複製 `.env.example` 為 `.env` 並修改：

```bash
cp .env.example .env
```

主要變數：
| 變數 | 預設值 | 說明 |
|------|--------|------|
| POSTGRES_DB | family_map | 資料庫名稱 |
| POSTGRES_USER | postgres | 資料庫使用者 |
| POSTGRES_PASSWORD | postgres | 資料庫密碼 |
| SPRING_PROFILES_ACTIVE | docker | Spring 設定檔 |

---

## 常用操作

### 進入容器
```bash
# 進入 backend 容器
docker-compose -f docker-compose.full.yml exec backend sh

# 進入資料庫容器
docker-compose -f docker-compose.full.yml exec db psql -U postgres -d family_map
```

### 重新啟動特定服務
```bash
docker-compose -f docker-compose.full.yml restart backend
```

### 查看映像大小
```bash
docker images | grep playmaker
```

### 清理未使用的資源
```bash
# 清理停止的容器、未使用的網路、映像
docker system prune

# 包含未使用的 volumes
docker system prune -a --volumes
```

---

## 資料庫操作

### 連線到 PostgreSQL
```bash
docker-compose -f docker-compose.full.yml exec db psql -U postgres -d family_map
```

### 備份資料庫
```bash
docker-compose -f docker-compose.full.yml exec db pg_dump -U postgres family_map > backup.sql
```

### 還原資料庫
```bash
cat backup.sql | docker-compose -f docker-compose.full.yml exec -T db psql -U postgres family_map
```

### 查看 Flyway 遷移狀態
```bash
docker-compose -f docker-compose.full.yml exec db psql -U postgres -d family_map -c "SELECT * FROM flyway_schema_history ORDER BY installed_rank;"
```

---

## 疑難排解

### 建構失敗時清除快取重試
```bash
docker-compose -f docker-compose.full.yml build --no-cache
```

### 資料庫��線失敗
1. 確認資料庫容器已啟動：`docker-compose -f docker-compose.full.yml ps db`
2. 等待資料庫初始化完成（首次啟動需幾秒鐘）
3. 檢查日誌：`docker-compose -f docker-compose.full.yml logs db`

### 前端無法連接後端
1. 確認 backend 容器已啟動
2. 檢查 `nginx.conf` 中的 API proxy 設定
3. 確認網路設定正確

### 完全重置
```bash
# 停止並移除所有容器、網路、volumes
docker-compose -f docker-compose.full.yml down -v

# 移除所有相關映像
docker rmi playmaker-backend playmaker-frontend playmaker-admin

# 重新建構
docker-compose -f docker-compose.full.yml build --no-cache

# 啟動
docker-compose -f docker-compose.full.yml up -d
```

---

## 快速參考

```bash
# 完整啟動流程
docker-compose -f docker-compose.full.yml up -d

# 查看狀態
docker-compose -f docker-compose.full.yml ps

# 查看所有日誌
docker-compose -f docker-compose.full.yml logs -f

# 停止
docker-compose -f docker-compose.full.yml down
```
