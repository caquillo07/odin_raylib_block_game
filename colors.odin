package main

import rl "vendor:raylib"

Color :: enum {
	DarkGray,
	Green,
	Red,
	Orange,
	Yellow,
	Purple,
	Cyan,
	Blue,
	LightBlue,
	DarkBlue,
}

Colors := [Color]rl.Color {
	.DarkGray  = rl.Color{26, 31, 40, 255},
	.Green     = rl.Color{47, 230, 23, 255},
	.Red       = rl.Color{232, 18, 18, 255},
	.Orange    = rl.Color{226, 116, 17, 255},
	.Yellow    = rl.Color{237, 234, 4, 255},
	.Purple    = rl.Color{166, 0, 247, 255},
	.Cyan      = rl.Color{21, 204, 209, 255},
	.Blue      = rl.Color{13, 64, 216, 255},
	.LightBlue = rl.Color{59, 85, 162, 255},
	.DarkBlue  = rl.Color{44, 44, 127, 255},
}
