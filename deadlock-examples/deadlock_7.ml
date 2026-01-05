open Moonpool

let () = 
  
  let pool = Ws_pool.create ~num_threads:1 () in
  let fut, promise = Fut.make () in
  Gc.finalise_last (fun _ -> Printf.printf "Finalizer: promise collected!\n%!") promise;
  let _ = Fut.spawn ~on:pool (fun () ->
    Printf.printf "Task started, awaiting promise...\n%!";
    Fut.await fut
  ) in
  Thread.delay 0.2;
  Gc.full_major ()
