import gleam/bytes_builder
import gleam/http/response
import gleam/pgo

pub type Context {
  Context(conn: pgo.Connection)
}

pub fn res_json(status: Int, body: String) {
  response.new(status)
  |> response.set_header("Content-Type", "application/json")
  |> response.set_body(bytes_builder.from_string(body))
}
