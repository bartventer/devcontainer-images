# Arch Linux

## Summary

*Simple Arch Linux container with Git and common utilities installed.*

| Metadata | Value |  
|----------|-------|
| *Categories* | Core, Other |
| *Image type* | Dockerfile |
| *Published images* | docker.io/bartventer/devcontainer-images/archlinux |
| *Available image variants* | latest |
| *Published image architecture(s)* | x86-64 |
| *Container host OS support* | Linux, macOS, Windows |
| *Container OS* | Arch Linux |
| *Languages, platforms* | Any |

See **[history](history)** for information on the contents of published images.

## Using this image

You can directly reference pre-built versions of `Dockerfile` by using the `image` property in `.devcontainer/devcontainer.json` or updating the `FROM` statement in your own `Dockerfile` to one of the following. An example `Dockerfile` is included in this repository.

- `docker.io/bartventer/archlinux` (latest)

Refer to [this guide](https://containers.dev/guide/dockerfile) for more details.

You can decide how often you want updates by referencing a [semantic version](https://semver.org/) of each image. For example:

- `docker.io/bartventer/archlinux:1`
- `docker.io/bartventer/archlinux:1.0`
- `docker.io/bartventer/archlinux:1.0.0`

See [history](history) for information on the contents of each version and [here for a complete list of available tags](https://github.com/bartventer?tab=packages&repo_name=devcontainer-images).

Alternatively, you can use the contents of [.devcontainer](.devcontainer) to fully customize your container's contents or to build it for a container host architecture not supported by the image.

Beyond `git`, this image / `Dockerfile` includes `zsh`, [Oh My Zsh!](https://ohmyz.sh/), a non-root `vscode` user with `sudo` access, and a set of common dependencies for development.

## License

Copyright (c) Bart Venter. All rights reserved.

Licensed under the MIT License. See [LICENSE](LICENSE) for more information.
