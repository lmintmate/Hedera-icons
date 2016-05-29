#!/bin/sh
type trans >/dev/null 2>&1||{ echo >&2 "I require Translate-shell but it's not installed.  Aborting."; exit 1; }

cd 48

_translation=$(trans -b :fr Star)
