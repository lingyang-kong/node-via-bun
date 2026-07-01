# node-via-bun

Bun-backed `node`, `nodejs`, `npm`, and `npx` shims for package managers and
tools that expect Node.js command names.

This project is intentionally deceptive: Node-oriented tools see familiar
commands on `PATH`, but those commands execute Bun. The goal is to let Bun stand
in for Node in environments that only know how to ask for `node` or `nodejs`.

Repository: <https://github.com/lingyang-kong/node-via-bun>

## Behavior

```text
/usr/bin/node   -> /usr/bin/bun
/usr/bin/nodejs -> /usr/bin/bun
/usr/bin/npm    -> /usr/bin/bun
/usr/bin/npx    -> /usr/bin/bunx
```

The Homebrew formula links `node`, `npm`, and `npx`; the Debian package also
links `nodejs` to match Debian's `nodejs` command surface.

For ordinary commands, the shim passes arguments through to Bun. For
`--version` and `-v`, the shim reports versions aligned with Bun's Node
compatibility layer.

This project does not install `corepack`.

## Compatibility Warning

This is not a real Node.js distribution.

- Bun is not fully compatible with Node.js.
- Some CLIs, build tools, package scripts, and Homebrew formulae that assume
  real Node behavior may fail.
- If you need predictable upstream Node semantics, install official Node.js
  instead.
- If you are evaluating whether this shim fits your workflow, see Bun's docs at
  <https://bun.sh/>.

## Debian Package

The source package is `node-via-bun`. The binary package is intentionally named
`nodejs` because it replaces the system Node package.

Debian package versions are shim package versions, not static claims about
Bun's current Node.js compatibility version.

The package only declares compatibility for command surfaces it actually owns:
`npm`, `npx`, and the old `nodejs-legacy` `/usr/bin/node` alias. It does not
provide `nodejs-dev` or `nodejs-doc`.

## APT Install

```sh
curl --fail --silent --show-error --location 'https://lingyang-kong.github.io/node-via-bun/key.gpg' \
	| sudo gpg --dearmor --output /usr/share/keyrings/node-via-bun.gpg

echo 'deb [signed-by=/usr/share/keyrings/node-via-bun.gpg] https://lingyang-kong.github.io/node-via-bun stable main' \
	| sudo tee /etc/apt/sources.list.d/node-via-bun.list

curl --fail --silent --show-error --location 'https://lingyang-kong.github.io/node-via-bun/node-via-bun.pref' \
	| sudo tee /etc/apt/preferences.d/node-via-bun.pref >/dev/null
```

Install:

```sh
sudo apt update
sudo apt install nodejs
```

The preference file pins `+via-bun` versions of `nodejs` with priority 1001,
so the Bun-backed shim remains the candidate even when other repositories offer
higher-version `nodejs` packages.

## Homebrew Install

Tap the Homebrew repository and install `node`:

```sh
brew tap lingyang-kong/node-via-bun
brew install lingyang-kong/node-via-bun/node
```

## License

MIT. See [LICENSE](LICENSE).
