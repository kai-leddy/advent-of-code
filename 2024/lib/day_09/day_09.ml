let forward (diskmap : char array) : int option Iter.t =
  let id = ref 0 in
  let index = ref 0 in
  let rem = ref (Utils.char_to_int diskmap.(0)) in
  Iter.from_fun (fun () ->
      if !index >= Array.length diskmap then None
      else
        let v = if !index mod 2 = 0 then Some (Some !id) else Some None in
        decr rem;
        if !rem <= 0 then (
          incr index;
          (rem := try Utils.char_to_int diskmap.(!index) with _ -> 0);
          if !index mod 2 = 0 then incr id);
        v)
;;

let backward (diskmap : char array) : int option Iter.t =
  let id = ref (Array.length diskmap / 2) in
  let index = ref (Array.length diskmap - 1) in
  let rem = ref (Utils.char_to_int diskmap.(!index)) in
  Iter.from_fun (fun () ->
      if !index <= 0 then None
      else
        let v = if !index mod 2 = 0 then Some (Some !id) else Some None in
        decr rem;
        if !rem <= 0 then (
          decr index;
          (rem := try Utils.char_to_int diskmap.(!index) with _ -> 0);
          if !index mod 2 = 0 then decr id);
        v)
;;

let compacted (diskmap : char array) : int Iter.t =
  let fw = forward diskmap in
  let bw = backward diskmap in
  let bi = ref (Iter.length (backward diskmap)) in
  let rec nextb () =
    decr bi;
    match Iter.head bw with
    | Some (Some u) -> Some u
    | Some None -> nextb ()
    | None -> None
  in
  fw
  |> Iter.mapi (fun i a ->
         if i > !bi + 1 then None
         else match a with Some n -> Some n | None -> nextb ())
  |> Iter.keep_some
;;

let part1 input =
  let diskmap = List.nth input 0 |> CCString.to_array in
  (* print_endline " "; *)
  (* forward diskmap *)
  (* |> Fun.flip Iter.for_each (fun a -> *)
  (*        match a with Some n -> print_int n | None -> print_char '.'); *)
  (* print_endline " "; *)
  (* backward diskmap *)
  (* |> Fun.flip Iter.for_each (fun a -> *)
  (*        match a with Some n -> print_int n | None -> print_char '.'); *)
  print_endline " ";
  (* compacted diskmap |> (Fun.flip Iter.for_each) print_int *)
  compacted diskmap |> Iter.foldi (fun acc i v -> acc + (i * v)) 0 |> print_int
;;

let part2 input =
  let len = string_of_int (0 - List.length input) in
  Printf.printf "\n%s\n" len
;;

let example = [ "2333133121414131402" ]
