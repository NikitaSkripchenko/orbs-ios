#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/../.."
build_dir="$(mktemp -d /private/tmp/thinking-orbs-social.XXXXXX)"
trap 'rm -rf "$build_dir"' EXIT
cp media/social/render.swift "$build_dir/main.swift"
swiftc -O -module-cache-path "$build_dir/cache" \
  Sources/ThinkingOrbsKit/Engine/*.swift \
  Sources/ThinkingOrbsKit/Generated/OrbSpec.swift \
  Sources/ThinkingOrbsKit/OrbState.swift Sources/ThinkingOrbsKit/OrbSize.swift \
  Sources/ThinkingOrbsKit/ThinkingOrb.swift "$build_dir/main.swift" \
  -o "$build_dir/render"
for variant in noir editorial pulse; do
  "$build_dir/render" "$variant" media/social "$@"
done
