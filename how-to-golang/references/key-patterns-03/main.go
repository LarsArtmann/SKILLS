// source: how-to-golang/references//home/lars/projects/SKILLS/how-to-golang/references/key-patterns block #3
k := koanf.New(".")
k.Load(confmap.Provider(defaults, "."), nil)
k.Load(file.Provider(path), yaml.Parser())
k.Load(env.Provider(".", env.Opt{Prefix: "APP_"}), nil)
k.Unmarshal("", &cfg)

