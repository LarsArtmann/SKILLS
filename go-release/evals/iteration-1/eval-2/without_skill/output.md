Tag the same commit with both module tags. The root module gets a plain semantic-version tag; nested modules get a `<path>/v<version>` tag.

```bash
git tag v1.3.0 <commit-hash>
git tag cli/v1.3.0 <commit-hash>
git push origin v1.3.0 cli/v1.3.0
```

Tags to push:

- `v1.3.0` → `github.com/myorg/mono`
- `cli/v1.3.0` → `github.com/myorg/mono/cli`

The order of tagging/pushing does not matter.
