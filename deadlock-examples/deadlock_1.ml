open Eio.Std

let () =
  Eio_main.run @@ fun env ->
    Switch.run @@ fun sw ->

      let clock = Eio.Stdenv.clock env in

      let lock_a = Mutex.create () in
      let lock_b = Mutex.create () in

      (* Task 1: A -> B *)
      Fiber.fork ~sw (fun () ->
        traceln "Task 1: acquiring A";
        Mutex.lock lock_a;

        Eio.Time.sleep clock 0.5;

        traceln "Task 1: acquiring B";
        Mutex.lock lock_b;

        traceln "Task 1: acquired A and B";

        Mutex.unlock lock_b;
        Mutex.unlock lock_a
      );

      (* Task 2: B -> A *)
      Fiber.fork ~sw (fun () ->
        traceln "Task 2: acquiring B";
        Mutex.lock lock_b;

        Eio.Time.sleep clock 0.5;

        traceln "Task 2: acquiring A";
        Mutex.lock lock_a;

        traceln "Task 2: acquired B and A";

        Mutex.unlock lock_a;
        Mutex.unlock lock_b
      );

      traceln "Main: finished spawning tasks (not awaiting)"
