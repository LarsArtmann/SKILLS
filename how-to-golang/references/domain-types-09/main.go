// source: how-to-golang/references//home/lars/projects/SKILLS/how-to-golang/references/domain-types block #9
// parent package (recorder.go)
type Middleware = func(http.Handler) http.Handler  // alias — same type

// sub-module (server_timing/middleware.go)
type Middleware = func(http.Handler) http.Handler  // alias — same type

// No conversion needed — they're identical types
addStackMiddleware(t, stack, MiddlewareServerTiming,
    servertiming.ServerTimingMiddleware())  // just works

