#!/bin/bash
# Script to set up tools for multiple repositories

# Exit on any error
set -e

# Error handling
trap 'echo "Error occurred at line $LINENO. Exiting..."; exit 1' ERR

# Logging function
log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1"
}

# Usage function
usage() {
    echo "Usage: $0 [--parallel] [--dry-run] [organization]"
    echo "Options:"
    echo "  --parallel    Process repositories in parallel"
    echo "  --dry-run     Show what would be done without making changes"
    echo "  organization  GitHub organization (optional)"
    exit 1
}

# Parse arguments
PARALLEL=false
DRY_RUN=false
ORGANIZATION=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --parallel)
            PARALLEL=true
            shift
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        -h|--help)
            usage
            ;;
        *)
            ORGANIZATION=$1
            shift
            ;;
    esac
done

# Load configuration if exists
CONFIG_FILE=".repo-setup.conf"
if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
fi

# Check if GitHub CLI is installed
if ! command -v gh &> /dev/null; then
    log "GitHub CLI (gh) is not installed. Please install it first."
    exit 1
fi

# Check if user is authenticated
if ! gh auth status &> /dev/null; then
    log "Please login to GitHub CLI first using: gh auth login"
    exit 1
fi

# Check if template repository exists
if [ ! -d "template-repo" ]; then
    log "template-repo directory not found. Please create it first."
    exit 1
fi

# Create a directory to store all repositories
mkdir -p repos
cd repos

# Get repository list
REPO_LIST=$(if [ -n "$ORGANIZATION" ]; then
    gh repo list "$ORGANIZATION" --json name -q '.[].name'
else
    gh repo list --json name -q '.[].name'
fi)

process_repo() {
    local repo=$1
    log "Configuring $repo..."
    
    # Clone or update repository
    if [ -d "$repo" ]; then
        log "Updating existing repository..."
        cd "$repo"
        git pull
    else
        log "Cloning repository..."
        gh repo clone "$repo"
        cd "$repo"
    fi
    
    # Create backup branch
    timestamp=$(date +%Y%m%d_%H%M%S)
    git branch "backup_${timestamp}" || log "Warning: Could not create backup branch"
    
    # Create necessary directories
    mkdir -p .github/workflows
    mkdir -p .semaphore
    
    # Copy configuration files (with error handling)
    log "Copying configuration files..."
    if [ "$DRY_RUN" = false ]; then
        cp -r ../../template-repo/.github/workflows/* .github/workflows/ 2>/dev/null || log "No workflow files to copy"
        cp ../../template-repo/.semaphore/semaphore.yml .semaphore/ 2>/dev/null || log "No Semaphore config to copy"
        cp ../../template-repo/.codacy.yml . 2>/dev/null || log "No Codacy config to copy"
        cp ../../template-repo/.snyk . 2>/dev/null || log "No Snyk config to copy"
        cp ../../template-repo/vercel.json . 2>/dev/null || log "No Vercel config to copy"
        
        # Check if there are changes to commit
        if git status --porcelain | grep .; then
            log "Changes detected, committing..."
            git add .
            git commit -m "Add tool configurations"
            git push
        else
            log "No changes to commit for $repo"
        fi
    else
        log "(DRY RUN) Would copy configuration files and commit changes"
    fi
    
    cd ..
    log "Completed configuration for $repo"
    log "----------------------------------------"
}

# Process repositories
if [ "$PARALLEL" = true ]; then
    for repo in $REPO_LIST; do
        process_repo "$repo" &
    done
    wait
else
    for repo in $REPO_LIST; do
        process_repo "$repo"
    done
fi

log "All repositories have been configured!"