"""
CloudMart User Service
Manages user registration, authentication (JWT), and profile management.

Data Store:
  - Default: In-memory dictionary (for local dev / Docker Compose)
  - Cloud:   Set DB_BACKEND=postgres via env var to use managed PostgreSQL
             (RDS / Cloud SQL / Azure Database for PostgreSQL)
"""

import os
import uuid
import json
import logging
import threading
from datetime import datetime, timedelta
from functools import wraps

from flask import Flask, jsonify, request, abort
import bcrypt
import jwt as pyjwt

# ---------------------------------------------------------------------------
# App setup
# ---------------------------------------------------------------------------
app = Flask(__name__)
app.config["JSON_SORT_KEYS"] = False

JWT_SECRET = os.environ.get("JWT_SECRET", "cloudmart-dev-secret-change-in-production")
JWT_EXPIRY_HOURS = int(os.environ.get("JWT_EXPIRY_HOURS", "24"))

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(name)s: %(message)s",
)
logger = logging.getLogger("user-service")

# ---------------------------------------------------------------------------
# In-memory data store
# ---------------------------------------------------------------------------

users_db = {}

# Seed data — password for all seed users is "password123"
_hashed_pw = bcrypt.hashpw(b"password123", bcrypt.gensalt()).decode("utf-8")

SEED_USERS = [
    {
        "id": "user-001",
        "email": "alice@cloudmart.example",
        "name": "Alice Fernando",
        "passwordHash": _hashed_pw,
        "role": "customer",
        "address": "42 Galle Road, Colombo 03, Sri Lanka",
        "createdAt": "2025-01-10T08:00:00Z",
    },
    {
        "id": "user-002",
        "email": "bob@cloudmart.example",
        "name": "Bob Perera",
        "passwordHash": _hashed_pw,
        "role": "customer",
        "address": "15 Kandy Road, Peradeniya, Sri Lanka",
        "createdAt": "2025-01-12T10:00:00Z",
    },
    {
        "id": "user-admin",
        "email": "admin@cloudmart.example",
        "name": "CloudMart Admin",
        "passwordHash": _hashed_pw,
        "role": "admin",
        "address": "",
        "createdAt": "2025-01-01T00:00:00Z",
    },
]

for u in SEED_USERS:
    users_db[u["id"]] = dict(u)

# ---------------------------------------------------------------------------
# Database abstraction (students implement for cloud DB)
# ---------------------------------------------------------------------------


class InMemoryUserStore:
    """In-memory user store for local development."""

    def find_by_email(self, email):
        for user in users_db.values():
            if user["email"] == email:
                return user
        return None

    def find_by_id(self, user_id):
        return users_db.get(user_id)

    def create(self, user_data):
        users_db[user_data["id"]] = user_data
        return user_data

    def update(self, user_id, data):
        user = users_db.get(user_id)
        if not user:
            return None
        for key in ["name", "address", "email"]:
            if key in data:
                user[key] = data[key]
        user["updatedAt"] = datetime.utcnow().isoformat() + "Z"
        return user

    def list_all(self):
        return list(users_db.values())


