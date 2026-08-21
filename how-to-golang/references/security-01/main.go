// source: how-to-golang/references//home/lars/projects/SKILLS/how-to-golang/references/security block #1
func AuthMiddleware(jwtKey func(token string) (Claims, error)) gin.HandlerFunc {
    return func(c *gin.Context) {
        token := strings.TrimPrefix(c.GetHeader("Authorization"), "Bearer ")
        if token == "" {
            c.AbortWithStatusJSON(401, gin.H{"error": "missing token"})
            return
        }
        claims, err := jwtKey(token)
        if err != nil {
            c.AbortWithStatusJSON(401, gin.H{"error": "invalid token"})
            return
        }
        c.Set("claims", claims)
        c.Next()
    }
}

