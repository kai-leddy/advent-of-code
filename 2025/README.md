# Advent of Code 2025 - Zig Solutions

This repository contains solutions for Advent of Code 2025 written in Zig.

## Requirements

- Zig 0.15.2 or later

If using `mise`, the correct Zig version is automatically managed.

## Project Structure

```
src/
├── 01/main.zig
├── 02/main.zig
├── ...
└── 12/main.zig
```

Each day has its own directory with a `main.zig` file containing the solution (and the input files, but I wont commit these).

## Running Solutions

To run the solution for a specific day, use:

```bash
zig run src/<day>/main.zig
```

For example, to run Day 1:

```bash
zig run src/01/main.zig
```

Or to build and run an executable binary:

```bash
zig build-exe src/01/main.zig -femit-bin=./zig-out/day01 -OReleaseFast && ./zig-out/day01
```

## Running Tests

To run tests for a specific day:

```bash
zig test src/<day>/main.zig
```

For example, to test Day 1:

```bash
zig test src/01/main.zig
```

## Building

The `build.zig` file can be extended to automate building and testing multiple days. For now, individual days can be built and tested using the commands above.
