type antennas = (char, (int * int) list) Hashtbl.t

module CoordSet = Set.Make (struct
  type t = int * int

  let compare = Stdlib.compare
end)

module CoordMath = struct
  let ( - ) ((ay, ax) : int * int) ((dy, dx) : int * int) = (ay - dy, ax - dx)
  let ( + ) ((ay, ax) : int * int) ((dy, dx) : int * int) = (ay + dy, ax + dx)
end

let parse (input : string list) : antennas =
  (* assuming roughly 3 antennas per row *)
  let ant = Hashtbl.create (List.length input * 3) in
  input
  |> List.iteri (fun y row ->
         CCString.to_list row
         |> List.iteri (fun x c ->
                match c with
                | '.' -> ()
                (* this includes all alphanumeric characters *)
                | '0' .. 'z' ->
                    let current =
                      try Hashtbl.find ant c with Not_found -> []
                    in
                    Hashtbl.replace ant c ((y, x) :: current)
                | _ -> failwith "Unexpected cell in grid"));
  ant
;;

let antinodes_of ((a : int * int), (b : int * int)) : (int * int) list =
  let open CoordMath in
  let d = b - a in
  [ a - d; b + d ]
;;

let pairs (n : (int * int) list) : ((int * int) * (int * int)) Iter.t =
  let arr = Array.of_list n in
  let len = Array.length arr in
  let a = ref 0 in
  let b = ref 1 in
  let inc () =
    if !b < len - 1 then incr b
    else (
      incr a;
      b := !a + 1)
  in
  let next () =
    if !a < len - 1 && !b < len then (
      let p = (arr.(!a), arr.(!b)) in
      inc ();
      Some p)
    else None
  in
  Iter.from_fun next
;;

let in_bounds input (y, x) =
  let max_y = List.length input in
  let max_x = String.length (List.nth input 0) in
  y >= 0 && x >= 0 && y < max_y && x < max_x
;;

let part1 input =
  let ant = parse input in
  let anti_for_freq ants =
    ants |> pairs |> Iter.map antinodes_of
    |> Iter.map (List.filter (in_bounds input))
  in
  let antis =
    Iter.hashtbl_values ant |> Iter.map anti_for_freq |> Iter.flatten
    |> Iter.fold (fun acc b -> b @ acc) []
  in
  CoordSet.cardinal (CoordSet.of_list antis) |> Printf.printf "\n%d\n"
;;

let all_antinodes_of is_in_bounds ((a : int * int), (b : int * int)) :
    (int * int) list =
  let open CoordMath in
  let d = b - a in
  let c = ref a in
  let an = ref [] in
  (* iterate in reverse *)
  while is_in_bounds !c do
    an := !c :: !an;
    c := !c - d
  done;
  (* iterate forward *)
  c := b;
  while is_in_bounds !c do
    an := !c :: !an;
    c := !c + d
  done;
  (* [ (by + dy, bx + dx); (ay - dy, ax - dx) ] *)
  !an
;;

let part2 input =
  let ant = parse input in
  let in_bounds_fun = in_bounds input in
  let anti_for_freq ants =
    ants |> pairs |> Iter.map (all_antinodes_of in_bounds_fun)
  in
  let antis =
    Iter.hashtbl_values ant |> Iter.map anti_for_freq |> Iter.flatten
    |> Iter.fold (fun acc b -> b @ acc) []
  in
  CoordSet.cardinal (CoordSet.of_list antis) |> Printf.printf "\n%d\n"
;;

let example =
  [
    "............";
    "........0...";
    ".....0......";
    ".......0....";
    "....0.......";
    "......A.....";
    "............";
    "............";
    "........A...";
    ".........A..";
    "............";
    "............";
  ]
;;
