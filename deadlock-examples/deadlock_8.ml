open Domainslib
module T = Task

let () =
  let pool = T.setup_pool ~num_domains:1 () in

  T.run pool (fun _ ->

    let _ =
      T.async pool (fun _ ->
        let ready = Atomic.make false in
        let a_ref = ref None in
        let b_ref = ref None in

        let a =
          T.async pool (fun _ ->
            while not (Atomic.get ready) do () done;
            Printf.printf "Task A waiting on B\n%!";
            ignore (T.await pool (Option.get !b_ref))
          )
        in

        let b =
          T.async pool (fun _ ->
            while not (Atomic.get ready) do () done;
            Printf.printf "Task B waiting on A\n%!";
            ignore (T.await pool (Option.get !a_ref))
          )
        in

        a_ref := Some a;
        b_ref := Some b;
        Atomic.set ready true;

        Gc.finalise_last
          (fun _ -> Printf.printf "Finalizing deadlocked task A\n%!") a;

        Gc.finalise_last
          (fun _ -> Printf.printf "Finalizing deadlocked task B\n%!") b;

        ignore (T.await pool a)
      )
    in

    Unix.sleep 1;
    Gc.full_major ()
  );

  T.teardown_pool pool
