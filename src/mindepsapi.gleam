import gleam/dynamic
import gleam/http/elli
import gleam/http/request.{type Request}
import gleam/io
import gleam/option
import gleam/pgo
import middleware
import web

fn service(req: Request(BitArray), _ctx: web.Context) {
  use <- middleware.logger(req)

  web.res_json(200, "{\"message\":\"hello world\"}")
}

pub fn main() {
  let conn =
    pgo.connect(
      pgo.Config(
        ..pgo.default_config(),
        database: "db",
        user: "vshakitskiy",
        password: option.Some("12345"),
        port: 5555,
        pool_size: 15,
      ),
    )

  case pgo.execute("select 1", conn, [], dynamic.dynamic) {
    Error(_) -> {
      io.println_error("Postgres connection unavailable")
      exit(1)
    }
    _ -> Nil
  }

  io.println("Listening on http://localhost:5000")
  elli.become(fn(req) { service(req, web.Context(conn:)) }, 5000)
}

@external(erlang, "erlang", "halt")
fn exit(code: Int) -> a
