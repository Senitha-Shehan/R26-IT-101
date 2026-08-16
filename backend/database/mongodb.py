import os
import socket
import sys

# Ensure backend root directory is in sys.path
PROJECT_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
if PROJECT_ROOT not in sys.path:
    sys.path.insert(0, PROJECT_ROOT)

import dns.resolver
from dotenv import load_dotenv
from pymongo import MongoClient

# Fallback DNS resolution for local routers/ISPs that fail SRV/hostname lookups for *.mongodb.net
try:
    _orig_getaddrinfo = socket.getaddrinfo
    _custom_resolver = dns.resolver.Resolver(configure=False)
    _custom_resolver.nameservers = ["8.8.8.8", "1.1.1.1", "8.8.4.4"]

    def _patched_getaddrinfo(host, port, family=0, type=0, proto=0, flags=0):
        try:
            return _orig_getaddrinfo(host, port, family, type, proto, flags)
        except socket.gaierror:
            if isinstance(host, str) and "mongodb.net" in host:
                answers = _custom_resolver.resolve(host, "A")
                if answers:
                    return _orig_getaddrinfo(answers[0].address, port, family, type, proto, flags)
            raise

    socket.getaddrinfo = _patched_getaddrinfo
    dns.resolver.default_resolver = _custom_resolver
except Exception:
    pass

load_dotenv()

MONGODB_URI = os.getenv("MONGODB_URI")
MONGODB_DATABASE = os.getenv("MONGODB_DATABASE", "cropguard")

_client = None


def get_mongo_client(timeout_ms=2000):
    """
    Attempts to connect to MongoDB Atlas with a short timeout.
    Returns MongoClient if online and valid, or None if offline/unreachable.
    """
    global _client
    if not MONGODB_URI:
        return None
    try:
        if _client is None:
            _client = MongoClient(MONGODB_URI, serverSelectionTimeoutMS=timeout_ms)
        _client.admin.command("ping")
        return _client
    except Exception:
        _client = None
        return None


def get_uncertain_collection(timeout_ms=2000):
    """
    Returns the 'uncertain_samples' MongoDB collection if connected, else None.
    """
    client = get_mongo_client(timeout_ms=timeout_ms)
    if client is not None:
        db = client[MONGODB_DATABASE]
        return db["uncertain_samples"]
    return None


def test_connection():
    client = get_mongo_client()
    if client is not None:
        print("MongoDB connection successful!")
        print(f"Database: {MONGODB_DATABASE}")
        print("Collection: uncertain_samples")
    else:
        print("MongoDB connection failed (Offline or MONGODB_URI not reachable).")


if __name__ == "__main__":
    test_connection()