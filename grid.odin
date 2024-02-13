package main

import "core:fmt"

import rl "vendor:raylib"

GridNumRows :: 20
GridNumCols :: 10

Position :: struct {
	row: int,
	col: int,
}

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
			completed += 1
		} else if completed > 0 {
			Grid_MoveRowDown(g, row, completed)
		}
	}
	return completed
}
