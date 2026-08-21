// source: how-to-golang/references//home/lars/projects/SKILLS/how-to-golang/references/rules block #2
package errors

import "github.com/cockroachdb/errors"

var (
    ErrNotFound       = errors.New("not found")
    ErrUnauthorized   = errors.New("unauthorized")
    ErrValidation     = errors.New("validation failed")
    ErrAlreadyExists  = errors.New("already exists")
)

