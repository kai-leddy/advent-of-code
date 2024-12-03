# Advent of Code 2024

This year, I'm going to attempt to solve the puzzles in Ocaml.

## Setup

```sh
opam install . --deps-only
dune build
```

## Usage

Place the input in the `inputs/` folder with the naming convention `day_<day>.txt`,
e.g. `day_01.txt`.
Run the executable with the day and part as arguments.

Optionally add `example` to the end of the command to run the example input.

Optionally append the whole command with `-w` to run in watch mode and
automatically recompile and rerun when files change.

```sh
# e.g. dune exec aoc <day> <part> [example]
dune exec aoc 1 1
dune exec aoc 1 2 example
dune exec aoc 2 1 example -w
```

## Testing

```sh
dune runtest
```
