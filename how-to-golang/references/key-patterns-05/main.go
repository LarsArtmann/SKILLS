// source: how-to-golang/references//home/lars/projects/SKILLS/how-to-golang/references/key-patterns block #5
import "charm.land/fang/v2"

fang.Execute(ctx, rootCmd,
    fang.WithVersion("1.0.0"),
    fang.WithCommit(buildCommit),
)

