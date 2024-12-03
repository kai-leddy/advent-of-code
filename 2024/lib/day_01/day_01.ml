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
;;

let part1 input = 
  let left, right = parse_all input |> List.split in
  let left, right = (List.sort compare left, List.sort compare right) in
  let ordered_tuples = List.combine left right in
  let diffs = ordered_tuples |> List.map (fun (a,b) -> Int.abs (b - a)) in
  let sum = diffs |> List.fold_left (+) 0 in
  Printf.printf "\n%s\n" (string_of_int sum)
;;

let occurences_in list item =
  let count acc x = if x = item then succ acc else acc in
  list |> List.fold_left count 0
;;

let part2 input = 
  let left, right = parse_all input |> List.split in
  let occurences = left |> List.map (occurences_in right) in
  let similarity_scores = List.map2 ( * ) left occurences in
  let sum = similarity_scores |> List.fold_left (+) 0 in
  Printf.printf "\n%s\n" (string_of_int sum)
;;

let example = [
  "3   4";
  "4   3";
  "2   5";
  "1   3";
  "3   9";
  "3   3";
];;
