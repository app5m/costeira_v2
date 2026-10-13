#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

flutter run -d chrome --web-hostname localhost --web-port 3000
