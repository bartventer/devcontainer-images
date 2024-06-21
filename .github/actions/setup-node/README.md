# Setup Node.js Action

This action simply sets up [actions/setup-node@v4](https://github.com/actions/setup-node/tree/v4/) with `yarn` as the package manager, and caches the dependencies.

## Inputs

### `node-version-file`

The file containing the Node.js version to use. Default: `'package.json'`.

### `cache`

The package manager to use for caching. Default: `'yarn'`.

### `cache-dependency-path`

The path to the lock file for caching. Default: `'yarn.lock'`.

## Usage

```yaml
uses: ./.github/actions/setup-node
with:
  node-version-file: 'package.json'
  cache: 'yarn'
  cache-dependency-path: 'yarn.lock'
```