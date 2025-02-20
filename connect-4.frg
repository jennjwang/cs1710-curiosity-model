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
    all row, col: Int | {
        (row < 0 or row > 2 or col < 0 or col > 2)
        implies no b.board[row][col]
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

-- 2's comp: 4 bits = 2^4 = 16 Ints to work with
-- [-8, 7]
firstTest: run {some b: Board | starting[b]} for exactly 2 Board, 4 Int

pred winning[b: Board, p: Player] {
    -- win H
    some row: Int | {
        b.board[row][0] = p and
        b.board[row][1] = p and
        b.board[row][2] = p
    }
    or 
    -- win V
    (some col: Int | {
        b.board[0][col] = p 
        b.board[1][col] = p 
        b.board[2][col] = p
    })
    or
    -- win D
    {b.board[0][0] = p
     b.board[1][1] = p
     b.board[2][2] = p} 
    or 
    {b.board[0][2] = p
     b.board[1][1] = p
     b.board[2][0] = p}

}

findWinningX: run {
    some b: Board | { 
        wellformed[b]
        winning[b, X]
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