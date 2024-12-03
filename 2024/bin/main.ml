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
  | "01" -> (module Aoc.Day_01)
  | "02" -> (module Aoc.Day_02)
  | "03" -> (module Aoc.Day_03)
  | "04" -> (module Aoc.Day_04)
  | "05" -> (module Aoc.Day_05)
  | "06" -> (module Aoc.Day_06)
  | "07" -> (module Aoc.Day_07)
  | "08" -> (module Aoc.Day_08)
  | "09" -> (module Aoc.Day_09)
  | "10" -> (module Aoc.Day_10)
  | "11" -> (module Aoc.Day_11)
  | "12" -> (module Aoc.Day_12)
  | "13" -> (module Aoc.Day_13)
  | "14" -> (module Aoc.Day_14)
  | "15" -> (module Aoc.Day_15)
  | "16" -> (module Aoc.Day_16)
  | "17" -> (module Aoc.Day_17)
  | "18" -> (module Aoc.Day_18)
  | "19" -> (module Aoc.Day_19)
  | "20" -> (module Aoc.Day_20)
  | "21" -> (module Aoc.Day_21)
  | "22" -> (module Aoc.Day_22)
  | "23" -> (module Aoc.Day_23)
  | "24" -> (module Aoc.Day_24)
  | "25" -> (module Aoc.Day_25)
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

