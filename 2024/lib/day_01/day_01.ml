let part1 inputfile = 
  Printf.printf "part1: %s\n" inputfile

let part2 _ = ()

let example = "Hello, World!"

let%expect_test "example" =
  print_endline example;
  [%expect {| Hello, World! |}]
