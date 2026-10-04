#!/usr/bin/env python3
"""Convert the committed stage list to the official tester's JSON input."""
import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent

def select(path):
    registry = (ROOT / "vendor/redis-tester/internal/tester_definition.go").read_text()
    known = set(re.findall(r'Slug:\s*"([a-z0-9]{3})"', registry))

    stages = []
    for number, line in enumerate(Path(path).read_text().splitlines(), 1):
        slug = line.split("#", 1)[0].strip()
        if not slug:
            continue
        if slug not in known:
            raise ValueError(f"{path}:{number}: unknown CodeCrafters stage {slug!r}")
        if slug in stages:
            raise ValueError(f"{path}:{number}: duplicate stage {slug!r}")
        stages.append(slug)

    if not stages:
        raise ValueError(f"{path}: select at least one stage")

    result = []
    for i, slug in enumerate(stages):
        result.append({
            "slug": slug,
            "tester_log_prefix": f"stage-{i + 1}-{slug}",
            "title": f"Stage {i + 1}: {slug}"
        })
    return result

def main():
    if len(sys.argv) > 1:
        stage_file = sys.argv[1]
    else:
        stage_file = ROOT / "ci/stages.txt"

    stages = select(stage_file)
    output = json.dumps(stages)
    print(output)

if __name__ == "__main__":
    try:
        main()
    except (OSError, ValueError) as error:
        sys.exit(str(error))
