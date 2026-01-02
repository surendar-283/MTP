open Eio.Std
open Effect
type _ Effect.t += E : unit t

let f () =
  
  Eio_main.run @@ fun _env ->
    Switch.run @@ fun sw ->
    
      Fiber.fork ~sw (fun () ->
        let lock_a = Mutex.create () in
        Gc.finalise_last  (fun _ -> Printf.printf "Finalized!\n%!") lock_a;
      );

      perform E

let g () = 
        try f() with
        | effect E,_ -> ()

let () = g ();
Gc.full_major();
Gc.full_major();
Gc.full_major()
