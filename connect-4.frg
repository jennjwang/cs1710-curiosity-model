#lang forge/froglet 

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
        (row < 0 or row > 5) implies no b.board[row][col]
    }
    
    // constrain column indices (0 to 6, for 7 columns)
    all row, col: Int | {
        (col < 0 or col > 6) implies no b.board[row][col]
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
        b.board[row][col] = p and
        b.board[row][add[col, 1]] = p and
        b.board[row][add[col, 2]] = p and
        b.board[row][add[col, 3]] = p
    }
    or 
    -- win V
    (some col, row: Int | {
        b.board[row][col] = p 
        b.board[add[row, 1]][col] = p 
        b.board[add[row, 2]][col] = p
        b.board[add[row, 3]][col] = p
    })
    or
    -- win D
    {
        b.board[row][col] = p
        b.board[add[row, 1]][add[col, 1]] = p
        b.board[add[row, 2]][add[col, 2]] = p
        b.board[add[row, 3]][add[col, 3]] = p
    } 
    or 
    {
        b.board[row][add[col, 3]] = p
        b.board[add[row, 1]][add[col, 2]] = p
        b.board[add[row, 2]][add[col, 1]] = p
        b.board[add[row, 3]][col] = p
    }

}

findWinningX: run {
    some b: Board | { 
        wellformed[b]
        winning[b, X]
        (XTurn[b] or OTurn[b]) // balanced board
    }
} 
  for exactly 1 Board, 4 Int

findWinningO: run {
    some b: Board | { 
        wellformed[b]
        winning[b, O]
        (XTurn[b] or OTurn[b]) // balanced board
    }
} 
  for exactly 1 Board, 4 Int

pred move[pre: Board, r, c: Int, p: Player, post: Board] {
    // GUARD
    no pre.board[r][c]
    p = X implies XTurn[pre]
    p = O implies OTurn[pre]
    
    // ACTION 
    post.board[r][c] = p
    // FRAME (nothing else changes)
    all r2, c2: Int | (r2 != r or c2 != c) => {
        post.board[r2][c2] = pre.board[r2][c2]
    }


}


// turns 
// end conditions 
// valid placements
// valid states 
// 