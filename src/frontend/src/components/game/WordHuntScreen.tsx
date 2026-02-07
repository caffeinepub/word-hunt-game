import { useState, useEffect } from 'react';
import { useWordHuntGame } from '../../hooks/useWordHuntGame';
import { LetterGrid } from './LetterGrid';
import { WordList } from './WordList';
import { GameControls } from './GameControls';
import { Trophy, Clock, AlertCircle, Download } from 'lucide-react';
import { formatTime } from '../../lib/wordhunt/time';
import { getDefaultDuration, secondsToDuration, validateDuration } from '../../lib/wordhunt/duration';
import { Button } from '../ui/button';

const GRID_SIZE = 15;

export function WordHuntScreen() {
  const [logoError, setLogoError] = useState(false);
  const [apkAvailable, setApkAvailable] = useState<boolean | null>(null);
  const game = useWordHuntGame(GRID_SIZE);
  
  // State for the next game's time limit (doesn't affect current game)
  const [nextGameDuration, setNextGameDuration] = useState(() => {
    const defaultDuration = getDefaultDuration();
    return secondsToDuration(defaultDuration);
  });

  // Check if APK is available with robust fallback
  useEffect(() => {
    const checkApkAvailability = async () => {
      try {
        // Try HEAD request first (preferred for checking existence)
        const headResponse = await fetch('/downloads/word-hunt-latest.apk', { 
          method: 'HEAD',
          cache: 'no-cache'
        });
        
        if (headResponse.ok) {
          setApkAvailable(true);
          return;
        }
        
        // Some static hosts don't support HEAD, try lightweight GET with range
        const getResponse = await fetch('/downloads/word-hunt-latest.apk', {
          method: 'GET',
          headers: { 'Range': 'bytes=0-0' },
          cache: 'no-cache'
        });
        
        // Accept 200 (full response) or 206 (partial content)
        setApkAvailable(getResponse.ok || getResponse.status === 206);
      } catch (error) {
        // Network error or file not found
        setApkAvailable(false);
      }
    };
    
    checkApkAvailability();
  }, []);

  const handleNewGame = () => {
    const validatedSeconds = validateDuration(nextGameDuration.minutes, nextGameDuration.seconds);
    game.startNewGame(GRID_SIZE, validatedSeconds);
  };

  const handleTimeLimitChange = (minutes: number, seconds: number) => {
    setNextGameDuration({ minutes, seconds });
  };

  const handleDownloadApk = () => {
    window.location.href = '/downloads/word-hunt-latest.apk';
  };

  return (
    <div className="flex flex-col min-h-screen">
      {/* Header */}
      <header className="sticky top-0 z-10 bg-gradient-to-r from-blue-600 to-blue-700 text-white shadow-lg">
        <div className="container mx-auto px-4 py-4">
          <div className="flex items-center justify-between gap-3 md:gap-4">
            <div className="flex items-center gap-3 md:gap-4">
              {!logoError && (
                <img
                  src="/assets/teacher.png"
                  alt="Word Hunt Logo"
                  className="w-12 h-12 md:w-16 md:h-16 object-contain flex-shrink-0"
                  onError={() => setLogoError(true)}
                />
              )}
              <div className="flex flex-col">
                <h1 className="text-2xl md:text-3xl font-bold tracking-tight">
                  Word Hunt Game
                </h1>
                <p className="text-sm md:text-base text-blue-50 mt-1">
                  Find all the automotive parts!
                </p>
              </div>
            </div>
            
            {/* Download APK Button */}
            {apkAvailable === true && (
              <Button
                onClick={handleDownloadApk}
                variant="outline"
                size="sm"
                className="bg-white/10 hover:bg-white/20 text-white border-white/30 hover:border-white/50 flex items-center gap-2 flex-shrink-0"
              >
                <Download className="w-4 h-4" />
                <span className="hidden sm:inline">Download APK</span>
                <span className="sm:hidden">APK</span>
              </Button>
            )}
            
            {apkAvailable === false && (
              <div className="text-xs text-blue-100 hidden md:block">
                APK not available
              </div>
            )}
          </div>
        </div>
      </header>

      {/* Main Content */}
      <main className="flex-1 container mx-auto px-4 py-6 max-w-7xl">
        <div className="space-y-6">
          {/* Controls */}
          <GameControls
            foundCount={game.foundCount}
            totalCount={game.totalCount}
            onNewGame={handleNewGame}
            remainingSeconds={game.remainingSeconds}
            timeLimitMinutes={nextGameDuration.minutes}
            timeLimitSeconds={nextGameDuration.seconds}
            onTimeLimitChange={handleTimeLimitChange}
          />

          {/* Time Up Warning */}
          {game.isTimeUp && !game.isComplete && (
            <div className="bg-destructive/10 border border-destructive/30 rounded-lg p-4 flex items-center gap-3">
              <AlertCircle className="w-5 h-5 text-destructive flex-shrink-0" />
              <p className="text-destructive font-semibold">
                Time's up! You found {game.foundCount} out of {game.totalCount} words. Start a new game to try again!
              </p>
            </div>
          )}

          {/* Game Area */}
          <div className="grid lg:grid-cols-[1fr,300px] gap-6">
            {/* Letter Grid */}
            <div className="flex justify-center">
              {game.gameState.puzzle && (
                <LetterGrid
                  grid={game.gameState.puzzle.grid}
                  placedWords={game.gameState.puzzle.placedWords}
                  foundWords={game.gameState.foundWords}
                  currentSelection={game.gameState.currentSelection}
                  onSelectionStart={game.handleSelectionStart}
                  onSelectionMove={game.handleSelectionMove}
                  onSelectionEnd={game.handleSelectionEnd}
                />
              )}
            </div>

            {/* Word List */}
            <div className="lg:sticky lg:top-24 lg:self-start">
              {game.gameState.puzzle && (
                <WordList
                  words={game.gameState.puzzle.wordList}
                  foundWords={game.gameState.foundWords}
                />
              )}
            </div>
          </div>

          {/* Completion Message */}
          {game.isComplete && (
            <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50 p-4">
              <div className="bg-card rounded-2xl shadow-2xl p-8 max-w-md w-full text-center space-y-4 animate-in fade-in zoom-in duration-300">
                <div className="flex justify-center">
                  <div className="bg-gradient-to-br from-blue-500 to-blue-700 rounded-full p-4">
                    <Trophy className="w-12 h-12 text-white" />
                  </div>
                </div>
                <h2 className="text-3xl font-bold text-foreground">
                  Congratulations!
                </h2>
                <p className="text-muted-foreground text-lg">
                  You found all {game.totalCount} words!
                </p>
                <div className="flex items-center justify-center gap-2 bg-muted/50 px-4 py-3 rounded-lg">
                  <Clock className="w-5 h-5 text-blue-600" />
                  <span className="text-xl font-mono font-bold text-foreground">
                    {formatTime(game.remainingSeconds)}
                  </span>
                </div>
                <button
                  onClick={handleNewGame}
                  className="w-full bg-gradient-to-r from-blue-600 to-blue-700 hover:from-blue-700 hover:to-blue-800 text-white font-semibold py-3 px-6 rounded-lg transition-all duration-200 shadow-lg hover:shadow-xl"
                >
                  Play Again
                </button>
              </div>
            </div>
          )}
        </div>
      </main>

      {/* Footer */}
      <footer className="bg-muted/30 border-t border-border mt-auto">
        <div className="container mx-auto px-4 py-4 text-center text-sm text-muted-foreground">
          © 2026. Built with love using{' '}
          <a
            href="https://caffeine.ai"
            target="_blank"
            rel="noopener noreferrer"
            className="text-blue-600 hover:text-blue-700 font-medium transition-colors"
          >
            caffeine.ai
          </a>
        </div>
      </footer>
    </div>
  );
}
