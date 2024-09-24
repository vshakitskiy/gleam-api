import gleam/bytes_builder.{type BytesBuilder}
import gleam/http
import gleam/http/request.{type Request}
import gleam/http/response.{type Response}
import gleam/int
import gleam/io
import gleam/pgo
import gleam/string

pub type Context {
  Context(conn: pgo.Connection, req: Request(BitArray))
}

// Response

pub fn res_json(status: Int, body: String) {
  response.new(status)
  |> response.set_header("content-type", "application/json")
  |> response.set_body(bytes_builder.from_string(body))
}

pub fn res_json_message(status: Int, message: String) {
  let body = ["{\"message\": \"", message, "\"}"] |> string.join("")
  res_json(status, body)
}

// Middlewares

@external(erlang, "time", "now")
fn now() -> Int

pub fn logger(req: Request(BitArray), handler: fn() -> Response(BytesBuilder)) {
  let start_time = now()
  let res = handler()

  [
    req.method |> http.method_to_string() |> string.uppercase(),
    " ",
    req.path,
    " ",
    res.status |> int.to_string(),
    " ",
    now() - start_time |> int.to_string(),
    "ms",
  ]
  |> string.concat()
  |> io.println()

  res
}

pub fn ensure_json(
  req: Request(BitArray),
  handler: fn() -> Response(BytesBuilder),
) {
  case request.get_header(req, "content-type") {
    Ok(value) ->
      case value {
        "application/json" -> handler()
        _ -> res_json_message(415, "content-Type must be application/json")
      }
    Error(Nil) ->
      res_json_message(415, "content-Type of application/json is required")
  }
}
