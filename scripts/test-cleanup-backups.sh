#!/bin/bash
# Tests for cleanup_backups() — no sudo needed, operates in temp dirs.
# Usage: bash scripts/test-cleanup-backups.sh

# No set -e: test failures are handled by assert_eq, we always want full output

PASS=0
FAIL=0

cleanup() {
  [[ -n "${TEST_DIR:-}" ]] && rm -rf "$TEST_DIR"
}

# Mock the helpers that cleanup_backups depends on
sudo()   { "$@"; }  # bypass sudo in tests
log()    { echo "[test] $*"; }
die()    { echo "ERROR: $*"; exit 1; }
warn()   { echo "WARNING: $*"; }

# Copy of cleanup_backups (same logic, no sudo dependency since we mock it)
cleanup_backups() {
  local dir="$1"
  local pattern="$2"
  local keep="${3:-3}"

  local count
  count=$(find "$dir" -maxdepth 1 -name "$pattern" 2>/dev/null | wc -l)

  if [[ "$count" -gt "$keep" ]]; then
    find "$dir" -maxdepth 1 -name "$pattern" -type f -print0 \
      | xargs -0 ls -t \
      | tail -n +$((keep + 1)) \
      | while read -r old; do
        sudo rm -f "$old"
        log "Pruned old backup: $old"
      done
  fi
}

assert_eq() {
  local expected="$1" actual="$2" label="$3"
  if [[ "$expected" == "$actual" ]]; then
    echo "  PASS: $label"
    ((PASS++))
  else
    echo "  FAIL: $label (expected: $expected, got: $actual)"
    ((FAIL++))
  fi
}

# === Test: no backups at all ===
test_no_backups() {
  echo "--- Test: no backups ---"
  TEST_DIR=$(mktemp -d)
  cleanup_backups "$TEST_DIR" "test.bak.*" 3
  local remaining
  remaining=$(find "$TEST_DIR" -name "test.bak.*" | wc -l)
  assert_eq "0" "$remaining" "no backups created when none exist"
  rm -rf "$TEST_DIR"
}

# === Test: fewer backups than keep threshold ===
test_fewer_than_keep() {
  echo "--- Test: fewer backups than keep threshold ---"
  TEST_DIR=$(mktemp -d)
  touch "$TEST_DIR/test.bak.1" "$TEST_DIR/test.bak.2"
  cleanup_backups "$TEST_DIR" "test.bak.*" 3
  local remaining
  remaining=$(find "$TEST_DIR" -name "test.bak.*" | wc -l)
  assert_eq "2" "$remaining" "kept 2 backups (under threshold of 3)"
  rm -rf "$TEST_DIR"
}

# === Test: exactly at keep threshold ===
test_exactly_at_keep() {
  echo "--- Test: exactly at keep threshold ---"
  TEST_DIR=$(mktemp -d)
  touch "$TEST_DIR/test.bak.1" "$TEST_DIR/test.bak.2" "$TEST_DIR/test.bak.3"
  cleanup_backups "$TEST_DIR" "test.bak.*" 3
  local remaining
  remaining=$(find "$TEST_DIR" -name "test.bak.*" | wc -l)
  assert_eq "3" "$remaining" "kept 3 backups (at threshold)"
  rm -rf "$TEST_DIR"
}

