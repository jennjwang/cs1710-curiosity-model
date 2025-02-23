#lang forge/froglet
open "connect-4.frg"

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