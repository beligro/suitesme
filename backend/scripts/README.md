# Database Seed Script

## Creating Test User

This script creates or updates a verified test user for debugging purposes.

### Test User Credentials
- **Email**: `test@example.com`
- **Password**: `test!Test`
- **Status**: Verified (no email verification needed)

### Running the Script

The script needs database connection parameters. You can provide them via environment variables or it will use defaults.

#### Option 1: Using Environment Variables (Recommended)

```bash
cd backend/scripts
export DB_HOST=localhost
export DB_PORT=5433          # Docker exposes postgres on 5433
export DB_USER=postgres
export DB_PASSWORD=your_password_here
export DB_NAME=suitesme
go run create_test_user.go
```

#### Option 2: Using .env file from project root

If you have a `.env` file in the project root, you can source it:

```bash
cd backend/scripts
source ../../.env
go run create_test_user.go
```

#### Option 3: Default values (if they match your setup)

```bash
cd backend/scripts
go run create_test_user.go
```

Defaults:
- Host: `localhost`
- Port: `5433` (Docker port mapping)
- User: `postgres`
- Password: `postgres`
- Database: `suitesme`

### Running via Docker

If you want to run the script inside the backend container:

```bash
docker compose exec backend go run /path/to/create_test_user.go
```

Or copy the script into the container and run it there where it can access the database directly via the service name.

