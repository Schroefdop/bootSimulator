# Boot iOS simulators from terminal!

This `oh-my-zsh` plugin lets you easily boot iOS simulators from terminal.

## How to install

### Prerequisites
1. `zsh`
2. [`oh-my-zsh`](https://github.com/robbyrussell/oh-my-zsh)

### Installation
Open terminal and paste the following lines. This will clone the repository to the right location, add `bootSimulator` to the plugins located in `~/.zshrc` and restart your shell.

```
git clone https://github.com/Schroefdop/bootSimulator.git ~/.oh-my-zsh/custom/plugins/bootSimulator
while read line; do; if [[ $line == plugins* ]]; then; sed -i -e 's/)/ bootSimulator)/g' ~/.zshrc; fi;  done < ~/.zshrc
exec zsh
```

Run `bootSimulator` to run the script!  

![](https://media.giphy.com/media/ZbOGdJJzqvOWkPchrt/giphy.gif)
