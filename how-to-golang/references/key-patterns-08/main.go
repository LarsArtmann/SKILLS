// source: how-to-golang/references//home/lars/projects/SKILLS/how-to-golang/references/key-patterns block #8
type CreateUserRequest struct {
    //govalid:required
    //govalid:email
    Email string `json:"email"`

    //govalid:required
    //govalid:min_len=2
    //govalid:max_len=100
    Name string `json:"name"`
}

