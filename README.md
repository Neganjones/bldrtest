# Deep Sea Fishing System

A comprehensive deep sea fishing resource for FiveM servers featuring cage placement, depth-based fishing, and dynamic minigames.

## Features

- **Cage Placement System**: Place up to 3 fishing cages simultaneously with real-time depth detection
- **Depth Tiers**: Four depth zones (shallow, medium, deep, very deep) with different fish spawns
- **Dynamic Rewards**: 3x multiplier at greater depths with rarity-based catch amounts
- **ox_lib Integration**: Beautiful menus, skill checks, and notifications
- **Minigame Variety**: Extensible minigame system with difficulty scaling
- **QBCore Support**: Full inventory and job integration
- **Server Validation**: Secure reward distribution with anti-exploit measures

## Installation

1. Extract to your resources folder as `deep-sea-fishing`
2. Ensure dependencies are running: `ox_lib`, `qb-core`
3. Add to `server.cfg`:
   ```
   ensure ox_lib
   ensure qb-core
   ensure deep-sea-fishing
   ```

## Configuration

Edit `shared/config.lua` to customize:

```lua
Config = {
    DEBUG = true,  -- Enable debug logging
    MAX_CAGES = 3, -- Maximum cages per player
    CAGE_MODEL = 'prop_crate_01a', -- Cage prop model
    MINIGAME = 'skillcheck', -- 'skillcheck', 'buttonmash', 'reaction', 'prompt', 'disabled'
}
```

## Item Usage

### Fishing Cage Item
Use the **fishing_cage** item from your inventory to begin setting up:

1. Open your inventory
2. Use the **Fishing Cage** item
3. Select desired depth from menu (Shallow, Medium, Deep, Very Deep)
4. Cage will be placed in water ahead of your position

**Item Names for Admin/Database:**
- `fishing_cage` - Base fishing cage item

## Fish Database

All fish are depth-specific with rarity tiers determining catch amounts and prices.

### Shallow Water Fish (0-10m)
| Fish | Rarity | Catch | Price | Notes |
|------|--------|-------|-------|-------|
| **Herring** | Common | 3-5 | $35 | Most abundant shallow fish |
| **Mackerel** | Common | 2-4 | $45 | Good starter catch |
| **Sea Bass** | Uncommon | 1-3 | $65 | Decent value fish |
| **Mullet** | Uncommon | 2-3 | $55 | Fairly common |

### Medium Depth Fish (10-50m)
| Fish | Rarity | Catch | Price | Notes |
|------|--------|-------|-------|-------|
| **Cod** | Uncommon | 2-4 | $85 | Standard medium fish |
| **Haddock** | Uncommon | 1-3 | $75 | Good profit |
| **Pollock** | Rare | 1-2 | $120 | More valuable |
| **Crab** | Rare | 1-2 | $95 | Specialty catch |

### Deep Water Fish (50-150m)
| Fish | Rarity | Catch | Price | Notes |
|------|--------|-------|-------|-------|
| **Lobster** | Rare | 1-2 | $180 | Prized deep-sea catch |
| **Shrimp** | Rare | 2-4 | $150 | Higher quantity |
| **Clam** | Rare | 2-3 | $160 | Shell specialty |
| **Oyster** | Epic | 1-2 | $250 | Rare, valuable |
| **Halibut** | Epic | 1-2 | $200 | Premium fish |

### Very Deep Water Fish (150m+)
| Fish | Rarity | Catch | Price | Notes |
|------|--------|-------|-------|-------|
| **Anglerfish** | Epic | 1-2 | $300 | Bioluminescent deep-sea fish |
| **Grouper** | Legendary | 1 | $500 | Extremely rare, maximum value |
| **Tuna** | Epic | 1-2 | $280 | Large deep-sea predator |
| **Swordfish** | Legendary | 1 | $450 | Elusive and valuable |

## Rarity Tiers

- **Common** (40% chance): 3-5 fish per catch
- **Uncommon** (30% chance): 2-3 fish per catch
- **Rare** (20% chance): 1-2 fish per catch
- **Epic** (8% chance): 1-2 fish per catch
- **Legendary** (2% chance): 1 fish per catch

## Depth Mechanics

Depth is automatically detected based on your cage's position in the water. Better fish require proper depth placement:

- **Shallow (0-10m)**: Easy catches, low value
- **Medium (10-50m)**: Standard fish, moderate value
- **Deep (50-150m)**: Premium catches, high value (2x multiplier)
- **Very Deep (150m+)**: Legendary fish, maximum value (3x multiplier)

### Depth Multiplier
- Shallow: 1x
- Medium: 1.5x
- Deep: 2x
- Very Deep: 3x

## Minigames

### Skill Check (Default)
Press the required key combinations to land the catch. Difficulty scales with depth:

