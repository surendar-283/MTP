open Domainslib
module T = Task

let () =
  let pool = T.setup_pool ~num_domains:1 () in

  T.run pool (fun _ ->

    let _ =
      T.async pool (fun _ ->
        let parent_ref = ref None in
        let ready = Atomic.make false in

        let child1 =
          T.async pool (fun _ ->
            while not (Atomic.get ready) do () done;
            Printf.printf "Child 1 awaiting parent\n%!";
            ignore (T.await pool (Option.get !parent_ref))
          )
        in

        let child2 =
          T.async pool (fun _ ->
            while not (Atomic.get ready) do () done;
            Printf.printf "Child 2 awaiting parent\n%!";
            ignore (T.await pool (Option.get !parent_ref))
          )
        in

        let parent =
          T.async pool (fun _ ->
            Printf.printf "Parent awaiting all children\n%!";
            ignore (T.await pool child1);
            ignore (T.await pool child2)
          )
        in

        parent_ref := Some parent;
        Atomic.set ready true;

        Gc.finalise_last
          (fun _ -> Printf.printf "Finalizing parent\n%!")
          parent;

        Gc.finalise_last
          (fun _ -> Printf.printf "Finalizing child 1\n%!")
          child1;

        Gc.finalise_last
          (fun _ -> Printf.printf "Finalizing child 2\n%!")
          child2;

        ignore (T.await pool parent)
      )
    in

    Unix.sleep 1;
    Gc.full_major ()
  );

  T.teardown_pool pool
