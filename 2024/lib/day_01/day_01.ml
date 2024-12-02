let part1 input = Printf.printf "%s\n" (List.fold_left (fun acc a -> acc ^ a) "" input)

let part2 _ = ()

let example = [ "Hello, World!" ]

let%expect_test "example" =
  part1 example;
  [%expect {| Hello, World! |}]
