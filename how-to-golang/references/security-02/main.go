// source: how-to-golang/references//home/lars/projects/SKILLS/how-to-golang/references/security block #2
import "golang.org/x/time/rate"

func RateLimitMiddleware(r *rate.Limiter) gin.HandlerFunc {
    return func(c *gin.Context) {
        if !r.Allow() {
            c.AbortWithStatusJSON(429, gin.H{"error": "rate limit exceeded"})
            return
        }
        c.Next()
    }
}

