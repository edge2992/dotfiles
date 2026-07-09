# Reverse merge patch used by settings-sync.sh:
#   apply(base; diff(rendered; live))
# diff is an RFC 7386-style recursive object diff: objects recurse, scalars
# and arrays replace atomically, keys removed from $b become null. apply
# applies such a patch; a null in the patch deletes the key.
# Expects: $base_a / $live_a (slurped arrays) and $rendered.
# Tested by scripts/test-merge-patch.sh.
def diff($a; $b):
  if ($a | type) == "object" and ($b | type) == "object" then
    reduce ((($a | keys) + ($b | keys)) | unique[]) as $k ({};
      if ($a | has($k)) and (($b | has($k)) | not) then . + {($k): null}
      elif ($a | has($k)) | not                    then . + {($k): $b[$k]}
      elif $a[$k] == $b[$k]                        then .
      else . + {($k): diff($a[$k]; $b[$k])} end)
  else $b end;
def apply($t; $p):
  if ($p | type) == "object" then
    reduce ($p | keys[]) as $k (if ($t | type) == "object" then $t else {} end;
      if $p[$k] == null then del(.[$k]) else .[$k] = apply(.[$k]; $p[$k]) end)
  else $p end;
apply($base_a[0]; diff($rendered; $live_a[0]))
