```bash
# 1. Get the merged fix locally
git checkout master
git pull origin master

# 2. Sanity check before tagging
go test ./...
go vet ./...          # optional but cheap

# 3. Verify you're tagging the right commit
git log --oneline -3

# 4. Create the annotated tag
git tag -a v1.2.1 -m "v1.2.1: bug fix release"

# 5. Push the tag
git push origin v1.2.1

# 6. (Optional) Create a GitHub Release
gh release create v1.2.1 --title "v1.2.1" --notes "Fixes: <short description of the bug>"

# 7. (Optional) Warm the Go module proxy so the version resolves immediately
go list -m github.com/myorg/myrepo@v1.2.1
# or: curl https://proxy.golang.org/github.com/myorg/myrepo/@v/v1.2.1.info
```

Notes:

- Use an **annotated** tag (`git tag -a`), not a lightweight one — Go tooling and some proxies handle them more reliably.
- Tag the commit **on master that contains the fix**, not a local dirty state.
- No re-push of code is needed beyond the tag; `go get github.com/myorg/myrepo@v1.2.1` works for consumers once the tag is visible (module proxy picks it up automatically, step 7 just speeds it up).
- Since v1.2.0 → v1.2.1 is a patch bump with no API changes, no `go.mod` module-path changes are required.
