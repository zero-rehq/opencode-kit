#!/usr/bin/env python3
import argparse
from pathlib import Path

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--template", required=True)
    ap.add_argument("--out", required=True)
    ap.add_argument("--var", action="append", default=[], help="KEY=VALUE")
    args = ap.parse_args()

    text = Path(args.template).read_text(encoding="utf-8")

    vars = {}
    for item in args.var:
        if "=" not in item:
            raise SystemExit(f"Invalid --var {item}. Use KEY=VALUE")
        k, v = item.split("=", 1)
        vars[k] = v

    for k, v in vars.items():
        text = text.replace("{{" + k + "}}", v)

    out = Path(args.out)
    out.parent.mkdir(parents=True, exist_ok=True)
    out.write_text(text, encoding="utf-8")

if __name__ == "__main__":
    main()
