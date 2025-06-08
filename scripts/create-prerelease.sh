#!/bin/bash

# Create iterative pre-release versions for lib-ml
# Usage: ./scripts/create-prerelease.sh [base-version]
# Example: ./scripts/create-prerelease.sh 1.2.3

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 lib-ml Pre-release Creator${NC}"
echo "=================================="

# Check if gh CLI is available
if ! command -v gh &> /dev/null; then
    echo -e "${RED}❌ GitHub CLI (gh) is not installed. Please install it first.${NC}"
    echo "Visit: https://github.com/cli/cli#installation"
    exit 1
fi

# Check if we're in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo -e "${RED}❌ Not in a git repository${NC}"
    exit 1
fi

# Determine base version
if [ -n "$1" ]; then
    BASE_VERSION="$1"
    echo -e "${YELLOW}📝 Using provided base version: ${BASE_VERSION}${NC}"
else
    # Get the latest stable release tag
    LATEST_TAG=$(git tag --sort=-version:refname | grep -E '^v[0-9]+\.[0-9]+\.[0-9]+$' | head -n1 | sed 's/^v//' 2>/dev/null || echo "")
    
    if [ -z "$LATEST_TAG" ]; then
        echo -e "${YELLOW}⚠️  No previous releases found. Using default version.${NC}"
        BASE_VERSION="0.1.0"
    else
        # Increment patch version
        IFS='.' read -r MAJOR MINOR PATCH <<< "$LATEST_TAG"
        NEXT_PATCH=$((PATCH + 1))
        BASE_VERSION="$MAJOR.$MINOR.$NEXT_PATCH"
        echo -e "${YELLOW}📈 Latest stable release: v${LATEST_TAG}${NC}"
        echo -e "${YELLOW}🎯 Calculated base version: ${BASE_VERSION}${NC}"
    fi
fi

# Validate version format
if ! [[ "$BASE_VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo -e "${RED}❌ Invalid version format. Use semantic versioning (e.g., 1.2.3)${NC}"
    exit 1
fi

BASE_PRE_VERSION="v${BASE_VERSION}-pre"
echo -e "${BLUE}🔍 Checking for existing pre-release versions...${NC}"

# Get all existing releases
EXISTING_RELEASES=$(gh api repos/$(gh repo view --json owner,name -q '.owner.login + "/" + .name')/releases --paginate -q '.[].tag_name' 2>/dev/null || echo "")

# Find the highest iteration number
MAX_ITERATION=0
ITERATION_FOUND=false

# Split base version for regex matching
IFS='.' read -r MAJOR MINOR PATCH <<< "$BASE_VERSION"

# Check if base pre-release version exists
if echo "$EXISTING_RELEASES" | grep -q "^${BASE_PRE_VERSION}$"; then
    ITERATION_FOUND=true
    MAX_ITERATION=0
    echo -e "${YELLOW}🔍 Found existing base pre-release: ${BASE_PRE_VERSION}${NC}"
fi

# Check for existing iterations
while IFS= read -r release; do
    if [[ "$release" =~ ^v${MAJOR}\.${MINOR}\.${PATCH}-pre-([0-9]+)$ ]]; then
        ITERATION_FOUND=true
        ITERATION_NUM=${BASH_REMATCH[1]}
        if [ "$ITERATION_NUM" -gt "$MAX_ITERATION" ]; then
            MAX_ITERATION=$ITERATION_NUM
        fi
        echo -e "${YELLOW}🔍 Found existing iteration: ${release}${NC}"
    fi
done <<< "$EXISTING_RELEASES"

# Determine the next version
if [ "$ITERATION_FOUND" = true ]; then
    NEXT_ITERATION=$((MAX_ITERATION + 1))
    NEXT_VERSION="v${BASE_VERSION}-pre-${NEXT_ITERATION}"
    echo -e "${GREEN}📦 Next version: ${NEXT_VERSION} (iteration ${NEXT_ITERATION})${NC}"
else
    NEXT_VERSION="$BASE_PRE_VERSION"
    NEXT_ITERATION=0
    echo -e "${GREEN}📦 Next version: ${NEXT_VERSION} (first pre-release)${NC}"
fi

# Confirm with user
echo ""
echo -e "${YELLOW}❓ Create pre-release ${NEXT_VERSION}? (y/N)${NC}"
read -r confirm
if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    echo -e "${RED}❌ Cancelled${NC}"
    exit 0
fi

echo -e "${BLUE}🔧 Preparing release...${NC}"

# Update version in __init__.py
VERSION_WITHOUT_V=$(echo "$NEXT_VERSION" | sed 's/^v//')
sed -i.bak "s/^__version__ = \".*\"$/__version__ = \"$VERSION_WITHOUT_V\"/" src/lib_ml/__init__.py
echo -e "${GREEN}✅ Updated version in src/lib_ml/__init__.py${NC}"

# Run tests
echo -e "${BLUE}🧪 Running tests...${NC}"
python -m pip install --upgrade pip -q
pip install -r requirements.txt -q
pip install pytest -q
python -m unittest discover tests -v

echo -e "${GREEN}✅ Tests passed${NC}"

# Build package
echo -e "${BLUE}📦 Building package...${NC}"
python -m pip install --upgrade build -q
python -m build
echo -e "${GREEN}✅ Package built${NC}"

# Get recent commits for release notes
RECENT_COMMITS=$(git log --oneline -5 --pretty=format:"- %s (%h)" 2>/dev/null || echo "- No recent commits found")
CURRENT_COMMIT=$(git rev-parse HEAD)
CURRENT_BRANCH=$(git branch --show-current)

# Create the release
echo -e "${BLUE}🚀 Creating GitHub release...${NC}"

RELEASE_NOTES="🚧 **Development Pre-release** - Iteration ${NEXT_ITERATION}

This is a development pre-release for testing and integration.

**Base Version**: v${BASE_VERSION}
**Branch**: ${CURRENT_BRANCH}
**Commit**: ${CURRENT_COMMIT}
**Created**: $(date -u +"%Y-%m-%d %H:%M:%S UTC")

## Recent Changes
${RECENT_COMMITS}

## Installation
\`\`\`bash
pip install --extra-index-url https://pkg.github.com/$(gh repo view --json owner -q '.owner.login') lib-ml==${VERSION_WITHOUT_V}
\`\`\`

⚠️ **This is a pre-release version intended for testing only.**"

gh release create "$NEXT_VERSION" \
    --title "Development Pre-release $NEXT_VERSION" \
    --notes "$RELEASE_NOTES" \
    --prerelease \
    dist/*.whl \
    dist/*.tar.gz

echo -e "${GREEN}✅ Successfully created pre-release: ${NEXT_VERSION}${NC}"
echo -e "${BLUE}🔗 Release URL: $(gh repo view --json url -q '.url')/releases/tag/${NEXT_VERSION}${NC}"

# Restore original __init__.py
mv src/lib_ml/__init__.py.bak src/lib_ml/__init__.py
echo -e "${YELLOW}🔧 Restored original __init__.py${NC}"

echo ""
echo -e "${GREEN}🎉 Pre-release creation completed successfully!${NC}" 