package main

import "core:fmt"

import rl "vendor:raylib"

SCREEN_WIDTH :: 300
SCREEN_HEIGHT :: 600

Color :: enum {
	DarkGray,
	Green,
	Red,
	Orange,
	Yellow,
	Purple,
	Cyan,
	Blue,
	DarkBlue,
}

Colors := [Color]rl.Color {
	.DarkGray = rl.Color{ 26, 31, 40, 255 },
	.Green = rl.Color{ 47, 230, 23, 255 },
	.Red = rl.Color{ 232, 18, 18, 255 },
	.Orange = rl.Color{ 226, 116, 17, 255 },
	.Yellow = rl.Color{ 237, 234, 4, 255 },
	.Purple = rl.Color{ 166, 0, 247, 255 },
	.Cyan = rl.Color{ 21, 204, 209, 255 },
	.Blue = rl.Color{ 13, 64, 216, 255 },
	.DarkBlue = rl.Color{ 44, 44, 127, 255 },
}

GridNumRows :: 20
GridNumCols :: 10

Grid :: struct {
	grid: [GridNumRows][GridNumCols]Color,
	numRows: int,
	numCols: int,
	cellSize: int,
}

Grid_New :: proc() -> Grid {
	return Grid {
		numRows = GridNumRows,
		numCols = GridNumCols,
		cellSize = 30,
	}
}

Grid_Print :: proc(g: Grid) {
	for i := 0; i < g.numRows; i += 1 {
		for j := 0; j < g.numCols; j += 1 {
			fmt.print(g.grid[i][j], " ")
		}
		fmt.println()
	}
}

Grid_Draw :: proc(g: ^Grid) {
	for row := 0; row < g.numRows; row += 1 {
		for col := 0; col < g.numCols; col += 1 {
			cellColor := g.grid[row][col]
			rl.DrawRectangle(
			i32(col * g.cellSize + 1),
			i32(row * g.cellSize + 1),
			i32(g.cellSize - 1),
			i32(g.cellSize - 1),
			Colors[cellColor],
			)
		}
	}
}

Grid_IsCellOutside :: proc(g: ^Grid, p: Position) -> bool {
	return p.row < 0 || p.row >= g.numRows || p.col < 0 || p.col >= g.numCols
}

Grid_IsCellEmpty :: proc(g: ^Grid, p: Position) -> bool {
	return g.grid[p.row][p.col] == Color(0)
}

Grid_IsRowFull :: proc(g: ^Grid, row: int) -> bool {
	for col := 0; col < g.numCols; col += 1 {
		if g.grid[row][col] == Color(0) {
			return false
		}
	}
	return true
}

Grid_ClearRow :: proc(g: ^Grid, row: int) {
	for col := 0; col < g.numCols; col += 1 {
		g.grid[row][col] = Color(0)
	}
}

Grid_MoveRowDown :: proc(g: ^Grid, row, numRows: int) {
	for col := 0; col < g.numCols; col += 1 {
		g.grid[row + numRows][col] = g.grid[row][col]
		g.grid[row][col] = Color(0)
	}
}

Grid_ClearFullRows :: proc(g: ^Grid) -> int {
	completed := 0
	for row := g.numRows - 1; row >= 0; row -= 1 {
		if Grid_IsRowFull(g, row) {
			Grid_ClearRow(g, row)
			completed+= 1
		}
		else if completed > 0 {
			Grid_MoveRowDown(g, row, completed)
		}
	}
	return completed
}

Position :: struct {
	row: int,
	col: int,
}

BlockType :: enum {
	L = 1,
	J,
	I,
	O,
	S,
	T,
	Z,
}

