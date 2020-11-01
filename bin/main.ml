open Base
open Lwt.Syntax

let echo_handler ic oc =
  let rec echo () =
    let* so = Lwt_io.read_line_opt ic in
    match so with
    | Some s ->
        let* () = Logs_lwt.info (fun m -> m "Client sent: %s" s) in
        let* () = Lwt_io.write_line oc s in
        echo ()
    | None -> 
      let* () = Logs_lwt.debug (fun m -> m "Client Disconnected.") in
      Lwt.return_unit
  in
  let* () = Logs_lwt.debug (fun m -> m "Client connected!") in
  echo ()

let create_socket ~port =
  let open Lwt_unix in
  let fd = socket PF_INET SOCK_STREAM 0 in
  let* () = bind fd @@ ADDR_INET(Unix.inet_addr_any, port) in
  let* () = Logs_lwt.debug (fun m -> m "TCP port %d binded." port) in
  let () = listen fd 5 in
  Lwt.return fd

let accept_connection conn =
  let fd, _ = conn in
  let ic = Lwt_io.of_fd ~mode:Lwt_io.Input fd in
  let oc = Lwt_io.of_fd ~mode:Lwt_io.Output fd in
  Lwt.on_failure (echo_handler ic oc) (fun e -> Logs.err (fun m -> m "%s" (Exn.to_string e) ));
  Lwt.return ()

let create_server sock =
  let rec serve () =
    let* conn = Lwt_unix.accept sock in
    let* () = accept_connection conn in
    serve ()
  in
  serve ()

let echosrv ~port =
  let* sk = create_socket ~port in
  create_server sk

let setup_logger () =
  Fmt_tty.setup_std_outputs ();
  Logs.set_level (Some Logs.Debug);
  Logs.set_reporter (Logs_fmt.reporter ~app:Fmt.stdout ())

let () = 
  setup_logger ();
  if Array.length (Sys.get_argv ()) > 1 
  then 
    let pr = echosrv ~port:(Int.of_string @@ Array.get (Sys.get_argv ()) 1) in
    let _ = Lwt_main.run pr in
    ()
  else 
    Stdio.print_endline "[Usage] echosrv <port>"
