#!/usr/bin/env bash

# Extract casks from the Nix file
nix_casks=$(sed -n '/casks = \[/,/];/p' modules/homebrew.nix | sed -E 's/^[[:space:]]*"([^"]+)"[[:space:]]*$/\1/' | grep -v 'casks = \[' | grep -v '\];')

# Get the list of installed casks from Homebrew
brew_casks=$(/opt/homebrew/bin/brew list --cask)

# Find the difference
diff_casks=$(diff <(echo "$brew_casks" | sort) <(echo "$nix_casks" | sort) | grep '<' | sed 's/^< //')

# Uninstall the casks found in the diff
if [[ -n "$diff_casks" ]]; then
    echo "The following casks will be uninstalled:"
    echo "$diff_casks"

    while read -r cask; do
        echo "Uninstalling $cask..."
        /opt/homebrew/bin/brew uninstall --cask "$cask"
    done <<< "$diff_casks"
else
    echo "No extra casks to uninstall."
fi
