let parse_muls input =
  let rec parse ?(acc=[]) line = 
    let scanner a b = (a, b) :: acc in
    match (Scanf.sscanf line "mul(%d,%d)" scanner)
    with
    | xs -> parse ~acc:xs (String.sub line 1 (String.length line - 1))
    | exception Scanf.Scan_failure _ -> parse ~acc (String.sub line 1 (String.length line - 1))
    | exception _ -> acc
  in
  input |> List.map parse |> List.flatten
;;

let part1 input = 
  let multiplied = parse_muls input |> List.map (fun (a,b) -> a * b) in
  let sum = multiplied |> List.fold_left (+) 0 in
  Printf.printf "\n%d\n" sum
;;

let part2 input = 
  let len = string_of_int (0 - List.length input) in
  Printf.printf "\n%s\n" len
;;

let example = [ 
  "xmul(2,4)%&mul[3,7]!@^do_not_mul(5,5)+mul(32,64]then(mul(11,8)mul(8,5))" 
];;
