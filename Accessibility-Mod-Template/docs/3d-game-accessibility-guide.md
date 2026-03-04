# 3D Game Accessibility Guide

Making 3D games accessible to blind players requires solving four connected problems: knowing where to go (pathfinding), communicating direction (audio guidance), moving automatically (auto-walk), and organizing what's around you (navigation categories).

This guide documents proven patterns from production mods tested by real blind players.

**Note:** Code examples use Unity API. Adapt layer masks, physics calls, and input methods to your game engine.

---

## Part 1: Pathfinding (A* on 3D Terrain)

Most 3D games have no NavMesh accessible to mods. This section describes a custom A* pathfinder that works on any terrain with physics raycasts.

### Core Idea

Build a virtual grid around the player, probe each cell with physics raycasts to find walkable ground, then run A* to find a path. The grid moves with the player — it's not a pre-built map.

### Data Structures

```csharp
public struct PathWaypoint
{
    public Vector3 Position;   // Ground position in world space
    public bool NeedsJump;     // Player must jump to reach this waypoint
}

private struct CellInfo
{
    public bool Walkable;      // Safe to walk here
    public Vector3 GroundPos;  // Actual ground position after probe
    public float Height;       // Height relative to player's up vector
    public bool HasHazard;     // Dangerous terrain (lava, spikes, etc.)
}
```

### Height-Propagating Cell Scanning

**Key insight:** Don't probe from a fixed height. Probe from the **parent cell's ground height** plus a probe offset. This naturally follows terrain up hills and down valleys.

```csharp
private CellInfo ScanCell(int x, int z, float refHeight)
{
    // Cache key includes height bucket for multi-level support
    int hBucket = Mathf.RoundToInt(refHeight / HeightBand);
    var key = (x, z, hBucket);

    if (_cache.TryGetValue(key, out CellInfo cached))
        return cached;

    // Probe from reference height + offset
    Vector3 worldPos = GridToWorld(x, z);
    Vector3 probeOrigin = worldPos + _up * (refHeight + ProbeHeight);

    CellInfo cell = default;

    if (Physics.SphereCast(probeOrigin, ProbeRadius, -_up, out RaycastHit hit,
        ProbeLength, physicsMask, QueryTriggerInteraction.Ignore))
    {
        cell.Walkable = Vector3.Angle(_up, hit.normal) <= MaxSlope;
        cell.GroundPos = hit.point;
        cell.Height = Vector3.Dot(hit.point - _origin, _up);

        // Check for hazards in the area
        var overlaps = Physics.OverlapSphere(
            hit.point + _up * 0.5f, 0.4f,
            hazardMask, QueryTriggerInteraction.Collide);

        if (overlaps != null)
        {
            foreach (var col in overlaps)
            {
                if (IsHazard(col)) // Game-specific hazard check
                {
                    cell.HasHazard = true;
                    break;
                }
            }
        }
    }

    _cache[key] = cell;
    return cell;
}
```

**Recommended constants:**
- `ProbeHeight = 12f` — cast from 12m above reference (catches elevated terrain)
- `ProbeLength = 24f` — cast 24m downward (handles cliffs)
- `ProbeRadius = 0.35f` — SphereCast radius, slightly smaller than player (~0.46m)
- `HeightBand = 3f` — round heights to 3m buckets for caching
- `MaxSlope = 45f` — maximum walkable slope angle

### Why SphereCast Instead of Raycast

A raycast is a single line — it can miss narrow passages that the player can't fit through. A SphereCast simulates a sphere moving through space, detecting if the player's body would collide. Use a radius slightly smaller than the player's collision radius.

### Adaptive Grid Resolution

For nearby targets, use a fine grid (1m cells). For distant targets, use a coarser grid (2m cells) to reduce computation. Add hysteresis to prevent thrashing:

```csharp
float distToTarget = HorizontalDistance(playerPos, targetPos);

if (distToTarget > 45f)
    _cellSize = 2f;        // coarse for far targets
else if (distToTarget < 35f)
    _cellSize = 1f;        // fine for close targets
// else keep current (hysteresis between 35-45m)
```

### 3D Cache Key

The cache key must be `(x, z, heightBucket)`, not just `(x, z)`. This supports multi-level structures (bridges, buildings with floors, caves under terrain).

