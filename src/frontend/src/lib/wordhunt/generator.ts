import { WORD_LIST } from './words';

export interface GridCell {
  letter: string;
  row: number;
  col: number;
}

export interface PlacedWord {
  word: string;
  cells: GridCell[];
}

export interface PuzzleData {
  grid: string[][];
  placedWords: PlacedWord[];
  wordList: string[];
}

const DIRECTIONS = [
  { dr: 0, dc: 1 },   // horizontal right
  { dr: 0, dc: -1 },  // horizontal left
  { dr: 1, dc: 0 },   // vertical down
  { dr: -1, dc: 0 },  // vertical up
  { dr: 1, dc: 1 },   // diagonal down-right
  { dr: 1, dc: -1 },  // diagonal down-left
  { dr: -1, dc: 1 },  // diagonal up-right
  { dr: -1, dc: -1 }, // diagonal up-left
];

function canPlaceWord(
  grid: string[][],
  word: string,
  row: number,
  col: number,
  dr: number,
  dc: number
): boolean {
  const rows = grid.length;
  const cols = grid[0].length;

  for (let i = 0; i < word.length; i++) {
    const r = row + i * dr;
    const c = col + i * dc;

    if (r < 0 || r >= rows || c < 0 || c >= cols) {
      return false;
    }

    if (grid[r][c] !== '' && grid[r][c] !== word[i]) {
      return false;
    }
  }

  return true;
}

function placeWord(
  grid: string[][],
  word: string,
  row: number,
  col: number,
  dr: number,
  dc: number
): GridCell[] {
  const cells: GridCell[] = [];

  for (let i = 0; i < word.length; i++) {
    const r = row + i * dr;
    const c = col + i * dc;
    grid[r][c] = word[i];
    cells.push({ letter: word[i], row: r, col: c });
  }

  return cells;
}

export function generatePuzzle(gridSize: number = 15): PuzzleData {
  // Initialize empty grid
  const grid: string[][] = Array(gridSize)
    .fill(null)
    .map(() => Array(gridSize).fill(''));

  const placedWords: PlacedWord[] = [];
  const shuffledWords = [...WORD_LIST].sort(() => Math.random() - 0.5);

  // Try to place words (prioritize longer words first for better puzzles)
  const sortedWords = shuffledWords.sort((a, b) => b.length - a.length);

  for (const word of sortedWords) {
    let placed = false;
    const attempts = 100;

    for (let attempt = 0; attempt < attempts && !placed; attempt++) {
      const row = Math.floor(Math.random() * gridSize);
      const col = Math.floor(Math.random() * gridSize);
      const direction = DIRECTIONS[Math.floor(Math.random() * DIRECTIONS.length)];

      if (canPlaceWord(grid, word, row, col, direction.dr, direction.dc)) {
        const cells = placeWord(grid, word, row, col, direction.dr, direction.dc);
        placedWords.push({ word, cells });
        placed = true;
      }
    }

    // Stop if we have enough words for a good puzzle
    if (placedWords.length >= 20) {
      break;
    }
  }

  // Fill empty cells with random letters
  const alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  for (let r = 0; r < gridSize; r++) {
    for (let c = 0; c < gridSize; c++) {
      if (grid[r][c] === '') {
        grid[r][c] = alphabet[Math.floor(Math.random() * alphabet.length)];
      }
    }
  }

  return {
    grid,
    placedWords,
    wordList: placedWords.map((pw) => pw.word),
  };
}
