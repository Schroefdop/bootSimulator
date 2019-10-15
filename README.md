# Boot iOS simulators from terminal!

This `oh-my-zsh` plugin let's you easily boot iOS simulators from terminal.

## How to install

### Prerequisites
1. `zsh`
2. [`oh-my-zsh`](https://github.com/robbyrussell/oh-my-zsh)

### Installation
Open terminal and paste the following line.

`git clone https://github.com/Schroefdop/bootSimulator.git ~/.oh-my-zsh/custom/plugins/bootSimulator`

After cloning is done, add the plugin to you `.zshrc` file by pasting the following code in terminal:
This will append the `bootSimulator` plugin to the `plugins` list.
```
while read line; do
    if [[ $line == plugins* ]]; then
        sed -i -e 's/)/ bootSimulator)/g' ~/.zshrc
    fi
  done < ~/.zshrc
```

Restart terminal and run `bootSimulator`
