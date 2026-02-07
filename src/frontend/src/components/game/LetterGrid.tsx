import { useRef, useCallback, type PointerEvent } from 'react';
import { type PlacedWord, type GridCell } from '../../lib/wordhunt/generator';

interface LetterGridProps {
  grid: string[][];
  placedWords: PlacedWord[];
  foundWords: Set<string>;
  currentSelection: GridCell[] | null;
  onSelectionStart: (row: number, col: number) => void;
  onSelectionMove: (row: number, col: number) => void;
  onSelectionEnd: () => void;
}

export function LetterGrid({
  grid,
  placedWords,
  foundWords,
  currentSelection,
  onSelectionStart,
  onSelectionMove,
  onSelectionEnd,
}: LetterGridProps) {
  const gridRef = useRef<HTMLDivElement>(null);

  const getCellFromPoint = useCallback(
    (x: number, y: number): { row: number; col: number } | null => {
      if (!gridRef.current) return null;

      const rect = gridRef.current.getBoundingClientRect();
      const cellSize = rect.width / grid[0].length;

      const col = Math.floor((x - rect.left) / cellSize);
      const row = Math.floor((y - rect.top) / cellSize);

      if (row >= 0 && row < grid.length && col >= 0 && col < grid[0].length) {
        return { row, col };
      }

      return null;
    },
    [grid]
  );

  const handlePointerDown = useCallback(
    (e: PointerEvent<HTMLDivElement>) => {
      e.preventDefault();
      const target = e.target as HTMLElement;
      target.setPointerCapture(e.pointerId);

      const cell = getCellFromPoint(e.clientX, e.clientY);
      if (cell) {
        onSelectionStart(cell.row, cell.col);
      }
    },
    [getCellFromPoint, onSelectionStart]
  );

  const handlePointerMove = useCallback(
    (e: PointerEvent<HTMLDivElement>) => {
      if (e.buttons === 0) return;

      const cell = getCellFromPoint(e.clientX, e.clientY);
      if (cell) {
        onSelectionMove(cell.row, cell.col);
      }
    },
    [getCellFromPoint, onSelectionMove]
  );

  const handlePointerUp = useCallback(() => {
    onSelectionEnd();
  }, [onSelectionEnd]);

  // Build a map of found cells
  const foundCellsMap = new Map<string, string>();
  placedWords.forEach((pw) => {
    if (foundWords.has(pw.word)) {
      pw.cells.forEach((cell) => {
        foundCellsMap.set(`${cell.row}-${cell.col}`, pw.word);
      });
    }
  });

  // Build a map of currently selected cells
  const selectedCellsMap = new Set<string>();
  currentSelection?.forEach((cell) => {
    selectedCellsMap.add(`${cell.row}-${cell.col}`);
  });

  // Responsive font sizing based on grid size
  const gridSize = grid.length;
  const getFontSizeClass = () => {
    if (gridSize <= 10) return 'text-sm sm:text-base md:text-lg lg:text-xl';
    if (gridSize <= 15) return 'text-xs sm:text-sm md:text-base lg:text-lg';
    return 'text-[10px] sm:text-xs md:text-sm lg:text-base';
  };

  return (
    <div className="w-full max-w-2xl">
      <div
        ref={gridRef}
        className="grid gap-0.5 md:gap-1 bg-muted/30 p-1 md:p-2 rounded-lg shadow-lg touch-none select-none"
        style={{
          gridTemplateColumns: `repeat(${grid[0].length}, 1fr)`,
          aspectRatio: '1',
        }}
        onPointerDown={handlePointerDown}
        onPointerMove={handlePointerMove}
        onPointerUp={handlePointerUp}
        onPointerCancel={handlePointerUp}
      >
        {grid.map((row, rowIndex) =>
          row.map((letter, colIndex) => {
            const key = `${rowIndex}-${colIndex}`;
            const isFound = foundCellsMap.has(key);
            const isSelected = selectedCellsMap.has(key);

            return (
              <div
                key={key}
                className={`
                  flex items-center justify-center
                  font-bold ${getFontSizeClass()}
                  rounded transition-all duration-150
                  ${
                    isFound
                      ? 'bg-gradient-to-br from-green-500 to-emerald-600 text-white shadow-md scale-95'
                      : isSelected
                      ? 'bg-gradient-to-br from-blue-400 to-blue-600 text-white shadow-md scale-105'
                      : 'bg-card hover:bg-accent/50 text-foreground'
                  }
                `}
                style={{
                  aspectRatio: '1',
                }}
              >
                {letter}
              </div>
            );
          })
        )}
      </div>

      {/* Instructions */}
      <div className="mt-4 text-center text-sm text-muted-foreground">
        <p className="font-medium">Drag to select words in any direction</p>
        <p className="text-xs mt-1">
          Horizontal • Vertical • Diagonal • Forward • Backward
        </p>
      </div>
    </div>
  );
}
