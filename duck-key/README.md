# duck-key

Reduces system audio volume by 90% while the right Option key is held down.

## Setup

1. Build: `make`
2. Grant Accessibility permission to the `duck-key` binary in System Settings > Privacy & Security > Accessibility
3. Run `./duck-key` and test: hold right Option key, observe volume drop; release, observe restore
4. Install as service: run Ansible from the dotfiles root

## View logs

    tail -f ~/Library/Logs/local.strager.duck-key.log