BlockPositions := #partial [BlockType][4][]Position {
	.L = {
		[]Position { { 0, 2 }, { 1, 0 }, { 1, 1 }, { 1, 2 } },
		[]Position { { 0, 1 }, { 1, 1 }, { 2, 1 }, { 2, 2 } },
		[]Position { { 1, 0 }, { 1, 1 }, { 1, 2 }, { 2, 0 } },
		[]Position { { 0, 0 }, { 0, 1 }, { 1, 1 }, { 2, 1 } },
	},
	.J = {
		[]Position { { 0, 0 }, { 1, 0 }, { 1, 1 }, { 1, 2 } },
		[]Position { { 0, 1 }, { 0, 2 }, { 1, 1 }, { 2, 1 } },
		[]Position { { 1, 0 }, { 1, 1 }, { 1, 2 }, { 2, 2 } },
		[]Position { { 0, 1 }, { 1, 1 }, { 2, 0 }, { 2, 1 } },
	},
	.I = {
		[]Position { { 1, 0 }, { 1, 1 }, { 1, 2 }, { 1, 3 } },
		[]Position { { 0, 2 }, { 1, 2 }, { 2, 2 }, { 3, 2 } },
		[]Position { { 2, 0 }, { 2, 1 }, { 2, 2 }, { 2, 3 } },
		[]Position { { 0, 1 }, { 1, 1 }, { 2, 1 }, { 3, 1 } },
	},
	.O = {
		[]Position { { 0, 0 }, { 0, 1 }, { 1, 0 }, { 1, 1 } },
		[]Position { { 0, 0 }, { 0, 1 }, { 1, 0 }, { 1, 1 } },
		[]Position { { 0, 0 }, { 0, 1 }, { 1, 0 }, { 1, 1 } },
		[]Position { { 0, 0 }, { 0, 1 }, { 1, 0 }, { 1, 1 } },
	},
	.S = {
		[]Position { { 0, 1 }, { 0, 2 }, { 1, 0 }, { 1, 1 } },
		[]Position { { 0, 0 }, { 1, 0 }, { 1, 1 }, { 2, 1 } },
		[]Position { { 1, 1 }, { 1, 2 }, { 2, 0 }, { 2, 1 } },
		[]Position { { 0, 1 }, { 1, 1 }, { 1, 2 }, { 2, 2 } },
	},
	.T = {
		[]Position { { 0, 1 }, { 1, 0 }, { 1, 1 }, { 1, 2 } },
		[]Position { { 0, 1 }, { 1, 1 }, { 1, 2 }, { 2, 1 } },
		[]Position { { 1, 0 }, { 1, 1 }, { 1, 2 }, { 2, 1 } },
		[]Position { { 0, 1 }, { 1, 0 }, { 1, 1 }, { 2, 1 } },
	},
	.Z = {
		[]Position { { 0, 0 }, { 0, 1 }, { 1, 1 }, { 1, 2 } },
		[]Position { { 0, 2 }, { 1, 1 }, { 1, 2 }, { 2, 1 } },
		[]Position { { 1, 0 }, { 1, 1 }, { 2, 1 }, { 2, 2 } },
		[]Position { { 0, 1 }, { 1, 0 }, { 1, 1 }, { 2, 0 } },
	},
}

Block :: struct {
	color: rl.Color,
	cellSize: int,
	rotationState: int,
	blockType: BlockType,
	rowOffset: int,
	colOffset: int,

	cells: [4][]Position,
}

Block_New :: proc(t: BlockType) -> Block {
	initialPos : Position
	switch t {
	case .L:
		initialPos.row = 0
		initialPos.col = 3
	case .J:
		initialPos.row = 0
		initialPos.col = 3
	case .I:
		initialPos.row = -1
		initialPos.col = 3
	case .O:
		initialPos.row = 0
		initialPos.col = 4
	case .S:
		initialPos.row = 0
		initialPos.col = 3
	case .T:
		initialPos.row = 0
		initialPos.col = 3
	case .Z:
		initialPos.row = 0
		initialPos.col = 3
	}
	return Block {
		color = Colors[cast(Color)t],
		cellSize = 30,
		rotationState = 0,
		blockType = t,
		rowOffset = initialPos.row,
		colOffset = initialPos.col,
		cells = BlockPositions[t],
	}
}

Block_Move :: proc(b: ^Block, p: Position) {
	b.rowOffset += p.row
	b.colOffset += p.col
}

Block_Rotate :: proc(b: ^Block) {
	b.rotationState = (b.rotationState + 1) % len(b.cells)
}

Block_UndoRotation :: proc(b: ^Block) {
	b.rotationState = b.rotationState - 1
	if b.rotationState < 0 {
		b.rotationState = len(b.cells) - 1
	}
}

Block_GetCellPositions :: proc(b: ^Block) -> [4]Position {
	tiles := b.cells[b.rotationState]
	movedTiles := [4]Position{ }
	for tile, i in &tiles {
		movedTiles[i] = Position{ tile.row + b.rowOffset, tile.col + b.colOffset }
	}
	return movedTiles
}

Block_Draw :: proc(b: ^Block) {
	tiles := Block_GetCellPositions(b)

	for tile in tiles {
		rl.DrawRectangle(
		i32(tile.col * b.cellSize + 1),
		i32(tile.row * b.cellSize + 1),
		i32(b.cellSize - 1),
		i32(b.cellSize - 1),
		b.color,
		)
	}
}

Game :: struct {
	grid: Grid,
	blocks: [BlockType]Block,
	usedBlocks: [BlockType]bool,
	currentBlock: Block,
	nextBlock: Block,
}

Game_New :: proc() -> Game {
	g := Game {
		grid = Grid_New(),
		blocks = [BlockType]Block{
			.L = Block_New(.L),
			.J = Block_New(.J),
			.I = Block_New(.I),
			.O = Block_New(.O),
			.S = Block_New(.S),
			.T = Block_New(.T),
			.Z = Block_New(.Z),
		},
	}

	g.currentBlock = Game_RandomBlock(&g)
	g.nextBlock = Game_RandomBlock(&g)
	return g
}

