#lang forge/froglet 

///////////////////////////////////////
// This is where we stopped on the 31st
///////////////////////////////////////

option run_sterling "ttt.js"

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

pred XTurn2[b: Board] {
    remainder[#{row,col: Int | some b.board[row][col]}, 2] = 0
}

pred XTurn[b: Board] {
  // even number of entries
  // #X = #O
  #{row, col: Int | b.board[row][col] = X}
  = 
  #{row, col: Int | b.board[row][col] = O}
}

diffPreds: run {
  some b: Board | {
    not (XTurn[b] iff XTurn2[b])
  }
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
    // AFTER CLASS: 
    r >= 0 and r <= 2 and c >= 0 and c <= 2
    // ACTION 
    post.board[r][c] = p
    // FRAME (nothing else changes)
    all r2, c2: Int | (r2 != r or c2 != c) => {
        post.board[r2][c2] = pre.board[r2][c2]
    }
}

///////////////////////////////////////
// Let's do some validation
///////////////////////////////////////

pred all_boards_starting {
    all b: Board | starting[b]
}
example emptyBoardIsStart is all_boards_starting for {
    Board = `Board0 
    X = `X   O = `O
    Player = X + O 
    no `Board0.board 
}


/////////////////////////////////////////
// Let's quickly model _GAMES_ of TTT...
/////////////////////////////////////////

one sig Game {
    firstBoard: one Board,
    // Don't forget to make this pfunc, not func
    nextBoard: pfunc Board -> Board
}

pred gameTrace {
    starting[Game.firstBoard]
    // AFTER CLASS: Wellformedness isn't enforced by `starting`, so add it here:
    wellformed[Game.firstBoard] 
    // AFTER CLASS: But it's also not enforced by `move` on 1/31. So I added it.

    all b: Board | some Game.nextBoard[b] => {
        some row, col: Int, p: Player | {
            move[b, row, col, p, Game.nextBoard[b]]
        }
    }
    // We COULD say "the trace is a linear trace" here...
    // ...but that wouldn't solve the "10! symmetries" problem
}

showAGame: run {
    gameTrace
} 
  for 10 Board 
  // This is NOT a "constraint" in the same sense as what you put a in a pred. 
  // It is a solver annotation, and affects the search space before the search.
  for {nextBoard is linear}