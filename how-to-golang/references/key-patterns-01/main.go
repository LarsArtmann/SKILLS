// source: how-to-golang/references//home/lars/projects/SKILLS/how-to-golang/references/key-patterns block #1
func NewUserService(i do.Injector) (*UserService, error) {
    repo, err := do.Invoke[UserRepository](i)
    if err != nil {
        return nil, fmt.Errorf("failed to resolve UserRepository: %w", err)
    }
    logger, err := do.Invoke[*slog.Logger](i)
    if err != nil {
        return nil, fmt.Errorf("failed to resolve Logger: %w", err)
    }
    return &UserService{repo: repo, logger: logger}, nil
}

