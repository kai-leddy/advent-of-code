let rec parse_rules ?(rules = []) input =
  match input with
  | "" :: rest -> (rules, rest)
  | x :: rest -> (
      try
        let rule = Scanf.sscanf x "%d|%d" (fun a b -> (a, b)) in
        parse_rules ~rules:(rule :: rules) rest
      with _ -> failwith "Unexpected input")
  | _ -> failwith "Unexpected input"
;;

let rec parse_pages ?(pages = []) input =
  match input with
  | [] -> pages
  | x :: rest -> (
      try
        let page = String.split_on_char ',' x |> List.map int_of_string in
        parse_pages ~pages:(page :: pages) rest
      with _ -> failwith "Unexpected input")
;;

let passes_rule page (l, r) =
  let l_i = List.find_index (( = ) l) page in
  let r_i = List.find_index (( = ) r) page in
  match l_i with
  | Some l_i -> ( match r_i with Some r_i -> l_i < r_i | None -> true)
  | None -> true
;;

let is_valid_page rules page = List.for_all (passes_rule page) rules

let part1 input =
  let rules, input = parse_rules input in
  let pages = parse_pages input in
  let valid_pages = pages |> List.filter (is_valid_page rules) in
  let middles =
    valid_pages |> List.map (fun x -> List.nth x (List.length x / 2))
  in
  middles |> List.fold_left ( + ) 0 |> Printf.printf "\n%d\n"
;;

let part2 input =
  let len = string_of_int (0 - List.length input) in
  Printf.printf "\n%s\n" len
;;

let example =
  [
    "47|53";
    "97|13";
    "97|61";
    "97|47";
    "75|29";
    "61|13";
    "75|53";
    "29|13";
    "97|29";
    "53|29";
    "61|53";
    "97|53";
    "61|29";
    "47|13";
    "75|47";
    "97|75";
    "47|61";
    "75|61";
    "47|29";
    "75|13";
    "53|13";
    "";
    "75,47,61,53,29";
    "97,61,53,29,13";
    "75,29,13";
    "75,97,47,61,53";
    "61,13,29";
    "97,13,75,29,47";
  ]
;;
