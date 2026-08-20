#!/usr/bin/env bash
#
# Claude Code statusline: model name + rate-limit usage, styled to match
# Claude Code's own understated terminal UI (dim secondary text, restrained
# color used only for warning-level usage, thin subtle progress bars).

jq -r '
  def dim: "[2m";
  def reset_ansi: "[0m";

  # Original hierarchy: the data (bar fill + percentage) is plain default
  # foreground - readable but not colorful; color appears only as a
  # warning (yellow >=70% used, red >=90% used). Decoration stays dim.
  def warn_color(pct):
    if pct >= 90 then "[31m"
    elif pct >= 70 then "[33m"
    else "" end;

  # resets_at is documented as a Unix epoch number, but tolerate an
  # ISO-8601 string too (and fall back to "now" rather than hard-erroring
  # on an unrecognized shape). NB: this whole jq program lives inside a
  # single-quoted bash string, so comments in here must never contain an
  # apostrophe - one did, and it silently truncated the script.
  def to_epoch:
    if type == "number" then .
    else (try fromdateiso8601 catch now) end;

  def remaining:
    ((to_epoch - now) | if . < 0 then 0 else floor end) as $seconds
    | if $seconds >= 86400
      then "\($seconds / 86400 | floor)d\(($seconds % 86400) / 3600 | floor)h"
      else "\($seconds / 3600 | floor)h\(($seconds % 3600) / 60 | floor)m"
      end;

  # jq quirk: (string * 0) evaluates to null, not "" — guard against that.
  def repeat_char(ch; n):
    if n <= 0 then "" else ch * n end;

  # Progress bar: rounded-block pair - filled segments colored, empty
  # counterparts dimmed. Medium weight, chosen by the user over thin
  # lines (unreadable) and solid blocks (too heavy).
  def bar(pct; c):
    (5) as $width
    | ((pct / 100 * $width) | round) as $raw
    | ($raw | if . > $width then $width elif . < 0 then 0 else . end) as $f0
    | (if pct > 0 and $f0 == 0 then 1 else $f0 end) as $f
    | c + repeat_char("▰"; $f) + reset_ansi
      + dim + repeat_char("▱"; $width - $f) + reset_ansi;

  # NB: "label" is a reserved jq keyword (used by label $out / break $out
  # control flow) and cannot be used as a function parameter name — hence
  # "lbl" here instead of "label", which caused a compile error before.
  # Shows REMAINING (not used): the bar drains as the window is consumed,
  # and the number is what is left. Warning colors still key off usage
  # (yellow at >=70% used, red at >=90% used).
  def window(lbl):
    select(.used_percentage != null and .resets_at != null)
    | (.used_percentage | round) as $pct
    | (100 - $pct) as $rem
    | warn_color($pct) as $c
    | dim + "\(lbl) " + reset_ansi
      + bar($rem; $c) + " "
      + $c + "\($rem)% remain" + reset_ansi
      + dim + " ↻ \(.resets_at | remaining)" + reset_ansi;

  # Context-window usage segment, in the same drain style as the
  # rate-limit windows: the bar shows what is left, and color warns
  # off percent used. There is no reset time here, since context does
  # not refill on a timer the way a rate-limit window does.
  def ctx_part:
    .context_window as $cw
    | select($cw.used_percentage != null and $cw.remaining_percentage != null)
    | ($cw.used_percentage | round) as $pct
    | ($cw.remaining_percentage | round) as $rem
    | warn_color($pct) as $c
    | dim + "ctx " + reset_ansi
      + bar($rem; $c) + " "
      + $c + "\($rem)%" + reset_ansi;

  # Model name, with the reasoning effort level appended dim when present
  # (effort is absent when the model has no effort parameter).
  (
      (.model.display_name? // "") as $model
      | (.effort.level? // "") as $lvl
      | if $model == "" then ""
        elif $lvl == "" then $model
        else $model + dim + " · " + $lvl + reset_ansi
        end
    ) as $model_part

  | [
      $model_part,
      ctx_part,
      (.rate_limits.five_hour? | window("5h")),
      (.rate_limits.seven_day? | window("7d"))
    ]
    | map(select(. != null and . != ""))
    | join(dim + " │ " + reset_ansi)
'
