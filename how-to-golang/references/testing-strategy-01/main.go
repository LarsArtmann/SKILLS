// source: how-to-golang/references//home/lars/projects/SKILLS/how-to-golang/references/testing-strategy block #1
var _ = Describe("UserService", func() {
    Describe("Create", func() {
        Context("with valid input", func() {
            It("creates a user and returns an ID", func() {
                user, err := service.Create(ctx, validCmd)
                Expect(err).NotTo(HaveOccurred())
                Expect(user.ID).NotTo(BeZero())
            })
        })

        Context("with duplicate email", func() {
            It("returns ErrAlreadyExists", func() {
                _, _ = service.Create(ctx, validCmd)
                _, err := service.Create(ctx, validCmd)
                Expect(err).To(MatchError(domainerrors.ErrAlreadyExists))
            })
        })
    })
})

