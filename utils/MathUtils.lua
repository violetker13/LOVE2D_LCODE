local MathUtils = {}

function MathUtils.distanceToSegment(px, py, x1, y1, x2, y2)
    local dx, dy = x2 - x1, y2 - y1
    if dx == 0 and dy == 0 then
        return math.sqrt((px - x1)^2 + (py - y1)^2)
    end
    local t = ((px - x1) * dx + (py - y1) * dy) / (dx*dx + dy*dy)
    t = math.max(0, math.min(1, t))
    local closestX = x1 + t * dx
    local closestY = y1 + t * dy
    return math.sqrt((px - closestX)^2 + (py - closestY)^2)
end

return MathUtils
