# echosrv

TCP echo server written in OCaml. It uses [Lwt](https://ocsigen.org/lwt/5.3.0/manual/manual) 
library for implementing concurrency.

## run
warn: you need ocaml compiler version higer than `4.08.0`.

running server that binds TCP port 8000.

```
$ dune build
$ dune install
$ echosrv 8000     
echosrv: [DEBUG] TCP port 8000 binded.
```

now you can connect to `echosrv` using client tools such as `nc`.

```
$ nc localhost 8000
hello?
hello?
```

`echosrv` will show you that what messages are echoed.

```
$ echosrv 8000     
echosrv: [DEBUG] TCP port 8000 binded.
echosrv: [DEBUG] Client connected!
echosrv: [INFO] Client sent: hello?
```
