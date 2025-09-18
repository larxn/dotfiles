#!/bin/bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if required tools are installed
check_dependencies() {
    if ! command -v gh &> /dev/null; then
        print_error "GitHub CLI (gh) is not installed. Please install it first."
        exit 1
    fi

    if ! command -v acli &> /dev/null; then
        print_error "Atlassian CLI (acli) is not installed. Please install it first."
        exit 1
    fi

    if ! command -v git &> /dev/null; then
        print_error "Git is not installed."
        exit 1
    fi

    if ! command -v jq &> /dev/null; then
        print_error "jq is not installed. Please install it first."
        exit 1
    fi
}

# Main function
main() {
    print_info "Starting PR creation process..."

    # Check dependencies
    check_dependencies

    # Get current branch and extract ticket ID
    local branch_name=$(git branch --show-current)
    print_info "Current branch: $branch_name"

    local ticket_id=$(echo "$branch_name" | cut -d'/' -f1)

    # Validate ticket ID format
    if [[ ! "$ticket_id" =~ ^[A-Z]+-[0-9]+$ ]]; then
        print_error "Invalid ticket ID format: $ticket_id"
        print_error "Expected format: TICKET-123"
        exit 1
    fi

    print_info "Extracted ticket ID: $ticket_id"

    # Fetch ticket data
    print_info "Fetching ticket data..."
    local ticket_data_file="/tmp/ticket_${ticket_id}.json"

    if ! acli jira workitem view "$ticket_id" --json > "$ticket_data_file" 2>/dev/null; then
        print_error "Failed to fetch ticket data for $ticket_id"
        print_error "Make sure the ticket exists and you have proper authentication set up"
        exit 1
    fi

    # Extract ticket name
    print_info "Parsing ticket data..."
    local ticket_name=$(jq -r '.fields.summary // empty' "$ticket_data_file" 2>/dev/null)

    if [ -z "$ticket_name" ] || [ "$ticket_name" = "null" ]; then
        print_warning "Could not extract ticket name. Using ticket ID as fallback."
        ticket_name="$ticket_id"
    fi

    print_info "Ticket name: $ticket_name"

    # Extract base URL for ticket link - try auth status first
    local site=$(acli jira auth status 2>/dev/null | grep -a "Site:" | sed 's/.*Site: //')
    local base_url=""

    if [ -n "$site" ]; then
        base_url="https://$site"
    else
        print_warning "Could not get site from auth status. Trying API response..."
        base_url="company.atlassian.net"
    fi

    local ticket_url="${base_url}/browse/${ticket_id}"
    print_info "Ticket URL: $ticket_url"

    # Get GitHub user
    print_info "Getting GitHub user..."
    local github_user=$(gh api user --jq '.login' 2>/dev/null)

    if [ -z "$github_user" ]; then
        print_error "Could not get current GitHub user. Make sure you're authenticated with GitHub CLI"
        exit 1
    fi

    print_info "GitHub user: $github_user"

    # Create PR
    local pr_title="${ticket_id}: ${ticket_name}"
    local pr_body="## Ticket
- [${ticket_name}](${ticket_url})

## Description

-

## Relevant pages

-

## Checklist

**Did you add or update tests?**

- [ ] 🌐 E2E
- [ ] 🧪 Unit/Feature
- [ ] 🙅 No testing needed

**Did you add or update documentation?**

- [ ] 📜 README.md
- [ ] 📓 Docs directory
- [ ] 📚 Postman/Swagger collection
  - Specify the path if applicable
- [ ] 💬 Inline code comments
- [ ] 🙅 No documentation needed
"

    print_info "Creating PR with title: $pr_title"

    local pr_url=$(gh pr create \
        --title "$pr_title" \
        --body "$pr_body" \
        --assignee "$github_user" 2>/dev/null)

    if [ $? -eq 0 ]; then
        print_info "PR created successfully: $pr_url"
    else
        print_error "Failed to create PR"
        exit 1
    fi

    # Cleanup
    rm -f "$ticket_data_file"

    print_info "Process completed successfully!"
}

# Run main function
main "$@"
