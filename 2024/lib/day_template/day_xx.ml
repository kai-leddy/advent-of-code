let part1 input = 
  let len = string_of_int (List.length input) in
  Printf.printf "%s\n" len

let part2 input = 
  let len = string_of_int (0 - List.length input) in
  Printf.printf "%s\n" len

let example = [ "Hello"; "World" ]
