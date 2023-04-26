# Run make all to install all (if not already installed)
# Otherwise run make [package]

.PHONY: all vscode pyenv xclip zsh

all: vscode pyenv xclip zsh

vscode:
	@which code > /dev/null || (echo "Installing VS Code" && sudo apt-get update && sudo apt-get install -y code)

pyenv:
	@which pyenv > /dev/null || (echo "Installing Pyenv" && curl https://pyenv.run | bash)

xclip:
	@which xclip > /dev/null || (echo "Installing xclip" && sudo apt-get update && sudo apt-get install -y xclip)

zsh:
	@which zsh > /dev/null || (echo "Installing zsh and Oh My Zsh" && sudo apt-get update && sudo apt-get install -y zsh && sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)")
