# cs1710-curiosity-model

## Project Objective

**What are you trying to model? Include a brief description that would give someone unfamiliar with the topic a basic understanding of your goal.**

This project models Connect Four, a two-player strategy game played on a 7x6 grid. Players take turns dropping pieces into columns, with the pieces stacking in the lowest available row. The objective is to form a line of four pieces in a row either horizontally, vertically, or diagonally. The model enforces the game rules and verifies conditions for valid moves and win detection. In this project, we explored gane states where players had guaranteed wins.

## Model Design and Visualization

**Give an overview of your model design choices, what checks or run statements you wrote, and what we should expect to see from an instance produced by the Sterling visualizer. How should we look at and interpret an instance created by your spec? Did you create a custom visualization, or did you use the default?**

The model represents the game board as a grid, with pieces placed according to game rules. Each move follows the mechanics of gravity, meaning pieces must fall to the lowest available row within a column.

We include checks and run statements for:

- **Valid piece placement** (ensuring pieces do not float above gaps).
- **Win condition detection** (checking for four connected pieces in any direction).
- **Game progression** (players alternating turns correctly).

Signatures and Predicates: At a high level, what do each of your sigs and preds represent in the context of the model? Justify the purpose for their existence and how they fit together.

Testing: What tests did you write to test your model itself? What tests did you write to verify properties about your domain area? Feel free to give a high-level overview of this.

Documentation: Make sure your model and test files are well-documented. This will help in understanding the structure and logic of your project.

Your README.md should not only serve as a guide to your project but also reflect your understanding and the thought process behind your modeling decisions.
