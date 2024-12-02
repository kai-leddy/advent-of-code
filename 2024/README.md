# Advent of Code 2024

This year, I'm going to attempt to solve the puzzles in Ocaml.

## Setup

```sh
opam install . --deps-only
dune build
```

## Usage

Place the input in the `inputs/` folder with the naming convention `day_<day>.txt`, e.g. `day_01.txt`.
Run the executable with the day and part as arguments.

```sh
# e.g. dune exec aoc <day> <part>
dune exec aoc 1 1
```

## Testing

```sh
dune runtest
```
