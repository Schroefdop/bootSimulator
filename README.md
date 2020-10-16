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
while read line; do; if [[ $line == plugins* ]]; then; sed -i -e 's/plugins=(/plugins=(bootSimulator /g' ~/.zshrc; fi;  done < ~/.zshrc
exec zsh
```

Run `bootSimulator` to run the script!  

## Features
- Looks into the `/Applications/` directory for apps starting with `Xcode`. When multiple are found, an option will be presented to switch Xcode tools. This is required if you would like to launch an older Simulator.app
- Checks the available Simulator iOS versions
- Lists available devices for the chosen iOS version
- Open one or more devices on your command!

![](https://media.giphy.com/media/ZbOGdJJzqvOWkPchrt/giphy.gif)
