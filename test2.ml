open Effect
open Effect.Deep

type _ Effect.t += E : int -> unit Effect.t

(* Store multiple continuations in a typed way *)
let cont1 : (unit, unit) continuation option ref = ref None
let cont2 : (unit, unit) continuation option ref = ref None
let cont3 : (unit, unit) continuation option ref = ref None
let cont4 : (unit, unit) continuation option ref = ref None

let () =

  (* Create continuation 1 - will be CONTINUED *)
  (match perform (E 1) with
   | () ->
       Printf.printf "Cont 1 was resumed!\n"
   | effect (E n), k ->
       Printf.printf "Captured cont %d (will continue)\n" n;
       cont1 := Some k);

  (* Create continuation 2 - will be LEAKED *)
  (match perform (E 2) with
   | () ->
       Printf.printf "Cont 2 was resumed!\n"
   | effect (E n), k ->
       Printf.printf "Captured cont %d (will leak)\n" n;
       cont2 := Some k);

  (* Create continuation 3 - will be LEAKED *)
  (match perform (E 3) with
   | () ->
       Printf.printf "Cont 3 was resumed!\n"
   | effect (E n), k ->
       Printf.printf "Captured cont %d (will leak)\n" n;
       cont3 := Some k);

  (* Create continuation 4 - will stay ALIVE *)
  (match perform (E 4) with
   | () ->
       Printf.printf "Cont 4 was resumed!\n"
   | effect (E n), k ->
       Printf.printf "Captured cont %d (will keep alive)\n" n;
       cont4 := Some k);

  (* Force a GC cycle while all continuations are still reachable *)
  Gc.full_major ();

  (* Resume continuation 1 *)
  (match !cont1 with
   | Some k -> continue k ()
   | None -> ());

  (* Drop references to continuations 2 and 3 *)
  cont2 := None;
  cont3 := None;

  (* Force another GC cycle to detect leaked continuations *)
  Gc.full_major ();
