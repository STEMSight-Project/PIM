"""
Timestamp utilities for the STEMSight Backend
Handles timezone conversions and datetime formatting
"""

from datetime import datetime, timezone
import pytz
from core.common import logger


def get_current_timestamp() -> str:
    """
    Get current timestamp in ISO format

    Returns:
        Current timestamp as ISO string
    """
    return datetime.now(timezone.utc).isoformat()


def get_sao_paulo_timestamp() -> str:
    """
    Get current timestamp in São Paulo timezone

    Returns:
        Current timestamp in São Paulo timezone
    """
    sao_paulo_tz = pytz.timezone("America/Sao_Paulo")
    return datetime.now(sao_paulo_tz).isoformat()


def timestamp_to_sao_paulo(timestamp_str: str) -> str:
    """
    Convert UTC timestamp to São Paulo timezone

    Args:
        timestamp_str: UTC timestamp string

    Returns:
        Timestamp converted to São Paulo timezone
    """
    try:
        utc_dt = datetime.fromisoformat(timestamp_str.replace("Z", "+00:00"))
        sao_paulo_tz = pytz.timezone("America/Sao_Paulo")
        sao_paulo_dt = utc_dt.astimezone(sao_paulo_tz)
        return sao_paulo_dt.isoformat()
    except (ValueError, TypeError) as e:
        logger.error("Error converting timestamp to São Paulo timezone: %s", e)
        return timestamp_str


def format_timestamp_for_display(timestamp_str: str) -> str:
    """
    Format timestamp for display in the UI

    Args:
        timestamp_str: ISO timestamp string

    Returns:
        Formatted timestamp string
    """
    try:
        dt = datetime.fromisoformat(timestamp_str.replace("Z", "+00:00"))
        return dt.strftime("%Y-%m-%d %H:%M:%S")
    except (ValueError, TypeError) as e:
        logger.error("Error formatting timestamp for display: %s", e)
        return timestamp_str


def parse_timestamp(timestamp_str: str) -> datetime:
    """
    Parse timestamp string to datetime object

    Args:
        timestamp_str: Timestamp string to parse

    Returns:
        Parsed datetime object
    """
    try:
        return datetime.fromisoformat(timestamp_str.replace("Z", "+00:00"))
    except (ValueError, TypeError) as e:
        logger.error("Error parsing timestamp: %s", e)
        raise ValueError(f"Invalid timestamp format: {timestamp_str}") from e
