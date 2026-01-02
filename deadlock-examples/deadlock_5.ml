open Eio.Std
open Effect

type _ Effect.t += E : unit t

let f () =
  Eio_main.run @@ fun env ->
    Switch.run @@ fun sw ->

      Fiber.fork ~sw (fun () ->
        let p, _r = Promise.create () in
        Gc.finalise_last (fun _ -> Printf.printf "Finalized!\n%!") p;
        traceln "Fiber: waiting on its own promise";
        Promise.await p;
      );

      Eio.Time.sleep env#clock 5.0;
      traceln "Main fiber: performing effect E";
      perform E

let g () =
  try f () with
  | effect E, _k -> ()

let () =
  g ();
  Gc.full_major ();
  Gc.full_major ();
  Gc.full_major ();
