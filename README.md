# lib-ml
This library includes the preprocessing logic for the Restaurant Sentiment Analysis project, for use by the model-training and model-service components.

## Installation

### Stable Release
```bash
pip install --extra-index-url https://pkg.github.com/remla25-team8 lib-ml
```

### Pre-release (Testing)
```bash
# Latest pre-release
pip install --extra-index-url https://pkg.github.com/remla25-team8 lib-ml --pre

# Specific pre-release iteration
pip install --extra-index-url https://pkg.github.com/remla25-team8 lib-ml==1.2.3-pre-2
```

### Development Installation
```bash
pip install git+https://github.com/remla25-team8/lib-ml.git@main
```

## Pre-release Versioning

This project supports **iterative pre-release versions** for continuous testing:
- Base releases: `v1.2.3`
- Pre-releases: `v1.2.3-pre`, `v1.2.3-pre-1`, `v1.2.3-pre-2`, etc.

See [docs/PRERELEASE.md](docs/PRERELEASE.md) for detailed information.