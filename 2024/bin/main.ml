
(* TODO: get the args from the command line and run the correct lib module *)

let print_usage_and_exit () = 
  print_endline "Usage: dune exec aoc <day> <part>"; 
  exit 1

let pad_day day = 
  if String.length day = 1 then "0" ^ day else day

let parse_args = function
  | [| _; day; part |] 
    when part = "1" || part = "2" -> pad_day day, part
  | _ -> print_usage_and_exit ()

let inputfile_for_day day = "inputs/day_" ^ day ^ ".txt"

let module_for_day day : (module Aoc.Day_intf.Intf) =
  match day with
  | "01" -> (module Aoc.Day_01)
  | _ -> print_usage_and_exit ()

let () = 
  let day, part = parse_args Sys.argv in
  let (module M) = module_for_day day in
    match part with
    | "1" -> M.part1 (inputfile_for_day day)
    | "2" -> M.part2 (inputfile_for_day day)
    | _ -> print_usage_and_exit ()
  (* let module Day = (val (Lib.get_module day) : Lib.Day) in *)

