Set-StrictMode -Version 2.0
$ErrorActionPreference = "Stop"

$VimExecutable = "C:\Program Files\Vim\vim81\vim.exe"

function RunVimTest {
  Param(
    [string] $TestScript
  )
  $LogFilePath = New-TemporaryFile
  $ScriptArgs = (
    # Fix some situations where the UI could hang waiting for user input.
    "-c", "set nomore",
    "-S", "${TestScript}"
  )
  RunVimWithLogFile -LogFilePath $LogFilePath -VimArgs $ScriptArgs
}

function RunVimWithLogFile {
  Param(
    [string] $LogFilePath,
    [string[]] $VimArgs
  )

  # Log test output to a file. Also, tell the test framework to :cqall! on
  # failure.
  $VimArgs += ("--cmd", "set verbosefile=$LogFilePath")

  try {
    LogAndRun $VimExecutable @VimArgs
  } Finally {
    Get-Content -Path $LogFilePath
  }
}

function LogAndRun {
  Param(
    [string] $Executable,
    [parameter(ValueFromRemainingArguments = $true)]
    [string[]] $Arguments
  )
  Write-Host -ForegroundColor Green (EscapeExecutableArguments $Executable @Arguments)
  $ArgumentList = (EscapeExecutableArguments @Arguments)
  $Process = Start-Process `
    -ArgumentList $ArgumentList `
    -FilePath $Executable `
    -NoNewWindow `
    -PassThru `
    -Wait
  if ($Process.ExitCode -ne 0) {
    throw "Command failed with status $($Process.ExitCode): $($Executable) $($ArgumentList)"
  }
}

function EscapeExecutableArguments {
  Param(
    [parameter(ValueFromRemainingArguments = $true)]
    [string[]] $Arguments
  )
  # HACK(strager): This solution is bad. It works well enough for now, though.
  $Out = ""
  foreach ($Argument in $Arguments) {
    if ($Out -ne "") {
      $Out += " "
    }
    if ($Argument -match " ") {
      $Out += "`"${Argument}`""
    } else {
      $Out += $Argument
    }
  }
  return $Out
}

# TODO(strager): Fix failing (commented-out) tests.
#RunVimTest -NeedVimrc -TestScript vim/vim/autoload/strager/test_directory_browser.vim
#RunVimTest -NeedVimrc -TestScript vim/vim/autoload/strager/test_search_buffers.vim
#RunVimTest -NeedVimrc -TestScript vim/vim/autoload/strager/test_syntax.vim
#RunVimTest -NeedVimrc -TestScript vim/vim/autoload/strager/test_tag_c.vim
RunVimTest -NeedVimrc -TestScript vim/vim/test/test_CVE-2019-12735.vim
#RunVimTest -NeedVimrc -TestScript vim/vim/test/test_c_make_ninja.vim
#RunVimTest -NeedVimrc -TestScript vim/vim/test/test_clipboard.vim
#RunVimTest -NeedVimrc -TestScript vim/vim/test/test_color_column.vim
#RunVimTest -NeedVimrc -TestScript vim/vim/test/test_directory_browser.vim
#RunVimTest -NeedVimrc -TestScript vim/vim/test/test_format.vim
#RunVimTest -NeedVimrc -TestScript vim/vim/test/test_grep.vim
#RunVimTest -NeedVimrc -TestScript vim/vim/test/test_indentation.vim

RunVimTest -TestScript vim/vim/autoload/strager/test_assert.vim
RunVimTest -TestScript vim/vim/autoload/strager/test_assert_throws.vim
#RunVimTest -TestScript vim/vim/autoload/strager/test_buffer.vim
RunVimTest -TestScript vim/vim/autoload/strager/test_check_syntax.vim
RunVimTest -TestScript vim/vim/autoload/strager/test_check_syntax_internal.vim
RunVimTest -TestScript vim/vim/autoload/strager/test_cxx_symbol.vim
#RunVimTest -TestScript vim/vim/autoload/strager/test_exception.vim
#RunVimTest -TestScript vim/vim/autoload/strager/test_file.vim
RunVimTest -TestScript vim/vim/autoload/strager/test_file_sort.vim
#RunVimTest -TestScript vim/vim/autoload/strager/test_function.vim
RunVimTest -TestScript vim/vim/autoload/strager/test_fzf.vim
RunVimTest -TestScript vim/vim/autoload/strager/test_help.vim
RunVimTest -TestScript vim/vim/autoload/strager/test_list.vim
#RunVimTest -TestScript vim/vim/autoload/strager/test_messages.vim
#RunVimTest -TestScript vim/vim/autoload/strager/test_move_file.vim
RunVimTest -TestScript vim/vim/autoload/strager/test_path.vim
RunVimTest -TestScript vim/vim/autoload/strager/test_pattern.vim
#RunVimTest -TestScript vim/vim/autoload/strager/test_project.vim
RunVimTest -TestScript vim/vim/autoload/strager/test_random_mt19937.vim
#RunVimTest -TestScript vim/vim/autoload/strager/test_search_files.vim
RunVimTest -TestScript vim/vim/autoload/strager/test_window.vim
Write-Host "All tests passed!"
