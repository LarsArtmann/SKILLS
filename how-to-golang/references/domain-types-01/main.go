// source: how-to-golang/references/domain-types block #1
package ids

import (
	"fmt"

	id "github.com/larsartmann/go-branded-id"
	"github.com/sixafter/nanoid"
)

type UserBrand struct{}

func (UserBrand) Name() string { return "User" }

type UserID = id.ID[UserBrand, nanoid.ID]

func GenerateUserID() UserID {
	return id.NewID[UserBrand](nanoid.Must())
}

func GenerateUserIDFromString(s string) (UserID, error) {
	if len(s) != 21 {
		return UserID{}, fmt.Errorf("invalid user ID %q: want 21 nanoid chars", s)
	}
	return id.NewID[UserBrand](nanoid.ID(s)), nil
}
