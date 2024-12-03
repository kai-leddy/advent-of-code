let parse_all input = 
  let parse line = 
    String.split_on_char ' ' line 
    |> List.filter (fun i -> String.length i != 0)
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

let rec small_diffs r t =
   match r with 
   | a :: b :: tl when small_diff a b -> (small_diffs (b :: tl) t) 
   | a :: b :: _ when not (small_diff a b) -> false 
   | _ -> t 
;; 

let rec is_increasing r t =
   match r with 
   | a :: b :: tl when a < b -> (is_increasing (b :: tl) t) 
   | a :: b :: _ when a > b -> false 
   | _ -> t 
;; 

let rec is_decreasing r t =
   match r with 
   | a :: b :: tl when a > b -> (is_decreasing (b :: tl) t) 
   | a :: b :: _ when a < b -> false 
   | _ -> t 
;; 

let safe report =
  small_diffs report true 
    && (is_increasing report true || is_decreasing report true)
;;

let part1 input = 
  let reports = parse_all input in
  reports |> List.filter safe |> List.length |> string_of_int |> Printf.printf "\n%s\n" 
;;

let part2 input = 
  let len = string_of_int (0 - List.length input) in
  Printf.printf "\n%s\n" len
;;

let example = [ 
  "7 6 4 2 1";
  "1 2 7 8 9";
  "9 7 6 2 1";
  "1 3 2 4 5";
  "8 6 4 4 1";
  "1 3 6 7 9";
];;
