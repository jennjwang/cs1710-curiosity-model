#lang forge

// Players representation
abstract sig Player {}
one sig Player0, Player1 extends Player {}

// Board representation with a mapping from coordinates to players
sig Board {
    // Partial function from (row, column) to Player
    board: pfunc Int -> Int -> Player
}

// Ensure the board follows physical constraints
pred wellformed[b: Board] {
    // Constrain row indices (0 to 5, for 6 rows) and column indices (0 to 6, for 7 columns)
    all row, col: Int | {
        (row < 0 or row > 5 or col < 0 or col > 6) implies no b.board[row][col]
    }
    
    // No floating pieces - enforce gravity
    all row, col: Int | {
        // If there's a piece at (row, col) and it's not the bottom row
        (some b.board[row][col] and row > 0) implies
        // There must be a piece below it (row-1, col)
        some b.board[subtract[row, 1]][col]
    }
}

// Initial empty board state
pred starting[b: Board] {
    all row, col: Int | {
        no b.board[row][col]
    }
}

// Player0's turn when number of pieces is equal
pred Player0Turn[b: Board] {
    // Player0 moves when the number of pieces for each player is equal
    #{row, col: Int | b.board[row][col] = Player0}
    = 
    #{row, col: Int | b.board[row][col] = Player1}
}

// Player1's turn when Player0 has one more piece
pred Player1Turn[b: Board] {
    // Player1 moves when Player0 has exactly one more piece
    #{row, col: Int | b.board[row][col] = Player0}
    = 
    add[1, #{row, col: Int | b.board[row][col] = Player1}]
}

// Check for winning configurations in all directions
pred winning[b: Board, p: Player] {
    // Horizontal win
    some row, col: Int | {
        row >= 0 and row < 6 and col >= 0 and col < 4
        b.board[row][col] = p and
        b.board[row][add[col, 1]] = p and
        b.board[row][add[col, 2]] = p and
        b.board[row][add[col, 3]] = p
    }
    or 
    // Vertical win
    (some col, row: Int | {
        row >= 0 and row < 3 and col >= 0 and col < 7
        b.board[row][col] = p and
        b.board[add[row, 1]][col] = p and
        b.board[add[row, 2]][col] = p and
        b.board[add[row, 3]][col] = p
    })
    or
    // Diagonal win (bottom-left to top-right)
    (some row, col: Int | {
        row >= 0 and row < 3 and col >= 0 and col < 4
        b.board[row][col] = p and
        b.board[add[row, 1]][add[col, 1]] = p and
        b.board[add[row, 2]][add[col, 2]] = p and
        b.board[add[row, 3]][add[col, 3]] = p
    })
    or 
    // Diagonal win (top-left to bottom-right)
    (some row, col: Int | {
        row >= 3 and row < 6 and col >= 0 and col < 4
        b.board[row][col] = p and
        b.board[subtract[row, 1]][add[col, 1]] = p and
        b.board[subtract[row, 2]][add[col, 2]] = p and
        b.board[subtract[row, 3]][add[col, 3]] = p
    })
}

// Verify all boards are empty at the start
pred all_boards_starting {
    all b: Board | starting[b]
}

// Check if a player has a guaranteed win
pred guaranteedWin[b: Board, p: Player] {
    wellformed[b]
    // Must be player's turn
    p = Player0 implies Player0Turn[b]
    p = Player1 implies Player1Turn[b]
    winning[b, p]
}

// Find the lowest empty position in a column (gravity)
pred lowestEmpty[b: Board, col: Int, row: Int] {
    // Position is empty
    no b.board[row][col]
    // Either at bottom row or has a piece below
    (row = 0 or some b.board[subtract[row, 1]][col])
    // No empty spaces below this position
    all lowerRow: Int | {
        lowerRow >= 0 and lowerRow < row implies
        some b.board[lowerRow][col]
    }
}

// Make a move by placing a piece in a column
pred move[pre: Board, c: Int, p: Player, post: Board] {
    // Column must be valid
    c >= 0 and c <= 6
    
    // Column must not be full
    some row: Int | {
        row >= 0 and row <= 5
        no pre.board[row][c]
    }
    
    // Must be player's turn
    p = Player0 implies Player0Turn[pre]
    p = Player1 implies Player1Turn[pre]
    
    // Find the lowest empty position and place the piece
    some row: Int | {
        lowestEmpty[pre, c, row]
        // Place new piece
        post.board[row][c] = p
        
        // Frame: preserve all OTHER positions
        all r2, c2: Int | {
            (r2 != row or c2 != c) implies {
                post.board[r2][c2] = pre.board[r2][c2]
            }
        }
    }
}

// Helper predicates for winning conditions
pred Player0Winning {some b: Board | winning[b, Player0]}
pred Player1Winning {some b: Board | winning[b, Player1]}

// Game structure to track board progression
one sig Game {
    firstBoard: one Board,
    // Partial function for next board state
    nextBoard: pfunc Board -> Board
}

// Define valid game trace with proper move sequence
pred gameTrace {
    // Start with an empty board
    starting[Game.firstBoard]
    wellformed[Game.firstBoard] 

    // For each board with a next state, ensure a valid move occurs
    all b: Board | some Game.nextBoard[b] implies {
        some col: Int, p: Player | {
            move[b, col, p, Game.nextBoard[b]]
        }
    }
}

// Instance for optimization
inst optimizer {
    Board = `Board0 + `Board1 + `Board2 + `Board3 + `Board4 + `Board5
    board in Board -> 
             (0 + 1 + 2 + 3 + 4 + 5) ->  // Valid row indices
             (0 + 1 + 2 + 3 + 4 + 5 + 6) ->  // Valid column indices
             (Player0 + Player1)  // Valid player pieces
}

// Find a valid game trace
showAGame: run {
    gameTrace
} 
  for 5 Board 
  for {nextBoard is linear}

// Find a game where Player0 wins
showPlayer0Win: run {
    gameTrace
    Player0Winning
} 
  for 6 Board 
  for {nextBoard is linear}

// Find a game where Player1 wins
showPlayer1Win: run {
    gameTrace
    Player1Winning
} 
  for 6 Board 
  for {nextBoard is linear}