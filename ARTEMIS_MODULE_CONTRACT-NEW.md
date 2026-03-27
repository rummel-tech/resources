# ARTEMIS MODULE CONTRACT
## Version 1.0 — Integration Specification

> This document is the authoritative specification for how any standalone application
> integrates with the Artemis Personal OS platform. Every module MUST implement this
> contract to be Artemis-compatible. Modules that do not implement the contract continue
> to function as fully independent standalone applications — the contract is purely additive.
>
> **Location:** This file should be committed to `rummel-tech/resources` as the platform-wide
> standard, and linked from every module's README.
>
> **Audience:** Developers of standalone modules (workout-planner, meal-planner, home-manager,
> vehicle-manager, etc.) and developers of the Artemis platform itself.

---

## 1. Architecture Overview

The Rummel Tech platform follows a **dual-mode architecture**: every application is designed
to operate as a fully independent product AND as an integrated module within Artemis.

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                          ARTEMIS PLATFORM                                   │
│                                                                             │
│   ┌──────────────┐    ┌──────────────┐    ┌──────────────┐                 │
│   │   Unified    │    │   Shared     │    │  AI Agent    │                 │
│   │  Dashboard   │    │    Auth      │    │   (Voice)    │                 │
│   └──────┬───────┘    └──────┬───────┘    └──────┬───────┘                 │
│          │                   │                   │                         │
│          └───────────────────┼───────────────────┘                         │
│                              │  Artemis Module Contract                    │
│          ┌───────────────────┼───────────────────┐                         │
│          ▼                   ▼                   ▼                         │
│   ┌─────────────┐   ┌─────────────┐   ┌─────────────┐   ┌─────────────┐  │
│   │  workout-   │   │    meal-    │   │   home-     │   │  vehicle-   │  │
│   │  planner   │   │   planner   │   │  manager    │   │   manager   │  │
│   │            │   │             │   │             │   │             │  │
│   │ Standalone │   │ Standalone  │   │ Standalone  │   │ Standalone  │  │
│   │     OR     │   │     OR      │   │     OR      │   │     OR      │  │
│   │  Module ✓  │   │  Module ✓   │   │  Module ✓   │   │  Module ✓   │  │
│   └─────────────┘   └─────────────┘   └─────────────┘   └─────────────┘  │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 2. Contract Requirements

The contract is divided into **Required** (must implement to be Artemis-compatible)
and **Optional** (enhances the integration but not mandatory).

### 2.1 Required Endpoints

Every module backend MUST expose these endpoints at the root level.

#### `GET /health`
Standard liveness probe. Already implemented in all modules.

```json
// Response 200
{
  "status": "healthy",
  "service": "workout-planner",
  "version": "1.2.0",
  "timestamp": "2026-03-25T09:00:00Z"
}
```

#### `GET /ready`
Standard readiness probe. Already implemented in all modules.

```json
// Response 200
{
  "status": "ready",
  "database": "connected",
  "dependencies": {}
}
```

#### `GET /artemis/manifest`
**NEW — Core of the contract.** Returns the module's capability declaration.
Artemis calls this endpoint on startup to discover what the module provides.

