# Sanitization (reversible)

One literal substitution was applied to `raw.log` and `COMMAND.txt`; `SOURCE_IDENTITY.txt` is byte-identical to the original.

| Placeholder | Original literal |
|---|---|
| `<CHECKOUT>` | `/root/wt-obs01-evidence` (ephemeral container checkout of main `2cfda326`) |

No secrets, credentials, e-mail addresses or personal data were present (scanned). Log identifiers such as `attempt_0`, `session_1` are synthetic test fixtures.

Verify the published copy, then the original-run provenance:

```sh
sha256sum -c SHA256SUMS
for f in raw.log COMMAND.txt SOURCE_IDENTITY.txt; do
  python3 -c "import sys;sys.stdout.buffer.write(open('$f','rb').read().replace(b'<CHECKOUT>',b'/root/wt-obs01-evidence'))" \
    | sha256sum | sed "s#-#$f#"
done | diff - SHA256SUMS.original && echo ORIGINAL_HASHES_MATCH
```
