## twitter source for unite.vim

A Twitter timeline in unite.vim with an asynchronous update. This is a kind of testing. I may make pull-request to TweetVim if this'd make it.
If you want more features, try to use TweetVim made by @basyura.

## Requirements

- open-browser.vim
- twibill.vim

## Usage

Simply do `:Utwit` command.
If you use this command at first time, a browser will be opened and you must authenticate the application.

All `:Unite` options are available in `:Utwit` too, except `-update-time=` option.

If you want to change winwidth or winheight, an example is below.

    :UTwit -winwidth=70 -vertical

If you want to remove a cursor highlight, an example is below.

    :UTwit -no-cursor-line
