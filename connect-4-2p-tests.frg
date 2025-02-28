#lang forge/froglet
open "connect-4-2p.frg"

// Test proper turn alternation across three boards
test_turns: run {
    some b1, b2, b3: Board | {
        wellformed[b1]
        wellformed[b2]
        wellformed[b3]
        
        starting[b1]  // empty board
        
        // Force first move to be at bottom of column
        some c1: Int | {
            move[b1, c1, Player0, b2]  // Player0 moves first
            b2.board[0][c1] = Player0  // Piece must be at bottom
            
            // Second move must be in different column
            some c2: Int | {
                c2 != c1  // Different column
                move[b2, c2, Player1, b3]  // Player1 moves second
                b3.board[0][c2] = Player1  // Also at bottom
            }
        }
    }
} for exactly 3 Board, 5 Int

// Example of an empty board as starting state
example emptyBoardIsStart is all_boards_starting for {
    Board = `Board0 
    Player0 = `Player0   
    Player1 = `Player1
    Player = Player0 + Player1 
    no `Board0.board 
}

// Find a board where Player0 has won
findWinningPlayer0: run {
     some b: Board | { 
         wellformed[b]
         winning[b, Player0]
         (Player0Turn[b] or Player1Turn[b]) // Balanced board
    }
} 
for exactly 1 Board, 4 Int

// Find a board where Player1 has won
findWinningPlayer1: run {
     some b: Board | { 
         wellformed[b]
         winning[b, Player1]
         (Player0Turn[b] or Player1Turn[b]) // Balanced board
     }
}  for exactly 1 Board, 5 Int


// Test suite for all winning conditions
test suite for winning {

    // Valid case: Player0 wins with horizontal connections
    example horizontalWinPlayer0 is { Player0Winning } for {
        Board = `Board0
        Player0 = `Player0
        Player1 = `Player1
        Player = Player0 + Player1
        `Board0.board = (0, 0) -> `Player0 +
                        (0, 1) -> `Player0 +
                        (0, 2) -> `Player0 +
                        (0, 3) -> `Player0
    }

    // Valid case: Player1 wins with horizontal connections
    example horizontalWinPlayer1 is { Player1Winning } for {
        Board = `Board0
        Player0 = `Player0      
        Player1 = `Player1
        Player = Player0 + Player1
        `Board0.board = (1, 0) -> `Player1 +
                        (1, 1) -> `Player1 +
                        (1, 2) -> `Player1 +
                        (1, 3) -> `Player1
    }

    // Valid case: Player0 wins with vertical connections
    example verticalWinPlayer0 is { Player0Winning } for {
        Board = `Board0
        Player0 = `Player0      
        Player1 = `Player1
        Player = Player0 + Player1
        `Board0.board = (0, 2) -> `Player0 +
                        (1, 2) -> `Player0 +
                        (2, 2) -> `Player0 +
                        (3, 2) -> `Player0
    }

    // Valid case: Player1 wins with vertical connections
    example verticalWinPlayer1 is { Player1Winning } for {
        Board = `Board0
        Player0 = `Player0      
        Player1 = `Player1
        Player = Player0 + Player1
        `Board0.board = (0, 0) -> `Player1 +
                        (1, 0) -> `Player1 +
                        (2, 0) -> `Player1 +
                        (3, 0) -> `Player1
    }

    // Valid case: Player0 wins with diagonal connections (bottom-left to top-right)
    example diagonalWinPlayer0 is { Player0Winning } for {
        Board = `Board0
        Player0 = `Player0      
        Player1 = `Player1
        Player = Player0 + Player1
        `Board0.board = (0, 0) -> `Player0 +
                        (1, 1) -> `Player0 +
                        (2, 2) -> `Player0 +
                        (3, 3) -> `Player0
    }

    // Valid case: Player1 wins with diagonal connections (top-left to bottom-right)
    example diagonalWinPlayer1 is { Player1Winning } for {
        Board = `Board0
        Player0 = `Player0      
        Player1 = `Player1
        Player = Player0 + Player1
        `Board0.board = (3, 0) -> `Player1 +
                        (2, 1) -> `Player1 +
                        (1, 2) -> `Player1 +
                        (0, 3) -> `Player1
    }

    // Invalid case: no winner on the board
    example noWinner is { not Player1Winning && not Player0Winning } for {
        Board = `Board0
        Player0 = `Player0      
        Player1 = `Player1
        Player = Player0 + Player1
        `Board0.board = (0, 0) -> `Player0 +
                        (0, 1) -> `Player1 +
                        (0, 2) -> `Player0 +
                        (1, 0) -> `Player1 +
                        (1, 1) -> `Player0 +
                        (1, 2) -> `Player1
    }
}


