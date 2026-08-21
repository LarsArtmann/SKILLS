// source: how-to-golang/references//home/lars/projects/SKILLS/how-to-golang/references/domain-types block #8
// parent package (recorder.go)
type Middleware func(http.Handler) http.Handler  // definition — distinct type

// sub-module (server_timing/middleware.go)
type Middleware func(http.Handler) http.Handler  // ANOTHER distinct type

// Pain: every composition boundary needs a conversion
addStackMiddleware(t, stack, MiddlewareServerTiming,
    Middleware(servertiming.ServerTimingMiddleware()))  // explicit conversion required

