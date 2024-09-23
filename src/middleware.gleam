import gleam/bytes_builder.{type BytesBuilder}
import gleam/http
import gleam/http/request.{type Request}
import gleam/http/response.{type Response}
import gleam/int
import gleam/io
import gleam/string

@external(erlang, "time", "now")
fn now() -> Int

pub fn logger(req: Request(BitArray), handler: fn() -> Response(BytesBuilder)) {
  io.debug(now())
  let res = handler()
  io.debug(now())
  [
    req.method |> http.method_to_string() |> string.uppercase(),
    " ",
    req.path,
    " ",
    res.status |> int.to_string(),
  ]
  |> string.concat()
  |> io.println()

  res
}
