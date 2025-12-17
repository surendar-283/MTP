open Domainslib

let () =
  let pool = Task.setup_pool ~num_domains:1 () in

  Task.run pool (fun _ ->
      let a_ref = ref None in
      let b_ref = ref None in

      let a =
        Task.async pool (fun _ ->
            Printf.printf "Task A waiting for Task B\n%!";
            ignore (Task.await pool (Option.get !b_ref)))
      in

      let b =
        Task.async pool (fun _ ->
            Printf.printf "Task B waiting for Task A\n%!";
            ignore (Task.await pool (Option.get !a_ref)))
      in

      a_ref := Some a;
      b_ref := Some b;

      ignore (Task.await pool a));

  Task.teardown_pool pool
