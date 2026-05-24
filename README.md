# node-via-bun
Conventional Debian packaging for a `nodejs` binary package backed by Bun.

The source package is `node-via-bun`. The binary package is intentionally named
`nodejs` because it replaces the system Node package.

Repository: <https://github.com/lingyang-kong/node-via-bun>

## Package Behavior
```text
/usr/bin/node     -> /usr/bin/bun
/usr/bin/npm      -> /usr/bin/bun
/usr/bin/npx      -> /usr/bin/bunx
/usr/bin/corepack -> unsupported, exits 127
```

## Build
GitHub Actions is the intended build path. Push a tag matching the version in
`debian/changelog`; the workflow builds the `.deb`, attaches it to the GitHub
release, and publishes an APT repository to `gh-pages`.

Debian packages require a version. In this layout the version lives in
`debian/changelog`, which is the conventional Debian source of truth.

Optional local build command:
```sh
sudo apt install debhelper dpkg-dev
dpkg-buildpackage -us -uc -b
sudo apt install '../nodejs_1.0.0+via-bun1_all.deb'
```

## Release
The GitHub release is published from
<https://github.com/lingyang-kong/node-via-bun/releases>.

## APT Repository Install
The workflow requires `APT_GPG_PRIVATE_KEY` in GitHub Actions secrets and
publishes signed repository metadata.

```sh
curl -fsSL 'https://raw.githubusercontent.com/lingyang-kong/node-via-bun/gh-pages/key.gpg' \
  | sudo gpg --dearmor -o /usr/share/keyrings/node-via-bun.gpg

echo 'deb [signed-by=/usr/share/keyrings/node-via-bun.gpg] https://raw.githubusercontent.com/lingyang-kong/node-via-bun/gh-pages stable main' \
  | sudo tee /etc/apt/sources.list.d/node-via-bun.list

curl -fsSL 'https://raw.githubusercontent.com/lingyang-kong/node-via-bun/gh-pages/node-via-bun.pref' \
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