```json
// Response 200
{
  "module": {
    "id": "workout-planner",
    "name": "Workout Planner",
    "version": "1.2.0",
    "description": "AI-powered fitness coaching with HealthKit integration",
    "icon": "fitness_center",
    "color": "#34d399",
    "standalone_url": "https://rummel-tech.github.io/workout-planner/",
    "api_base": "https://api.rummeltech.com/workout-planner"
  },
  "capabilities": {
    "auth": {
      "accepts_artemis_token": true,
      "standalone_auth": true
    },
    "dashboard_widgets": [
      {
        "id": "todays_workout",
        "name": "Today's Workout",
        "description": "Shows scheduled workout for today",
        "size": "medium",
        "data_endpoint": "/artemis/widgets/todays_workout",
        "refresh_seconds": 300
      },
      {
        "id": "weekly_progress",
        "name": "Weekly Progress",
        "description": "Workout completion this week",
        "size": "small",
        "data_endpoint": "/artemis/widgets/weekly_progress",
        "refresh_seconds": 3600
      }
    ],
    "quick_actions": [
      {
        "id": "log_workout",
        "label": "Log Workout",
        "icon": "add_circle",
        "endpoint": "/artemis/actions/log_workout",
        "method": "POST"
      },
      {
        "id": "start_workout",
        "label": "Start Today's Workout",
        "icon": "play_arrow",
        "endpoint": "/artemis/actions/start_workout",
        "method": "POST"
      }
    ],
    "provides_data": [
      {
        "id": "calories_burned",
        "name": "Daily Calories Burned",
        "description": "Calories burned per day from workouts",
        "endpoint": "/artemis/data/calories_burned",
        "schema": {
          "date": "string (ISO date)",
          "calories": "number",
          "workout_type": "string",
          "duration_minutes": "number"
        },
        "requires_permission": "fitness.calories.read"
      },
      {
        "id": "readiness_score",
        "name": "Readiness Score",
        "description": "Daily readiness score based on sleep and recovery",
        "endpoint": "/artemis/data/readiness_score",
        "schema": {
          "date": "string",
          "score": "number (0-100)",
          "factors": "object"
        },
        "requires_permission": "fitness.readiness.read"
      },
      {
        "id": "workout_schedule",
        "name": "Workout Schedule",
        "description": "Upcoming scheduled workouts",
        "endpoint": "/artemis/data/workout_schedule",
        "schema": {
          "workouts": "array",
          "date_range": "object"
        },
        "requires_permission": "fitness.schedule.read"
      }
    ],
    "consumes_data": [
      {
        "id": "nutrition_calories",
        "provider_module": "meal-planner",
        "data_id": "daily_calories",
        "use_case": "Adjust calorie burn targets based on intake",
        "required": false
      }
    ],
    "agent_tools": [
      {
        "id": "get_todays_workout",
        "description": "Get the user's scheduled workout for today or a specific date",
        "endpoint": "/artemis/agent/get_todays_workout",
        "method": "GET",
        "parameters": {
          "date": { "type": "string", "description": "ISO date, defaults to today", "required": false }
        }
      },
      {
        "id": "log_workout",
        "description": "Log a completed workout",
        "endpoint": "/artemis/agent/log_workout",
        "method": "POST",
        "parameters": {
          "type": { "type": "string", "description": "Workout type (strength, run, yoga, etc.)", "required": true },
          "duration_minutes": { "type": "number", "required": true },
          "notes": { "type": "string", "required": false }
        }
      },
      {
        "id": "schedule_workout",
        "description": "Schedule a workout for a specific date and time",
        "endpoint": "/artemis/agent/schedule_workout",
        "method": "POST",
        "parameters": {
          "type": { "type": "string", "required": true },
          "datetime": { "type": "string", "description": "ISO datetime or natural language", "required": true },
          "duration_minutes": { "type": "number", "required": false }
        }
      },
      {
        "id": "get_weekly_summary",
        "description": "Get a summary of workouts and progress for the current or specified week",
        "endpoint": "/artemis/agent/get_weekly_summary",
        "method": "GET",
        "parameters": {
          "week_start": { "type": "string", "description": "ISO date of week start", "required": false }
        }
      }
    ]
  }
}
```

#### `GET /artemis/widgets/{widget_id}`
Returns live data for a specific dashboard widget.
Called by Artemis to hydrate dashboard cards.

```json
// GET /artemis/widgets/todays_workout
// Headers: Authorization: Bearer <artemis_token>
// Response 200
{
  "widget_id": "todays_workout",
  "data": {
    "has_workout": true,
    "workout": {
      "title": "Upper Body Strength",
      "scheduled_time": "07:00",
      "duration_minutes": 60,
      "status": "scheduled"
    }
  },
  "last_updated": "2026-03-25T06:00:00Z"
}
```

#### `POST /artemis/agent/{tool_id}`
Executes an agent tool. Called by the Artemis AI agent when Claude invokes a module tool.
Parameters are passed as JSON body.

```json
// POST /artemis/agent/schedule_workout
// Headers: Authorization: Bearer <artemis_token>
// Body:
{
  "type": "strength",
  "datetime": "2026-03-26T07:00:00Z",
  "duration_minutes": 60
}
// Response 200
{
  "success": true,
  "result": {
    "workout_id": "wk_abc123",
    "title": "Strength Training",
    "scheduled_for": "2026-03-26T07:00:00Z"
  },
  "message": "Workout scheduled for tomorrow at 7:00 AM"
}
```

#### `GET /artemis/data/{data_id}`
Returns cross-module data for consumption by other modules or Artemis.
Only accessible with appropriate permission grant.

```json
// GET /artemis/data/calories_burned?date=2026-03-25
// Headers: Authorization: Bearer <artemis_token>
//          X-Artemis-Consumer: meal-planner
//          X-Artemis-Permission: fitness.calories.read
// Response 200
{
  "data_id": "calories_burned",
  "data": {
    "date": "2026-03-25",
    "calories": 420,
    "workout_type": "strength",
    "duration_minutes": 60
  }
}
```

---

### 2.2 Authentication Contract

Artemis uses a **shared JWT** issued by a central auth service. All modules must accept
this token in addition to their own standalone auth.

#### Token Format

```json
// JWT Payload
{
  "sub": "user_abc123",         // User ID (consistent across all modules)
  "email": "user@example.com",
  "name": "Shawn",
  "iss": "artemis-auth",        // Issuer — identifies as Artemis platform token
  "iat": 1711360800,
  "exp": 1711447200,
  "modules": ["workout-planner", "meal-planner", "home-manager"],  // Enabled modules
  "permissions": [              // Granted cross-module data permissions
    "fitness.calories.read",
    "nutrition.intake.read"
  ]
}
```

