#lang forge/froglet
open "connect-4-2p.frg"

test_turns: run {
    some b1, b2, b3: Board | {
        wellformed[b1]
        wellformed[b2]
        wellformed[b3]
        
        starting[b1]  // empty board
        
        // force first move to be at bottom of column
        some c1: Int | {
            move[b1, c1, X, b2]  // X moves first
            b2.board[0][c1] = X  // piece must be at bottom
            
            // second move must be in different column
            some c2: Int | {
                c2 != c1  // different column
                move[b2, c2, O, b3]  // O moves second
                b3.board[0][c2] = O  // also at bottom
            }
        }
    }
} for exactly 3 Board, 5 Int


example emptyBoardIsStart is all_boards_starting for {
    Board = `Board0 
    X = `X   
    O = `O
    Player = X + O 
    no `Board0.board 
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
}  for exactly 1 Board, 5 Int