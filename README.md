# strager's dotfiles

**EDUCATIONAL USE ONLY**. This work is Copyright Matthew "strager" Glazar.
License: [Creative Commons Attribution-NonCommercial-NoDerivatives 4.0
International License (CC-BY-NC-ND-4.0)](LICENSE)

## Installation

These dotfiles are deployed using [Ansible][]. First, make sure Ansible is
installed.

Install or update dotfiles symlinks by running the Ansible playbook:

```shell
# Linux/macOS:
ansible-playbook site.yml
# Windows:
.\deploy.ps1
```

### Opt-in roles

Some roles modify application preferences one-way. Syncing is not performed by
default, so you need to manually run these roles:

- `ansible-playbook site.yml --tags gnome-terminal`
- `ansible-playbook site.yml --tags iterm`

[Ansible]: https://docs.ansible.com/projects/ansible/latest/index.html
