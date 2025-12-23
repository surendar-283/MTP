open Eio.Std

type resolver_box = {
  _u : unit Promise.u;
}

let () =
  Eio_main.run @@ fun _env ->
    Switch.run @@ fun sw ->

      Fiber.fork ~sw (fun () ->
        traceln "Fiber: creating promise";

        let promise, u = Promise.create () in

        let box = { _u = u } in

        Gc.finalise_last
          (fun _ ->
             traceln "Finalizer: resolver capability unreachable")
          box;

        traceln "Fiber: awaiting promise (will deadlock)";
        Promise.await promise
      );

      traceln "Main fiber: nothing else to do";

      Gc.full_major ();
      Unix.sleep 1;
      Gc.full_major ()
