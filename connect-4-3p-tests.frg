#lang forge/froglet
open "connect-4-3p.frg"

test_threePlayerTurns: run {
    some b1, b2, b3, b4, b5: Board | {
        wellformed[b1]
        wellformed[b2]
        wellformed[b3]
        wellformed[b4]
        wellformed[b5]
        
        starting[b1]  // empty board
        
        // Player0 moves first (no previous player)
        some c1, c2, c3, c4: Int | {
            c1 >= 0 and c1 <= 6  // valid column
            c2 >= 0 and c2 <= 6  // valid column
            c3 >= 0 and c3 <= 6  // valid column

            c2 != c1
            c3 != c1 and c3 != c2
            c4 != c1 and c4 != c2 and c4 != c3

            move[b1, c1, Player0, Player2, b2]  // Player0 moves, no previous player
            b2.board[0][c1] = Player0  // piece must be at bottom
            
            // Player1 moves second (previous player is Player0)
            move[b2, c2, Player1, Player0, b3]  // Player1 moves, previous is Player0
            b3.board[0][c2] = Player1  // also at bottom
                
            
            // Player2 moves third (previous player is Player1)
            move[b3, c3, Player2, Player1, b4]  // Player2 moves, previous is Player1
            b4.board[0][c3] = Player2  // also at bottom

             
            // Player0 moves again (previous player is Player2)
            move[b4, c4, Player0, Player2, b5]  // Player0 moves, previous is Player2
            b5.board[0][c4] = Player0  // also at bottom
            
            }
        }
} for exactly 5 Board, 6 Int

test_startingPlayer: run {
    some b1, b2: Board | {
        wellformed[b1]
        wellformed[b2]
        starting[b1]
        some c1: Int | {
            c1 >= 0 and c1 <= 6
            move[b1, c1, Player0, Player2, b2]
            b2.board[0][c1] = Player0
        }
    }
} for exactly 2 Board, 7 Int

