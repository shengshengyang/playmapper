/**
 * 前端路徑優化服務
 * 使用 Turf.js 進行地理計算
 */

import * as turf from '@turf/turf'

/**
 * 計算兩點之間的距離（公里）
 */
export function calculateDistanceKm(coord1, coord2) {
  const from = turf.point([coord1.lng, coord1.lat])
  const to = turf.point([coord2.lng, coord2.lat])
  return turf.distance(from, to, { units: 'kilometers' })
}

/**
 * 計算距離矩陣
 */
export function calculateDistanceMatrix(places) {
  const n = places.length
  const matrix = []

  for (let i = 0; i < n; i++) {
    matrix[i] = []
    for (let j = 0; j < n; j++) {
      if (i === j) {
        matrix[i][j] = 0
      } else {
        matrix[i][j] = calculateDistanceKm(
          { lat: places[i].latitude, lng: places[i].longitude },
          { lat: places[j].latitude, lng: places[j].longitude }
        )
      }
    }
  }

  return matrix
}

/**
 * 貪心最近鄰居算法
 */
export function nearestNeighbor(distanceMatrix) {
  const n = distanceMatrix.length
  if (n === 0) return []
  if (n === 1) return [0]

  const visited = new Array(n).fill(false)
  const route = []

  let current = 0
  route.push(current)
  visited[current] = true

  for (let i = 1; i < n; i++) {
    let nearest = -1
    let minDist = Infinity

    for (let j = 0; j < n; j++) {
      if (!visited[j] && distanceMatrix[current][j] < minDist) {
        minDist = distanceMatrix[current][j]
        nearest = j
      }
    }

    if (nearest !== -1) {
      route.push(nearest)
      visited[nearest] = true
      current = nearest
    }
  }

  return route
}

/**
 * 2-opt 優化
 */
export function twoOptOptimize(route, distanceMatrix) {
  let improved = true
  let bestRoute = [...route]

  while (improved) {
    improved = false
    for (let i = 0; i < bestRoute.length - 1; i++) {
      for (let j = i + 1; j < bestRoute.length; j++) {
        const newRoute = twoOptSwap(bestRoute, i, j)
        if (calculateTotalDistance(newRoute, distanceMatrix) <
            calculateTotalDistance(bestRoute, distanceMatrix)) {
          bestRoute = newRoute
          improved = true
        }
      }
    }
  }

  return bestRoute
}

function twoOptSwap(route, i, j) {
  const newRoute = []
  for (let k = 0; k < i; k++) {
    newRoute.push(route[k])
  }
  for (let k = j; k >= i; k--) {
    newRoute.push(route[k])
  }
  for (let k = j + 1; k < route.length; k++) {
    newRoute.push(route[k])
  }
  return newRoute
}

function calculateTotalDistance(route, distanceMatrix) {
  let total = 0
  for (let i = 0; i < route.length - 1; i++) {
    total += distanceMatrix[route[i]][route[i + 1]]
  }
  return total
}

/**
 * 優化路徑
 */
export function optimizeRoute(places) {
  if (places.length <= 2) {
    return places.map((_, i) => i)
  }

  const distanceMatrix = calculateDistanceMatrix(places)
  let route = nearestNeighbor(distanceMatrix)
  route = twoOptOptimize(route, distanceMatrix)

  return route
}

/**
 * 估計開車時間（分鐘）
 * 假設平均時速 50 km/h
 */
export function estimateDrivingTime(distanceKm) {
  return Math.ceil(distanceKm / 50 * 60)
}

export default {
  calculateDistanceKm,
  calculateDistanceMatrix,
  nearestNeighbor,
  twoOptOptimize,
  optimizeRoute,
  estimateDrivingTime
}
