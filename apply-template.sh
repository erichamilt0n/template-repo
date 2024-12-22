#!/bin/bash

# Exit on error
set -e

# Function to display usage
usage() {
    echo "Usage: $0 <target-repo-path>"
    echo "Example: $0 /path/to/existing/repo"
    exit 1
}

# Function to backup a file if it exists
backup_if_exists() {
    local file=$1
    if [ -f "$file" ]; then
        echo "Backing up existing $file to ${file}.bak"
        cp "$file" "${file}.bak"
    fi
}

# Check arguments
if [ "$#" -ne 1 ]; then
    usage
fi

TARGET_REPO=$1
TEMPLATE_DIR=$(dirname "$0")

# Verify target repo exists and is a git repository
if [ ! -d "$TARGET_REPO/.git" ]; then
    echo "Error: $TARGET_REPO is not a git repository"
    exit 1
fi

echo "Applying template from $TEMPLATE_DIR to $TARGET_REPO"

# Create temporary working directory
TEMP_DIR=$(mktemp -d)
trap 'rm -rf "$TEMP_DIR"' EXIT

# Copy template files to temporary directory
cp -r "$TEMPLATE_DIR"/{.github,.semaphore,.codacy.yml,.snyk,*.md,*.json} "$TEMP_DIR/" 2>/dev/null || true

# Process each file/directory
cd "$TARGET_REPO"

# GitHub workflows and templates
echo "Setting up GitHub workflows and templates..."
mkdir -p .github/{workflows,ISSUE_TEMPLATE}
cp -r "$TEMP_DIR"/.github/* .github/

# Semaphore CI configuration
echo "Setting up Semaphore CI configuration..."
mkdir -p .semaphore
cp -r "$TEMP_DIR"/.semaphore/* .semaphore/

# Code quality and security configurations
echo "Setting up code quality and security configurations..."
for file in .codacy.yml .snyk; do
    backup_if_exists "$file"
    cp "$TEMP_DIR/$file" ./ 2>/dev/null || true
done

# Documentation files
echo "Setting up documentation files..."
for file in CONTRIBUTING.md SECURITY.md LICENSE; do
    if [ ! -f "$file" ]; then
        cp "$TEMP_DIR/$file" ./ 2>/dev/null || true
    else
        echo "Skipping existing $file"
    fi
done

# Package.json merge
if [ -f package.json ] && [ -f "$TEMP_DIR/package.json" ]; then
    echo "Merging package.json..."
    # Backup existing package.json
    cp package.json package.json.bak
    
    # Install jq if not present
    if ! command -v jq &> /dev/null; then
        echo "jq is required but not installed. Please install jq first."
        exit 1
    fi
    
    # Merge scripts and devDependencies
    jq -s '.[0] * {"scripts": (.[0].scripts + .[1].scripts), "devDependencies": (.[0].devDependencies + .[1].devDependencies)}' \
        package.json "$TEMP_DIR/package.json" > package.json.new
    mv package.json.new package.json
fi

# Update .gitignore
if [ -f "$TEMP_DIR/.gitignore" ]; then
    echo "Updating .gitignore..."
    if [ -f .gitignore ]; then
        # Append new entries while avoiding duplicates
        awk 'NF' "$TEMP_DIR/.gitignore" | while read -r line; do
            if ! grep -Fxq "$line" .gitignore; then
                echo "$line" >> .gitignore
            fi
        done
    else
        cp "$TEMP_DIR/.gitignore" ./
    fi
fi

echo "Template application complete!"
echo "Next steps:"
echo "1. Review the changes and backup files (.bak)"
echo "2. Update package.json scripts and dependencies if needed"
echo "3. Configure GitHub repository settings:"
echo "   - Branch protection rules"
echo "   - Required status checks"
echo "   - Repository secrets (GRAFANA_API_KEY, CODECOV_TOKEN, SNYK_TOKEN)"
echo "4. Enable GitHub features:"
echo "   - GitHub Pages"
echo "   - Dependabot alerts"
echo "   - Code scanning"
echo "5. Update CODEOWNERS file with your team members"
echo "6. Commit the changes:"
echo "   git add ."
echo '   git commit -m "Add template repository structure"'
echo "   git push"
