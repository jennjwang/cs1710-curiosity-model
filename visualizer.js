/*
  Visualization script for Connect 4 game in Sterling.
  Displays board states for each Board atom in the Forge model.
  
  Based on the Connect 4 model with 3 players.
*/

// Helper functions to extract atoms
function firstAtomOf(expr) {
  if (!expr.empty()) return expr.tuples()[0].atoms()[0];
  return "none";
}
const fam = firstAtomOf; // shorthand

// Constants for visualization
const CELL_SIZE = 40;
const BOARD_WIDTH = 7;
const BOARD_HEIGHT = 6;
const BOARD_SPACING = 60;

// Get all Board atoms
const boards = Board.tuples().map((btup) => fam(btup));

// Get all Player atoms
const players = Player.tuples().map((ptup) => fam(ptup));

// Create configuration for the board grid
const boardGridConfig = {
  grid_location: { x: 10, y: 10 },
  cell_size: { x_size: CELL_SIZE, y_size: CELL_SIZE },
  grid_dimensions: {
    y_size: BOARD_HEIGHT, // 6 rows
    x_size: BOARD_WIDTH, // 7 columns
  },
};

// Create a stage to hold all visualizations
const stage = new Stage();

// Function to get player color
function getPlayerColor(player) {
  if (player && player.id().includes("Player0")) return "red";
  if (player && player.id().includes("Player1")) return "yellow";
  if (player && player.id().includes("Player2")) return "blue";
  return "white";
}

// Function to get player label
function getPlayerLabel(player) {
  if (player && player.id().includes("Player0")) return "P0";
  if (player && player.id().includes("Player1")) return "P1";
  if (player && player.id().includes("Player2")) return "P2";
  return "";
}

// Track vertical position for multiple boards
let yOffset = 10;

// Process each board
boards.forEach((board, boardIndex) => {
  // Create title for the board
  const boardTitle = new TextBox({
    text: `Board: ${board.id()}`,
    x: 10,
    y: yOffset,
    color: "black",
    size: 16,
    font: "bold",
  });
  stage.add(boardTitle);

  // Adjust y-offset for the grid
  yOffset += 30;

  // Create grid for this board
  const boardGridConfig = {
    grid_location: { x: 10, y: yOffset },
    cell_size: { x_size: CELL_SIZE, y_size: CELL_SIZE },
    grid_dimensions: {
      y_size: BOARD_HEIGHT,
      x_size: BOARD_WIDTH,
    },
  };

  const boardGrid = new Grid(boardGridConfig);

  // Populate the grid with pieces
  for (let row = 0; row < BOARD_HEIGHT; row++) {
    for (let col = 0; col < BOARD_WIDTH; col++) {
      // Calculate inverted row (to show row 0 at bottom)
      const invertedRow = BOARD_HEIGHT - 1 - row;

      // Get player at this position
      const boardAtRow = board.join(board).join(row);
      const playerAtCell = boardAtRow.join(col);

      // Create a circle for the cell
      const cellColor = getPlayerColor(playerAtCell.atom());
      const playerLabel = getPlayerLabel(playerAtCell.atom());

      // Add a circle to represent the cell
      boardGrid.add(
        { x: col, y: invertedRow },
        new Circle({
          radius: CELL_SIZE * 0.4,
          fill: cellColor,
          stroke: "black",
          strokeWidth: 1,
        })
      );

      // Add the player label if there's a piece here
      if (playerLabel) {
        boardGrid.add(
          { x: col, y: invertedRow },
          new TextBox({
            text: playerLabel,
            color: "white",
            size: 14,
            bold: true,
          })
        );
      }
    }
  }

  // Add column labels at the bottom
  for (let col = 0; col < BOARD_WIDTH; col++) {
    const colLabel = new TextBox({
      text: `${col}`,
      x: 10 + col * CELL_SIZE + CELL_SIZE / 2,
      y: yOffset + BOARD_HEIGHT * CELL_SIZE + 15,
      color: "black",
      size: 12,
    });
    stage.add(colLabel);
  }

  // Add the board grid to the stage
  stage.add(boardGrid);

  // Add border around the entire board
  const boardBorder = new Rectangle({
    x: 10,
    y: yOffset,
    width: BOARD_WIDTH * CELL_SIZE,
    height: BOARD_HEIGHT * CELL_SIZE,
    fill: "none",
    stroke: "black",
    strokeWidth: 2,
  });
  stage.add(boardBorder);

  // Update y-offset for the next board
  yOffset += BOARD_HEIGHT * CELL_SIZE + BOARD_SPACING;
});

// Add a legend to explain the colors
const legendY = yOffset;
const players = ["Player0", "Player1", "Player2"];
const colors = ["red", "yellow", "blue"];
const labels = ["P0", "P1", "P2"];

// Title for the legend
const legendTitle = new TextBox({
  text: "Legend:",
  x: 10,
  y: legendY,
  color: "black",
  size: 14,
  font: "bold",
});
stage.add(legendTitle);

// Add legend items
for (let i = 0; i < players.length; i++) {
  // Circle for the player color
  const legendCircle = new Circle({
    x: 70 + i * 80,
    y: legendY,
    radius: 15,
    fill: colors[i],
    stroke: "black",
    strokeWidth: 1,
  });
  stage.add(legendCircle);

  // Label for the player
  const legendLabel = new TextBox({
    text: labels[i],
    x: 70 + i * 80,
    y: legendY,
    color: "white",
    size: 12,
    bold: true,
  });
  stage.add(legendLabel);

  // Player name
  const playerName = new TextBox({
    text: players[i],
    x: 70 + i * 80,
    y: legendY + 25,
    color: "black",
    size: 12,
  });
  stage.add(playerName);
}

// Render the stage
stage.render(svg);
