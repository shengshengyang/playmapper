# Family Map Admin

親子遊玩地圖系統 - 管理後台

## 技術棧

- Vue 3
- Vite
- Vue Router
- Pinia
- Tailwind CSS
- Axios
- Day.js

## 快速開始

### 安裝依賴

```bash
cd family-map-admin
npm install
```

### 啟動開發伺服器

```bash
npm run dev
```

管理後台將在 http://localhost:5174 啟動

### 建構生產版本

```bash
npm run build
```

## 預設管理員帳號

```
帳號: admin
密碼: admin123
```

## 功能模組

### 儀表板 (Dashboard)
- 統計數據總覽
- 待審核景點快捷處理
- 最近活動記錄

### 景點管理 (Places)
- 景點列表（搜尋、篩選、分頁）
- 新增景點
- 編輯景點
- 刪除景點
- 設施標籤管理

### 審核管理 (Reviews)
- 待審核景點列表
- 審核通過/拒絕
- 拒絕原因填寫
- 景點詳情查看

### 使用者管理 (Users)
- 使用者列表
- 角色權限設定
- 帳號刪除

## 專案結構

```
src/
├── views/               # 頁面視圖
│   ├── LoginView.vue    # 登入頁
│   ├── LayoutView.vue   # 主佈局
│   ├── DashboardView.vue
│   ├── PlacesView.vue
│   ├── PlaceFormView.vue
│   ├── ReviewsView.vue
│   └── UsersView.vue
├── stores/              # Pinia 狀態管理
│   ├── authStore.js
│   ├── placesStore.js
│   └── reviewsStore.js
├── services/            # API 服務
│   └── api.js
└── router/              # 路由配置
    └── index.js
```

## 路由配置

| 路徑 | 頁面 | 說明 |
|------|------|------|
| /login | LoginView | 登入頁面 |
| /dashboard | DashboardView | 儀表板 |
| /places | PlacesView | 景點管理 |
| /places/add | PlaceFormView | 新增景點 |
| /places/:id/edit | PlaceFormView | 編輯景點 |
| /reviews | ReviewsView | 審核管理 |
| /users | UsersView | 使用者管理 |

## API 代理

開發環境透過 Vite 代理連接後端：

```javascript
server: {
  port: 5174,
  proxy: {
    '/api': {
      target: 'http://localhost:8080',
      changeOrigin: true
    }
  }
}
```
