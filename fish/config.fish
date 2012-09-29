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
  function go
    git checkout $argv
  end

  function ss
    ~/Projects/spaceport-server/spaceport-server $argv
  end
end

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
set --export EDITOR vim
set --export CABAL cabal-dev

set --export ANDROID_SDK $HOME/local/android
set --export NDKROOT $HOME/local/android-ndk
set --export FLEX_HOME $HOME/local/flex-sdk
