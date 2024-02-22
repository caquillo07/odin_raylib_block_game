package main

import "core:fmt"

import rl "vendor:raylib"

SCREEN_WIDTH :: 300
SCREEN_HEIGHT :: 600

lastUpdateTime: f64
BlockMoveInterval :: 0.2

eventTriggered :: proc(interval: f64 = BlockMoveInterval) -> bool {
	if rl.GetTime() - lastUpdateTime >= interval {
		lastUpdateTime = rl.GetTime()
		return true
	}
	return false
}

main :: proc() {
	rl.InitWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "Block Game - Odin")
	rl.SetTargetFPS(120)

	game := Game_New()
	lastUpdateTime: f32 = 0

	for !rl.WindowShouldClose() {
		Game_HandleInput(&game)
		if eventTriggered(0.1) {
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
