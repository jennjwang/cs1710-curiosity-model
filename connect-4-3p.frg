#lang forge

// Players 
abstract sig Player {}
one sig Player0, Player1, Player2 extends Player {}

// Board 
sig Board {
    // Partial function from (Int,Int) to Player
    board: pfunc Int -> Int -> Player
}

// Well-formed board constraints
pred wellformed[b: Board] {
    // Constrain row indices (0 to 5, for 6 rows) and column indices (0 to 6, for 7 columns)
    all row, col: Int | {
        (row < 0 or row > 5 or col < 0 or col > 6) implies no b.board[row][col]
    }
    
    // No floating pieces
    all row, col: Int | {
        // If there's a piece at (row, col) and it's not the bottom row
        (some b.board[row][col] and row > 0) implies
        // There must be a piece below it (row-1, col)
        some b.board[subtract[row, 1]][col]
    }
}

// Starting board: no pieces on the board
pred starting[b: Board] {
    all row, col: Int | {
        no b.board[row][col]
    }
}

// Player turn: ensure the next player is valid and count moves
pred playerTurn[b: Board, previous: Player, current: Player] {
    // Ensure that the next player is valid
    current in Player and previous != current

    current = Player0 implies
    #{row, col: Int | b.board[row][col] = previous}
    =  #{row, col: Int | b.board[row][col] = current}
    
    // Count the number of moves for the current player and the next player
    current != Player0 implies #{row, col: Int | b.board[row][col] = previous}
    = add[1, #{row, col: Int | b.board[row][col] = current}]
}

// Winning conditions
pred winning[b: Board, p: Player] {
    // Horizontal win
    some row: Int, col: Int | {
        row >= 0 and row < 6 and col >= 0 and col < 4
        b.board[row][col] = p
        b.board[row][add[col, 1]] = p
        b.board[row][add[col, 2]] = p
        b.board[row][add[col, 3]] = p
    }
    or 
    // Vertical win
    (some col: Int, row: Int | {
        row >= 0 and row < 3 and col >= 0 and col < 7
        b.board[row][col] = p 
        b.board[add[row, 1]][col] = p 
        b.board[add[row, 2]][col] = p
        b.board[add[row, 3]][col] = p
    })
    or
    // Diagonal win (top-left to bottom-right)
    (some row: Int, col: Int | {
        row >= 0 and row < 3 and col >= 0 and col < 4
        b.board[row][col] = p
        b.board[add[row, 1]][add[col, 1]] = p
        b.board[add[row, 2]][add[col, 2]] = p
        b.board[add[row, 3]][add[col, 3]] = p
    }) 
    or 
    // Diagonal win (bottom-left to top-right)
    (some row: Int, col: Int | {
        row >= 0 and row < 3 and col >= 3 and col < 7
        b.board[row][col] = p
        b.board[add[row, 1]][subtract[col, 1]] = p
        b.board[add[row, 2]][subtract[col, 2]] = p
        b.board[add[row, 3]][subtract[col, 3]] = p
    })
}

// All boards start empty
pred all_boards_starting {
    all b: Board | starting[b]
}

// Guaranteed win for a player
pred guaranteedWin[b: Board, p: Player] {
    wellformed[b]
    // Must be player's turn
    playerTurn[b, p]
    winning[b, p]
}

// Find the lowest empty spot in a column
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

// Move predicate: place a piece in a column
pred move[pre: Board, c: Int, p: Player, previous: Player, post: Board] {
    // Column must be valid
    c >= 0 and c <= 6
    
    // Column must not be full
    some row: Int | {
        row >= 0 and row <= 5
        no pre.board[row][c]
    }
    
    // Must be player's turn
    playerTurn[pre, previous, p]
    
    // Find the lowest empty position and place the piece
    some row: Int | {
        row >= 0 and row <= 5
        lowestEmpty[pre, c, row]
        // Clear any previous piece at this position
        no pre.board[row][c]
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

// Game structure
one sig Game {
    firstBoard: one Board,
    // Partial function for next board
    nextBoard: pfunc Board -> Board
}

// Game trace: starting board and valid moves
pred gameTrace {
    starting[Game.firstBoard]
    wellformed[Game.firstBoard] 

    all b: Board | some Game.nextBoard[b] => {
        some col: Int, p: Player, nextPlayer: Player | {
            move[b, col, p, nextPlayer, Game.nextBoard[b]]
        }
    }
}

// Instance for optimization
inst optimizer {
    Board = `Board0 + `Board1 + `Board2 + `Board3 + `Board4 + `Board5
    board in Board -> 
             (0 + 1 + 2 + 3 + 4 + 5) ->  // Valid row indices
             (0 + 1 + 2 + 3 + 4 + 5 + 6) ->  // Valid column indices
             Player  // Valid player pieces
}

// Run the game trace
showAGame: run {
    gameTrace
} for 5 Board for {nextBoard is linear}