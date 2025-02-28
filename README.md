# cs1710-curiosity-model

## Project Objective

**What are you trying to model? Include a brief description that would give someone unfamiliar with the topic a basic understanding of your goal.**

This project models Connect Four, a two-player strategy game played on a 7x6 grid. Players take turns dropping pieces into columns, with the pieces stacking in the lowest available row. The objective is to form a line of four pieces in a row either horizontally, vertically, or diagonally. The model enforces the game rules and verifies conditions for valid moves and win detection. In this project, we also explored a three player version of the

## Model Design and Visualization

**Give an overview of your model design choices, what checks or run statements you wrote, and what we should expect to see from an instance produced by the Sterling visualizer. How should we look at and interpret an instance created by your spec? Did you create a custom visualization, or did you use the default?**

The model represents the game board as a 6 x 7 grid, with pieces placed according to game rules. Each move follows the mechanics of gravity, meaning pieces must fall to the lowest available row within a column. We chose to model the board as a partial function mapping row and column indices to players. This allows for a sparse representation of the board, where only occupied positions are stored.

We created two versions of the game, one with the traditional two players and another with three players, which gives us more complex scenarios to look at. In the model, we forced rules including:

- Turn order: in the two-player version, Player0 and Player1 alternate turnes. In the sequence is Player0 -> Player1 -> Player2 -> Player0 -> ... In both versions, the players should have roughly the same number of pieces on the board, ensuring that no player is ahead in the number of moves.
- Valid moves: The move predicate ensures that:
  - A piece is placed in a valid column (0–6).
  - The piece is placed in the lowest empty spot in a chosen column (no floating pieces).
  - The move is made by the correct player according to the turn order.
- Well-formed boards: The wellformed predicate ensures that:
  - The board dimensions are respected (rows 0–5, columns 0–6).
  - No floating pieces exist (every piece must have a piece below it, except for the bottom row).

We include checks and run statements for:

- Valid piece placement: checking that the model rejects invalid configurations like floating pieces and out-of-bounds placements.
- Win condition detection: verifying the model correctly identifies horizontal, vertical, and diagonal connections of four pieces for both players).
- Game progression: making sure that players alternate turns correctly and that the board is balanced.

An instance produced by the Sterling visualizer shows a sequence of Board objects representing the game states as play progresses. Each Board shows the placement of pieces, mapping coordinates to players. To interpret these instances, first look at the Game.firstBoard relation to identify the starting state, then follow the Game.nextBoard connections to trace the game's progression. Each Board's "board" relation shows which player has pieces at specific coordinates, with rows starting at 0 (bottom) and columns from 0-6 (left to right).

We created a custom visualization that displays each Board instance as a traditional Connect Four grid with 7 columns and 6 rows. Each board is rendered vertically as a grid of cells with empty white circles representing available spaces. Player pieces are shown as colored circles: Player0 pieces appear as red circles labeled "P0", Player1 pieces as yellow circles labeled "P1", and Player2 pieces, if available, as blue circles labeled "P2". The visualization inverts the row indexing so that row 0 appears at the bottom of the display (matching how pieces would naturally stack in a physical Connect Four game) and matches the column indexing from 0-6 left to right. Multiple boards are displayed vertically in sequence, each labeled with its corresponding atom name (e.g., "Board0", "Board1"). You can follow the boards from top to bottom, seeing how pieces accumulate and how the game state evolves with each move.

**Signatures and Predicates: At a high level, what do each of your sigs and preds represent in the context of the model? Justify the purpose for their existence and how they fit together.**

Signatures define the core entities (players, boards, game)

- Player: An abstract signature representing the players
  - This abstraction represents the game participants and allows us to model the alternating turn structure and track piece ownership
- Board: Represents the game board with a partial function mapping coordinates to players (Int -> Int -> Player)
  - The Board creates a 2D grid representing a specific state of the game board
