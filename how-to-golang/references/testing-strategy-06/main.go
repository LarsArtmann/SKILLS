// source: how-to-golang/references//home/lars/projects/SKILLS/how-to-golang/references/testing-strategy block #6
It("returns expected user API response", func() {
    resp, err := client.Get("/api/users/123")
    Expect(err).NotTo(HaveOccurred())
    snaps.MatchSnapshot(t, resp.Body)
})

