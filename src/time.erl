-module(time).

-export([now/0]).

now() -> os:system_time(millisecond).