type t = int * int list

let parse (input : string) : t =
  let open Angstrom in
  let digit = function '0' .. '9' -> true | _ -> false in
  let integer = take_while digit |> map ~f:int_of_string in
  let res = integer <* char ':' in
  let ins = many (char ' ' *> integer) in
  let parser = both res ins in
  input |> parse_string ~consume:All parser |> Result.get_ok
;;

let parse_all input = input |> List.map parse
let operators = [ ( + ); ( * ) ]

let operator_permutations (len : int) : (int -> int -> int) list list =
  let op_lists = ref [ [] ] in
  for _ = 0 to len - 1 do
    let next_op_list = ref [ [] ] in
    for j = 0 to List.length operators - 1 do
      for k = 0 to List.length !op_lists - 1 do
        next_op_list :=
          (List.nth operators j :: List.nth !op_lists k) :: !next_op_list
      done
    done;
    op_lists := !next_op_list
  done;
  !op_lists
;;

let check_equation ((res, ins) : t) : bool =
  let perms = operator_permutations (List.length ins - 1) in
  let apply perm =
    let sum = ref (List.nth ins 0) in
    perm |> List.iteri (fun i op -> sum := op !sum (List.nth ins (i + 1)));
    !sum
  in
  let found = perms |> List.map apply |> List.find_opt (fun v -> v = res) in
  match found with Some _ -> true | None -> false
;;

let part1 input =
  let eqs = parse_all input in
  eqs |> Iter.of_list |> Iter.filter check_equation
  |> Iter.map (fun (r, _) -> r)
  |> Iter.fold ( + ) 0 |> Printf.printf "\n%d\n"
;;

let part2 input =
  let len = string_of_int (0 - List.length input) in
  Printf.printf "\n%s\n" len
;;

let example =
  [
    "190: 10 19";
    "3267: 81 40 27";
    "83: 17 5";
    "156: 15 6";
    "7290: 6 8 6 15";
    "161011: 16 10 13";
    "192: 17 8 14";
    "21037: 9 7 18 13";
    "292: 11 6 16 20";
  ]
;;