class PostgresUserStore:
    """
    PostgreSQL adapter using psycopg2.

    Set DB_BACKEND=postgres and either:
      - DATABASE_URL (full connection string), OR
      - DB_HOST, DB_PORT, DB_NAME, DB_USER, DB_PASSWORD

    When running on EKS with IRSA, credentials are fetched automatically
    from AWS Secrets Manager (secret name set via SECRETS_MANAGER_SECRET_NAME).
    """

    def __init__(self):
        import psycopg2
        import psycopg2.extras
        self.psycopg2 = psycopg2
        self.extras = psycopg2.extras
        self.conn = self._connect()
        self._ensure_table()

    def _get_credentials_from_secrets_manager(self):
        """Fetch DB credentials from AWS Secrets Manager via IRSA workload identity."""
        import boto3
        secret_name = os.environ.get("SECRETS_MANAGER_SECRET_NAME")
        if not secret_name:
            return None
        try:
            region = os.environ.get("AWS_REGION", "ap-south-1")
            client = boto3.client("secretsmanager", region_name=region)
            response = client.get_secret_value(SecretId=secret_name)
            return json.loads(response["SecretString"])
        except Exception as e:
            logger.warning(f"Could not fetch credentials from Secrets Manager: {e}")
            return None

    def _connect(self):
        """Build a psycopg2 connection, preferring Secrets Manager over env vars."""
        # Try Secrets Manager first (cloud deployment with IRSA)
        creds = self._get_credentials_from_secrets_manager()
        if creds:
            dsn = (
                f"host={creds['host']} "
                f"port={creds.get('port', 5432)} "
                f"dbname={creds['dbname']} "
                f"user={creds['username']} "
                f"password={creds['password']} "
                f"sslmode=require "  # Assignment: enforce SSL in transit
                f"connect_timeout={os.environ.get('DB_CONNECT_TIMEOUT', '5')}"
            )
        elif os.environ.get("DATABASE_URL"):
            dsn = os.environ["DATABASE_URL"]
        else:
            dsn = (
                f"host={os.environ.get('DB_HOST', 'localhost')} "
                f"port={os.environ.get('DB_PORT', '5432')} "
                f"dbname={os.environ.get('DB_NAME', 'cloudmart')} "
                f"user={os.environ.get('DB_USER', 'cloudmartadmin')} "
                f"password={os.environ.get('DB_PASSWORD', '')} "
                f"sslmode=require "
                f"connect_timeout={os.environ.get('DB_CONNECT_TIMEOUT', '5')}"
            )
        conn = self.psycopg2.connect(dsn)
        conn.autocommit = True
        logger.info("Connected to PostgreSQL")
        return conn

    def _cursor(self):
        """Return a DictCursor, reconnecting if the connection dropped."""
        try:
            self.conn.isolation_level  # Ping
        except Exception:
            logger.warning("PostgreSQL connection lost — reconnecting")
            self.conn = self._connect()
        return self.conn.cursor(cursor_factory=self.extras.RealDictCursor)

    def _ensure_table(self):
        """Create the users table if it doesn't exist yet (idempotent)."""
        with self._cursor() as cur:
            cur.execute("""
                CREATE TABLE IF NOT EXISTS users (
                    id            TEXT PRIMARY KEY,
                    email         TEXT UNIQUE NOT NULL,
                    name          TEXT NOT NULL,
                    "passwordHash" TEXT NOT NULL,
                    role          TEXT NOT NULL DEFAULT 'customer',
                    address       TEXT DEFAULT '',
                    "createdAt"   TEXT NOT NULL,
                    "updatedAt"   TEXT
                )
            """)
            for user in SEED_USERS:
                cur.execute(
                    """
                    INSERT INTO users (id, email, name, "passwordHash", role, address, "createdAt")
                    VALUES (%(id)s, %(email)s, %(name)s, %(passwordHash)s, %(role)s, %(address)s, %(createdAt)s)
                    ON CONFLICT (id) DO NOTHING
                    """,
                    user,
                )
        logger.info("users table ready")

    def find_by_email(self, email):
        with self._cursor() as cur:
            cur.execute("SELECT * FROM users WHERE email = %s", (email,))
            row = cur.fetchone()
            return dict(row) if row else None

    def find_by_id(self, user_id):
        with self._cursor() as cur:
            cur.execute("SELECT * FROM users WHERE id = %s", (user_id,))
            row = cur.fetchone()
            return dict(row) if row else None

    def create(self, user_data):
        with self._cursor() as cur:
            cur.execute(
                """
                INSERT INTO users (id, email, name, "passwordHash", role, address, "createdAt")
                VALUES (%(id)s, %(email)s, %(name)s, %(passwordHash)s, %(role)s, %(address)s, %(createdAt)s)
                RETURNING *
                """,
                user_data,
            )
            return dict(cur.fetchone())

    def update(self, user_id, data):
        fields = {k: data[k] for k in ["name", "address", "email"] if k in data}
        if not fields:
            return self.find_by_id(user_id)
        fields["updatedAt"] = datetime.utcnow().isoformat() + "Z"
        fields["id"] = user_id
        set_clause = ", ".join(
            f'"{k}" = %({k})s' if k in ("updatedAt",) else f"{k} = %({k})s"
            for k in fields if k != "id"
        )
        with self._cursor() as cur:
            cur.execute(
                f'UPDATE users SET {set_clause} WHERE id = %(id)s RETURNING *',
                fields,
            )
            row = cur.fetchone()
            return dict(row) if row else None

    def list_all(self):
        with self._cursor() as cur:
            cur.execute("SELECT * FROM users ORDER BY \"createdAt\"")
            return [dict(r) for r in cur.fetchall()]


