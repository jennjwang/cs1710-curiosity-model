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



test suite for winning {

    // valid case: x wins with horizontal connections
    example horizontalWinX is { XWinning } for {
        Board = `Board0
        X = `X
        O = `O
        Player = X + O
        `Board0.board = (0, 0) -> `X +
                        (0, 1) -> `X +
                        (0, 2) -> `X +
                        (0, 3) -> `X
    }

    // valid case: o wins with horizontal connections
    example horizontalWinO is { OWinning } for {
        Board = `Board0
        X = `X      
        O = `O
        Player = X + O
        `Board0.board = (1, 0) -> `O +
                        (1, 1) -> `O +
                        (1, 2) -> `O +
                        (1, 3) -> `O
    }

    // valid case: x wins with vertical connections
    example verticalWinX is { XWinning } for {
        Board = `Board0
        X = `X      
        O = `O
        Player = X + O
        `Board0.board = (0, 2) -> `X +
                        (1, 2) -> `X +
                        (2, 2) -> `X +
                        (3, 2) -> `X
    }

    // valid case: o wins with vertical connections
    example verticalWinO is { OWinning } for {
        Board = `Board0
        X = `X      
        O = `O
        Player = X + O
        `Board0.board = (0, 0) -> `O +
                        (1, 0) -> `O +
                        (2, 0) -> `O +
                        (3, 0) -> `O
    }

    // valid case: x wins with diagonal connections
    example diagonalWinX is { XWinning } for {
        Board = `Board0
        X = `X      
        O = `O
        Player = X + O
        `Board0.board = (0, 0) -> `X +
                        (1, 1) -> `X +
                        (2, 2) -> `X +
                        (3, 3) -> `X
    }

    // valid case: o wins with diagonal connections
    example diagonalWinO is { OWinning } for {
        Board = `Board0
        X = `X      
        O = `O
        Player = X + O
        `Board0.board = (3, 0) -> `O +
                        (2, 1) -> `O +
                        (1, 2) -> `O +
                        (0, 3) -> `O
    }

    // invalid case: there is no winner
    example noWinner is { not OWinning && not XWinning } for {
        Board = `Board0
        X = `X      
        O = `O
        Player = X + O
        `Board0.board = (0, 0) -> `X +
                        (0, 1) -> `O +
                        (0, 2) -> `X +
                        (1, 0) -> `O +
                        (1, 1) -> `X +
                        (1, 2) -> `O
    }

}


test expect {
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


test expect {
    // test empty board is wellformed
    emptyBoardValid: {
        some b: Board | {
            starting[b]
            wellformed[b]
        }
    } is sat

    // test valid piece placement at bottom
    bottomPieceValid: {
        some b: Board | {
            wellformed[b]
            some b.board[0][0]  // piece at bottom-left
            #{row, col: Int | some b.board[row][col]} = 1  // only one piece
        }
    } is sat

    // test valid stacking in same column
    stackingValid: {
        some b: Board | {
            wellformed[b]
            some b.board[0][0]  // bottom piece
            some b.board[1][0]  // piece above it
            #{row, col: Int | some b.board[row][col]} = 2  // only two pieces
        }
    } is sat
}

test expect {
    // test piece outside row bounds is invalid
    outOfBoundsRowInvalid: {
        some b: Board | {
            wellformed[b]
            some b.board[6][0]  // piece too high
        }
    } is unsat

    // test piece outside column bounds is invalid
    outOfBoundsColInvalid: {
        some b: Board | {
            wellformed[b]
            some b.board[0][7]  // piece too far right
        }
    } is unsat

    // test floating piece is invalid
    floatingPieceInvalid: {
        some b: Board | {
            wellformed[b]
            some b.board[1][0]  // piece in second row
            no b.board[0][0]    // no piece below it
        }
    } is unsat

    // test negative indices are invalid
    negativeIndicesInvalid: {
        some b: Board | {
            wellformed[b]
            some b.board[-1][0] or some b.board[0][-1]
        }
    } is unsat
}

test expect {
    // test valid column fill
    fullColumnValid: {
        some b: Board | {
            wellformed[b]
            // fill entire first column
            some b.board[0][0]
            some b.board[1][0]
            some b.board[2][0]
            some b.board[3][0]
            some b.board[4][0]
            some b.board[5][0]
        }
    } is sat

    // test multiple columns with different heights
    multipleColumnsValid: {
        some b: Board | {
            wellformed[b]
            // two pieces in first column
            some b.board[0][0]
            some b.board[1][0]
            // one piece in second column
            some b.board[0][1]
        }
    } is sat
}