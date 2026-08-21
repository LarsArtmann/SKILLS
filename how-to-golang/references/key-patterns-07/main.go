// source: how-to-golang/references//home/lars/projects/SKILLS/how-to-golang/references/key-patterns block #7
import (
    "github.com/gin-gonic/gin"
    "github.com/danielgtaylor/huma/v2"
    "github.com/danielgtaylor/huma/v2/adapters/humagin"
)

router := gin.Default()
api := humagin.New(router, huma.DefaultConfig("My API", "1.0.0"))

huma.Register(api, huma.Operation{
    Method: http.MethodPost,
    Path:   "/users",
}, CreateUserHandler)

