package main

import rl "vendor:raylib"

BlockType :: enum {
	L = 1,
	J,
	I,
	O,
	S,
	T,
	Z,
}

BlockPositions := [BlockType][4][]Position {
	.L =  {
		[]Position{{0, 2}, {1, 0}, {1, 1}, {1, 2}},
		[]Position{{0, 1}, {1, 1}, {2, 1}, {2, 2}},
		[]Position{{1, 0}, {1, 1}, {1, 2}, {2, 0}},
		[]Position{{0, 0}, {0, 1}, {1, 1}, {2, 1}},
	},
	.J =  {
		[]Position{{0, 0}, {1, 0}, {1, 1}, {1, 2}},
		[]Position{{0, 1}, {0, 2}, {1, 1}, {2, 1}},
		[]Position{{1, 0}, {1, 1}, {1, 2}, {2, 2}},
		[]Position{{0, 1}, {1, 1}, {2, 0}, {2, 1}},
	},
	.I =  {
		[]Position{{1, 0}, {1, 1}, {1, 2}, {1, 3}},
		[]Position{{0, 2}, {1, 2}, {2, 2}, {3, 2}},
		[]Position{{2, 0}, {2, 1}, {2, 2}, {2, 3}},
		[]Position{{0, 1}, {1, 1}, {2, 1}, {3, 1}},
	},
	.O =  {
		[]Position{{0, 0}, {0, 1}, {1, 0}, {1, 1}},
		[]Position{{0, 0}, {0, 1}, {1, 0}, {1, 1}},
		[]Position{{0, 0}, {0, 1}, {1, 0}, {1, 1}},
		[]Position{{0, 0}, {0, 1}, {1, 0}, {1, 1}},
	},
	.S =  {
		[]Position{{0, 1}, {0, 2}, {1, 0}, {1, 1}},
		[]Position{{0, 0}, {1, 0}, {1, 1}, {2, 1}},
		[]Position{{1, 1}, {1, 2}, {2, 0}, {2, 1}},
		[]Position{{0, 1}, {1, 1}, {1, 2}, {2, 2}},
	},
	.T =  {
		[]Position{{0, 1}, {1, 0}, {1, 1}, {1, 2}},
		[]Position{{0, 1}, {1, 1}, {1, 2}, {2, 1}},
		[]Position{{1, 0}, {1, 1}, {1, 2}, {2, 1}},
		[]Position{{0, 1}, {1, 0}, {1, 1}, {2, 1}},
	},
	.Z =  {
		[]Position{{0, 0}, {0, 1}, {1, 1}, {1, 2}},
		[]Position{{0, 2}, {1, 1}, {1, 2}, {2, 1}},
		[]Position{{1, 0}, {1, 1}, {2, 1}, {2, 2}},
		[]Position{{0, 1}, {1, 0}, {1, 1}, {2, 0}},
	},
}

Block :: struct {
	color:         rl.Color,
	cellSize:      int,
	rotationState: int,
	blockType:     BlockType,
	rowOffset:     int,
	colOffset:     int,
	cells:         [4][]Position,
}

Block_New :: proc(t: BlockType) -> Block {
	initialPos: Position
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
	return(
		Block {
			color = Colors[cast(Color)t],
			cellSize = 30,
			rotationState = 0,
			blockType = t,
			rowOffset = initialPos.row,
			colOffset = initialPos.col,
			cells = BlockPositions[t],
		} \
	)
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
	movedTiles := [4]Position{}
	for tile, i in &tiles {
		movedTiles[i] = Position{tile.row + b.rowOffset, tile.col + b.colOffset}
	}
	return movedTiles
}

Block_Draw :: proc(b: ^Block, offsetX, offsetY: int) {
	tiles := Block_GetCellPositions(b)

	for tile in tiles {
		rl.DrawRectangle(
			i32(tile.col * b.cellSize + offsetX), // 10 is the offset
			i32(tile.row * b.cellSize + offsetY), // 10 is the offset
			i32(b.cellSize - 1),
			i32(b.cellSize - 1),
			b.color,
		)
	}
}
