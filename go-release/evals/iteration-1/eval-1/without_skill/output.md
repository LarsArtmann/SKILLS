```bash
cd /path/to/myrepo
git checkout master
git pull origin master
go test ./...
git tag -a v1.2.1 -m "Release v1.2.1"
git push origin v1.2.1
```

Optional: create a GitHub release with the CLI:

```bash
gh release create v1.2.1 --title "v1.2.1" --notes "Bug fix release"
```
