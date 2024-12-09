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

let operator_permutations operators (len : int) : (int -> int -> int) list list
    =
  let op_lists = ref [ [] ] in
  for _ = 0 to len - 1 do
    op_lists :=
      !op_lists
      |> List.map (fun opl -> operators |> List.map (fun o -> o :: opl))
      |> List.flatten
  done;
  !op_lists
;;

let op_perms_cached ops =
  let op_len_fun = operator_permutations ops in
  CCCache.with_cache (CCCache.unbounded ~eq:( = ) 16) op_len_fun
;;

let check_equation get_op_perms ((res, ins) : t) : bool =
  let perms = get_op_perms (List.length ins - 1) in
  let ins = Array.of_list ins in
  let apply perm =
    perm |> CCList.foldi (fun acc i op -> op acc ins.(i + 1)) ins.(0)
  in
  let found = perms |> List.find_opt (fun p -> apply p = res) in
  Printf.printf ".";
  flush Stdlib.stdout;
  match found with Some _ -> true | None -> false
;;

let part1 input =
  let operators = [ ( + ); ( * ) ] in
  let eqs = parse_all input in
  let op_perms_of_len_cache = op_perms_cached operators in
  eqs |> Iter.of_list
  |> Iter.filter (check_equation op_perms_of_len_cache)
  |> Iter.map (fun (r, _) -> r)
  |> Iter.fold ( + ) 0 |> Printf.printf "\n%d\n"
;;

let part2 input =
  let ( || ) a b = string_of_int a ^ string_of_int b |> int_of_string in
  let operators = [ ( + ); ( * ); ( || ) ] in
  let eqs = parse_all input in
  let op_perms_of_len_cache = op_perms_cached operators in
  eqs |> Iter.of_list
  |> Iter.filter (check_equation op_perms_of_len_cache)
  |> Iter.map (fun (r, _) -> r)
  |> Iter.fold ( + ) 0 |> Printf.printf "\n%d\n"
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
