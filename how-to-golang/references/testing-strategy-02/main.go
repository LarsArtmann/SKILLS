// source: how-to-golang/references//home/lars/projects/SKILLS/how-to-golang/references/testing-strategy block #2
var _ = Describe("UserRepository", func() {
    var (
        repo     *UserRepository
        db       *sql.DB
        container *postgres.PostgresContainer
    )

    BeforeEach(func() {
        ctx := context.Background()
        var err error
        container, err = postgres.RunContainer(ctx,
            testcontainers.WithImage("postgres:16"),
            postgres.WithDatabase("testdb"),
            postgres.WithUsername("test"),
            postgres.WithPassword("test"),
        )
        Expect(err).NotTo(HaveOccurred())

        dsn, err := container.ConnectionString(ctx, "sslmode=disable")
        Expect(err).NotTo(HaveOccurred())

        db, err = sql.Open("pgx", dsn)
        Expect(err).NotTo(HaveOccurred())

        // Run migrations
        _, err = db.Exec(ctx, migrationSQL)
        Expect(err).NotTo(HaveOccurred())

        repo = NewUserRepository(db)
    })

    AfterEach(func() {
        db.Close()
        container.Terminate(context.Background())
    })

    It("persists and retrieves users", func() {
        user := &User{Email: "test@example.com", Name: "Test"}
        saved, err := repo.Save(ctx, user)
        Expect(err).NotTo(HaveOccurred())

        found, err := repo.FindByID(ctx, saved.ID)
        Expect(err).NotTo(HaveOccurred())
        Expect(found.Email).To(Equal("test@example.com"))
    })
})

