let string_to_char_list s = List.init (String.length s) (String.get s)
;;

let scan_matrix fn input =
  for y = 0 to List.length input - 1 do
    let row = List.nth input y in
    for x = 0 to List.length row  - 1 do
      let cell = List.nth row x in
      fn cell x y
    done
  done
;;

let lookup matrix x y = 
  try List.nth (List.nth matrix y) x 
  with _ -> ' '
;;

let scan_for_xmas matrix count = 
  let lookup = lookup matrix in
  let scanning_fn cell x y = 
    (* only test if the current cell is an X *)
    if cell = 'X' then (
      (* check for straight XMAS on the same row *)
      if (lookup (x + 1) y = 'M' && lookup (x + 2) y = 'A' && lookup (x + 3) y = 'S') then incr count;
      if (lookup (x - 1) y = 'M' && lookup (x - 2) y = 'A' && lookup (x - 3) y = 'S') then incr count;
      (* check for straight XMAS vertically *)
      if (lookup x (y + 1) = 'M' && lookup x (y + 2) = 'A' && lookup x (y + 3) = 'S') then incr count;
      if (lookup x (y - 1) = 'M' && lookup x (y - 2) = 'A' && lookup x (y - 3) = 'S') then incr count;
      (* check for XMAS diagonally *)
      if (lookup (x + 1) (y + 1) = 'M' && lookup (x + 2) (y + 2) = 'A' && lookup (x + 3) (y + 3) = 'S') then incr count;
      if (lookup (x - 1) (y - 1) = 'M' && lookup (x - 2) (y - 2) = 'A' && lookup (x - 3) (y - 3) = 'S') then incr count;
      if (lookup (x + 1) (y - 1) = 'M' && lookup (x + 2) (y - 2) = 'A' && lookup (x + 3) (y - 3) = 'S') then incr count;
      if (lookup (x - 1) (y + 1) = 'M' && lookup (x - 2) (y + 2) = 'A' && lookup (x - 3) (y + 3) = 'S') then incr count;
    )
  in scanning_fn
;;

let part1 input = 
  let matrix = input |> List.map string_to_char_list in
  let count = ref 0 in
  scan_matrix (scan_for_xmas matrix count) matrix;
  Printf.printf "\n%d\n" !count
;;

let scan_for_x_mas matrix count = 
  let lookup = lookup matrix in
  let scanning_fn cell x y = 
    (* only test if the current cell is an A *)
    if cell = 'A' then (
      (* check for northwest/southeast match *)
      if (lookup (x + 1) (y + 1) = 'M' && lookup (x - 1) (y - 1) = 'S')
      || (lookup (x + 1) (y + 1) = 'S' && lookup (x - 1) (y - 1) = 'M')
      then
      (* check for northeast/southwest match *)
      if (lookup (x + 1) (y - 1) = 'M' && lookup (x - 1) (y + 1) = 'S')
      || (lookup (x + 1) (y - 1) = 'S' && lookup (x - 1) (y + 1) = 'M')
      then incr count;
    )
  in scanning_fn
;;

let part2 input = 
  let matrix = input |> List.map string_to_char_list in
  let count = ref 0 in
  scan_matrix (scan_for_x_mas matrix count) matrix;
  Printf.printf "\n%d\n" !count
;;

let example = [ 
  "MMMSXXMASM";
  "MSAMXMSMSA";
  "AMXSXMAAMM";
  "MSAMASMSMX";
  "XMASAMXAMM";
  "XXAMMXXAMA";
  "SMSMSASXSS";
  "SAXAMASAAA";
  "MAMMMXMMMM";
  "MXMXAXMASX";
];;
