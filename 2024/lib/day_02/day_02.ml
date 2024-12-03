let parse_all input = 
  let parse line = 
    String.split_on_char ' ' line 
    |> List.filter (fun i -> String.length i > 0)
    |> List.map int_of_string
  in
  List.map parse input
;;

let small_diff a b = 
  let diff = Int.abs (a - b) in
  match diff with
  | 1 | 2 | 3 -> true
  | _ -> false
;;

let rec small_diffs ?(acc=true) record =
   match record with 
   | a :: b :: tl when small_diff a b -> (small_diffs (b :: tl) ~acc) 
   | a :: b :: _ when not (small_diff a b) -> false 
   | _ -> acc 
;; 

let rec is_increasing ?(acc=true) record =
   match record with 
   | a :: b :: tl when a < b -> (is_increasing (b :: tl) ~acc) 
   | a :: b :: _ when a > b -> false 
   | _ -> acc 
;; 

let rec is_decreasing ?(acc=true) record =
   match record with 
   | a :: b :: tl when a > b -> (is_decreasing (b :: tl) ~acc) 
   | a :: b :: _ when a < b -> false 
   | _ -> acc 
;; 

let safe report =
  small_diffs report && (is_increasing report || is_decreasing report)
;;

let part1 input = 
  let reports = parse_all input in
  reports |> List.filter safe |> List.length |> string_of_int |> Printf.printf "\n%s\n" 
;;

let dampener fn report =
  let not_index i j _ = i != j in
  let list_without_index i _ = List.filteri (not_index i) report in
  let permutations = List.mapi list_without_index report in
  List.exists fn permutations
;;

let part2 input = 
  let reports = parse_all input in
  let safe_with_dampener report = safe report || dampener safe report in
  reports |> List.filter safe_with_dampener |> List.length |> string_of_int |> Printf.printf "\n%s\n" 
;;

let example = [ 
  "7 6 4 2 1";
  "1 2 7 8 9";
  "9 7 6 2 1";
  "1 3 2 4 5";
  "8 6 4 4 1";
  "1 3 6 7 9";
];;
