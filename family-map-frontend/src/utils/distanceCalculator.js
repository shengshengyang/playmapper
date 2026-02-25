/**
 * 距離計算工具
 */

/**
 * 地球半徑（公里）
 */
const EARTH_RADIUS_KM = 6371

/**
 * 角度轉弧度
 */
function toRadians(degrees) {
  return degrees * Math.PI / 180
}

/**
 * Haversine 公式計算兩點間���離
 */
export function haversineDistance(lat1, lng1, lat2, lng2) {
  const dLat = toRadians(lat2 - lat1)
  const dLng = toRadians(lng2 - lng1)

  const a = Math.sin(dLat / 2) * Math.sin(dLat / 2) +
            Math.cos(toRadians(lat1)) * Math.cos(toRadians(lat2)) *
            Math.sin(dLng / 2) * Math.sin(dLng / 2)

  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a))

  return EARTH_RADIUS_KM * c
}

/**
 * 格式化距離
 */
export function formatDistance(km) {
  if (km < 1) {
    return `${Math.round(km * 1000)} 公尺`
  }
  return `${km.toFixed(1)} 公里`
}

/**
 * 估計開車時間（分鐘）
 */
export function estimateDrivingTime(distanceKm, avgSpeedKmh = 50) {
  return Math.ceil(distanceKm / avgSpeedKmh * 60)
}

/**
 * 計算總距離
 */
export function calculateTotalDistance(places) {
  let total = 0
  for (let i = 0; i < places.length - 1; i++) {
    total += haversineDistance(
      places[i].latitude, places[i].longitude,
      places[i + 1].latitude, places[i + 1].longitude
    )
  }
  return total
}

/**
 * 找出中心點
 */
export function findCenterPoint(places) {
  if (places.length === 0) {
    return { lat: 24.1477, lng: 120.6736 } // 台中市中心
  }

  let sumLat = 0
  let sumLng = 0

  for (const place of places) {
    sumLat += place.latitude
    sumLng += place.longitude
  }

  return {
    lat: sumLat / places.length,
    lng: sumLng / places.length
  }
}

/**
 * 計算邊界
 */
export function calculateBounds(places) {
  if (places.length === 0) {
    return null
  }

  let minLat = Infinity
  let maxLat = -Infinity
  let minLng = Infinity
  let maxLng = -Infinity

  for (const place of places) {
    minLat = Math.min(minLat, place.latitude)
    maxLat = Math.max(maxLat, place.latitude)
    minLng = Math.min(minLng, place.longitude)
    maxLng = Math.max(maxLng, place.longitude)
  }

  return {
    southWest: { lat: minLat, lng: minLng },
    northEast: { lat: maxLat, lng: maxLng }
  }
}

export default {
  haversineDistance,
  formatDistance,
  estimateDrivingTime,
  calculateTotalDistance,
  findCenterPoint,
  calculateBounds
}
