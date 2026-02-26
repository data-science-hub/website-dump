#!/usr/bin/env bash
# crawl.sh — Mirror https://datasciencehub.net/ recursively using wget
#
# Usage:
#   ./crawl.sh            # full crawl (default)
#   ./crawl.sh --resume   # resume a previously interrupted crawl
#   ./crawl.sh --dry-run  # print wget command without executing

set -euo pipefail

TARGET_URL="https://datasciencehub.net/"
OUTPUT_DIR="./site"
LOG_FILE="./crawl.log"
WAIT_SECONDS=1        # polite delay between requests
RANDOM_WAIT=1         # add up to WAIT_SECONDS of random extra delay
MAX_RETRIES=5

DRY_RUN=0
RESUME=0

for arg in "$@"; do
  case "$arg" in
    --dry-run)  DRY_RUN=1 ;;
    --resume)   RESUME=1 ;;
    *)
      echo "Unknown option: $arg"
      echo "Usage: $0 [--resume] [--dry-run]"
      exit 1
      ;;
  esac
done

WGET_OPTS=(
  # --- mirroring ---
  --mirror                  # recursive + timestamping + infinite depth + no clobber
  --page-requisites         # fetch CSS, JS, images needed to render each page
  --convert-links           # rewrite links so the local copy is browsable offline
  --adjust-extension        # save .html extension where missing
  --no-parent               # never ascend above TARGET_URL

  # --- output ---
  --directory-prefix="$OUTPUT_DIR"

  # --- politeness ---
  --wait="$WAIT_SECONDS"
  --random-wait             # vary delay by 0.5x–1.5x WAIT_SECONDS
  --limit-rate=500k         # cap bandwidth per request

  # --- robustness ---
  --tries="$MAX_RETRIES"
  --timeout=30
  --read-timeout=60
  --retry-connrefused

  # --- identity ---
  --user-agent="Mozilla/5.0 (compatible; site-archiver/1.0)"

  # --- logging ---
  --append-output="$LOG_FILE"
  --show-progress
)

# Resume: skip files already fully downloaded
if [[ "$RESUME" -eq 1 ]]; then
  WGET_OPTS+=(--continue --no-clobber)
else
  WGET_OPTS+=(--timestamping)
fi

CMD=(wget "${WGET_OPTS[@]}" "$TARGET_URL")

echo "Target : $TARGET_URL"
echo "Output : $OUTPUT_DIR"
echo "Log    : $LOG_FILE"
echo ""

if [[ "$DRY_RUN" -eq 1 ]]; then
  echo "[dry-run] Command that would be executed:"
  echo "${CMD[*]}"
  exit 0
fi

mkdir -p "$OUTPUT_DIR"

echo "Starting crawl at $(date)…"
echo "Press Ctrl-C to pause; re-run with --resume to continue."
echo ""

"${CMD[@]}"

echo ""
echo "Crawl finished at $(date)."
echo "Site saved to: $OUTPUT_DIR"
echo "Log:           $LOG_FILE"