- Game: Represents the entire game as a sequence of board states
  - The Game signature contains firstBoard (starting state) and nextBoard (transitions between states), connecting board states into a coherent game trace.

Key Predicates

Board structure and constraints: predicates that ensure wellformedness and valid game states

- wellformed: Ensures the board follows physical constraints
  - Bounds checking (6 rows, 7 columns)
  - Gravity simulation (no floating pieces)
- starting: Defines the initial empty state of the board
- lowestEmpty: Helper predicate that finds where a piece will land in a column
  - Implements the gravity rule of Connect Four

Game Mechanics: turn and move predicates define how the game progresses

- Player0Turn/Player1Turn: Controls turn alternation
  - Based on counting pieces to determine whose turn it is
  - Creates a balanced, alternating play pattern
- playerTurn: Determines whose turn it is based on piece count
  - Enforces the turn order Player0 → Player1 → Player2 in three player version
- move: Defines valid moves with guarding
  - Ensures turns alternate correctly
  - Makes sure pieces fall to the lowest available position
  - Preserves pieces from the previous state (frame condition)
- gameTrace: Creates sequences of valid game states
  - Manages progression from the first board through subsequent moves

Winning Conditions: winning predicates identify game outcomes

- winning: Determines if a player has won
  - Checks for four-in-a-row connections in the horizontal, vertical, and both diagonal directions
- guaranteedWin: Checks if a player is guaranteed to win on a board before putting down their last piece (i.e., they have at least two ways to connect their four pieces).
  - Useful for finding certain game states or analyzing board positions to develop a winning strategy.

**Testing: What tests did you write to test your model itself? What tests did you write to verify properties about your domain area? Feel free to give a high-level overview of this.**

We wrote tests to validate our Connect Four model. These tests revolved around the aspects of basic turn mechanics, board constraints, and types of player moves:

- Basic turn mechanics examples:

  - test_threePlayerTurns: tests three-player rotation (Player0 → Player1 → Player2 → Player0)
  - test_startingPlayer: checks that Player0 is always the first player
  - test_turns: verifies player alternation in two player setting (Player0 → Player1)

- Board constraints examples:

  - emptyBoardValid: confirms empty boards are well-formed
  - bottomPieceValid: tests valid piece placement at bottom
  - stackingValid: verifies pieces can stack properly
  - outOfBoundsRowInvalid: Ensures pieces can't be placed beyond the top row
  - outOfBoundsColInvalid: Verifies pieces can't be placed outside column boundaries
  - fullColumnValid: Tests the ability to completely fill a column
  - negativeIndicesInvalid: Checks that negative board coordinates are rejected
  - multipleColumnsValid: Verifies columns can have different heights
  - emptyBoardValid: Confirms empty boards are valid

- Player moves examples:
  - fullColumnMove: Verifies that attempting to place a piece in a full column is invalid
  - noConsecutiveMoves: Ensures players cannot make two consecutive moves, enforcing turn alternation

We also wrote tests to verify properties about our domain area, though we reocgnize the game and the domain arec closely related. These test make sure that the model adhered to the rules of Connect-4 and the gravity condition. These tests focused on verifying the winning conditions and checking that the pieces fall to the bottom of the board.

- Winning conditions examples:

  - Test suite with examples for all winning patterns: horizontalWinPlayer0 and horizontalWinPlayer1. verticalWinPlayer0 and verticalWinPlayer1, diagonalWinPlayer0 and diagonalWinPlayer1
  - noWinner for non-winning configurations
  - drawPossible: tests that a full board with no winner is a valid draw state

- Gravity condition examples:

  - floatingPieceInvalid: Confirms that pieces can't "float" without support
  - bottomPieceValid: Tests placement of a single piece at the bottom
  - stackingValid: Verifies that pieces can stack properly in the same column

Documentation: Make sure your model and test files are well-documented. This will help in understanding the structure and logic of your project.

Your README.md should not only serve as a guide to your project but also reflect your understanding and the thought process behind your modeling decisions.
