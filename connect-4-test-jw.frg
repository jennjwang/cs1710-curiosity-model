#lang forge/froglet

open "connect-4.frg"

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