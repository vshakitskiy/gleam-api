import gleam/http
import gleam/http/request.{type Request}
import web

pub fn user_router(path_seg: List(String), ctx: web.Context) {
  case path_seg {
    [] -> {
      case ctx.req.method {
        http.Post -> post_user_route(ctx)
        _ ->
          web.res_json_message(
            405,
            "method is not allowed; expected GET, POST, PUT or DELETE",
          )
      }
    }
    [id] -> todo
    _ -> web.res_json_message(404, "unknown endpoint")
  }
}

fn post_user_route(ctx: web.Context) {
  web.res_json(200, "{}")
}