def create_user_store():
    backend = os.environ.get("DB_BACKEND", "memory").lower()
    if backend == "postgres":
        return PostgresUserStore()
    else:
        logger.info("Using in-memory user store (set DB_BACKEND=postgres for cloud DB)")
        return InMemoryUserStore()


user_store = None
user_store_lock = threading.Lock()


def get_user_store():
    global user_store
    if user_store is None:
        with user_store_lock:
            if user_store is None:
                user_store = create_user_store()
    return user_store

# ---------------------------------------------------------------------------
# JWT helpers
# ---------------------------------------------------------------------------


def generate_token(user):
    """Generate a JWT token for an authenticated user."""
    payload = {
        "sub": user["id"],
        "email": user["email"],
        "name": user["name"],
        "role": user["role"],
        "iat": datetime.utcnow(),
        "exp": datetime.utcnow() + timedelta(hours=JWT_EXPIRY_HOURS),
    }
    return pyjwt.encode(payload, JWT_SECRET, algorithm="HS256")


def require_auth(f):
    """Decorator to require a valid JWT token."""

    @wraps(f)
    def decorated(*args, **kwargs):
        auth_header = request.headers.get("Authorization", "")
        if not auth_header.startswith("Bearer "):
            return jsonify({"error": "Unauthorized", "message": "Missing or invalid Authorization header"}), 401
        token = auth_header.split(" ", 1)[1]
        try:
            payload = pyjwt.decode(token, JWT_SECRET, algorithms=["HS256"])
            request.user = payload
        except pyjwt.ExpiredSignatureError:
            return jsonify({"error": "Unauthorized", "message": "Token has expired"}), 401
        except pyjwt.InvalidTokenError:
            return jsonify({"error": "Unauthorized", "message": "Invalid token"}), 401
        return f(*args, **kwargs)

    return decorated


def safe_user(user):
    """Return user dict without password hash."""
    return {k: v for k, v in user.items() if k != "passwordHash"}


# ---------------------------------------------------------------------------
# Routes
# ---------------------------------------------------------------------------


@app.route("/health")
def health():
    return jsonify({"status": "healthy", "service": "user-service"})


@app.route("/ready")
def ready():
    if os.environ.get("DB_BACKEND", "memory").lower() == "postgres" and user_store is None:
        return jsonify({"status": "ready", "service": "user-service", "database": "lazy"})
    return jsonify({"status": "ready", "service": "user-service"})


