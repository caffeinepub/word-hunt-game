/**
 * Utilities for parsing, validating, and clamping user-selected countdown durations
 */

const MIN_DURATION_SECONDS = 30; // 30 seconds minimum
const MAX_DURATION_SECONDS = 3600; // 60 minutes maximum

export interface DurationInput {
  minutes: number;
  seconds: number;
}

/**
 * Converts minutes and seconds to total seconds
 */
export function durationToSeconds(minutes: number, seconds: number): number {
  return minutes * 60 + seconds;
}

/**
 * Converts total seconds to minutes and seconds
 */
export function secondsToDuration(totalSeconds: number): DurationInput {
  const minutes = Math.floor(totalSeconds / 60);
  const seconds = totalSeconds % 60;
  return { minutes, seconds };
}

/**
 * Validates and clamps a duration to sensible bounds
 */
export function validateDuration(minutes: number, seconds: number): number {
  const total = durationToSeconds(minutes, seconds);
  return Math.max(MIN_DURATION_SECONDS, Math.min(MAX_DURATION_SECONDS, total));
}

/**
 * Parses a numeric input, returning 0 for invalid values
 */
export function parseNumericInput(value: string): number {
  const parsed = parseInt(value, 10);
  return isNaN(parsed) || parsed < 0 ? 0 : parsed;
}

/**
 * Gets the default duration in seconds (5 minutes)
 */
export function getDefaultDuration(): number {
  return 300; // 5 minutes
}
