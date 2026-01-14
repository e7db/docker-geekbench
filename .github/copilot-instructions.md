# Copilot Instructions for docker-geekbench

## Project Overview

Docker Geekbench is a Dockerized version of [Geekbench](https://www.geekbench.com/), a cross-platform benchmark that measures system performance. This project provides multi-architecture Docker images for running Geekbench on Linux systems, including ARM support.

**Container registries:**
- Docker Hub: `e7db/geekbench`
- GHCR: `ghcr.io/e7db/geekbench`

## Project Structure

```
build.sh             # Multi-version build script with buildx
setup.sh             # Geekbench download and installation script
Dockerfile           # Multi-stage Ubuntu-based container
README.md            # Documentation and usage instructions
```

## Supported Versions & Architectures

| Version | `amd64` | `arm64/v8` | `arm/v7` |
|---------|---------|------------|----------|
| 6.x     | ✅      | ✅         |          |
| 5.x     | ✅      | ✅         | ✅       |
| 4.x     | ✅      |            |          |
| 3.x     | ✅      |            |          |
| 2.x     | ✅      |            |          |

ARM builds use Geekbench Preview releases from the official CDN.

## Build System

The `build.sh` script handles multi-architecture builds:
- Fetches available versions from geekbench.com (legacy + latest)
- Uses Docker buildx for multi-platform builds
- Supports `--dry-run` for testing and `--all` for exhaustive version discovery
- Tags images with full version, minor, and major version numbers
- Caches builds using GHCR registry cache

Key environment variables:
- `GHCR_IMAGE` - GHCR image name
- `DOCKERHUB_IMAGE` - Docker Hub image name

## Clean Code Principles

Follow these clean code principles when contributing:

### Single Responsibility
- Each function should do one thing and do it well
- Keep functions small and focused (ideally < 30 lines)
- Separate concerns: version detection, architecture handling, building

### Meaningful Names
- Use descriptive function names: `has_arm_preview` not `check_arm`
- Use consistent naming conventions (snake_case for functions/variables)
- Prefix check functions appropriately

### DRY (Don't Repeat Yourself)
- Extract common patterns into reusable functions
- Use helper functions for URL checking and tag generation
- Centralize platform detection logic

### Comments and Documentation
- Functions should be self-documenting through clear names
- Add comments only when explaining "why", not "what"
- Keep README and documentation in sync with code

### Error Handling
- Fail fast with clear error messages
- Validate inputs early (VERSION check in setup.sh)
- Use consistent exit codes (0=success, 1=error)

### Code Organization
- Group related functions together
- Order: helpers → version handling → build logic → main
- Keep configuration separate from logic

## Shell Script Best Practices

- Use `set -e` to exit on errors where appropriate
- Quote variables: `"$VAR"` not `$VAR`
- Use `[[` for conditionals (bash)
- Prefer `local` variables in functions
- Use meaningful return codes
- Avoid global state when possible

## Testing Guidelines

- Test builds with `--dry-run` flag before actual builds
- Verify architecture detection for ARM preview availability
- Test version parsing and tag generation
- Validate Docker buildx multi-platform builds work correctly

## Docker Best Practices

- Use multi-stage builds (setup → libs → scratch)
- Use `scratch` as final base for minimal image size
- Extract only required glibc libraries for each architecture
- Use `debian:stable-slim` for build stages (smaller than Ubuntu)
- Run as non-root user (65534:65534) for security
- Use `--no-install-recommends` to minimize build dependencies
- Set WORKDIR to geekbench directory (required for .plar files)
- Use symlink entrypoint for multi-arch support
- Use SIGINT as stop signal for graceful termination

## CI/CD Workflows

- `docker-image.yml` - Build and push to GHCR (always) and Docker Hub (tags only)
- `codeql.yml` - Security scanning

## Architecture Detection

The setup script detects architecture at build time:
- `x86_64` → `geekbench_x86_64` (standard Linux release)
- `aarch64` → `geekbench_aarch64` (ARM Preview release)
- `armv7l` → `geekbench_armv7` (ARM Preview release, GB5 only)
