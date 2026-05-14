#!/usr/bin/env bash
set -euo pipefail

# 主服执行：从副服拉取 SQLite 并合并到主库
# 默认按当前需求：
#   主服: 39.107.81.44
#   副服: 8.163.89.131

SLAVE_SSH="${SLAVE_SSH:-root@8.163.89.131}"
SLAVE_DB_PATH="${SLAVE_DB_PATH:-/opt/PvZ-TV-Server/data/pvz_metrics.db}"
MASTER_DB_PATH="${MASTER_DB_PATH:-/opt/PvZ-TV-Server/data/pvz_metrics.db}"
WORKDIR="${WORKDIR:-/opt/pvz-sync}"
INBOX_DB="${WORKDIR}/pvz_metrics_slave.db"
TMP_SQL="${WORKDIR}/sync_run.sql"
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SQL_TEMPLATE="${BASE_DIR}/sync.sql"

mkdir -p "${WORKDIR}"

if ! command -v sqlite3 >/dev/null 2>&1; then
  echo "[SYNC] sqlite3 not found"
  exit 1
fi

if ! command -v scp >/dev/null 2>&1; then
  echo "[SYNC] scp not found"
  exit 1
fi

echo "[SYNC] pull start: ${SLAVE_SSH}:${SLAVE_DB_PATH}"
scp -q "${SLAVE_SSH}:${SLAVE_DB_PATH}" "${INBOX_DB}"
echo "[SYNC] pull done: ${INBOX_DB}"

if [[ ! -f "${MASTER_DB_PATH}" ]]; then
  echo "[SYNC] master db not found: ${MASTER_DB_PATH}"
  exit 1
fi

escaped_inbox="${INBOX_DB//\//\\/}"
sed "s/__SLAVE_DB__/${escaped_inbox}/g" "${SQL_TEMPLATE}" > "${TMP_SQL}"

echo "[SYNC] merge start"
sqlite3 "${MASTER_DB_PATH}" < "${TMP_SQL}"
echo "[SYNC] merge done"

rm -f "${TMP_SQL}"