@app.route("/auth/register", methods=["POST"])
def register():
    """Register a new user."""
    data = request.get_json()
    if not data:
        abort(400, description="Request body required")

    email = data.get("email", "").strip().lower()
    password = data.get("password", "")
    name = data.get("name", "")

    if not email or not password or not name:
        abort(400, description="Missing required fields: email, password, name")

    if len(password) < 8:
        abort(400, description="Password must be at least 8 characters")

    # Check if email already exists
    store = get_user_store()

    if store.find_by_email(email):
        abort(409, description=f"Email {email} is already registered")

    # Hash password
    password_hash = bcrypt.hashpw(password.encode("utf-8"), bcrypt.gensalt()).decode("utf-8")

    user = {
        "id": f"user-{uuid.uuid4().hex[:8]}",
        "email": email,
        "name": name,
        "passwordHash": password_hash,
        "role": "customer",
        "address": data.get("address", ""),
        "createdAt": datetime.utcnow().isoformat() + "Z",
    }

    store.create(user)

    # Generate token
    token = generate_token(user)
    logger.info(f"User registered: {user['id']} — {email}")

    return jsonify({"user": safe_user(user), "token": token}), 201


@app.route("/auth/login", methods=["POST"])
def login():
    """Authenticate a user and return a JWT token."""
    data = request.get_json()
    if not data:
        abort(400, description="Request body required")

    email = data.get("email", "").strip().lower()
    password = data.get("password", "")

    if not email or not password:
        abort(400, description="Missing required fields: email, password")

    user = get_user_store().find_by_email(email)
    if not user:
        # Use same error message for security (don't reveal whether email exists)
        return jsonify({"error": "Unauthorized", "message": "Invalid email or password"}), 401

    if not bcrypt.checkpw(password.encode("utf-8"), user["passwordHash"].encode("utf-8")):
        return jsonify({"error": "Unauthorized", "message": "Invalid email or password"}), 401

    token = generate_token(user)
    logger.info(f"User logged in: {user['id']} — {email}")

    return jsonify({"user": safe_user(user), "token": token})


@app.route("/auth/verify", methods=["GET"])
@require_auth
def verify_token():
    """Verify a JWT token and return the user info."""
    return jsonify({"valid": True, "user": request.user})


@app.route("/users/me", methods=["GET"])
@require_auth
def get_my_profile():
    """Get the current user's profile."""
    user = get_user_store().find_by_id(request.user["sub"])
    if not user:
        abort(404, description="User not found")
    return jsonify(safe_user(user))


@app.route("/users/me", methods=["PUT"])
@require_auth
def update_my_profile():
    """Update the current user's profile."""
    data = request.get_json()
    if not data:
        abort(400, description="Request body required")

    user = get_user_store().update(request.user["sub"], data)
    if not user:
        abort(404, description="User not found")

    logger.info(f"User updated profile: {user['id']}")
    return jsonify(safe_user(user))


@app.route("/users/<user_id>", methods=["GET"])
def get_user(user_id):
    """Get a user by ID (public profile info only)."""
    user = get_user_store().find_by_id(user_id)
    if not user:
        abort(404, description=f"User {user_id} not found")
    # Return limited public info
    return jsonify({"id": user["id"], "name": user["name"], "createdAt": user["createdAt"]})


# ---------------------------------------------------------------------------
# Error handlers
# ---------------------------------------------------------------------------


@app.errorhandler(400)
def bad_request(e):
    return jsonify({"error": "Bad Request", "message": str(e.description)}), 400


@app.errorhandler(404)
def not_found(e):
    return jsonify({"error": "Not Found", "message": str(e.description)}), 404


@app.errorhandler(409)
def conflict(e):
    return jsonify({"error": "Conflict", "message": str(e.description)}), 409


@app.errorhandler(500)
def internal_error(e):
    logger.error(f"Internal Server Error: {e}")
    return jsonify({"error": "Internal Server Error"}), 500


# ---------------------------------------------------------------------------
# Entry point
# ---------------------------------------------------------------------------

if __name__ == "__main__":
    port = int(os.environ.get("PORT", 8003))
    debug = os.environ.get("FLASK_DEBUG", "false").lower() == "true"
    logger.info(f"Starting user-service on port {port}")
    app.run(host="0.0.0.0", port=port, debug=debug)
