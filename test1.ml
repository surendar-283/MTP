open Effect
open Effect.Deep

type _ Effect.t += E : int -> unit Effect.t

(* Store multiple continuations *)
let cont1 = ref (Obj.repr ())
let cont2 = ref (Obj.repr ())
let cont3 = ref (Obj.repr ())
let cont4 = ref (Obj.repr ())

let () =

  (* Create continuation 1 - will be CONTINUED *)
  (match perform (E 1) with
   | () -> Printf.printf "Cont 1 was resumed!\n"
   | effect (E n), k -> Printf.printf "Captured cont %d (will continue)\n" n; cont1 := Obj.repr k);
  
  (* Create continuation 2 - will be LEAKED *)
  (match perform (E 2) with
   | () -> Printf.printf "Cont 2 was resumed!\n"
   | effect (E n), k -> Printf.printf "Captured cont %d (will leak)\n" n; cont2 := Obj.repr k);
  
  (* Create continuation 3 - will be LEAKED *)
  (match perform (E 3) with
   | () -> Printf.printf "Cont 3 was resumed!\n"
   | effect (E n), k -> Printf.printf "Captured cont %d (will leak)\n" n; cont3 := Obj.repr k);
  
  (* Create continuation 4 - will stay ALIVE *)
  (match perform (E 4) with
   | () -> Printf.printf "Cont 4 was resumed!\n"
   | effect (E n), k -> Printf.printf "Captured cont %d (will keep alive)\n" n; cont4 := Obj.repr k);

  Gc.full_major ();

  let k1 : (unit, unit) continuation = Obj.magic !cont1 in
  continue k1 ();
  cont2 := Obj.repr ();
  cont3 := Obj.repr ();

  Gc.full_major ();

