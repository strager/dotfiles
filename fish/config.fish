if status --is-interactive
  # See .vimrc
  function gs
    git status -s -b $argv
  end
  function gc
    git commit -v $argv
  end
  function g.
    git add -p $argv
  end
  function gi
    git add -i $argv
  end
  function gd
    git diff $argv
  end
  function gD
    git diff --cached $argv
  end
  function gv
    git pull --ff --commit $argv
  end
  function gu
    git push $argv
  end
  function gp
    git checkout -p $argv
  end
  function gr
    git rebase $argv
  end
  function grc
    git rebase --continue $argv
  end
  function go
    git checkout $argv
  end

  function ss
    ~/Projects/spaceport-server/spaceport-server $argv
  end
end

set PATH /usr/local/bin $PATH

set PATH $HOME/bin $PATH
set PATH $HOME/local/node/bin $PATH
set PATH $HOME/local/node/lib/node_modules/npm/bin/node-gyp-bin $PATH
set PATH $HOME/local/flex/bin $PATH
set PATH $HOME/local/zinnia/bin $PATH
set PATH $HOME/Library/Haskell/bin $PATH
set PATH $HOME/local/android/tools $PATH
set PATH $HOME/local/android/platform-tools $PATH
set PATH $HOME/local/bin $PATH
set PATH $HOME/local/android/tools $PATH
set PATH $HOME/local/android-ndk $PATH
set PATH $HOME/.cabal/bin $PATH
set PATH $HOME/Library/Haskell/bin $PATH
set PATH $HOME/Projects/fruitstrap $PATH
set PATH $HOME/local/flex-sdk/bin $PATH
set PATH $HOME/local/gyp $PATH

set --export EDITOR vim
set --export CABAL cabal

set --export ANDROID_SDK $HOME/local/android
set --export NDKROOT $HOME/local/android-ndk
set --export FLEX_HOME $HOME/local/flex-sdk

# Adapted from default fish_prompt.
function fish_prompt --description 'Write out the prompt'
  set -g __fish_prompt_status $status

  if not set -q __fish_prompt_normal
    set -g __fish_prompt_normal (set_color normal)
  end

  switch $USER
  case root
    if not set -q __fish_prompt_cwd
      if set -q fish_color_cwd_root
        set -g __fish_prompt_cwd (set_color $fish_color_cwd_root)
      else
        set -g __fish_prompt_cwd (set_color $fish_color_cwd)
      end
    end

  case '*'
    if not set -q __fish_prompt_cwd
      set -g __fish_prompt_cwd (set_color $fish_color_cwd)
    end
  end

  if test "$__fish_prompt_status" -eq 0
    set -g __fish_prompt_status_string ""
  else
    set -g __fish_prompt_status_string (printf ' %d' "$__fish_prompt_status")
  end

  printf '%s%s%s%s%s> ' \
    "$__fish_prompt_cwd" \
    (prompt_pwd) \
    (set_color $fish_color_error) \
    "$__fish_prompt_status_string" \
    "$__fish_prompt_normal"
end

# Adapted from default prompt_pwd.
function prompt_pwd --description 'Print the current working directory, shortend to fit the prompt'
  if test "$PWD" != "$HOME"
    printf "%s" (echo $PWD|sed -e "s|^$HOME|~|" -e 's-/\(\.\{0,1\}[^/]\)\([^/]*\)-/\1-g')
    echo $PWD|sed -e 's-.*/\.\{0,1\}[^/]\([^/]*$\)-\1-'
  else
    echo '~'
  end
end
