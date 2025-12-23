open Eio.Std

let () =
  Eio_main.run @@ fun _env ->
    Switch.run @@ fun sw ->
      Fiber.fork ~sw (fun () ->
        traceln "Fiber: creating promise and awaiting";
        let t, _set_t = Promise.create () in
        Promise.await t;
      );
      traceln "Main fiber: nothing else to do"