Game_ResetUsedBlocks :: proc(g: ^Game) {
	fmt.println("Resetting used blocks")
	for t in BlockType {
		g.usedBlocks[t] = false
	}
}

Game_GetAvailableBlocks :: proc(g: ^Game) -> i32 {
	available: i32
	for isUsed, blockType in g.usedBlocks {
		if !isUsed {
			available += 1
		}
	}
	return available
}

Game_RandomBlock :: proc(g: ^Game) -> Block {
	if Game_GetAvailableBlocks(g) == 0 {
		Game_ResetUsedBlocks(g)
	}

	availableBlocks := [dynamic]BlockType{ }
	defer delete(availableBlocks)

	for isUsed, blockType in g.usedBlocks {
		fmt.println(blockType, isUsed)
		if !isUsed {
			append(&availableBlocks, blockType)
		}
	}
	fmt.println(availableBlocks)
	randomIndex := rl.GetRandomValue(0, i32(len(availableBlocks) - 1))
	nextType := availableBlocks[randomIndex]
	g.usedBlocks[nextType] = true
	return g.blocks[nextType]
}

Game_Draw :: proc(g: ^Game) {
	Grid_Draw(&g.grid)
	Block_Draw(&g.currentBlock)
}

Game_HandleInput :: proc(g: ^Game) {
	if rl.IsKeyPressed(rl.KeyboardKey.RIGHT) {
		Game_MoveBlockRight(g)
	}
	if rl.IsKeyPressed(rl.KeyboardKey.LEFT) {
		Game_MoveBlockLeft(g)
	}
	if rl.IsKeyPressed(rl.KeyboardKey.DOWN) {
		Game_MoveBlockDown(g)
	}
	if rl.IsKeyPressed(rl.KeyboardKey.UP) {
		Game_RotateBlock(g)
	}
}

Game_MoveBlockLeft :: proc(g: ^Game) {
	Block_Move(&g.currentBlock, Position{ 0, -1 })
	if Game_IsBlockOutside(g) || !Game_BlockFits(g, &g.currentBlock) {
		Block_Move(&g.currentBlock, Position{ 0, 1 })
	}
}

Game_MoveBlockRight :: proc(g: ^Game) {
	Block_Move(&g.currentBlock, Position{ 0, 1 })
	if Game_IsBlockOutside(g) || !Game_BlockFits(g, &g.currentBlock) {
		Block_Move(&g.currentBlock, Position{ 0, -1 })
	}
}

Game_MoveBlockDown :: proc(g: ^Game) {
	Block_Move(&g.currentBlock, Position{ 1, 0 })
	if Game_IsBlockOutside(g) || !Game_BlockFits(g, &g.currentBlock) {
		Block_Move(&g.currentBlock, Position{ -1, 0 })
		Game_LockBlock(g)
	}
}

Game_RotateBlock :: proc(g: ^Game) {
	Block_Rotate(&g.currentBlock)
	if Game_IsBlockOutside(g) {
		Block_UndoRotation(&g.currentBlock)
	}
}

Game_LockBlock :: proc(g: ^Game) {
	tiles := Block_GetCellPositions(&g.currentBlock)
	for tile in tiles {
		g.grid.grid[tile.row][tile.col] = cast(Color)g.currentBlock.blockType
	}
	g.currentBlock = g.nextBlock
	g.nextBlock = Game_RandomBlock(g)
	Grid_ClearFullRows(&g.grid)
}

Game_IsBlockOutside :: proc(g: ^Game) -> bool {
	tiles := Block_GetCellPositions(&g.currentBlock)
	for tile in tiles {
		if Grid_IsCellOutside(&g.grid, tile) {
			return true
		}
	}
	return false
}

Game_BlockFits :: proc(g: ^Game, b: ^Block) -> bool {
	tiles := Block_GetCellPositions(b)
	for tile in tiles {
		if !Grid_IsCellEmpty(&g.grid, tile) {
			return false
		}
	}
	return true
}

lastUpdateTime: f64
BlockMoveInterval :: 0.2

eventTriggered :: proc(interval: f64 = BlockMoveInterval) -> bool {
	if rl.GetTime() - lastUpdateTime >= interval {
		lastUpdateTime = rl.GetTime()
		return true
	}
	return false
}

main :: proc () {
	fmt.println("Hello, World!")
	rl.InitWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "Block Game - Odin")
	rl.SetTargetFPS(120)

	game := Game_New()
	lastUpdateTime : f32 = 0

	for !rl.WindowShouldClose() {
		Game_HandleInput(&game)
		if eventTriggered(0.3) {
			Game_MoveBlockDown(&game)
		}

		rl.BeginDrawing()
		{
			rl.ClearBackground(Colors[.DarkBlue])
			Game_Draw(&game)

			rl.DrawFPS(10, 10)
		}
		rl.EndDrawing()
	}
}