#### Module Auth Behaviour

```
Standalone mode:  Module issues and validates its own tokens (unchanged)
Artemis mode:     Module ALSO accepts tokens where iss == "artemis-auth"
                  and validates against the shared public key
```

Modules should check `iss` to determine token type. Shared public key is distributed
via `GET /artemis/auth/public-key` on the Artemis auth service.

---

### 2.3 Port & URL Conventions

#### Local Development
| Module | Port |
|--------|------|
| workout-planner | 8000 |
| meal-planner | 8010 |
| home-manager | 8020 |
| vehicle-manager | 8030 |
| artemis (platform) | 8080 |
| artemis-auth | 8090 |
| *(next module)* | 8040 |

#### Production URL Pattern
All production APIs follow the pattern:
```
https://api.rummeltech.com/{module-name}/
```
e.g. `https://api.rummeltech.com/workout-planner/artemis/manifest`

The Artemis platform itself lives at `https://artemis.rummeltech.com`

---

## 3. Optional Enhancements

These endpoints further enrich the Artemis integration but are not required for basic compatibility.

### `GET /artemis/notifications`
Returns pending notifications for the user from this module.

```json
{
  "notifications": [
    {
      "id": "notif_xyz",
      "type": "workout_reminder",
      "title": "Workout in 15 minutes",
      "body": "Upper Body Strength starts at 7:00 AM",
      "priority": "high",
      "actions": [
        { "id": "dismiss", "label": "Dismiss" },
        { "id": "snooze", "label": "Snooze 10 min" }
      ],
      "created_at": "2026-03-25T06:45:00Z"
    }
  ]
}
```

### `POST /artemis/notifications/{id}/action`
Executes a notification action (dismiss, snooze, etc.)

### `GET /artemis/summary`
Returns a natural language daily summary for this module.
Used by the Artemis AI agent for morning briefings.

```json
{
  "summary": "You have a 60-minute upper body strength session at 7 AM. Your readiness score is 78 — good to train hard today.",
  "data_points": {
    "todays_workouts": 1,
    "readiness_score": 78,
    "weekly_completion": "3/5 workouts done"
  }
}
```

### `GET /artemis/calendar`
Returns scheduled activities in a unified calendar format.
Allows Artemis to render a cross-module activity calendar.

```json
{
  "events": [
    {
      "id": "wk_abc123",
      "title": "Upper Body Strength",
      "start": "2026-03-25T07:00:00Z",
      "end": "2026-03-25T08:00:00Z",
      "type": "workout",
      "color": "#34d399",
      "module": "workout-planner",
      "status": "scheduled"
    }
  ]
}
```

---

## 4. Module Manifest Registration

When Artemis starts, it discovers modules by polling known manifest endpoints.
The module registry is configured in `artemis/config/modules.yaml`:

```yaml
modules:
  - id: workout-planner
    manifest_url: http://localhost:8000/artemis/manifest      # dev
    prod_manifest_url: https://api.rummeltech.com/workout-planner/artemis/manifest
    enabled: true

  - id: meal-planner
    manifest_url: http://localhost:8010/artemis/manifest
    prod_manifest_url: https://api.rummeltech.com/meal-planner/artemis/manifest
    enabled: true

  - id: home-manager
    manifest_url: http://localhost:8020/artemis/manifest
    prod_manifest_url: https://api.rummeltech.com/home-manager/artemis/manifest
    enabled: true

  - id: vehicle-manager
    manifest_url: http://localhost:8030/artemis/manifest
    prod_manifest_url: https://api.rummeltech.com/vehicle-manager/artemis/manifest
    enabled: true
```

---

## 5. Implementation Guide — Adding Contract Endpoints to an Existing Module

This section is a step-by-step guide for making an existing module Artemis-compatible.
Use workout-planner as the reference implementation.

### Step 1: Add the `/artemis` router

In `backend/main.py` (or your FastAPI app file):

```python
from fastapi import APIRouter, Depends, Header
from .artemis import router as artemis_router

app.include_router(artemis_router, prefix="/artemis", tags=["artemis"])
```

### Step 2: Create `backend/artemis.py`

