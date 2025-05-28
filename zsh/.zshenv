# Zsh startup file hierarchy:

# ~/.zshenv ← Use this for environment variables
# ~/.zprofile (login shells only)
# ~/.zshrc (interactive shells - for aliases, functions, prompt)
# ~/.zlogin (login shells, after zshrc)

if [ -f ~/.env ]; then
    source ~/.env
fi
