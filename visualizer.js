const d3 = require("d3");
d3.selectAll("svg > *").remove(); // Clear the SVG canvas

/*
  Visualizer for the Connect 4 game model.
  This code renders the board states for each Board atom in the Forge model.
  Each board is displayed as a grid of cells, with player pieces represented by their initials (P0, P1, P2).

  TN 2024
*/

// Constants for visualization
const CELL_SIZE = 40; // Size of each cell in the grid
const BOARD_WIDTH = 7; // Number of columns in the Connect 4 board
const BOARD_HEIGHT = 6; // Number of rows in the Connect 4 board
const BOARD_SPACING = 60; // Vertical spacing between boards

// Function to print a value (player piece) in a specific cell
function printValue(row, col, yoffset, value) {
  // Invert the row index so that 0 is the bottom row
  const invertedRow = BOARD_HEIGHT - 1 - row;

  d3.select(svg)
    .append("text")
    .style("fill", "black") // Text color
    .style("font-size", "20px") // Font size
    .style("text-anchor", "middle") // Center text horizontally
    .attr("x", (col + 0.5) * CELL_SIZE) // X position (column-based)
    .attr("y", yoffset + (invertedRow + 0.75) * CELL_SIZE) // Y position (using inverted row)
    .text(value); // Display the player piece (P0, P1, P2)
}

// Function to print a board state
function printState(stateAtom, yoffset) {
  // Draw the grid for the board
  for (let r = 0; r < BOARD_HEIGHT; r++) {
    for (let c = 0; c < BOARD_WIDTH; c++) {
      // Get the player piece at (r, c)
      const player = stateAtom.board[r][c];
      if (player != null) {
        // Print the player piece (P0, P1, P2)
        const playerString = player.toString();
        // Fix the issue with playerAbbrev by using the last character
        if (playerString.length >= 2) {
          const playerAbbrev =
            playerString[0] + playerString[playerString.length - 1];
          printValue(r, c, yoffset, playerAbbrev);
        }
      }
    }
  }

  // Draw a rectangle around the board
  d3.select(svg)
    .append("rect")
    .attr("x", 0)
    .attr("y", yoffset)
    .attr("width", BOARD_WIDTH * CELL_SIZE)
    .attr("height", BOARD_HEIGHT * CELL_SIZE)
    .attr("stroke-width", 2)
    .attr("stroke", "black")
    .attr("fill", "transparent");
}

// Main visualization logic
let offset = 10; // Vertical offset for the first board
for (let b = 0; b <= 10; b++) {
  const boardAtom = Board.atom("Board" + b); // Get the Board atom
  if (boardAtom != null) {
    printState(boardAtom, offset); // Render the board state
    offset += BOARD_HEIGHT * CELL_SIZE + BOARD_SPACING; // Increase offset for the next board
  }
}
