// source: how-to-golang/references//home/lars/projects/SKILLS/how-to-golang/references/testing-strategy block #4
import "testing/quick"

func TestEmailNormalization(t *testing.T) {
    err := quick.Check(func(email string) bool {
        normalized := normalizeEmail(email)
        // Property: normalized email is always lowercase
        return normalized == strings.ToLower(normalized)
    }, nil)
    if err != nil { t.Error(err) }
}

// With gopter for advanced property testing (generators, shrinking):
import (
    "github.com/leanovate/gopter"
    "github.com/leanovate/gopter/gen"
    "github.com/leanovate/gopter/prop"
)

func TestULIDSortability(t *testing.T) {
    properties := gopter.NewProperties(nil)
    properties.Property("ULIDs are lexicographically sortable", prop.ForAll(
        func(a, b int) bool {
            id1 := generateULID(time.Unix(int64(a), 0))
            id2 := generateULID(time.Unix(int64(b), 0))
            if a < b { return id1 < id2 }
            return id1 >= id2
        },
        gen.Int(), gen.Int(), // one generator per parameter
    ))
    properties.TestingRun(t)
}

