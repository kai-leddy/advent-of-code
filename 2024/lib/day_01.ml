let part1 _ = ()

let part2 _ = ()

let example = "Hello, World!"

let%expect_test "example" =
  print_endline example;
  [%expect {| Hello, World! |}]
