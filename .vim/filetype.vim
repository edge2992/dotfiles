augroup filetypedetect
    " 読み込み時、新規ファイル作成時に、.rb,
    " .erbで終わるファイルだったら、ruby用の設定ファイルを読み込む
    au BufRead, BufNewFile *.rb *.erb setfiletype ruby
augroup END
