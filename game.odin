package main

import "core:fmt"

import rl "vendor:raylib"

Game :: struct {
	grid:         Grid,
	blocks:       [BlockType]Block,
	usedBlocks:   [BlockType]bool,
	currentBlock: Block,
	nextBlock:    Block,
	gameOver:     bool,
	score:        int,
	music:        rl.Music,
	rotateSound:  rl.Sound,
	clearSound:   rl.Sound,
}

Game_New :: proc() -> Game {
	g := Game {
		grid = Grid_New(),
		blocks = [BlockType]Block {
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
	rl.InitAudioDevice()

	g.music = rl.LoadMusicStream("sounds/music.mp3")
	g.rotateSound = rl.LoadSound("sounds/rotate.mp3")
	g.clearSound = rl.LoadSound("sounds/clear.mp3")

	rl.PlayMusicStream(g.music)
	return g
}

Game_Destroy :: proc(g: ^Game) {
	rl.UnloadMusicStream(g.music)
	rl.UnloadSound(g.rotateSound)
	rl.UnloadSound(g.clearSound)

	rl.CloseAudioDevice()
}

@(private)
Game_ResetUsedBlocks :: proc(g: ^Game) {
	fmt.println("Resetting used blocks")
	for t in BlockType {
		g.usedBlocks[t] = false
	}
}

@(private)
Game_GetAvailableBlocks :: proc(g: ^Game) -> i32 {
	available: i32
	for isUsed, blockType in g.usedBlocks {
		if !isUsed {
			available += 1
		}
	}
	return available
}

@(private)
Game_RandomBlock :: proc(g: ^Game) -> Block {
	if Game_GetAvailableBlocks(g) == 0 {
		Game_ResetUsedBlocks(g)
	}

	availableBlocks := [dynamic]BlockType{}
	defer delete(availableBlocks)

	for isUsed, blockType in g.usedBlocks {
		if !isUsed {
			append(&availableBlocks, blockType)
		}
	}
	randomIndex := rl.GetRandomValue(0, i32(len(availableBlocks) - 1))
	nextType := availableBlocks[randomIndex]
	g.usedBlocks[nextType] = true
	return g.blocks[nextType]
}

Game_Draw :: proc(g: ^Game) {
	Grid_Draw(&g.grid)
	Block_Draw(&g.currentBlock, 11, 11)
	#partial switch g.nextBlock.blockType {
	case .I:
		Block_Draw(&g.nextBlock, 255, 290)
	case .O:
		Block_Draw(&g.nextBlock, 255, 280)
	case:
		Block_Draw(&g.nextBlock, 270, 270)
	}
}

@(private)
Game_Reset :: proc(g: ^Game) {
	Grid_Reset(&g.grid)
	g.currentBlock = Game_RandomBlock(g)
	g.nextBlock = Game_RandomBlock(g)
	g.gameOver = false
	g.score = 0
}

Game_HandleInput :: proc(g: ^Game) {
	keyPress := rl.GetKeyPressed()
	if g.gameOver && keyPress != .KEY_NULL {
		Game_Reset(g)
		return
	}
	#partial switch keyPress {
	case .RIGHT:
		Game_MoveBlockRight(g)
	case .LEFT:
		Game_MoveBlockLeft(g)
	case .DOWN:
		Game_MoveBlockDown(g)
		Game_UpdateScore(g, 0, 1)
		break
	case .UP:
		Game_RotateBlock(g)
	}
}

@(private)
Game_MoveBlockLeft :: proc(g: ^Game) {
	if g.gameOver {
		return
	}
	Block_Move(&g.currentBlock, Position{0, -1})
	if Game_IsBlockOutside(g) || !Game_BlockFits(g, &g.currentBlock) {
		Block_Move(&g.currentBlock, Position{0, 1})
	}
}

@(private)
Game_MoveBlockRight :: proc(g: ^Game) {
	if g.gameOver {
		return
	}
	Block_Move(&g.currentBlock, Position{0, 1})
	if Game_IsBlockOutside(g) || !Game_BlockFits(g, &g.currentBlock) {
		Block_Move(&g.currentBlock, Position{0, -1})
	}
}

@(private)
Game_MoveBlockDown :: proc(g: ^Game) {
	if g.gameOver {
		return
	}
	Block_Move(&g.currentBlock, Position{1, 0})
	if Game_IsBlockOutside(g) || !Game_BlockFits(g, &g.currentBlock) {
		Block_Move(&g.currentBlock, Position{-1, 0})
		Game_LockBlock(g)
	}
}

@(private)
Game_RotateBlock :: proc(g: ^Game) {
	if g.gameOver {
		return
	}
	Block_Rotate(&g.currentBlock)
	if Game_IsBlockOutside(g) {
		Block_UndoRotation(&g.currentBlock)
	} else {
		rl.PlaySound(g.rotateSound)
	}
}

@(private)
Game_LockBlock :: proc(g: ^Game) {
	tiles := Block_GetCellPositions(&g.currentBlock)
	for tile in tiles {
		g.grid.grid[tile.row][tile.col] = cast(Color)g.currentBlock.blockType
	}
	g.currentBlock = g.nextBlock
	if (!Game_BlockFits(g, &g.currentBlock)) {
		g.gameOver = true
	}
	g.nextBlock = Game_RandomBlock(g)
	if rowsCleared := Grid_ClearFullRows(&g.grid); rowsCleared > 0 {
		rl.PlaySound(g.clearSound)
		Game_UpdateScore(g, rowsCleared, 0)
	}
}

@(private)
Game_IsBlockOutside :: proc(g: ^Game) -> bool {
	tiles := Block_GetCellPositions(&g.currentBlock)
	for tile in tiles {
		if Grid_IsCellOutside(&g.grid, tile) {
			return true
		}
	}
	return false
}

@(private)
Game_BlockFits :: proc(g: ^Game, b: ^Block) -> bool {
	tiles := Block_GetCellPositions(b)
	for tile in tiles {
		if !Grid_IsCellEmpty(&g.grid, tile) {
			return false
		}
	}
	return true
}

@(private)
Game_UpdateScore :: proc(g: ^Game, linesCleared, moveDownPoints: int) {
	switch linesCleared {
	case 1:
		g.score += 100
	case 2:
		g.score += 300
	case 3:
		g.score += 500
	case:
	// nothing
	}
	g.score += moveDownPoints
}
