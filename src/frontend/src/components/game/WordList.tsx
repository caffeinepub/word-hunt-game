import { Check } from 'lucide-react';

interface WordListProps {
  words: string[];
  foundWords: Set<string>;
}

export function WordList({ words, foundWords }: WordListProps) {
  const sortedWords = [...words].sort((a, b) => {
    const aFound = foundWords.has(a);
    const bFound = foundWords.has(b);
    if (aFound === bFound) return a.localeCompare(b);
    return aFound ? 1 : -1;
  });

  return (
    <div className="bg-card rounded-lg shadow-lg p-4 border border-border">
      <h2 className="text-lg font-bold text-foreground mb-3 flex items-center gap-2">
        <span className="bg-gradient-to-r from-blue-600 to-blue-700 text-white px-3 py-1 rounded-full text-sm">
          {foundWords.size}/{words.length}
        </span>
        Words to Find
      </h2>

      <div className="max-h-[500px] overflow-y-auto space-y-1 pr-2">
        {sortedWords.map((word) => {
          const isFound = foundWords.has(word);
          return (
            <div
              key={word}
              className={`
                flex items-center gap-2 px-3 py-2 rounded-md text-sm transition-all duration-200
                ${
                  isFound
                    ? 'bg-green-500/10 text-green-700 dark:text-green-400'
                    : 'bg-muted/50 text-foreground'
                }
              `}
            >
              {isFound && (
                <Check className="w-4 h-4 flex-shrink-0 text-green-600 dark:text-green-400" />
              )}
              <span
                className={`
                  font-medium break-all
                  ${isFound ? 'line-through opacity-60' : ''}
                `}
              >
                {word}
              </span>
            </div>
          );
        })}
      </div>
    </div>
  );
}
