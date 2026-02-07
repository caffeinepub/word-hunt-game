import { GridCell } from './generator';

export type { GridCell };

export interface Selection {
  start: { row: number; col: number };
  end: { row: number; col: number };
  cells: GridCell[];
}

function isInLine(
  startRow: number,
  startCol: number,
  endRow: number,
  endCol: number
): boolean {
  const dr = endRow - startRow;
  const dc = endCol - startCol;

  // Same cell
  if (dr === 0 && dc === 0) return true;

  // Horizontal, vertical, or diagonal
  return dr === 0 || dc === 0 || Math.abs(dr) === Math.abs(dc);
}

export function getSelectionCells(
  grid: string[][],
  startRow: number,
  startCol: number,
  endRow: number,
  endCol: number
): GridCell[] {
  if (!isInLine(startRow, startCol, endRow, endCol)) {
    return [];
  }

  const cells: GridCell[] = [];
  const dr = endRow - startRow;
  const dc = endCol - startCol;
  const steps = Math.max(Math.abs(dr), Math.abs(dc));

  if (steps === 0) {
    return [{ letter: grid[startRow][startCol], row: startRow, col: startCol }];
  }

  const stepR = dr === 0 ? 0 : dr / Math.abs(dr);
  const stepC = dc === 0 ? 0 : dc / Math.abs(dc);

  for (let i = 0; i <= steps; i++) {
    const r = startRow + i * stepR;
    const c = startCol + i * stepC;
    cells.push({ letter: grid[r][c], row: r, col: c });
  }

  return cells;
}

export function cellsToWord(cells: GridCell[]): string {
  return cells.map((c) => c.letter).join('');
}

export function validateSelection(
  cells: GridCell[],
  remainingWords: string[]
): string | null {
  const word = cellsToWord(cells);
  const reversedWord = word.split('').reverse().join('');

  if (remainingWords.includes(word)) {
    return word;
  }

  if (remainingWords.includes(reversedWord)) {
    return reversedWord;
  }

  return null;
}
