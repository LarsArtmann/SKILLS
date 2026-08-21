// source: how-to-golang/references//home/lars/projects/SKILLS/how-to-golang/references/key-patterns block #6
var _ = Describe("UserService", func() {
    It("creates a user", func() {
        user, err := service.Create(ctx, cmd)
        Expect(err).NotTo(HaveOccurred())
        Expect(user.ID).NotTo(BeZero())
    })
})

