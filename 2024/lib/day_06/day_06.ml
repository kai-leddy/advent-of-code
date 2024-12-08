type map = char array array
type direction = N | E | S | W

module Hist = Set.Make (struct
  type t = int * int * direction

  let compare = Stdlib.compare
end)

type t = {
  map : map;
  mutable pos : int * int;
  mutable dir : direction;
  mutable hist : Hist.t;
}

let _pp (state : t) =
  CCArray.pp ~pp_sep:CCFormat.newline ~pp_stop:CCFormat.newline
    ~pp_start:CCFormat.newline
    (CCFormat.array ~sep:CCFormat.pp_print_nothing CCFormat.char)
    Format.std_formatter state.map
;;

let parse_map input : map = input |> List.map CCString.to_array |> Array.of_list

let find_start_pos map =
  match map |> Array.find_index (fun row -> Array.mem '^' row) with
  | Some y -> (
      match map.(y) |> Array.find_index (fun cell -> cell = '^') with
      | Some x -> (y, x)
      | None -> failwith "Could not find starting pos")
  | None -> failwith "Could not find starting pos"
;;

let is_in_bounds (map : map) (pos : int * int) : bool =
  match pos with
  | _, x when x < 0 -> false
  | y, _ when y < 0 -> false
  | _, x when x >= Array.length map.(0) -> false
  | y, _ when y >= Array.length map -> false
  | _ -> true
;;

let traverse (state : t) : bool =
  let in_bounds = is_in_bounds state.map in
  let is_loop = ref false in
  while in_bounds state.pos && not !is_loop do
    let y, x = state.pos in
    if Hist.mem (y, x, state.dir) state.hist then is_loop := true
    else (
      state.map.(y).(x) <- 'X';
      state.hist <- Hist.add (y, x, state.dir) state.hist;
      (* _pp state; *)
      match state.dir with
      | N ->
          if try state.map.(y - 1).(x) != '#' with _ -> true then
            state.pos <- (y - 1, x)
          else state.dir <- E
      | E ->
          if try state.map.(y).(x + 1) != '#' with _ -> true then
            state.pos <- (y, x + 1)
          else state.dir <- S
      | S ->
          if try state.map.(y + 1).(x) != '#' with _ -> true then
            state.pos <- (y + 1, x)
          else state.dir <- W
      | W ->
          if try state.map.(y).(x - 1) != '#' with _ -> true then
            state.pos <- (y, x - 1)
          else state.dir <- N)
  done;
  Printf.printf ".";
  flush Stdlib.stdout;
  !is_loop
;;

let count_traversed (state : t) : int =
  let count_x acc cell = if cell = 'X' then succ acc else acc in
  state.map
  |> Array.map (fun a -> a |> Array.fold_left count_x 0)
  |> Array.fold_left ( + ) 0
;;

let part1 input =
  let m = parse_map input in
  let p = find_start_pos m in
  let state : t = { map = m; pos = p; dir = N; hist = Hist.empty } in
  let _ = traverse state in
  Printf.printf "\n%d\n" (count_traversed state)
;;

let clone_map (map : map) : map = map |> Array.map Array.copy

let permutations (m : map) : map Iter.t =
  Iter.(0 -- (Array.length m - 1))
  |> Iter.flat_map (fun y ->
         Iter.(0 -- (Array.length m.(0) - 1))
         |> Iter.map (fun x ->
                if m.(y).(x) = 'X' then (
                  let m' = clone_map m in
                  m'.(y).(x) <- '#';
                  Some m')
                else None))
  |> Iter.filter_map Fun.id
;;

let part2 input =
  let m = parse_map input in
  let p = find_start_pos m in
  let orig = { map = m; pos = p; dir = N; hist = Hist.empty } in
  let _ = traverse orig in
  permutations orig.map
  |> Iter.map (fun map -> { map; pos = p; dir = N; hist = Hist.empty })
  |> Iter.map traverse |> Iter.filter Fun.id |> Iter.length
  |> Printf.printf "\n%d\n"
;;

let example =
  [
    "....#.....";
    ".........#";
    "..........";
    "..#.......";
    ".......#..";
    "..........";
    ".#..^.....";
    "........#.";
    "#.........";
    "......#...";
  ]
;;
