"""
Timestamp utilities for the STEMSight Backend
Handles timezone conversions and datetime formatting
"""

from datetime import datetime, timezone
import pytz
from core.common import logger
from typing import Union


def _to_datetime(value: Union[str, datetime]) -> datetime:
    """Normalize input to a timezone-aware datetime in UTC.

    Accepts either an ISO timestamp string (with or without trailing Z) or a
    datetime object. Returns a timezone-aware datetime in UTC.
    """
    if isinstance(value, datetime):
        dt = value
    elif isinstance(value, str):
        # Accept 'Z' as UTC as produced by many services
        dt = datetime.fromisoformat(value.replace("Z", "+00:00"))
    else:
        raise TypeError("timestamp must be a str or datetime")

    # If naive, assume UTC
    if dt.tzinfo is None:
        dt = dt.replace(tzinfo=timezone.utc)

    # Convert to UTC for internal normalization
    return dt.astimezone(timezone.utc)


def get_current_timestamp() -> str:
    """Get current timestamp in ISO format (UTC)."""
    return datetime.now(timezone.utc).isoformat()


def get_sao_paulo_timestamp() -> str:
    """Get current timestamp in São Paulo timezone as ISO string."""
    sao_paulo_tz = pytz.timezone("America/Sao_Paulo")
    # Start from UTC then convert to target tz to avoid ambiguity
    return datetime.now(timezone.utc).astimezone(sao_paulo_tz).isoformat()


def timestamp_to_sao_paulo(timestamp: Union[str, datetime]) -> str:
    """Convert a timestamp (str or datetime) to São Paulo timezone string.

    Returns the ISO formatted timestamp in São Paulo timezone. If parsing
    fails the original input (string) is returned so callers can handle it.
    """
    try:
        utc_dt = _to_datetime(timestamp)
        sao_paulo_tz = pytz.timezone("America/Sao_Paulo")
        sao_paulo_dt = utc_dt.astimezone(sao_paulo_tz)
        return sao_paulo_dt.isoformat()
    except Exception as e:
        logger.error("Error converting timestamp to São Paulo timezone: %s", e)
        # Return original representation for graceful degradation
        return timestamp if isinstance(timestamp, str) else timestamp.isoformat()


def format_timestamp_for_display(timestamp: Union[str, datetime]) -> str:
    """Format timestamp for display in the UI as 'YYYY-MM-DD HH:MM:SS'.

    Accepts ISO string or datetime. If parsing fails the original input is
    returned to avoid raising inside UI code.
    """
    try:
        dt = _to_datetime(timestamp)
        return dt.strftime("%Y-%m-%d %H:%M:%S")
    except Exception as e:
        logger.error("Error formatting timestamp for display: %s", e)
        return timestamp if isinstance(timestamp, str) else timestamp.isoformat()


def parse_timestamp(timestamp_str: str) -> datetime:
    """Parse ISO timestamp string to a timezone-aware datetime (UTC).

    Raises ValueError for invalid inputs.
    """
    try:
        return _to_datetime(timestamp_str)
    except (ValueError, TypeError) as e:
        logger.error("Error parsing timestamp: %s", e)
        raise ValueError(f"Invalid timestamp format: {timestamp_str}") from e
