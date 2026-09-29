#!/usr/bin/env bash

set -euo pipefail

site_directory="${1:?Site directory is required}"
pull_requests_file="${2:?Pull request metadata file is required}"
output_directory="$site_directory/previews"
rows_file="$(mktemp)"
preview_count=0

cleanup() {
  rm -f "$rows_file"
}
trap cleanup EXIT

mkdir -p "$output_directory"
shopt -s nullglob

for preview_directory in "$site_directory"/pr/*; do
  preview_number="$(basename "$preview_directory")"
  [[ "$preview_number" =~ ^[1-9][0-9]*$ ]] || continue

  pull_request="$(jq -c --argjson number "$preview_number" '.[] | select(.number == $number)' "$pull_requests_file")"
  [[ -n "$pull_request" ]] || continue

  jq -r --arg preview_url "../pr/$preview_number/" '
    def html: tostring | @html;
    def display_author: (.author.name // .author.login // "Unknown");
    def display_updated: (.updatedAt | fromdateiso8601 | strftime("%Y-%m-%d %H:%M UTC"));
    "<tr>" +
    "<td data-label=\"PR\"><a href=\"\(.url | html)\" target=\"_blank\" rel=\"noopener noreferrer\">#\(.number)</a></td>" +
    "<td data-label=\"Change\"><strong>\(.title | html)</strong><span class=\"branch\">\(.headRefName | html)</span></td>" +
    "<td data-label=\"Author\">\(display_author | html)</td>" +
    "<td data-label=\"Updated\"><time datetime=\"\(.updatedAt | html)\">\(display_updated | html)</time></td>" +
    "<td data-label=\"State\"><span class=\"status \(if .isDraft then "draft" else "open" end)\">\(if .isDraft then "Draft" else "Open" end)</span></td>" +
    "<td data-label=\"Actions\"><div class=\"actions\"><a class=\"button primary\" href=\"\($preview_url)\">Open docs</a><a class=\"button\" href=\"\(.url | html)\" target=\"_blank\" rel=\"noopener noreferrer\">View PR</a></div></td>" +
    "</tr>"
  ' <<< "$pull_request" >> "$rows_file"

  preview_count=$((preview_count + 1))
done

cat > "$output_directory/index.html" <<EOF
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <meta name="color-scheme" content="light">
  <title>Coinbase dbt Docs previews</title>
  <style>
    :root { --ink:#17212b; --muted:#5d6875; --line:#d9e0e7; --surface:#fff; --canvas:#f3f6f8; --navy:#12344d; --teal:#087f72; --teal-dark:#05645a; }
    * { box-sizing:border-box; }
    body { margin:0; color:var(--ink); background:var(--canvas); font-family:"Trebuchet MS","Segoe UI",sans-serif; letter-spacing:0; }
    header { color:#fff; background:var(--navy); border-bottom:5px solid var(--teal); }
    .inner, main { width:min(1180px,calc(100% - 40px)); margin:0 auto; }
    .inner { display:flex; align-items:center; justify-content:space-between; gap:24px; min-height:126px; padding:24px 0; }
    .eyebrow { margin:0 0 7px; color:#9ddbd3; font-size:.78rem; font-weight:700; text-transform:uppercase; }
    h1 { margin:0; font-family:Georgia,"Times New Roman",serif; font-size:2.8rem; font-weight:600; letter-spacing:0; }
    .subtitle { margin:8px 0 0; color:#d7e4ec; line-height:1.5; }
    main { padding:36px 0 56px; }
    .summary { display:flex; align-items:center; justify-content:space-between; gap:20px; margin-bottom:18px; }
    .count { color:var(--muted); }
    .count strong { display:inline-grid; place-items:center; min-width:32px; height:28px; margin-right:8px; padding:0 9px; color:#fff; background:var(--teal); border-radius:4px; }
    .table-shell { overflow:hidden; background:var(--surface); border:1px solid var(--line); border-radius:8px; box-shadow:0 14px 38px rgba(23,33,43,.09); }
    table { width:100%; border-collapse:collapse; font-size:.91rem; }
    th { padding:14px 16px; color:#435260; background:#edf2f5; border-bottom:1px solid var(--line); font-size:.74rem; text-align:left; text-transform:uppercase; }
    td { padding:17px 16px; border-bottom:1px solid var(--line); vertical-align:middle; }
    tbody tr:last-child td { border-bottom:0; }
    a { color:var(--teal-dark); font-weight:700; }
    .branch { display:block; margin-top:5px; color:var(--muted); font-family:"Courier New",monospace; font-size:.78rem; overflow-wrap:anywhere; }
    .status { display:inline-block; padding:5px 9px; border-radius:4px; font-size:.76rem; font-weight:800; }
    .status.open { color:#176b50; background:#e8f5ef; }
    .status.draft { color:#815b00; background:#fff3d6; }
    .actions { display:flex; gap:8px; white-space:nowrap; }
    .button { display:inline-flex; align-items:center; justify-content:center; min-height:36px; padding:0 12px; color:var(--navy); background:#fff; border:1px solid #b9c5ce; border-radius:5px; font-size:.8rem; text-decoration:none; }
    .button.primary, .production-link { color:#fff; background:var(--teal); border-color:var(--teal); }
    .button.primary:hover, .production-link:hover { background:var(--teal-dark); }
    .empty { padding:56px 24px; color:var(--muted); text-align:center; }
    footer { margin-top:20px; color:var(--muted); font-size:.82rem; }
    @media (max-width:820px) {
      h1 { font-size:2rem; }
      .inner, .summary { align-items:flex-start; flex-direction:column; }
      .table-shell { overflow:visible; border:0; background:transparent; box-shadow:none; }
      thead { display:none; }
      table, tbody, tr, td { display:block; width:100%; }
      tr { margin-bottom:14px; padding:10px 16px; background:var(--surface); border:1px solid var(--line); border-radius:8px; }
      td { display:grid; grid-template-columns:minmax(92px,.35fr) 1fr; gap:12px; padding:10px 0; }
      td::before { content:attr(data-label); color:var(--muted); font-size:.72rem; font-weight:800; text-transform:uppercase; }
      .actions { flex-wrap:wrap; }
    }
  </style>
</head>
<body>
  <header><div class="inner"><div><p class="eyebrow">coinbase-market-data</p><h1>Pull request previews</h1><p class="subtitle">Review model documentation and lineage before changes reach production.</p></div><a class="button production-link" href="../">Production dbt Docs</a></div></header>
  <main>
    <div class="summary"><span class="count"><strong>$preview_count</strong>published preview$( [[ "$preview_count" -eq 1 ]] || printf 's' )</span></div>
    <div class="table-shell">
EOF

if [[ "$preview_count" -eq 0 ]]; then
  cat >> "$output_directory/index.html" <<'EOF'
      <div class="empty"><strong>No previews are currently published.</strong><p>A preview appears after an open pull request passes dbt CI.</p></div>
EOF
else
  cat >> "$output_directory/index.html" <<'EOF'
      <table><thead><tr><th>PR</th><th>Change</th><th>Author</th><th>Updated</th><th>State</th><th>Actions</th></tr></thead><tbody>
EOF
  cat "$rows_file" >> "$output_directory/index.html"
  cat >> "$output_directory/index.html" <<'EOF'
      </tbody></table>
EOF
fi

cat >> "$output_directory/index.html" <<'EOF'
    </div>
    <footer>Previews are replaced after each successful CI run and removed when their pull request closes.</footer>
  </main>
</body>
</html>
EOF
