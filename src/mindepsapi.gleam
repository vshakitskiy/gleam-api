import gleam/dynamic
import gleam/http/elli
import gleam/http/request
import gleam/io
import gleam/option
import gleam/pgo
import router.{api_router}
import web

fn service(ctx: web.Context) {
  use <- web.logger(ctx.req)
  use <- web.ensure_json(ctx.req)

  case request.path_segments(ctx.req) {
    ["api", ..seg] -> api_router(seg, ctx)
    _ -> web.res_json_message(404, "unknown endpoint")
  }
}

pub fn main() {
  let conn = setup_conn()
  io.println("listening on http://localhost:5000")
  elli.become(fn(req) { service(web.Context(conn:, req:)) }, 5000)
}

fn setup_conn() {
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
      io.println_error("postgres connection unavailable")
      exit(1)
    }
    _ -> io.println("connected to postgres")
  }

  let user_table =
    "create table if not exists users (
      id serial primary key,
      username text not null,
      password_hash text not null,
      email text not null
    );"
  case pgo.execute(user_table, conn, [], dynamic.dynamic) {
    Error(query_error) -> {
      io.debug(query_error)
      Nil
    }
    _ -> io.println("Ensured user table")
  }

  conn
}

@external(erlang, "erlang", "halt")
fn exit(code: Int) -> a
