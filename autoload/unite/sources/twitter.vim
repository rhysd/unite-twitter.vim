scriptencoding utf-8

let s:save_cpo = &cpo
set cpo&vim

" source definition {{{
let s:source = {
    \   "name" : "twitter",
    \   "description" : "A Twitter timeline in unite.vim with a asynchronous update",
    \   "action_table" : {},
    \   "hooks" : {},
    \}

function! unite#sources#twitter#define()
    return s:source
endfunction
"}}}

function! s:source.hooks.on_init(args, context)
    let a:context.source__counter = 2
endfunction

" get script local ID
function! s:source.async_gather_candidates(args, context)
    " TODO 更新間隔を updatetime の倍数に設定できるように（設定自体は絶対秒で
    " 指定できるようにする）
    if a:context.source__counter < 2
        let a:context.source__counter += 1
        return []
    endif

    let a:context.source__counter = 0
    let a:context.source.unite__cached_candidates = []
    return map(unite#twitter#home_timeline(), "{
                \ 'word' : '@'.v:val.user.screen_name.': '.v:val.text.' ['.v:val.created_at.']',
                \ 'is_multiline' : 1,
                \ }")
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
