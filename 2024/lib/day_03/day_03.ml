let parse_muls input conditional =
  let enabled = ref true in
  let rec parse ?(acc=[]) line = 
    let scanner a b = if !enabled then (a, b) :: acc else acc in
    let next = 
      if String.length line > 0 
      then String.sub line 1 (String.length line - 1) 
      else "" 
    in
    (match line with
    | l when conditional && String.starts_with ~prefix:"do()" l -> enabled := true
    | l when conditional && String.starts_with ~prefix:"don't()" l -> enabled := false
    | _ -> ());
    match (Scanf.sscanf line "mul(%d,%d)" scanner) with
    | xs -> parse ~acc:xs next
    | exception Scanf.Scan_failure _ -> parse ~acc next
    | exception _ -> acc
  in
  input |> List.map parse |> List.flatten
;;

let part1 input = 
  let multiplied = parse_muls input false |> List.map (fun (a,b) -> a * b) in
  let sum = multiplied |> List.fold_left (+) 0 in
  Printf.printf "\n%d\n" sum
;;

let part2 input = 
  let multiplied = parse_muls input true |> List.map (fun (a,b) -> a * b) in
  let sum = multiplied |> List.fold_left (+) 0 in
  Printf.printf "\n%d\n" sum
;;

let example = [ 
  "xmul(2,4)&mul[3,7]!^don't()_mul(5,5)+mul(32,64](mul(11,8)undo()?mul(8,5))" 
];;
