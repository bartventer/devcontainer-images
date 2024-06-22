# Arch Linux

## Summary
*Simple Arch Linux container with common tools installed.*

| Metadata | Value |
|----------|-------|
| *Contributors* | [Bart Venter](https://github.com/bartvener) |
| *Definition type* | Dockerfile |
| *Published images* | ghcr.io/bartventer/devcontainer-images/base-archlinux |
| *Container host OS support* | Linux, macOS, Windows |
| *Container OS* | OS: Linux, Distribution: Arch |
| *Published image architecture(s)* | linux/amd64 |
| *Languages* | Python, Node.js |
| *Features* | [Common Utilities](https://github.com/bartventer/arch-devcontainer-features/tree/main/src/common-utils/README.md) |


## Using this image
You can directly reference pre-built versions of `Dockerfile` by using the `image` property in `.devcontainer/devcontainer.json` or updating the `FROM` statement in your own  `Dockerfile` to one of the following. An example `Dockerfile` is included in this repository.
- `ghcr.io/bartventer/devcontainer-images/base-archlinux` _(latest)_

Refer to [this guide](https://containers.dev/guide/dockerfile) for more details.

You can decide how often you want updates by referencing a [semantic version](https://semver.org/) of each image. For example:

- `ghcr.io/bartventer/devcontainer-images/base-archlinux:1`
- `ghcr.io/bartventer/devcontainer-images/base-archlinux:1.0`
- `ghcr.io/bartventer/devcontainer-images/base-archlinux:1.0.6`
- `ghcr.io/bartventer/devcontainer-images/base-archlinux:latest`


## License
Copyright (c) Bart Venter.
Licensed under the MIT License. See [LICENSE](https://github.com/bartventer/devcontainer-images/blob/main/LICENSE).

---

_Note: This file was auto-generated by a GitHub Action based on the [metadata.json](./metadata.json). Do not edit this file directly._