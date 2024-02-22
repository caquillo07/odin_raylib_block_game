package main

import "core:fmt"
import "core:strings"

import rl "vendor:raylib"

SCREEN_WIDTH :: 500 // 200 offset for UI
SCREEN_HEIGHT :: 620 // 20 offset for UI

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

	font := rl.LoadFontEx("fonts/monogram.ttf", 64, nil, 0)

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
			rl.DrawTextEx(font, "Score", rl.Vector2{365, 15}, 38, 2, rl.WHITE)
			rl.DrawRectangleRounded(rl.Rectangle{320, 55, 170, 60}, 0.3, 0, Colors[.LightBlue])

			sb := strings.builder_make() // will default to 16 cap, 0 len
			defer strings.builder_destroy(&sb)
			score := fmt.sbprintf(&sb, "%d", game.score)
			scoreText := strings.to_string(sb)
			scoreTextCString := strings.clone_to_cstring(scoreText)
			scoreTextSize := rl.MeasureTextEx(font, scoreTextCString, 38, 2)

			rl.DrawTextEx(
				font,
				scoreTextCString,
				rl.Vector2{320 + (170 - scoreTextSize.x) / 2, 65},
				38,
				2,
				rl.WHITE,
			)


			rl.DrawTextEx(font, "Next", rl.Vector2{370, 175}, 38, 2, rl.WHITE)
			rl.DrawRectangleRounded(rl.Rectangle{320, 215, 170, 180}, 0.3, 0, Colors[.LightBlue])


			if game.gameOver {
				rl.DrawTextEx(font, "GAME OVER", rl.Vector2{320, 450}, 38, 2, rl.WHITE)
			}
			Game_Draw(&game)

			rl.DrawFPS(10, 10)
		}
		rl.EndDrawing()
	}
}