- **Shallow**: Easy (simple key press)
- **Medium**: Medium (2-3 keys)
- **Deep**: Hard (3-5 keys)
- **Very Deep**: Very Hard (4-6 keys)

### Button Mash
Rapidly press keys to fill a meter before time runs out. Depth determines time limit.

### Reaction Time
React quickly when the prompt appears. Slower reaction = lower catch bonus.

### Prompt
Complete custom prompts (e.g., "Match the color" or "Remember the sequence").

### Disabled
Skip minigames entirely for instant catches at base rewards.

## Rewards

### Success Bonuses
- **Perfect Catch** (Skillcheck with 100% accuracy): +50% reward
- **Good Catch** (80%+ accuracy): +25% reward
- **Standard Catch**: Base reward

### Catch Formula
```
Final Reward = Base Price × Fish Count × Depth Multiplier × Success Bonus × Rarity Bonus
```

**Example - Very Deep Lobster with Perfect Catch:**
- Base Price: $180
- Fish Count: 2
- Depth Multiplier: 3x
- Success Bonus: 1.5x (perfect catch)
- Total: $180 × 2 × 3 × 1.5 = **$1,620**

## Usage Guide

### Basic Fishing Session

1. **Get in a Boat**
   - Navigate to a boat on shore or spawn one
   - Get in the boat before attempting to place a cage
   - You must be in a boat to use fishing cages

2. **Use Fishing Cage Item**
   - Open inventory while in the boat
   - Find the Fishing Cage item
   - Use it to open the depth selection menu
   - Choose your desired depth (e.g., Deep for best rewards)

3. **Approach & Interact**
   - Stay in/near your boat
   - Approach the placed cage (within 50 meters)
   - Press **E** to open the fishing menu

4. **Cast Line**
    - Select "Cast Fishing Line" from menu
    - Prepare for minigame

5. **Complete Minigame**
    - Follow on-screen prompts
    - Higher success = bigger rewards

6. **Collect Rewards**
    - Fish items added to inventory
    - Cash automatically deposited
    - Notification shows total earnings

### Multiple Cages

You can place up to 3 cages simultaneously while in a boat:

1. Use first Fishing Cage item → Select Shallow depth
2. Use second Fishing Cage item → Select Medium depth
3. Use third Fishing Cage item → Select Deep depth

Rotate between them for variety and maximum earnings. Each cage operates independently. You must remain in or near your boat for all fishing activities.

## Inventory Integration

Caught fish are stored as QBCore items. Each fish type can be:

- **Sold** to fishing vendors
- **Processed** at canneries (requires custom scripts)
- **Delivered** for job missions
- **Traded** with other players

## Server Validation

All rewards are validated server-side:

- Catch amounts verified against fish database
- Depth position authenticated
- Player inventory checked before rewards
- Exploit protection for rapid catches
- Automatic cleanup on player disconnect

## Events

### Server Events

```lua
-- Triggered when player catches fish
TriggerEvent('deepfishing:server:CatchFish', {
    playerId = source,
    fishType = 'lobster',
    quantity = 2,
    depth = 'deep',
    reward = 500
})
```

### Client Events

```lua
-- Triggered on successful catch
TriggerEvent('deepfishing:client:CatchSuccess', {
    fish = 'lobster',
    quantity = 2,
    reward = 500
})

-- Triggered on failed minigame
TriggerEvent('deepfishing:client:CatchFailed', {})
```

## Exports

```lua
-- Get all active cages for current player
local cages = exports['deep-sea-fishing']:GetPlayerCages()

-- Get specific cage info
local cageInfo = exports['deep-sea-fishing']:GetCageInfo(cageId)

-- Get fish available at depth
local fish = exports['deep-sea-fishing']:GetFishAtDepth('deep')
```

## Troubleshooting

### Cages not placing
- **Make sure you're in a boat** - this is required!
- Check water level in location
- Verify you have the Fishing Cage item in inventory
- Verify prop model exists (`prop_crate_01a`)

### Fish not catching
- Verify minigame is completing successfully
- Check QBCore inventory has space
- Look at server console for validation errors

### No notifications showing
- Ensure ox_lib is running and loaded
- Check client console for JS errors
- Verify notification config in shared/config.lua

### Depth not detecting correctly
- Confirm water raycasting is enabled
- Check if location has water collisions
- Try different placement coordinates

## Performance

- Optimized with zone-based caching
- Minimal server load (event-driven)
- Client-side depth calculations
- Proper cleanup on resource stop

## Support

For issues or feature requests, check:

- Server console for error messages
- Enable DEBUG = true in config.lua
- Verify all dependencies are running
- Check that QBCore is properly initialized

## License

This resource is provided as-is for FiveM servers.
