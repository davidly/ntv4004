"""Independent Life rules and a small VT100 screen for the C sample's tests."""
from collections import Counter
import re


def initial(pattern):
    shapes = {
        1: {(1,2),(2,3),(3,1),(3,2),(3,3)},
        2: {(2,11),(2,12),(2,13)},
        3: {(2,24),(2,25),(3,24),(3,25)},
        4: {(8,15),(8,16),(9,14),(9,15),(10,15)},
        5: {(0,0),(0,1),(0,2)},
    }
    return shapes[pattern] if pattern else set.union(*(shapes[i] for i in range(1,5)))


def step(board):
    counts = Counter((r+dy,c+dx) for r,c in board
                     for dy in (-1,0,1) for dx in (-1,0,1) if dy or dx)
    return {cell for cell,n in counts.items()
            if 0 <= cell[0] < 16 and 0 <= cell[1] < 32
            and (n == 3 or (n == 2 and cell in board))}


def terminal(text):
    """Replay output and snapshot the board whenever the status line completes.

    Track actual cell writes as well, so tests detect unnecessary full redraws
    and stale cells that escape an otherwise correct simulation.
    """
    screen = [[' ']*80 for _ in range(24)]
    row = col = clears = 0
    visible = True
    dirty, frames = set(), []
    offset = 0
    while offset < len(text):
        if text[offset] == '\x1b':
            match = re.match(r'\x1b\[([?;0-9]*)([A-Za-z])',text[offset:])
            if not match: raise AssertionError('Malformed terminal escape')
            args, command = match.groups()
            offset += len(match[0])
            if command == 'H':
                fields = args.split(';')
                row = int(fields[0] or '1')-1
                col = int(fields[1] or '1')-1 if len(fields) > 1 else 0
            elif command == 'J' and args == '2':
                screen = [[' ']*80 for _ in range(24)]
                clears += 1
            elif command in ('h','l') and args == '?25':
                visible = command == 'h'
            elif command == 'K' and not args:
                screen[row][col:] = [' ']*(80-col)
                if row == 1:
                    status = re.fullmatch(r'Generation (\d+)  Live (\d+)  (RUNNING|PAUSED)',
                                          ''.join(screen[1]).rstrip())
                    if not status: raise AssertionError('Invalid status line')
                    board = set()
                    if ''.join(screen[2][:66]) != '+'+'-'*64+'+':
                        raise AssertionError('Missing top border')
                    if ''.join(screen[19][:66]) != '+'+'-'*64+'+':
                        raise AssertionError('Missing bottom border')
                    for r in range(16):
                        line = screen[r+3]
                        if line[0] != '|' or line[65] != '|':
                            raise AssertionError('Missing side border')
                        for c in range(32):
                            cell = ''.join(line[1+2*c:3+2*c])
                            if cell not in ('[]','  '):
                                raise AssertionError('Malformed displayed cell')
                            if cell == '[]': board.add((r,c))
                    generation, population, state = status.groups()
                    frames.append((int(generation),int(population),state,board,set(dirty)))
                    dirty.clear()
            else:
                raise AssertionError('Unexpected terminal control: '+match[0])
        else:
            ch = text[offset]
            offset += 1
            if ch == '\n': row += 1; col = 0
            elif ch == '\r': col = 0
            else:
                if not (0 <= row < 24 and 0 <= col < 80):
                    raise AssertionError('Output exceeds terminal dimensions')
                screen[row][col] = ch
                if 3 <= row < 19 and 1 <= col < 65:
                    dirty.add((row-3,(col-1)//2))
                col += 1
    return frames, clears, visible, screen
