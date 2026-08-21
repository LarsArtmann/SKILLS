// source: how-to-golang/references//home/lars/projects/SKILLS/how-to-golang/references/testing-strategy block #3
var _ = Describe("User Registration E2E", Ordered, func() {
    It("registers, confirms email, and logs in", func() {
        baseURL := "http://localhost:8080"

        // 1. Register
        regBody, _ := json.Marshal(CreateUserRequest{
            Email: "e2e@example.com",
            Name:  "E2E User",
        })
        resp, err := http.Post(baseURL+"/api/users", "application/json", bytes.NewReader(regBody))
        Expect(err).NotTo(HaveOccurred())
        Expect(resp.StatusCode).To(Equal(http.StatusCreated))

        // 2. Confirm email (simulated)
        confirmURL := resp.Header.Get("X-Confirmation-URL")
        resp, err = http.Get(baseURL + confirmURL)
        Expect(err).NotTo(HaveOccurred())
        Expect(resp.StatusCode).To(Equal(http.StatusOK))

        // 3. Login
        loginBody, _ := json.Marshal(LoginRequest{
            Email:    "e2e@example.com",
            Password: "test-password",
        })
        resp, err = http.Post(baseURL+"/api/auth/login", "application/json", bytes.NewReader(loginBody))
        Expect(err).NotTo(HaveOccurred())
        Expect(resp.StatusCode).To(Equal(http.StatusOK))

        var loginResp struct{ Token string }
        err = json.NewDecoder(resp.Body).Decode(&loginResp)
        Expect(err).NotTo(HaveOccurred())
        Expect(loginResp.Token).NotTo(BeEmpty())
    })
})

