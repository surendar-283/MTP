open Domainslib

module T = Task

let spin () =
  for _ = 1 to 50_000_000 do
    ()
  done

let () =

  let m1 = Mutex.create () in
  let m2 = Mutex.create () in

  let pool = T.setup_pool ~num_domains:2 () in

  T.run pool (fun _ ->
    let t1 =
      T.async pool (fun _ ->
        Mutex.lock m1;
        Printf.printf "Task 1: locked m1\n%!";
        spin (); 
        Mutex.lock m2;
        Printf.printf "Task 1: locked m2\n%!";
        Mutex.unlock m2;
        Mutex.unlock m1
      )
    in

    let t2 =
      T.async pool (fun _ ->
        Mutex.lock m2;
        Printf.printf "Task 2: locked m2\n%!";
        spin ();
        Mutex.lock m1;
        Printf.printf "Task 2: locked m1\n%!";
        Mutex.unlock m1;
        Mutex.unlock m2
      )
    in
    
    T.await pool t1;
    T.await pool t2;
  );

  T.teardown_pool pool
