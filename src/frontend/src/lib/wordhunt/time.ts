/**
 * Formats seconds into MM:SS format, clamping at minimum of 0
 */
export function formatTime(seconds: number): string {
  const clampedSeconds = Math.max(0, seconds);
  const mins = Math.floor(clampedSeconds / 60);
  const secs = clampedSeconds % 60;
  return `${mins.toString().padStart(2, '0')}:${secs.toString().padStart(2, '0')}`;
}
