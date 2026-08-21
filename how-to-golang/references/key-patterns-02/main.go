// source: how-to-golang/references//home/lars/projects/SKILLS/how-to-golang/references/key-patterns block #2
// Railway pipeline
return uniflow.NewPipeline().
    Then(validate).Then(create).Then(emit).Run(ctx, input)

// Sentinel errors + wrapping
var ErrNotFound = errors.New("not found")
return nil, errors.Wrap(err, "failed to get user")
if errors.Is(err, ErrNotFound) { ... }

