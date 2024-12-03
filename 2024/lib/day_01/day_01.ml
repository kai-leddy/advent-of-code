let parse_all input = 
  let items_to_num_tuple items = 
    match items with
    | l :: r :: [] -> (int_of_string l, int_of_string r) 
    | _ -> (0, 0)
  in
  let parse line = 
    String.split_on_char ' ' line 
    |> List.filter (fun i -> String.length i != 0)
    |> items_to_num_tuple 
  in
  List.map parse input

let part1 input = 
  let left, right = parse_all input |> List.split in
  let left, right = (List.sort compare left, List.sort compare right) in
  let ordered_tuples = List.combine left right in
  let diffs = ordered_tuples |> List.map (fun (a,b) -> Int.abs (b - a)) in
  let sum = List.fold_left (+) 0 diffs in
  Printf.printf "\n%s\n" (string_of_int sum)

let part2 input = 
  let len = string_of_int (0 - List.length input) in
  Printf.printf "\n%s\n" len

let example = [
  "3   4";
  "4   3";
  "2   5";
  "1   3";
  "3   9";
  "3   3";
]
