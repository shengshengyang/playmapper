import dayjs from 'dayjs'
import 'dayjs/locale/zh-tw'

dayjs.locale('zh-tw')

/**
 * 格式化時間
 */
export function formatTime(date, format = 'HH:mm') {
  return dayjs(date).format(format)
}

/**
 * 格式化日期
 */
export function formatDate(date, format = 'YYYY-MM-DD') {
  return dayjs(date).format(format)
}

/**
 * 格式化日期時間
 */
export function formatDateTime(date, format = 'YYYY-MM-DD HH:mm') {
  return dayjs(date).format(format)
}

/**
 * 計算時間差（分鐘）
 */
export function diffInMinutes(start, end) {
  return dayjs(end).diff(dayjs(start), 'minute')
}

/**
 * 計算時間差（小時）
 */
export function diffInHours(start, end) {
  return dayjs(end).diff(dayjs(start), 'hour', true)
}

/**
 * 加上分鐘
 */
export function addMinutes(date, minutes) {
  return dayjs(date).add(minutes, 'minute').toDate()
}

/**
 * 格式化持續時間
 */
export function formatDuration(minutes) {
  if (minutes < 60) {
    return `${minutes} 分鐘`
  }

  const hours = Math.floor(minutes / 60)
  const mins = minutes % 60

  if (mins === 0) {
    return `${hours} 小時`
  }

  return `${hours} 小時 ${mins} 分鐘`
}

/**
 * 檢查是否在用餐時間
 */
export function isMealTime(time) {
  const hour = dayjs(time).hour()
  const minute = dayjs(time).minute()
  const timeInMinutes = hour * 60 + minute

  // 午餐時段 11:30-13:30
  if (timeInMinutes >= 690 && timeInMinutes <= 810) {
    return 'lunch'
  }

  // 晚餐時段 17:30-19:30
  if (timeInMinutes >= 1050 && timeInMinutes <= 1170) {
    return 'dinner'
  }

  return null
}

/**
 * 檢查是否需要休息（連續開車超過2小時）
 */
export function needsBreak(continuousDrivingMinutes) {
  return continuousDrivingMinutes >= 120
}

export default {
  formatTime,
  formatDate,
  formatDateTime,
  diffInMinutes,
  diffInHours,
  addMinutes,
  formatDuration,
  isMealTime,
  needsBreak
}
