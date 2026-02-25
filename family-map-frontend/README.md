# Family Map Frontend

親子遊玩地圖系統前端

## 技術棧

- Vue 3
- Vite
- Vue Router
- Pinia (狀態管理)
- Tailwind CSS
- Leaflet (地圖)
- Axios
- Turf.js (地理計算)
- Day.js (時間處理)

## 快速開始

### 環境需求

- Node.js 18+
- npm 9+

### 安裝依賴

```bash
npm install
```

### 啟動開發伺服器

```bash
npm run dev
```

應用將在 http://localhost:5173 啟動

### 建構生產版本

```bash
npm run build
```

## 專案結構

```
src/
├── components/          # Vue 組件
│   ├── map/             # 地圖相關組件
│   ├── planner/         # 行程規劃組件
│   ├── place/           # 景點相關組件
│   └── admin/           # 後台管理組件
├── views/               # 頁面視圖
├── stores/              # Pinia 狀態管理
├── services/            # API 服務
├── utils/               # 工具函數
└── router/              # 路由配置
```

## 主要頁面

| 路徑 | 頁面 | 說明 |
|------|------|------|
| `/` | MapView | 地圖探索首頁 |
| `/planner` | PlannerView | 智慧行程規劃 |
| `/place/:id` | PlaceDetailView | 景點詳情 |
| `/my-trips` | MyTripsView | 我的行程 |
| `/admin` | AdminView | 後台管理 |

## 配置

### API 代理

開發環境透過 Vite 代理連接後端：

```javascript
// vite.config.js
server: {
  proxy: {
    '/api': {
      target: 'http://localhost:8080',
      changeOrigin: true
    }
  }
}
```

### Tailwind CSS

自定義顏色配置於 `tailwind.config.js`

## 功能特色

- 🗺️ 互動式地圖探索
- 📍 景點搜尋與篩選
- 👶 年齡適合度篩選
- 🚗 智慧路線優化
- ⏰ 自動插入用餐/休息時間
- 📝 行程規劃精靈
- ⭐ 景點評分與評論
- 🔐 後台審核系統
