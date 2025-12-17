open Domainslib

let () =
  let pool = Task.setup_pool ~num_domains:1 () in
  Task.run pool (fun _ ->
      let _ =
        Task.async pool (fun _ ->
            let r = ref None in
            let t =
              Task.async pool (fun _ ->
                  Printf.printf "waiting forever!\n%!";
                  match !r with
                  | None -> Printf.printf "No task to wait on!\n%!"
                  | Some t -> ignore (Task.await pool t))
            in
            Gc.finalise_last (fun _ -> Printf.printf "Finalizing...\n%!") t;
            r := Some t;
            ignore (Task.await pool t))
      in
      Gc.full_major ();
      Unix.sleep 1;
      Gc.full_major ());

  Task.teardown_pool pool
