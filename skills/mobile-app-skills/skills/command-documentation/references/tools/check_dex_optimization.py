"""Read packaged R8 scores without building, modifying or uploading the AAB."""

import argparse
import hashlib
import json
import math
from pathlib import Path
import sys
import zipfile


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("bundle", type=Path, help="Exact release AAB to inspect")
    args = parser.parse_args()
    try:
        with zipfile.ZipFile(args.bundle) as bundle:
            report = json.loads(bundle.read("BUNDLE-METADATA/com.android.tools/r8.json"))
            dex_bytes = sum(
                entry.file_size for entry in bundle.infolist()
                if entry.filename.endswith(".dex")
            )
        scores = {}
        for category in ("Optimization", "Obfuscation", "Shrinking"):
            disabled = report["stats"][f"no{category}Percentage"]
            if (isinstance(disabled, bool) or not isinstance(disabled, (int, float))
                    or not math.isfinite(disabled) or not 0 <= disabled <= 100):
                raise ValueError(f"Invalid {category} percentage: {disabled!r}")
            scores[category] = 100 - disabled
        for option in ("isOptimizationsEnabled", "isObfuscationEnabled", "isShrinkingEnabled"):
            if report["options"].get(option) is not True:
                raise ValueError(f"R8 option {option} is not enabled")
        digest = hashlib.sha256()
        with args.bundle.open("rb") as source:
            for block in iter(lambda: source.read(1024 * 1024), b""):
                digest.update(block)
        print(f"Bundle: {args.bundle.resolve()}")
        print(f"SHA-256: {digest.hexdigest()}")
        print(f"Uncompressed DEX: {dex_bytes:,} bytes")
        for category, score in scores.items():
            print(f"{category}: {score:.2f}%")
        # This app's reported Play minimum. Compare raw values, not rounding.
        if any(score < 25 for score in scores.values()):
            raise ValueError("At least one packaged score is below 25%")
        print("PASS: all packaged scores meet 25%; runtime/Play checks remain required.")
        return 0
    except (OSError, zipfile.BadZipFile, KeyError, ValueError, TypeError) as error:
        print(f"FAIL: {error}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    sys.exit(main())
