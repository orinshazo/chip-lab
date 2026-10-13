#!/usr/bin/env python3
"""Regression runner for chip-lab.

Runs `make test` for every project under projects/ (skipping ones marked with a
`.wip` file), optionally over several random seeds, and prints a summary.

    scripts/regress.py                    # all projects, 1 random seed each
    scripts/regress.py --seeds 5          # 5 random seeds per project
    scripts/regress.py --seed 1234 p00    # reproduce one seed on matching projects
    scripts/regress.py --include-wip      # also run work-in-progress projects

Exit code is non-zero if anything failed, so CI can gate on it.
Phase 2 of ROADMAP.md asks you to extend this (parallel jobs, reports).
"""

from __future__ import annotations

import argparse
import random
import subprocess
import sys
import time
import xml.etree.ElementTree as ET
from dataclasses import dataclass
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parent.parent
PROJECTS_DIR = REPO_ROOT / "projects"
LOG_DIR = REPO_ROOT / "build" / "regress"


@dataclass
class Result:
    project: str
    seed: int
    passed: bool
    seconds: float
    tests: int
    failures: int
    log: Path


def discover(filters: list[str], include_wip: bool) -> list[Path]:
    projects = []
    for path in sorted(PROJECTS_DIR.iterdir()):
        if not (path / "Makefile").is_file():
            continue
        if (path / ".wip").exists() and not include_wip:
            continue
        if filters and not any(f in path.name for f in filters):
            continue
        projects.append(path)
    return projects


def count_cocotb_results(project: Path) -> tuple[int, int]:
    results = project / "build" / "results.xml"
    if not results.is_file():
        return 0, 0
    cases = ET.parse(results).getroot().iter("testcase")
    tests = failures = 0
    for case in cases:
        tests += 1
        failures += int(case.find("failure") is not None or case.find("error") is not None)
    return tests, failures


def run_one(project: Path, seed: int) -> Result:
    LOG_DIR.mkdir(parents=True, exist_ok=True)
    log = LOG_DIR / f"{project.name}.seed{seed}.log"
    start = time.monotonic()
    subprocess.run(["make", "-C", str(project), "clean"], capture_output=True, check=False)
    with log.open("w") as fh:
        proc = subprocess.run(
            ["make", "-C", str(project), "test", f"SEED={seed}"],
            stdout=fh, stderr=subprocess.STDOUT, check=False,
        )
    tests, failures = count_cocotb_results(project)
    return Result(project.name, seed, proc.returncode == 0, time.monotonic() - start,
                  tests, failures, log)


def print_summary(results: list[Result]) -> None:
    width = max([len(r.project) for r in results] + [7])
    print(f"\n{'PROJECT':<{width}}  {'SEED':>10}  {'COCOTB':>7}  {'TIME':>7}  STATUS")
    print("-" * (width + 40))
    for r in results:
        status = "PASS" if r.passed else f"FAIL  -> {r.log.relative_to(REPO_ROOT)}"
        cocotb = f"{r.tests - r.failures}/{r.tests}" if r.tests else "-"
        print(f"{r.project:<{width}}  {r.seed:>10}  {cocotb:>7}  {r.seconds:>6.1f}s  {status}")
    failed = sum(not r.passed for r in results)
    print("-" * (width + 40))
    print(f"{len(results)} run(s), {failed} failed")


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("filters", nargs="*", help="substring(s) of project names to run")
    seeds = parser.add_mutually_exclusive_group()
    seeds.add_argument("--seeds", type=int, default=1, help="random seeds per project")
    seeds.add_argument("--seed", type=int, help="run exactly this seed")
    parser.add_argument("--include-wip", action="store_true", help="also run projects with a .wip marker")
    args = parser.parse_args()

    projects = discover(args.filters, args.include_wip)
    if not projects:
        print("no projects matched", file=sys.stderr)
        return 2

    seed_list = [args.seed] if args.seed is not None else [
        random.randrange(1, 2**31) for _ in range(args.seeds)
    ]
    results = []
    for project in projects:
        for seed in seed_list:
            print(f"running {project.name} seed={seed} ...", flush=True)
            results.append(run_one(project, seed))

    print_summary(results)
    return 0 if all(r.passed for r in results) else 1


if __name__ == "__main__":
    sys.exit(main())
