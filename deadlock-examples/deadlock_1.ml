open Domainslib
let () =
  let pool = Task.setup_pool ~num_domains:1 () in
  Task.run pool (fun _ ->
    let r = ref None in
    let t =
      Task.async pool (fun _ ->
        Printf.printf "waiting forever!\n%!";
        ignore (Task.await pool (Option.get !r))
      )
    in
    r := Some t;
    ignore (Task.await pool t)
  );
  Task.teardown_pool pool
