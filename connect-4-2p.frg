#lang forge

// Players 
abstract sig Player {}
one sig X, O extends Player {}

// Board 
sig Board {
    // Partial function from (Int,Int) to Player
    board: pfunc Int -> Int -> Player
}

pred wellformed[b: Board] {
    // constrain row indices (0 to 5, for 6 rows)
    all row, col: Int | {
        (row < 0 or row > 5 or col < 0 or col > 6) implies no b.board[row][col]
    }
    
    // no floating pieces
    all row, col: Int | {
        // if there's a piece at (row, col)
        (some b.board[row][col] and row > 0) implies
        // there must be a piece below it (row-1, col)
        some b.board[subtract[row, 1]][col]
    }
}

pred starting[b: Board] {
    all row, col: Int | {
        no b.board[row][col]
    }
}

pred XTurn[b: Board] {
  // even number of entries
  // #X = #O
  #{row, col: Int | b.board[row][col] = X}
  = 
  #{row, col: Int | b.board[row][col] = O}
}

pred OTurn[b: Board] {
  // defn in terms of XTurn?
  // not XTurn[b] // see notes
  #{row, col: Int | b.board[row][col] = X}
  = 
  add[1, #{row, col: Int | b.board[row][col] = O}]
}

pred winning[b: Board, p: Player] {
    -- win H
    some row, col: Int | {
        (row > -1 and row < 6 and col > -1 and col < 4 )
        b.board[row][col] = p and
        b.board[row][add[col, 1]] = p and
        b.board[row][add[col, 2]] = p and
        b.board[row][add[col, 3]] = p
    }
    or 
    -- win V
    (some col, row: Int | {
        (row > -1 and row < 3 and col > -1 or col < 6 )
        b.board[row][col] = p 
        b.board[add[row, 1]][col] = p 
        b.board[add[row, 2]][col] = p
        b.board[add[row, 3]][col] = p
    })

    or
    -- win D
    {
        (row > -1 and row < 3 and col > -1 or col < 4 )
        b.board[row][col] = p
        b.board[add[row, 1]][add[col, 1]] = p
        b.board[add[row, 2]][add[col, 2]] = p
        b.board[add[row, 3]][add[col, 3]] = p
    } 
    or 
    {
        (row > -1 and row < 3 and col > -1 or col < 4 )
        b.board[row][add[col, 3]] = p
        b.board[add[row, 1]][add[col, 2]] = p
        b.board[add[row, 2]][add[col, 1]] = p
        b.board[add[row, 3]][col] = p
    }
}

pred all_boards_starting {
    all b: Board | starting[b]
}

pred guaranteedWin[b: Board, p: Player] {
    wellformed[b]
    // must be player's turn
    p = X implies XTurn[b]
    p = O implies OTurn[b]
    winning[b, p]
}

// find lowest empty spot in a column
pred lowestEmpty[b: Board, col: Int, row: Int] {
    // position is empty
    no b.board[row][col]
    // either at bottom row or has piece below
    (row = 0 or some b.board[subtract[row, 1]][col])
    // no empty spaces below this position
    all lowerRow: Int | {
        lowerRow >= 0 and lowerRow < row implies
        some b.board[lowerRow][col]
    }
}

pred move[pre: Board, c: Int, p: Player, post: Board] {
    // column must be valid
    c >= 0 and c <= 6
    
    // column must not be full
    some row: Int | {
        row >= 0 and row <= 5
        no pre.board[row][c]
    }
    
    // must be player's turn
    p = X implies XTurn[pre]
    p = O implies OTurn[pre]
    
    // find lowest empty position and place piece
    some row: Int | {
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

pred XWinning {some b: Board | winning[b, X]}
pred OWinning {some b: Board | winning[b, O]}


one sig Game {
    firstBoard: one Board,
    // Don't forget to make this pfunc, not func
    nextBoard: pfunc Board -> Board
}

pred gameTrace {
    starting[Game.firstBoard]
    wellformed[Game.firstBoard] 

    all b: Board | some Game.nextBoard[b] => {
        some row, col: Int, p: Player | {
            move[b, col, p, Game.nextBoard[b]]
        }
    }
    // We COULD say "the trace is a linear trace" here...
    // ...but that wouldn't solve the "10! symmetries" problem
}

inst optimizer {
    Board = `Board0 + `Board1 + `Board2 + `Board3 + `Board4 + `Board5
    board in Board -> 
             (0 + 1 + 2 + 3 + 4 + 5) ->  // Valid row indices
             (0 + 1 + 2 + 3 + 4 + 5 + 6) ->  // Valid column indices
             (`X + `O)  // Only valid player pieces
}

showAGame: run {
    gameTrace
} 
  for 5 Board for {nextBoard is linear}