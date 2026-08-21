// source: how-to-golang/references//home/lars/projects/SKILLS/how-to-golang/references/performance-tuning block #1
// errgroup: g.Go blocks until a slot frees up
g, ctx := errgroup.WithContext(ctx)
g.SetLimit(20) // the measured knee, not runtime.NumCPU()
for _, item := range items {
    g.Go(func() error { return process(ctx, item) })
}
err := g.Wait()

// or a semaphore channel when errgroup doesn't fit
sem := make(chan struct{}, 20)

