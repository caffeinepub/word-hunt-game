import { useState, useCallback, useEffect, useRef } from 'react';
import { generatePuzzle, type PuzzleData, type PlacedWord } from '../lib/wordhunt/generator';
import { getSelectionCells, validateSelection, type GridCell } from '../lib/wordhunt/selection';

export interface GameState {
  puzzle: PuzzleData | null;
  foundWords: Set<string>;
  currentSelection: GridCell[] | null;
  isSelecting: boolean;
  startCell: { row: number; col: number } | null;
  endCell: { row: number; col: number } | null;
}

export function useWordHuntGame(gridSize: number = 15) {
  const [gameState, setGameState] = useState<GameState>({
    puzzle: null,
    foundWords: new Set(),
    currentSelection: null,
    isSelecting: false,
    startCell: null,
    endCell: null,
  });

  const [remainingSeconds, setRemainingSeconds] = useState(300); // Default 5 minutes
  const [isTimerRunning, setIsTimerRunning] = useState(false);
  const timerRef = useRef<number | null>(null);

  const isTimeUp = remainingSeconds <= 0;

  // Start timer when puzzle is generated
  useEffect(() => {
    if (gameState.puzzle && !isComplete && !isTimeUp && isTimerRunning) {
      timerRef.current = window.setInterval(() => {
        setRemainingSeconds((prev) => {
          const newValue = prev - 1;
          if (newValue <= 0) {
            setIsTimerRunning(false);
            return 0;
          }
          return newValue;
        });
      }, 1000);

      return () => {
        if (timerRef.current) {
          clearInterval(timerRef.current);
          timerRef.current = null;
        }
      };
    }
  }, [gameState.puzzle, isTimerRunning, isTimeUp]);

  const startNewGame = useCallback((size: number = gridSize, durationSeconds: number = 300) => {
    const puzzle = generatePuzzle(size);
    setGameState({
      puzzle,
      foundWords: new Set(),
      currentSelection: null,
      isSelecting: false,
      startCell: null,
      endCell: null,
    });
    setRemainingSeconds(durationSeconds);
    setIsTimerRunning(true);
  }, [gridSize]);

  useEffect(() => {
    startNewGame(gridSize, 300);
  }, []);

  const handleSelectionStart = useCallback((row: number, col: number) => {
    if (isTimeUp) return;
    
    setGameState((prev) => ({
      ...prev,
      isSelecting: true,
      startCell: { row, col },
      endCell: { row, col },
      currentSelection: prev.puzzle
        ? [{ letter: prev.puzzle.grid[row][col], row, col }]
        : null,
    }));
  }, [isTimeUp]);

  const handleSelectionMove = useCallback((row: number, col: number) => {
    setGameState((prev) => {
      if (!prev.isSelecting || !prev.startCell || !prev.puzzle || isTimeUp) {
        return prev;
      }

      const cells = getSelectionCells(
        prev.puzzle.grid,
        prev.startCell.row,
        prev.startCell.col,
        row,
        col
      );

      return {
        ...prev,
        endCell: { row, col },
        currentSelection: cells,
      };
    });
  }, [isTimeUp]);

  const handleSelectionEnd = useCallback(() => {
    setGameState((prev) => {
      if (!prev.currentSelection || !prev.puzzle || isTimeUp) {
        return {
          ...prev,
          isSelecting: false,
          startCell: null,
          endCell: null,
          currentSelection: null,
        };
      }

      const remainingWords = prev.puzzle.wordList.filter(
        (word) => !prev.foundWords.has(word)
      );

      const foundWord = validateSelection(prev.currentSelection, remainingWords);

      if (foundWord) {
        const newFoundWords = new Set(prev.foundWords);
        newFoundWords.add(foundWord);

        return {
          ...prev,
          foundWords: newFoundWords,
          isSelecting: false,
          startCell: null,
          endCell: null,
          currentSelection: null,
        };
      }

      return {
        ...prev,
        isSelecting: false,
        startCell: null,
        endCell: null,
        currentSelection: null,
      };
    });
  }, [isTimeUp]);

  const isComplete = gameState.puzzle
    ? gameState.foundWords.size === gameState.puzzle.wordList.length
    : false;

  // Stop timer when puzzle is complete
  useEffect(() => {
    if (isComplete) {
      setIsTimerRunning(false);
    }
  }, [isComplete]);

  const foundCount = gameState.foundWords.size;
  const totalCount = gameState.puzzle?.wordList.length || 0;

  return {
    gameState,
    startNewGame,
    handleSelectionStart,
    handleSelectionMove,
    handleSelectionEnd,
    isComplete,
    foundCount,
    totalCount,
    remainingSeconds,
    isTimeUp,
  };
}
