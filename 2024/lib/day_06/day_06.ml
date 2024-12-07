type map = char array array
type direction = N | E | S | W
type t = { map : map; mutable pos : int * int; mutable dir : direction }

let pp (state : t) =
  CCArray.pp ~pp_sep:CCFormat.newline ~pp_stop:CCFormat.newline
    ~pp_start:CCFormat.newline
    (CCFormat.array CCFormat.char)
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

let is_in_bounds (state : t) : bool =
  match state.pos with
  | _, x when x < 0 -> false
  | y, _ when y < 0 -> false
  | _, x when x >= Array.length state.map.(0) -> false
  | y, _ when y >= Array.length state.map -> false
  | _ -> true
;;

let traverse (state : t) =
  let c = ref 0 in
  while is_in_bounds state do
    pp state;
    (* TODO: remove this debugging code *)
    incr c;
    if !c > 10 then failwith "test";
    let y, x = state.pos in
    state.map.(y).(x) <- 'X';
    match state.dir with
    | N ->
        if state.map.(y - 1).(x) = '.' then state.pos <- (y - 1, x)
        else state.dir <- E
    | E ->
        if state.map.(y).(x + 1) = '.' then state.pos <- (y, x + 1)
        else state.dir <- S
    | S ->
        if state.map.(y + 1).(x) = '.' then state.pos <- (y + 1, x)
        else state.dir <- W
    | W ->
        if state.map.(y).(x - 1) = '.' then state.pos <- (y, x - 1)
        else state.dir <- N
  done
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
  let state : t = { map = m; pos = p; dir = N } in
  traverse state;
  Printf.printf "\n%d\n" (count_traversed state)
;;

let part2 input =
  let len = string_of_int (0 - List.length input) in
  Printf.printf "\n%s\n" len
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
