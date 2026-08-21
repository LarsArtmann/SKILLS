// source: how-to-golang/references//home/lars/projects/SKILLS/how-to-golang/references/domain-types block #1
package ids

import (
	id "github.com/larsartmann/go-composable-business-types/id"
	"github.com/larsartmann/go-composable-business-types/nanoid"
)

type UserBrand struct{}
type UserID = id.ID[UserBrand, nanoid.NanoID]

func GenerateUserID() UserID {
	return id.NewID[UserBrand, nanoid.NanoID](nanoid.New())
}

func GenerateUserIDFromString(s string) (UserID, error) {
	nid, err := nanoid.Parse(s)
	if err != nil { return UserID{}, fmt.Errorf("invalid user ID: %w", err) }
	return id.NewID[UserBrand, nanoid.NanoID](nid), nil
}