```python
from fastapi import APIRouter, HTTPException, Header
from typing import Optional
import jwt

router = APIRouter()

MODULE_MANIFEST = {
    "module": {
        "id": "workout-planner",
        "name": "Workout Planner",
        "version": "1.2.0",
        # ... full manifest
    },
    "capabilities": {
        # ... capabilities
    }
}

@router.get("/manifest")
async def get_manifest():
    return MODULE_MANIFEST

@router.get("/widgets/{widget_id}")
async def get_widget_data(widget_id: str, authorization: Optional[str] = Header(None)):
    token = validate_artemis_token(authorization)
    # Return widget data based on widget_id
    ...

@router.post("/agent/{tool_id}")
async def execute_agent_tool(tool_id: str, body: dict, authorization: Optional[str] = Header(None)):
    token = validate_artemis_token(authorization)
    # Execute tool based on tool_id
    ...

@router.get("/data/{data_id}")
async def get_shared_data(data_id: str, authorization: Optional[str] = Header(None)):
    token = validate_artemis_token(authorization)
    # Return data based on data_id, check permissions
    ...

def validate_artemis_token(authorization: Optional[str]) -> dict:
    """Accept both standalone tokens and Artemis platform tokens."""
    if not authorization or not authorization.startswith("Bearer "):
        raise HTTPException(status_code=401, detail="Missing token")
    token = authorization.split(" ")[1]
    try:
        payload = jwt.decode(token, options={"verify_signature": False})  # verify properly in prod
        return payload
    except Exception:
        raise HTTPException(status_code=401, detail="Invalid token")
```

### Step 3: Update your module's README

Add the Artemis badge and compatibility section:

```markdown
## Artemis Integration

This application is Artemis-compatible. It can be used as a standalone application
or integrated into the Artemis Personal OS platform.

- **Manifest endpoint**: `GET /artemis/manifest`
- **Artemis contract version**: 1.0
- **Data provided**: Calories burned, readiness score, workout schedule
- **Data consumed**: Nutrition calorie intake (optional)

[View Artemis Integration Contract](https://github.com/rummel-tech/resources/blob/main/ARTEMIS_MODULE_CONTRACT.md)
```

---

## 6. Current Module Status

| Module | Contract Status | Manifest | Widgets | Agent Tools | Auth | Cross-Module Data |
|--------|----------------|----------|---------|-------------|------|-------------------|
| workout-planner | 🔴 Not started | ❌ | ❌ | ❌ | ✅ (own auth) | ❌ |
| meal-planner | 🔴 Not started | ❌ | ❌ | ❌ | ❌ | ❌ |
| home-manager | 🔴 Not started | ❌ | ❌ | ❌ | ❌ | ❌ |
| vehicle-manager | 🔴 Not started | ❌ | ❌ | ❌ | ❌ | ❌ |
| artemis (platform) | 🔴 Not started | N/A | N/A | N/A | ❌ | N/A |

*This table should be updated as modules implement the contract.*

---

## 7. Cross-Module Data Registry

This is the authoritative list of data that modules expose and consume.
Update this when adding new `provides_data` or `consumes_data` declarations.

| Provider | Data ID | Description | Consumers |
|----------|---------|-------------|-----------|
| workout-planner | `calories_burned` | Daily calories burned from workouts | meal-planner |
| workout-planner | `readiness_score` | Daily readiness score | artemis-agent |
| workout-planner | `workout_schedule` | Upcoming scheduled workouts | artemis-agent, artemis-calendar |
| meal-planner | `daily_calories` | Daily calorie intake | workout-planner |
| meal-planner | `macros` | Daily macro breakdown | artemis-agent |
| meal-planner | `meal_schedule` | Upcoming planned meals | artemis-calendar |
| home-manager | `task_schedule` | Upcoming home tasks | artemis-calendar |
| home-manager | `goals_progress` | Home goal completion rates | artemis-agent |
| vehicle-manager | `maintenance_schedule` | Upcoming vehicle maintenance | artemis-calendar |
| vehicle-manager | `vehicle_summary` | Fleet overview | artemis-agent |

---

## 8. Permissions Model

Cross-module data access requires explicit user consent. Permission IDs follow this pattern:

```
{module}.{resource}.{action}

Examples:
  fitness.calories.read
  nutrition.intake.read
  home.tasks.read
  vehicle.schedule.read
```

Permissions are stored in the Artemis auth token and checked by each module
in the `X-Artemis-Permission` header on `/artemis/data/` requests.

---

## 9. Versioning

This contract follows semantic versioning. Breaking changes increment the major version.

- **v1.0** — Initial contract: manifest, widgets, agent tools, shared auth
- Future minor versions add optional endpoints
- Modules declare which contract version they implement in the manifest: `"contract_version": "1.0"`

---

## 10. Security Considerations

- All `/artemis/*` endpoints require a valid token (Artemis or standalone)
- Cross-module data endpoints additionally require the `X-Artemis-Permission` header
- The Artemis platform never stores cross-module data — it passes it through in real-time
- Users can revoke cross-module permissions at any time via the Artemis settings screen
- No module should expose data to Artemis that users haven't explicitly opted into

---

*This contract is maintained in `rummel-tech/resources`. Raise a PR against this file
to propose changes. All module owners should be reviewers.*
