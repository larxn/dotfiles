#--------------------------------------------
# Directory Management
#--------------------------------------------

# Create a new directory and step into it
mkcd() {
    mkdir -p -- "$1" && cd -- "$1"
}

# Create a new directory and step into it
mkcode() {
    mkdir -p -- "$1" && code -- "$1"
}

#--------------------------------------------
# Process Management
#--------------------------------------------
alias kp='npx kill-port'


#--------------------------------------------
# Git
#--------------------------------------------
alias gpl='git pull'
alias gp='git push'
alias gci='git commit -m '
alias gchb='git checkout -b '
alias gch='git checkout '
alias ggh='git checkout main || git checkout master'
alias gs='git switch -'
alias glog='git log --oneline'

#--------------------------------------------
# Node Package Manager Aliases
#--------------------------------------------
detect_package_manager() {
  if [ -f "yarn.lock" ]; then
    echo "yarn"

  elif [ -f "pnpm-lock.yaml" ]; then
    echo "pnpm"

  elif [ -f "package-lock.json" ]; then
    echo "npm"

  else
    echo "pnpm"
  fi
}

# Install packages
i() {
    local pm=$(detect_package_manager)

    # If no parameters are provided, run the package manager installer
    if [ $# -eq 0 ]; then
        case $pm in
            "yarn")
                yarn install
                ;;
            "pnpm")
                pnpm install
                ;;
            "npm")
                npm install
                ;;
        esac

    else
        # If parameters are provided, add the specified packages
        case $pm in
            "yarn")
                yarn add "$@"
                ;;
            "pnpm")
                pnpm add "$@"
                ;;
            "npm")
                npm install "$@"
                ;;
        esac
    fi
}

# Run dev script
d() {
    local pm=$(detect_package_manager)
    case $pm in
        "yarn")
            yarn dev
            ;;
        "pnpm")
            pnpm dev
            ;;
        "npm")
            npm run dev
            ;;
    esac
}

# Uninstall packages
u() {
    local pm=$(detect_package_manager)
    case $pm in
        "yarn")
            yarn remove "$@"
            ;;
        "pnpm")
            pnpm remove "$@"
            ;;
        "npm")
            npm uninstall "$@"
            ;;
    esac
}

# Run build script
b() {
    local pm=$(detect_package_manager)
    case $pm in
        "yarn")
            yarn build
            ;;
        "pnpm")
            pnpm build
            ;;
        "npm")
            npm run build
            ;;
    esac
}

# Run storybook script
sb() {
    local pm=$(detect_package_manager)
    case $pm in
        "yarn")
            yarn storybook
            ;;
        "pnpm")
            pnpm storybook
            ;;
        "npm")
            npm run storybook
            ;;
    esac
}
