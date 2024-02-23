# Odin Block Game Using Raylib

This repo contains the implementation of a game inspired by the classic game Tetris using the Raylib library,
the goal of the project was to learn/practice the basics of game programming and the Odin language.

This project does not follow best practices and is not intended to be a production ready game,
but rather a simple project to learn the basics of game development and Odin.

Odin was chosen for its simplicity, performance and control of low level details. Another reason is that Odin has a list
of features that are very useful for game development, and most of the third party libraries I need come vendored in.
Other languages considered were C, C++, Rust and Zig, all of which I will be trying next.

## Running

First, you need to install the Raylib library. You can download it from the official website: https://www.raylib.com/
Second, you need to install the Odin compiler. You can download it from the official website: https://odin-lang.org/

Lastly, you can run the game by running the following command in the terminal:

```bash
mkdir -p bin
odin run . --out:bin/game
```

Alternatively, the provided `run.sh` script can be used to run the game.

```bash
./run.sh
```
