import { RotateCcw, Clock, Timer } from 'lucide-react';
import { formatTime } from '../../lib/wordhunt/time';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';

interface GameControlsProps {
  foundCount: number;
  totalCount: number;
  onNewGame: () => void;
  remainingSeconds: number;
  timeLimitMinutes: number;
  timeLimitSeconds: number;
  onTimeLimitChange: (minutes: number, seconds: number) => void;
}

export function GameControls({
  foundCount,
  totalCount,
  onNewGame,
  remainingSeconds,
  timeLimitMinutes,
  timeLimitSeconds,
  onTimeLimitChange,
}: GameControlsProps) {
  const progress = totalCount > 0 ? (foundCount / totalCount) * 100 : 0;

  const handleMinutesChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const value = e.target.value;
    const parsed = value === '' ? 0 : parseInt(value, 10);
    if (!isNaN(parsed) && parsed >= 0 && parsed <= 60) {
      onTimeLimitChange(parsed, timeLimitSeconds);
    }
  };

  const handleSecondsChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const value = e.target.value;
    const parsed = value === '' ? 0 : parseInt(value, 10);
    if (!isNaN(parsed) && parsed >= 0 && parsed <= 59) {
      onTimeLimitChange(timeLimitMinutes, parsed);
    }
  };

  return (
    <div className="bg-card rounded-lg shadow-lg p-4 border border-border">
      <div className="flex flex-col gap-4">
        {/* Top Row: Progress and Timer */}
        <div className="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4">
          {/* Progress */}
          <div className="flex-1 w-full">
            <div className="flex items-center justify-between mb-2">
              <span className="text-sm font-semibold text-foreground">
                Progress
              </span>
              <span className="text-sm font-bold text-blue-600">
                {foundCount} / {totalCount}
              </span>
            </div>
            <div className="w-full bg-muted rounded-full h-3 overflow-hidden">
              <div
                className="h-full bg-gradient-to-r from-blue-500 to-blue-700 transition-all duration-500 ease-out rounded-full"
                style={{ width: `${progress}%` }}
              />
            </div>
          </div>

          {/* Timer */}
          <div className="flex items-center gap-2 bg-muted/50 px-4 py-2 rounded-lg">
            <Clock className="w-4 h-4 text-blue-600" />
            <span className="text-lg font-mono font-bold text-foreground">
              {formatTime(remainingSeconds)}
            </span>
          </div>
        </div>

        {/* Middle Row: Time Limit Control */}
        <div className="flex flex-col sm:flex-row items-start sm:items-end gap-4 border-t border-border pt-4">
          <div className="flex-1 w-full">
            <Label htmlFor="time-limit-minutes" className="text-sm font-semibold text-foreground flex items-center gap-2 mb-2">
              <Timer className="w-4 h-4 text-blue-600" />
              Time Limit (for next game)
            </Label>
            <div className="flex items-center gap-2">
              <div className="flex items-center gap-1">
                <Input
                  id="time-limit-minutes"
                  type="number"
                  min="0"
                  max="60"
                  value={timeLimitMinutes}
                  onChange={handleMinutesChange}
                  className="w-16 text-center"
                />
                <span className="text-sm text-muted-foreground">min</span>
              </div>
              <div className="flex items-center gap-1">
                <Input
                  id="time-limit-seconds"
                  type="number"
                  min="0"
                  max="59"
                  value={timeLimitSeconds}
                  onChange={handleSecondsChange}
                  className="w-16 text-center"
                />
                <span className="text-sm text-muted-foreground">sec</span>
              </div>
            </div>
          </div>

          {/* New Game Button */}
          <button
            onClick={onNewGame}
            className="flex items-center gap-2 bg-gradient-to-r from-blue-600 to-blue-700 hover:from-blue-700 hover:to-blue-800 text-white font-semibold py-2.5 px-5 rounded-lg transition-all duration-200 shadow-md hover:shadow-lg whitespace-nowrap"
          >
            <RotateCcw className="w-4 h-4" />
            New Game
          </button>
        </div>
      </div>
    </div>
  );
}
