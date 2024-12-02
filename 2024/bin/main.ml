let print_usage_and_exit () = 
  Printf.printf "\nUsage: dune exec aoc <day> <part> [example]";
  exit 1

let pad_day day = 
  if String.length day = 1 then "0" ^ day else day

let parse_args = function
  | [| _; day; part; example |] -> pad_day day, part, example = "example"
  | [| _; day; part |] -> pad_day day, part, false
  | _ -> print_usage_and_exit ()

let inputfile_for_day day = "inputs/day_" ^ day ^ ".txt"

let read_all_input inputfile = 
  try 
    let ic = open_in inputfile in
    let input = In_channel.input_lines ic in
    close_in ic;
    input
  with _ -> Printf.printf "\nError reading input file"; exit 1

let module_for_day day : (module Aoc.Day_intf.Intf) =
  match day with
  (* TODO: make more folders and map them all here *)
  | "01" -> (module Aoc.Day_01)
  | _ -> print_usage_and_exit ()

let () = 
  let day, part, example = parse_args Sys.argv in
  let (module M) = module_for_day day in
  let input = 
    if example then M.example 
    else inputfile_for_day day |> read_all_input  in
    match part with
    | "1" -> M.part1 input 
    | "2" -> M.part2 input 
    | _ -> print_usage_and_exit ()

