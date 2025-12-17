type myint

external make_myint : int -> myint = "ml_make_myint"

let () =
  let _ = make_myint 10 in
  Gc.compact ();
  (* force garbage collection *)
  print_endline "Done"
