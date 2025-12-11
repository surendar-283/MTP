open Domainslib

module T = Task

let flag0 = Atomic.make false
let flag1 = Atomic.make false
let turn  = Atomic.make 0  

let buggy_peterson id =
  let other = 1 - id in

  (* Entry section: set my flag and give turn to the other *)
  if id = 0 then Atomic.set flag0 true else Atomic.set flag1 true;
  Atomic.set turn other;

  Printf.printf "Task %d: trying to enter critical section...\n%!" id;

  (* BROKEN waiting condition: uses OR instead of AND *)
  let rec wait () =
    let other_flag =
      if id = 0 then Atomic.get flag1 else Atomic.get flag0
    in
    let t = Atomic.get turn in
    (* Correct Peterson:   while other_flag && t = other do ()
       Broken version:     while other_flag || t = other do ()
       This can cause both tasks to spin forever. *)
    if other_flag || t = other then
      wait ()
    else
      ()
  in
  wait ();

  (* This line should NEVER be reached if both tasks try to enter *)
  Printf.printf
    "Task %d: ENTERED critical section (this should not happen if both run)\n%!"
    id;

  (* Exit section: clear my flag *)
  if id = 0 then Atomic.set flag0 false else Atomic.set flag1 false

let () =
  let pool = T.setup_pool ~num_domains:2 () in

  T.run pool (fun _ ->
    (* Two concurrent "threads" using the broken Peterson algorithm *)
    let t0 = T.async pool (fun _ -> buggy_peterson 0) in
    let t1 = T.async pool (fun _ -> buggy_peterson 1) in

    (* These awaits will never complete if both tasks get into the wait loop *)
    T.await pool t0;
    T.await pool t1;
  );

  T.teardown_pool pool
