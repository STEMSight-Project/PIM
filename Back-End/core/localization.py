"""Simple localization symbols used across the project.

These are small, stable constants intended for display in logs or simple
UI text. Keep this file minimal to avoid importing heavy i18n libraries in
modules that only need a symbol.
"""

green_check_mark = "✅"
red_cross = "❌"
blue_circle = "🔵"
yellow_circle = "🟡"
red_circle = "🔴"
blue_square = "🟦"

__all__ = [
	"green_check_mark",
	"red_cross",
	"blue_circle",
	"yellow_circle",
	"red_circle",
	"blue_square",
]