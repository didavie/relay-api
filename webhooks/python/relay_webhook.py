"""Verify the X-Relay-Signature header of a Relay webhook (Python 3.8 or later, standard library only).

Header: X-Relay-Signature: t=<unix seconds>,v1=<hex HMAC-SHA256 of "<t>.<raw body>">
Use the raw request body bytes, not a re-serialised JSON object.
"""

from __future__ import annotations

import hashlib
import hmac
import time
from typing import Optional, Union


def verify_relay_signature(
    raw_body: Union[bytes, str],
    header: Optional[str],
    secret: Optional[str],
    tolerance_seconds: int = 300,
    now: Optional[int] = None,
) -> bool:
    """Return True when the signature is valid and not older than ``tolerance_seconds``."""
    if not header or not secret:
        return False
    body = raw_body.encode("utf-8") if isinstance(raw_body, str) else raw_body
    current = int(time.time()) if now is None else int(now)

    timestamp = None
    signatures = []
    for part in header.split(","):
        key, _, value = part.strip().partition("=")
        if key == "t" and value.isdigit():
            timestamp = int(value)
        elif key == "v1" and value:
            signatures.append(value.lower())
    if timestamp is None or not signatures or abs(current - timestamp) > tolerance_seconds:
        return False

    message = str(timestamp).encode("ascii") + b"." + body
    expected = hmac.new(secret.encode("utf-8"), message, hashlib.sha256).hexdigest()
    return any(hmac.compare_digest(expected, sig) for sig in signatures)


# Example with Flask:
#
#   import os
#
#   from flask import Flask, request, abort
#   from relay_webhook import verify_relay_signature
#
#   app = Flask(__name__)
#
#   @app.post("/hooks/relay")
#   def relay_hook():
#       if not verify_relay_signature(request.get_data(), request.headers.get("X-Relay-Signature"),
#                                     os.environ["RELAY_WEBHOOK_SECRET"]):
#           abort(401)
#       event = request.get_json()
#       # Skip event["id"] if you already handled it, then handle event["event"] and event["data"].
#       return "ok"
