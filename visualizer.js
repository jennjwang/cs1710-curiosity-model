const d3 = require("d3");
d3.selectAll("svg > *").remove(); // Clear the SVG canvas

/*
  Visualizer for the Connect 4 game model.
  This code renders the board states for each Board atom in the Forge model.
  Each board is displayed as a grid of cells, with player pieces represented by colored circles.
*/

// Constants for visualization
const CELL_SIZE = 40; // Size of each cell in the grid
const BOARD_WIDTH = 7; // Number of columns in the Connect 4 board
const BOARD_HEIGHT = 6; // Number of rows in the Connect 4 board
const BOARD_SPACING = 60; // Vertical spacing between boards

// Function to draw a circle representing a player's piece
function drawPiece(row, col, yoffset, playerStr) {
  // Invert the row index so that 0 is the bottom row
  const invertedRow = BOARD_HEIGHT - 1 - row;

  // Determine player and color based on the string
  let color = "gray";
  let label = "?";

  if (playerStr.includes("00")) {
    color = "red";
    label = "P0";
  } else if (playerStr.includes("10")) {
    color = "yellow";
    label = "P1";
  } else if (playerStr.includes("20")) {
    color = "blue";
    label = "P2";
  }

  // Draw the colored circle
  d3.select(svg)
    .append("circle")
    .attr("cx", (col + 0.5) * CELL_SIZE) // X position (center of cell)
    .attr("cy", yoffset + (invertedRow + 0.5) * CELL_SIZE) // Y position (center of cell)
    .attr("r", CELL_SIZE * 0.4) // Radius (slightly smaller than cell)
    .attr("fill", color)
    .attr("stroke", "black")
    .attr("stroke-width", 1);

  // Add the player label
  d3.select(svg)
    .append("text")
    .style("fill", "white") // Text color
    .style("font-size", "14px") // Font size
    .style("text-anchor", "middle") // Center text horizontally
    .style("font-weight", "bold") // Make text bold
    .attr("x", (col + 0.5) * CELL_SIZE) // X position (column-based)
    .attr("y", yoffset + (invertedRow + 0.55) * CELL_SIZE) // Y position (using inverted row)
    .text(label); // Display the player label
}

// Function to print a board state
function printState(stateAtom, yoffset) {
  // Draw the game board with cells
  for (let r = 0; r < BOARD_HEIGHT; r++) {
    for (let c = 0; c < BOARD_WIDTH; c++) {
      // Invert the row index for display
      const invertedRow = BOARD_HEIGHT - 1 - r;

      // Draw each cell of the grid
      d3.select(svg)
        .append("rect")
        .attr("x", c * CELL_SIZE)
        .attr("y", yoffset + invertedRow * CELL_SIZE)
        .attr("width", CELL_SIZE)
        .attr("height", CELL_SIZE)
        .attr("stroke-width", 1)
        .attr("stroke", "black")
        .attr("fill", "#e0e0e0"); // Light gray background

      // Draw empty slot circles
      d3.select(svg)
        .append("circle")
        .attr("cx", (c + 0.5) * CELL_SIZE)
        .attr("cy", yoffset + (invertedRow + 0.5) * CELL_SIZE)
        .attr("r", CELL_SIZE * 0.4)
        .attr("fill", "white")
        .attr("stroke", "#cccccc")
        .attr("stroke-width", 1);
    }
  }

  // Draw a rectangle around the entire board
  d3.select(svg)
    .append("rect")
    .attr("x", 0)
    .attr("y", yoffset)
    .attr("width", BOARD_WIDTH * CELL_SIZE)
    .attr("height", BOARD_HEIGHT * CELL_SIZE)
    .attr("stroke-width", 2)
    .attr("stroke", "black")
    .attr("fill", "none");

  // Add pieces to the board
  for (let r = 0; r < BOARD_HEIGHT; r++) {
    for (let c = 0; c < BOARD_WIDTH; c++) {
      // Get the player piece at (r, c)
      const player = stateAtom.board[r][c];
      if (player != null) {
        // Get string representation of the player
        const playerStr = player.toString();
        // Draw the player piece
        drawPiece(r, c, yoffset, playerStr);
      }
    }
  }
}

// Add column labels at the bottom of each board
function addColumnLabels(yoffset) {
  for (let c = 0; c < BOARD_WIDTH; c++) {
    d3.select(svg)
      .append("text")
      .style("fill", "black")
      .style("font-size", "12px")
      .style("text-anchor", "middle")
      .attr("x", (c + 0.5) * CELL_SIZE)
      .attr("y", yoffset + BOARD_HEIGHT * CELL_SIZE + 15)
      .text(c);
  }
}

// Main visualization logic
let offset = 30; // Vertical offset for the first board
for (let b = 0; b <= 10; b++) {
  const boardAtom = Board.atom("Board" + b); // Get the Board atom
  if (boardAtom != null) {
    // Add board label
    d3.select(svg)
      .append("text")
      .style("fill", "black")
      .style("font-size", "16px")
      .style("font-weight", "bold")
      .attr("x", 0)
      .attr("y", offset - 10)
      .text("Board" + b);

    printState(boardAtom, offset); // Render the board state
    addColumnLabels(offset); // Add column labels

    offset += BOARD_HEIGHT * CELL_SIZE + BOARD_SPACING; // Increase offset for the next board
  }
}