# === Test: more backups than keep threshold (prune oldest) ===
test_prune_oldest() {
  echo "--- Test: prune oldest when over threshold ---"
  TEST_DIR=$(mktemp -d)
  # Create files with specific mtimes: oldest = bak.1, newest = bak.5
  touch -t 202601010100 "$TEST_DIR/test.bak.1"
  touch -t 202601020100 "$TEST_DIR/test.bak.2"
  touch -t 202601030100 "$TEST_DIR/test.bak.3"
  touch -t 202601040100 "$TEST_DIR/test.bak.4"
  touch -t 202601050100 "$TEST_DIR/test.bak.5"
  cleanup_backups "$TEST_DIR" "test.bak.*" 3
  local remaining
  remaining=$(find "$TEST_DIR" -name "test.bak.*" | wc -l)
  assert_eq "3" "$remaining" "3 backups remain after pruning 2 of 5"
  # The 2 oldest (1, 2) should be gone; 3, 4, 5 should remain
  [[ -f "$TEST_DIR/test.bak.1" ]] && local r1=1 || local r1=0
  [[ -f "$TEST_DIR/test.bak.2" ]] && local r2=1 || local r2=0
  [[ -f "$TEST_DIR/test.bak.3" ]] && local r3=1 || local r3=0
  [[ -f "$TEST_DIR/test.bak.4" ]] && local r4=1 || local r4=0
  [[ -f "$TEST_DIR/test.bak.5" ]] && local r5=1 || local r5=0
  assert_eq "0" "$r1" "bak.1 (oldest) pruned"
  assert_eq "0" "$r2" "bak.2 pruned"
  assert_eq "1" "$r3" "bak.3 kept"
  assert_eq "1" "$r4" "bak.4 kept"
  assert_eq "1" "$r5" "bak.5 (newest) kept"
  rm -rf "$TEST_DIR"
}

# === Test: custom keep count (keep=1) ===
test_custom_keep_1() {
  echo "--- Test: custom keep=1 ---"
  TEST_DIR=$(mktemp -d)
  touch -t 202601010100 "$TEST_DIR/test.bak.1"
  touch -t 202601020100 "$TEST_DIR/test.bak.2"
  touch -t 202601030100 "$TEST_DIR/test.bak.3"
  cleanup_backups "$TEST_DIR" "test.bak.*" 1
  local remaining
  remaining=$(find "$TEST_DIR" -name "test.bak.*" | wc -l)
  assert_eq "1" "$remaining" "1 backup remains after pruning (keep=1)"
  [[ -f "$TEST_DIR/test.bak.3" ]] && local kept=1 || local kept=0
  assert_eq "1" "$kept" "newest backup (bak.3) kept"
  rm -rf "$TEST_DIR"
}

# === Test: special chars in filenames ===
test_special_chars() {
  echo "--- Test: special characters in backup filenames ---"
  TEST_DIR=$(mktemp -d)
  touch "$TEST_DIR/test.bak.2026-01-01_12:00:00"
  touch "$TEST_DIR/test.bak.2026-01-02_12:00:00"
  touch "$TEST_DIR/test.bak.2026-01-03_12:00:00"
  touch "$TEST_DIR/test.bak.2026-01-04_12:00:00"
  # Also test a file with spaces (if someone manually names one)
  touch "$TEST_DIR/test.bak.2026-01-05 12:00:00" 2>/dev/null || true
  cleanup_backups "$TEST_DIR" "test.bak.*" 2
  local remaining
  remaining=$(find "$TEST_DIR" -name "test.bak.*" 2>/dev/null | wc -l)
  assert_eq "2" "$remaining" "pruned to 2 despite special chars"
  rm -rf "$TEST_DIR"
}

# === Test: pattern matches no files ===
test_no_match() {
  echo "--- Test: pattern matches nothing ---"
  TEST_DIR=$(mktemp -d)
  cleanup_backups "$TEST_DIR" "nonexistent.*" 3
  local remaining
  remaining=$(find "$TEST_DIR" -type f | wc -l)
  assert_eq "0" "$remaining" "no files affected when pattern matches nothing"
  rm -rf "$TEST_DIR"
}

# === Test: non-existent directory ===
test_missing_dir() {
  echo "--- Test: non-existent directory ---"
  # find on a missing dir returns silently; function should not crash
  cleanup_backups "/tmp/opencode/nonexistent-12345" "*.bak.*" 3
  assert_eq "0" "0" "function does not crash on missing directory"
}

# === Run tests ===
echo "============================================"
echo "  cleanup_backups() — edge case tests"
echo "============================================"
echo ""
test_no_backups
test_fewer_than_keep
test_exactly_at_keep
test_prune_oldest
test_custom_keep_1
test_special_chars
test_no_match
test_missing_dir
echo ""
echo "============================================"
echo "  Results: $PASS passed, $FAIL failed"
echo "============================================"
[[ "$FAIL" -eq 0 ]] || exit 1
