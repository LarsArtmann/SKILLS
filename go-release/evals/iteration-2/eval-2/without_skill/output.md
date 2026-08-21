Tag both modules at the same commit:

```
git tag v1.3.0          # root module: github.com/myorg/mono
git tag cli/v1.3.0      # nested module: github.com/myorg/mono/cli
```

Push order:

```
git push origin cli/v1.3.0
git push origin v1.3.0
```

Notes:

- The nested module **must** be tagged with the directory-prefixed form `cli/v1.3.0`, not `v1.3.0`, because in a monorepo where the root module exists, a plain `v1.3.0` tag can only refer to the root module.
- Order doesn't strictly matter to the Go tooling (the proxy resolves each tag independently), but pushing the nested tag first is the common convention — if the nested tag fails to push, you haven't yet published a root release pointing at a commit where `cli` isn't tagged.
- Both tags must point at the same commit SHA; verify with `git tag --points-at HEAD`.
