open Domainslib

module T = Task
module C = Chan

let () =
  let pool = T.setup_pool ~num_domains:2 () in

  T.run pool (fun _ ->
    let ch1 = C.make_bounded 0 in
    let ch2 = C.make_bounded 0 in

    let task1 =
      T.async pool (fun _ ->
        Printf.printf "Task 1 waiting to receive from ch1...\n%!";
        let x = C.recv ch1 in
        Printf.printf "Task 1 received %d, now sending on ch2...\n%!" x;
        C.send ch2 100
      )
    in

    let task2 =
      T.async pool (fun _ ->
        Printf.printf "Task 2 waiting to receive from ch2...\n%!";
        let y = C.recv ch2 in
        Printf.printf "Task 2 received %d, now sending on ch1...\n%!" y;
        C.send ch1 200
      )
    in

    T.await pool task1;
    T.await pool task2;
  );

  T.teardown_pool pool