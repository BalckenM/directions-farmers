# API Authentication — Super Admin Test Account

This account works against **any environment** (local, staging, production). It is a real `farm_owner` row in the database with all modules activated. There is no mock or demo bypass — every token it produces goes through the same JWT pipeline as any user.

---

## Credentials

| Field    | Value                                            |
| -------- | ------------------------------------------------ |
| Email    | `superadmin@4dfarm.io`                           |
| Password | `4dFarm$Admin2024!`                              |
| Farm ID  | `farm-super-001`                                 |
| Role     | `owner` → promoted to `superAdmin` on `/auth/me` |

---

## Step 1 — Login and get a token

**POST** `/api/v1/auth/login`

### Request

```http
POST https://backendfarmers--directions-payroll.us-east4.hosted.app/api/v1/auth/login
Content-Type: application/json

{
  "email": "superadmin@4dfarm.io",
  "password": "4dFarm$Admin2024!"
}
```

### Response

```json
{
  "data": {
    "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  }
}
```

Copy the `accessToken` value.

---

## Step 2 — Authenticate every subsequent request

Add a single header to **every** request:

```
Authorization: Bearer <accessToken>
```

**Example:**

```http
GET https://backendfarmers--directions-payroll.us-east4.hosted.app/api/v1/auth/me
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

---

## Postman Setup

### Option A — Set the token per-request

1. Select the request → **Authorization** tab
2. Type: `Bearer Token`
3. Token: paste your `accessToken`

### Option B — Collection-level variable (recommended)

1. **Login request** → **Tests** tab → add:
   ```js
   const json = pm.response.json();
   pm.collectionVariables.set("accessToken", json.data.accessToken);
   pm.collectionVariables.set("refreshToken", json.data.refreshToken);
   ```
2. On the **Collection** → **Authorization** tab:
   - Type: `Bearer Token`
   - Token: `{{accessToken}}`
3. Every request in the collection inherits this automatically.

---

## Token Lifespan and Refresh

| Token         | TTL        |
| ------------- | ---------- |
| Access token  | 15 minutes |
| Refresh token | 30 days    |

When the access token expires, call:

**POST** `/api/v1/auth/refresh`

```http
POST /api/v1/auth/refresh
Content-Type: application/json

{
  "refreshToken": "<refreshToken>"
}
```

Returns a new `accessToken` and `refreshToken`.

In Postman, add to the refresh request **Tests** tab:

```js
const json = pm.response.json();
pm.collectionVariables.set("accessToken", json.data.accessToken);
pm.collectionVariables.set("refreshToken", json.data.refreshToken);
```

---

## Apply the seed (first time only)

If the account does not yet exist in a given database, run:

```bash
# from backend/
npm run db:seed
```

The seed is idempotent — safe to run multiple times.

---

## Activated modules

This account has all modules active so no endpoint returns `403 MODULE_NOT_ACTIVE`:

- `mod_cattle`
- `mod_goat`
- `mod_poultry`
- `mod_crop`
- `mod_payroll`
- `mod_financial`

---

## Base URLs

| Environment | Base URL                                                                |
| ----------- | ----------------------------------------------------------------------- |
| Production  | `https://backendfarmers--directions-payroll.us-east4.hosted.app/api/v1` |
| Local       | `http://localhost:8080/api/v1`                                          |
