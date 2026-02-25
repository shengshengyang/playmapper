import L from 'leaflet'

// 台灣中心點
export const TAIWAN_CENTER = [23.9739, 120.9820]
export const TAICHUNG_CENTER = [24.1477, 120.6736]

// 預設地圖選項
export const defaultMapOptions = {
  center: TAICHUNG_CENTER,
  zoom: 13,
  zoomControl: true
}

// 建立自定義圖標
export function createPlaceIcon(color = '#3b82f6', size = 'md') {
  const sizes = {
    sm: [24, 24],
    md: [32, 32],
    lg: [40, 40]
  }

  const iconSize = sizes[size] || sizes.md

  return L.divIcon({
    className: 'custom-marker',
    html: `
      <div style="
        width: ${iconSize[0]}px;
        height: ${iconSize[1]}px;
        background-color: ${color};
        border: 3px solid white;
        border-radius: 50% 50% 50% 0;
        transform: rotate(-45deg);
        box-shadow: 0 2px 5px rgba(0,0,0,0.3);
      ">
        <div style="
          width: 10px;
          height: 10px;
          background-color: white;
          border-radius: 50%;
          position: absolute;
          top: 50%;
          left: 50%;
          transform: translate(-50%, -50%);
        "></div>
      </div>
    `,
    iconSize: iconSize,
    iconAnchor: [iconSize[0] / 2, iconSize[1]],
    popupAnchor: [0, -iconSize[1]]
  })
}

// 建立選中狀態圖標
export function createSelectedIcon() {
  return L.divIcon({
    className: 'selected-marker',
    html: `
      <div style="
        width: 40px;
        height: 40px;
        background-color: #d946ef;
        border: 4px solid white;
        border-radius: 50% 50% 50% 0;
        transform: rotate(-45deg);
        box-shadow: 0 0 10px rgba(217, 70, 239, 0.6);
        animation: pulse 1.5s infinite;
      ">
        <div style="
          width: 12px;
          height: 12px;
          background-color: white;
          border-radius: 50%;
          position: absolute;
          top: 50%;
          left: 50%;
          transform: translate(-50%, -50%);
        "></div>
      </div>
    `,
    iconSize: [40, 40],
    iconAnchor: [20, 40],
    popupAnchor: [0, -40]
  })
}

// 繪製路線
export function createRoutePolyline(coordinates, options = {}) {
  const defaultOptions = {
    color: '#3b82f6',
    weight: 4,
    opacity: 0.8,
    smoothFactor: 1
  }

  return L.polyline(coordinates, { ...defaultOptions, ...options })
}

// 計算兩點間距離（公尺）
export function calculateDistance(lat1, lng1, lat2, lng2) {
  const point1 = L.latLng(lat1, lng1)
  const point2 = L.latLng(lat2, lng2)
  return point1.distanceTo(point2)
}

// 根據年齡取得圖標顏色
export function getColorByAge(minAge, maxAge) {
  if (maxAge <= 3) return '#22c55e' // 綠色 - 嬰幼兒
  if (maxAge <= 6) return '#3b82f6' // 藍色 - 幼兒園
  if (maxAge <= 12) return '#f59e0b' // 橘色 - 國小
  return '#8b5cf6' // 紫色 - 青少年
}

export default {
  TAIWAN_CENTER,
  TAICHUNG_CENTER,
  defaultMapOptions,
  createPlaceIcon,
  createSelectedIcon,
  createRoutePolyline,
  calculateDistance,
  getColorByAge
}
