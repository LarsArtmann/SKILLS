// source: how-to-golang/references//home/lars/projects/SKILLS/how-to-golang/references/testing-strategy block #5
func TestAPIConcurrency(t *testing.T) {
    if testing.Short() { t.Skip("skipping load test") }

    concurrent := 100
    maxDuration := 200 * time.Millisecond
    errors := make(chan error, concurrent)

    var wg sync.WaitGroup
    for i := 0; i < concurrent; i++ {
        wg.Add(1)
        go func() {
            defer wg.Done()
            start := time.Now()
            resp, err := client.Get("/api/users")
            if err != nil { errors <- err; return }
            if time.Since(start) > maxDuration {
                errors <- fmt.Errorf("response took %v", time.Since(start))
            }
        }()
    }
    wg.Wait()
    close(errors)

    for err := range errors { t.Error(err) }
}

