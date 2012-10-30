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

" get script local ID
function! s:get_SID() " {{{
  return matchstr(expand('<sfile>'), '<SNR>\d\+_')
endfunction
let s:SID = s:get_SID()
delfunction s:get_SID
"}}}

function! s:source.hooks.on_init(args, context)
    let a:context.update_time = g:unite_twitter_update_milliseconds
endfunction

function! s:source.async_gather_candidates(args, context)
    return map(unite#twitter#home_timeline(), "{
                \ 'word' : '@'.v:val.user.screen_name.': '.v:val.text.' ['.v:val.created_at.']',
                \ 'is_multiline' : 1,
                \ 'is_invalidate' : 1,
                \ }")
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
