import L from 'leaflet'

export const TAIWAN_CENTER = [23.9739, 120.9820]
export const TAICHUNG_CENTER = [24.1477, 120.6736]

export const defaultMapOptions = {
  center: TAICHUNG_CENTER,
  zoom: 13,
  zoomControl: true
}

const placeTypeIconMap = {
  '親子廁所': '🚻',
  '尿布台': '🍼',
  '哺乳室': '🤱',
  '無障礙廁所': '♿',
  '兒童遊戲區': '🛝',
  '休息區': '🪑'
}

const placeTypeLabelMap = {
  '親子廁所': '親子廁所',
  '尿布台': '尿布台',
  '哺乳室': '哺乳室',
  '無障礙廁所': '無障礙廁所',
  '兒童遊戲區': '兒童遊戲區',
  '休息區': '休息區'
}

const statusLabelMap = {
  approved: '已審核',
  pending: '待審核'
}

export function getPlaceTypeIcon(infrastructureType) {
  return placeTypeIconMap[infrastructureType] || '📍'
}

export function getPlaceTypeLabel(infrastructureType) {
  return placeTypeLabelMap[infrastructureType] || '一般設施'
}

export function getPlaceStatusLabel(status) {
  return statusLabelMap[status] || '未知狀態'
}

export function createPlaceIcon({ color = '#3b82f6', size = 'md', infrastructureType = '', reviewStatus = 'approved' } = {}) {
  const sizes = {
    sm: [24, 24],
    md: [34, 34],
    lg: [40, 40]
  }

  const iconSize = sizes[size] || sizes.md
  const markerOpacity = reviewStatus === 'pending' ? 0.72 : 1
  const borderStyle = reviewStatus === 'pending' ? '2px dashed #f59e0b' : '3px solid white'

  return L.divIcon({
    className: 'custom-marker',
    html: `
      <div style="
        width: ${iconSize[0]}px;
        height: ${iconSize[1]}px;
        background-color: ${color};
        border: ${borderStyle};
        border-radius: 50% 50% 50% 0;
        transform: rotate(-45deg);
        box-shadow: 0 2px 5px rgba(0,0,0,0.3);
        opacity: ${markerOpacity};
        display: flex;
        align-items: center;
        justify-content: center;
      ">
        <span style="
          transform: rotate(45deg);
          font-size: 14px;
          line-height: 1;
        ">${getPlaceTypeIcon(infrastructureType)}</span>
      </div>
    `,
    iconSize,
    iconAnchor: [iconSize[0] / 2, iconSize[1]],
    popupAnchor: [0, -iconSize[1]]
  })
}

export function createSelectedIcon(place = {}) {
  const iconEmoji = getPlaceTypeIcon(place.infrastructureType)
  return L.divIcon({
    className: 'selected-marker',
    html: `
      <div style="
        width: 42px;
        height: 42px;
        background-color: #d946ef;
        border: 4px solid white;
        border-radius: 50% 50% 50% 0;
        transform: rotate(-45deg);
        box-shadow: 0 0 10px rgba(217, 70, 239, 0.6);
        animation: pulse 1.5s infinite;
        display: flex;
        align-items: center;
        justify-content: center;
      ">
        <span style="
          transform: rotate(45deg);
          font-size: 15px;
          line-height: 1;
        ">${iconEmoji}</span>
      </div>
    `,
    iconSize: [42, 42],
    iconAnchor: [21, 42],
    popupAnchor: [0, -42]
  })
}

export function createRoutePolyline(coordinates, options = {}) {
  const defaultOptions = {
    color: '#3b82f6',
    weight: 4,
    opacity: 0.8,
    smoothFactor: 1
  }

  return L.polyline(coordinates, { ...defaultOptions, ...options })
}

export function calculateDistance(lat1, lng1, lat2, lng2) {
  const point1 = L.latLng(lat1, lng1)
  const point2 = L.latLng(lat2, lng2)
  return point1.distanceTo(point2)
}

export function getColorByAge(minAge, maxAge) {
  if (maxAge <= 3) return '#22c55e'
  if (maxAge <= 6) return '#3b82f6'
  if (maxAge <= 12) return '#f59e0b'
  return '#8b5cf6'
}

export default {
  TAIWAN_CENTER,
  TAICHUNG_CENTER,
  defaultMapOptions,
  createPlaceIcon,
  createSelectedIcon,
  createRoutePolyline,
  calculateDistance,
  getColorByAge,
  getPlaceTypeIcon,
  getPlaceTypeLabel,
  getPlaceStatusLabel
}
