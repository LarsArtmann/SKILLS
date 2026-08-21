// source: how-to-golang/references//home/lars/projects/SKILLS/how-to-golang/references/key-patterns block #4
import "charm.land/log/v2"

handler := log.NewWithOptions(os.Stdout, log.Options{
    ReportTimestamp: true, ReportCaller: true, Level: log.DebugLevel,
})
logger := slog.New(handler)
// Per-service: logger.With("service", "user")
// Per-request: log.WithContext(ctx, requestLogger)

