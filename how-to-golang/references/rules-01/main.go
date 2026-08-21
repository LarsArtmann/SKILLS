// source: how-to-golang/references//home/lars/projects/SKILLS/how-to-golang/references/rules block #1
func BenchmarkUserService_Create(b *testing.B) {
    b.ReportAllocs()
    for i := 0; i < b.N; i++ {
        _, err := service.Create(ctx, cmd)
        if err != nil { b.Fatal(err) }
    }
}

