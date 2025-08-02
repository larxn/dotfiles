
detect_package_manager() {
  if [ -f "yarn.lock" ]; then
    echo "yarn"

  elif [ -f "pnpm-lock.yaml" ]; then
    echo "pnpm"

  elif [ -f "package-lock.json" ]; then
    echo "npm"

  else
    echo "npm"
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
