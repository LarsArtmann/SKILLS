// source: how-to-golang/references//home/lars/projects/SKILLS/how-to-golang/references/security block #4
// Password hashing with argon2id
import "golang.org/x/crypto/argon2"

func HashPassword(password string, salt []byte) []byte {
    return argon2.IDKey([]byte(password), salt, 3, 64*1024, 4, 32)
}