**Critical:** The A* node must use the **same heightBucket** as the cache key. The bucket is based on `refHeight` (the parent cell's height), NOT the neighbor's actual height. Mismatching this causes `KeyNotFoundException`.

### 8-Connected Grid with Diagonal Safety

Use 8 neighbors (4 cardinal + 4 diagonal). For diagonals, verify both adjacent cardinal cells are walkable to prevent wall-clipping:

```csharp
// Diagonal from (x,z) to (x+1, z+1):
// Check (x+1, z) AND (x, z+1) are both walkable
if (!ScanCell(nx, curZ, curHeight).Walkable ||
    !ScanCell(curX, nz, curHeight).Walkable)
    continue; // Would clip through corner
```

Diagonal cost = `cellSize * 1.414f` (sqrt(2)).

### Edge Classification

Each edge between cells has three states:

```csharp
private byte CheckEdge(CellInfo from, CellInfo to)
{
    float vertDiff = Mathf.Abs(Vector3.Dot(
        to.GroundPos - from.GroundPos, _up));

    if (vertDiff > MaxStepHeight) // e.g., 3m
        return 1; // Impassable — too high

    // Check at chest height (0.9m) for walls
    Vector3 fromChest = from.GroundPos + _up * 0.9f;
    Vector3 toChest = to.GroundPos + _up * 0.9f;

    bool wallHit = Physics.SphereCast(fromChest, ProbeRadius,
        (toChest - fromChest).normalized, out _,
        (toChest - fromChest).magnitude,
        physicsMask, QueryTriggerInteraction.Ignore);

    if (!wallHit) return 0; // Clear passage

    // Wall exists — check if jumpable (clear at 1.2m)
    Vector3 fromHigh = from.GroundPos + _up * 1.2f;
    Vector3 toHigh = to.GroundPos + _up * 1.2f;

    bool highHit = Physics.SphereCast(fromHigh, ProbeRadius,
        (toHigh - fromHigh).normalized, out _,
        (toHigh - fromHigh).magnitude,
        physicsMask, QueryTriggerInteraction.Ignore);

    return highHit ? (byte)1 : (byte)2; // 2 = jumpable
}
// Return: 0 = walkable, 1 = impassable, 2 = needs jump
```

### A* Cost Modifiers

```csharp
float moveCost = isDiagonal ? _cellSize * 1.414f : _cellSize;
if (needsJump) moveCost += 1.5f;      // Prefer non-jump paths
if (hasHazard) moveCost += 50f;        // Strongly avoid hazards
```

### 3D Heuristic

Include vertical distance for accurate estimates on hilly terrain:

```csharp
private float Heuristic(int x1, int z1, float h1, int x2, int z2, float h2)
{
    float dx = (x2 - x1) * _cellSize;
    float dz = (z2 - z1) * _cellSize;
    float dy = h2 - h1;
    return Mathf.Sqrt(dx * dx + dz * dz + dy * dy);
}
```

### Target Directly Above or Below

When the target is nearly vertical (no horizontal offset), A* has no direction to search. Pick an arbitrary horizontal direction:

```csharp
Vector3 toTarget = targetPos - playerPos;
Vector3 flat = toTarget - Vector3.Project(toTarget, _up);

if (flat.sqrMagnitude < 0.1f)
{
    flat = Vector3.Cross(_up, Vector3.right);
    if (flat.sqrMagnitude < 0.01f)
        flat = Vector3.Cross(_up, Vector3.forward);
}
```

### Path Simplification

Remove intermediate waypoints when line-of-sight exists:

```csharp
private List<PathWaypoint> SimplifyPath(List<PathWaypoint> raw)
{
    var result = new List<PathWaypoint> { raw[0] };
    int current = 0;

    while (current < raw.Count - 1)
    {
        int furthest = current + 1;

        for (int i = current + 2; i < raw.Count; i++)
        {
            // Preserve jump waypoints (don't simplify past them)
            bool hasJump = false;
            for (int j = current + 1; j <= i; j++)
                if (raw[j].NeedsJump) { hasJump = true; break; }
            if (hasJump) break;

            // Line-of-sight check at chest height
            Vector3 from = raw[current].Position + _up * 0.9f;
            Vector3 to = raw[i].Position + _up * 0.9f;

            if (!Physics.SphereCast(from, ProbeRadius,
                (to - from).normalized, out _,
                (to - from).magnitude,
                physicsMask, QueryTriggerInteraction.Ignore))
            {
                furthest = i;
            }
            else break;
        }

        result.Add(raw[furthest]);
        current = furthest;
    }

    return result;
}
```

### Long Distance Segmentation

For targets beyond 50m, compute paths in segments to keep A* fast:

```csharp
private const float SegmentDistance = 50f;

if (horizontalDistance > SegmentDistance)
{
    // Compute path to 50m intermediate goal
    Vector3 segGoal = playerPos + direction * SegmentDistance;
    path = FindPath(playerPos, segGoal);
    _segmented = true;
}
else
{
    path = FindPath(playerPos, targetPos);
    _segmented = false;
}

// When segment consumed, recompute immediately (no wait)
```

### Result Caching

Multiple systems (guidance, auto-walk) may query the same path within one frame. Cache results briefly:

```csharp
private const float CacheMaxAge = 0.4f;    // seconds
private const float CachePosTolerance = 1f; // meters

// Return cached result if positions haven't moved much
```

### Exploration Limits

Set a maximum number of cells to explore before giving up:

```csharp
private const int MaxExplored = 12000;

// In A* loop:
if (explored >= MaxExplored)
{
    // Return best partial path (closest to target)
    break;
}
```

---

## Part 2: Audio Guidance

### 3D Spatial Audio

Position an AudioSource toward the target waypoint so the player hears direction through stereo/headphones:

```csharp
_audioSource = gameObject.AddComponent<AudioSource>();
_audioSource.spatialBlend = 1.0f;  // Fully 3D
_audioSource.rolloffMode = AudioRolloffMode.Linear;
_audioSource.minDistance = 1f;
_audioSource.maxDistance = 50f;

// Each frame, position toward next waypoint:
Vector3 toWaypoint = nextWaypoint - playerPosition;
_audioSource.transform.position =
    playerPosition + toWaypoint.normalized * 10f;
```

### 5-Tier Alignment System

Tick rate changes based on how well-aligned the player faces the target:

```csharp
// Alignment = dot product on horizontal plane only
Vector3 playerForward = /* player's forward, projected onto horizontal plane */;
Vector3 toTarget = /* direction to waypoint, projected onto horizontal plane */;
float dot = Vector3.Dot(playerForward.normalized, toTarget.normalized);

// Tier 1: On target (dot > 0.93) → fast ticks, 0.12s, 1200 Hz
// Tier 2: Good (dot > 0.7)       → 0.2s, 1000 Hz
// Tier 3: Partial (dot > 0.3)    → 0.5s, 1000 Hz
// Tier 4: Slight (dot > 0)       → 0.9s, 1000 Hz
// Tier 5: Facing away (dot < 0)  → 1.5s, 1000 Hz
```

**Important:** Calculate alignment on the **horizontal plane only**. Players navigate by turning left/right, not by looking up/down.

### Procedural Click Generation

Generate audio clips at runtime instead of shipping sound files:

```csharp
private AudioClip CreateClick(float frequency, float duration)
{
    int sampleRate = 44100;
    int samples = Mathf.RoundToInt(sampleRate * duration);
    float[] data = new float[samples];

    for (int i = 0; i < samples; i++)
    {
        float t = (float)i / sampleRate;
        float envelope = Mathf.Max(0f, 1f - t / duration); // Linear decay
        data[i] = Mathf.Sin(2f * Mathf.PI * frequency * t) * envelope * 0.8f;
    }

    AudioClip clip = AudioClip.Create(
        $"Click_{frequency}Hz", samples, 1, sampleRate, false);
    clip.SetData(data, 0);
    return clip;
}
```

### Arrival Detection

Check arrival on horizontal AND vertical distance separately:

```csharp
private const float ArrivalHorizontal = 1.2f;
private const float ArrivalVertical = 3f;

Vector3 toTarget = targetPos - playerPos;
Vector3 vertical = Vector3.Project(toTarget, playerUp);
Vector3 horizontal = toTarget - vertical;

bool arrived = horizontal.magnitude <= ArrivalHorizontal
            && vertical.magnitude <= ArrivalVertical;
```

---

## Part 3: Auto-Walk

### Waypoint Following

Move the player along the A* path by injecting input toward each waypoint:

```csharp
// Advance waypoint when close enough
while (_waypointIndex < path.Count)
{
    Vector3 toWp = path[_waypointIndex].Position - playerPos;
    Vector3 horizontal = toWp - Vector3.Project(toWp, playerUp);

    if (horizontal.magnitude > WaypointReachDist) // 1.5m
        break;

    _waypointIndex++;
}

// Turn player toward current waypoint
// Inject forward movement input
```

### Stuck Detection

Detect when the player isn't making progress:

```csharp
private const float MoveCheckInterval = 0.5f;
private const float MinMoveDistance = 0.05f;

// Every 0.5s, check if player has moved at least 0.05m
// AND is still on the same waypoint index
if (distanceMoved < MinMoveDistance && sameWaypointIndex)
{
    _stuckCount++;
    if (_stuckCount >= MaxRescans) // e.g., 4
    {
        StopAutoWalk();
        ScreenReader.Say(Loc.Get("autowalk_stuck"));
    }
    else
    {
        // Rescan path from current position
        _path = _scanner.FindPath(playerPos, targetPos);
    }
}
```

### Jump Handling

When a waypoint is marked `NeedsJump`:

```csharp
if (path[_waypointIndex].NeedsJump && IsGrounded())
{
    // Inject jump input for multiple frames (3-4 minimum)
    _jumpFramesRemaining = 4;
}

// In input injection:
if (_jumpFramesRemaining > 0)
{
    InjectJumpInput();
    _jumpFramesRemaining--;
}
```

**Add horizontal boost at jump time** if the game's jump only adds vertical velocity:

```csharp
private const float JumpBoostSpeed = 4f; // m/s

void OnJumpExecuted()
{
    Vector3 forward = GetDirectionToWaypoint();
    playerBody.AddForce(forward * JumpBoostSpeed, ForceMode.VelocityChange);
}
```

### Hazard Detection and Stop

Stop auto-walk when entering dangerous terrain:

```csharp
// Check hazard type when entering a volume
switch (hazardType)
{
    case HazardType.Water:
        if (IsDeepWater())
            StopAutoWalk("Deep water");
        else
            AnnounceOnce("Shallow water");
        break;

    case HazardType.Lava:
    case HazardType.Plasma:
        StopAutoWalk("Dangerous terrain");
        break;
}
```

### Ground Detection

Monitor if the player falls off terrain:

```csharp
if (!IsGrounded())
{
    _airborneTime += Time.deltaTime;
    if (_airborneTime > 3f)
    {
        StopAutoWalk("Airborne too long");
    }
}
else
{
    if (_airborneTime > 0.5f)
    {
        // Just landed — rescan path
        _path = null;
    }
    _airborneTime = 0f;
}
```

---

## Part 4: Navigation Categories

### Organizing Targets

Group scannable objects into categories for manageable browsing:

```csharp
public enum NavCategory
{
    Ship = 0,           // Player's vehicle
    NPCs = 1,           // Characters to talk to
    Interactables = 2,  // Items, switches, doors
    Points = 3,         // Named locations, landmarks
    Signs = 4           // Readable signs, notices
}
```

### Scanning by Distance

Each category has a scan radius:

```csharp
private static readonly float[] ScanRanges = {
    500f,  // Ship — always findable
    100f,  // NPCs
    60f,   // Interactables
    500f,  // Points
    30f    // Signs
};
```

### Category Cycling

Use modifier + PageUp/PageDown to change category, PageUp/PageDown alone to cycle within:

```csharp
// Alt+PageUp/Down → change category
if (altHeld && Input.GetKeyDown(KeyCode.PageUp))
    ChangeCategory(-1);

// PageUp/Down → cycle within category (auto-selects target)
if (Input.GetKeyDown(KeyCode.PageUp))
    CycleTarget(-1);
```

### Auto-Targeting

When the player cycles to a target, it becomes the active target automatically — no separate "select" step needed.

```csharp
private void CycleTarget(int direction)
{
    var list = _categories[(int)_currentCategory];
    if (list.Count == 0) return;

    _currentIndex = (_currentIndex + direction + list.Count) % list.Count;
    _activeTarget = list[_currentIndex];

    ScreenReader.Say(Loc.Get("nav_target",
        _currentIndex + 1, list.Count, _activeTarget.Name));
}
```

---

## Architecture Summary

```
PathScanner        — Terrain scanning + A* pathfinding (pure computation)
    ↓ path
PathGuidanceHandler — 3D audio ticks toward next waypoint
    ↓ waypoints
AutoWalkHandler    — Follows waypoints, injects movement, handles jumps/hazards
    ↑ target
NavigationHandler  — Scans environment, organizes targets by category
```

- **PathScanner** is shared between GuidanceHandler and AutoWalkHandler (single instance, cached results)
- **NavigationHandler** provides the target
- **GuidanceHandler** provides directional audio (can work independently of auto-walk)
- **AutoWalkHandler** provides automated movement (optional — player can walk manually with guidance)

---

## Quick Start

1. Implement PathScanner with your game's physics layer masks
2. Add PathGuidanceHandler with audio ticks — this alone is hugely useful
3. Add NavigationHandler to let players find targets by category
4. Optionally add AutoWalkHandler for fully automated movement
5. Test with headphones (3D audio requires stereo separation)
