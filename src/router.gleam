import router/user.{user_router}
import web

pub fn api_router(path_seg: List(String), ctx: web.Context) {
  case path_seg {
    ["user", ..seg] -> user_router(seg, ctx)
    _ -> web.res_json_message(404, "unknown endpoint")
  }
}