// Test expect blocks for win conditions
test expect {
    // Test horizontal win detection
    horizontalWin: {
        some b: Board, p: Player | {
            wellformed[b]
            b.board[0][0] = p
            b.board[0][1] = p
            b.board[0][2] = p
            b.board[0][3] = p
            winning[b, p]
        }
    } is sat

    // Test vertical win detection
    verticalWin: {
        some b: Board, p: Player | {
            wellformed[b]
            b.board[0][0] = p
            b.board[1][0] = p
            b.board[2][0] = p
            b.board[3][0] = p
            winning[b, p]
        }
    } is sat

    // Test diagonal win detection (bottom-left to top-right)
    diagonalWin1: {
        some b: Board, p1: Player, p2: Player | {
            wellformed[b]
            b.board[0][0] = p1
            b.board[1][1] = p1
            b.board[2][2] = p1
            b.board[3][3] = p1
            b.board[1][0] = p2
            b.board[2][0] = p2
            b.board[3][0] = p1
            b.board[3][1] = p2
            b.board[3][2] = p1
            winning[b, p1]
        }
    } is sat

    // Test diagonal win detection (top-left to bottom-right)
    diagonalWin2: {
        some b: Board, p1: Player, p2: Player | {
            wellformed[b]
            b.board[3][0] = p1
            b.board[2][1] = p1
            b.board[1][2] = p1
            b.board[0][3] = p1
            b.board[2][0] = p2
            b.board[1][0] = p2
            b.board[1][1] = p1
            b.board[0][0] = p2
            b.board[0][2] = p1
            winning[b, p1]
        }
    } is sat

    // Test case with no winning condition
    noWin: {
        some b: Board, p1: Player, p2: Player| {
            wellformed[b]
            b.board[0][0] = p1
            b.board[0][1] = p2
            b.board[0][2] = p1
            b.board[1][0] = p2
            b.board[1][1] = p1
            b.board[1][2] = p2
            not winning[b, p1]
            not winning[b, p2]
        }
    } is sat
}


// Test expect blocks for board constraints
test expect {
    // Test that empty board is wellformed
    emptyBoardValid: {
        some b: Board | {
            starting[b]
            wellformed[b]
        }
    } is sat

    // Test valid piece placement at bottom
    bottomPieceValid: {
        some b: Board | {
            wellformed[b]
            some b.board[0][0]  // Piece at bottom-left
            #{row, col: Int | some b.board[row][col]} = 1  // Only one piece
        }
    } is sat

    // Test valid stacking in same column
    stackingValid: {
        some b: Board | {
            wellformed[b]
            some b.board[0][0]  // Bottom piece
            some b.board[1][0]  // Piece above it
            #{row, col: Int | some b.board[row][col]} = 2  // Only two pieces
        }
    } is sat
}

// Test expect blocks for invalid configurations
test expect {
    // Test piece outside row bounds is invalid
    outOfBoundsRowInvalid: {
        some b: Board | {
            wellformed[b]
            some b.board[6][0]  // Piece too high (above row 5)
        }
    } is unsat

    // Test piece outside column bounds is invalid
    outOfBoundsColInvalid: {
        some b: Board | {
            wellformed[b]
            some b.board[0][7]  // Piece too far right (beyond column 6)
        }
    } is unsat

    // Test floating piece is invalid
    floatingPieceInvalid: {
        some b: Board | {
            wellformed[b]
            some b.board[1][0]  // Piece in second row
            no b.board[0][0]    // No piece below it
        }
    } is unsat

    // Test negative indices are invalid
    negativeIndicesInvalid: {
        some b: Board | {
            wellformed[b]
            some b.board[-1][0] or some b.board[0][-1]
        }
    } is unsat
}

// Test expect blocks for valid board configurations
test expect {
    // Test valid column fill
    fullColumnValid: {
        some b: Board | {
            wellformed[b]
            // Fill entire first column
            some b.board[0][0]
            some b.board[1][0]
            some b.board[2][0]
            some b.board[3][0]
            some b.board[4][0]
            some b.board[5][0]
        }
    } is sat

    // Test multiple columns with different heights
    multipleColumnsValid: {
        some b: Board | {
            wellformed[b]
            // Two pieces in first column
            some b.board[0][0]
            some b.board[1][0]
            // One piece in second column
            some b.board[0][1]
        }
    } is sat
}

pred boardFull[b: Board] {
    all col: Int | col >= 0 and col <= 6 implies
        some b.board[5][col]
}

test expect {
    // Test that a full board with no winner is a draw
    drawPossible: {
        some b: Board | {
            wellformed[b]
            boardFull[b]
            not winning[b, Player0]
            not winning[b, Player1]
            
            // Force all pieces to be in valid positions
            all row, col: Int | some b.board[row][col] implies {
                row >= 0 and row <= 5
                col >= 0 and col <= 6
            }
        }
    } is sat
}

test expect {
    // test that a move to a full column is invalid
    fullColumnMove: {
        some b, b2: Board | {
            wellformed[b]
            b.board[0][0] = Player0
            b.board[1][0] = Player1
            b.board[2][0] = Player0
            b.board[3][0] = Player1
            b.board[4][0] = Player0
            b.board[5][0] = Player1
            move[b, 0, Player0, b2]
        }
    } is unsat
}

test expect {
    // test player can't make two consecutive moves
    noConsecutiveMoves: {
        some b1, b2, b3: Board | {
            wellformed[b1]
            starting[b1]
            some col: Int | {
                move[b1, col, Player0, b2]
                move[b2, col, Player0, b3] 
            }
        }
    } is unsat
}