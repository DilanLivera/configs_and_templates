#!/usr/bin/env bash
# Claude Code status line — model, token usage, and context remaining
# Input: JSON from Claude Code via stdin
input=$(cat)

# ANSI color helpers
reset='\033[0m'
dim='\033[2m'
bold='\033[1m'
green='\033[32m'
yellow='\033[33m'
red='\033[31m'
cyan='\033[36m'
white='\033[37m'

sep="${dim} · ${reset}"

model=$(echo "$input" | jq -r '.model.id // empty' | sed 's/claude-//')
total_in=$(echo "$input" | jq -r '.context_window.total_input_tokens // 0')
total_out=$(echo "$input" | jq -r '.context_window.total_output_tokens // 0')
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
five_hour_used=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
five_hour_resets=$(echo "$input" | jq -r '.rate_limits.five_hour.resets_at // empty')

total_tokens=$(( total_in + total_out ))

if [ "$total_tokens" -ge 1000 ]; then
  tokens_fmt=$(awk "BEGIN { printf \"%.1fk\", $total_tokens / 1000 }")
else
  tokens_fmt="${total_tokens}"
fi

# Model segment
out=$(printf "⚡ ${cyan}${bold}%s${reset}" "$model")

# Tokens segment
out="${out}${sep}"
out="${out}$(printf "🪙 ${white}%s${reset}" "$tokens_fmt")"

# Session rate-limit segment
if [ -n "$five_hour_used" ] && [ -n "$five_hour_resets" ]; then
  session_left=$(awk "BEGIN { printf \"%.0f\", 100 - $five_hour_used }")

  # Pick color based on how much session is left
  if awk "BEGIN { exit !($session_left > 50) }"; then
    session_color="$green"
  elif awk "BEGIN { exit !($session_left > 20) }"; then
    session_color="$yellow"
  else
    session_color="$red"
  fi

  now=$(date +%s)
  secs_until=$(( five_hour_resets - now ))
  if [ "$secs_until" -lt 0 ]; then
    secs_until=0
  fi
  hours_until=$(( secs_until / 3600 ))
  mins_until=$(( (secs_until % 3600) / 60 ))
  if [ "$hours_until" -ge 1 ]; then
    reset_fmt="${hours_until}h ${mins_until}m"
  else
    reset_fmt="${mins_until}m"
  fi

  out="${out}${sep}"
  out="${out}$(printf "🔋 ${session_color}${bold}%s%%${reset}" "$session_left")"
  out="${out}${sep}"
  out="${out}$(printf "🕐 ${white}%s${reset}" "$reset_fmt")"
fi

printf '%b' "$out"
