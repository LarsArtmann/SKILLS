# Domain Types (go-composable-business-types)

Required for all new services. No primitive types for domain concepts.

## Core Types

| Type                     | Package     | Use For                        |
| ------------------------ | ----------- | ------------------------------ |
| `id.ID[Brand, V]`        | `id`        | Branded entity identifiers     |
| `nanoid.NanoID`          | `nanoid`    | URL-safe unique IDs (21 chars) |
| `types.Email`            | `types`     | Validated email                |
| `types.URL`              | `types`     | Validated URL (http/https)     |
| `types.Cents`            | `types`     | Money (int64, no float errors) |
| `money.Money`            | `money`     | ISO 4217 currency              |
| `types.Percentage`       | `types`     | 0-100 validated                |
| `types.Timestamp`        | `types`     | Domain-wrapped time.Time       |
| `types.Duration`         | `types`     | Domain-wrapped time.Duration   |
| `bounded.BoundedString`  | `bounded`   | Length-validated string        |
| `datapoint.DataPoint[T]` | `datapoint` | Data + complete audit trail    |
| `actor.ActorChain[T]`    | `actor`     | Ordered actor chain for audit  |
| `temporal.Bitemporal`    | `temporal`  | validFrom/Until + recorded     |

## Branded ID Pattern (canonical)

```go
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
```

Key points:

- `id.ID[Brand, V]` implements `sql.Scanner`, `driver.Valuer`, `json.Marshaler`/`Unmarshaler` — no manual methods
- Zero value serializes to JSON `null`
- `ProcessUser(orderID)` → **compile error**, not runtime bug
- sqlc `overrides` maps DB columns to branded IDs directly
