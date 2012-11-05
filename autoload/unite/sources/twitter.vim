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
    let a:context.source__count_limit =
                \ (empty(a:args) ? g:unite_twitter_update_seconds : str2nr(a:args[0]))
                \   * 1000 / a:context.update_time
    if a:context.source__count_limit == 0
        let a:context.source__count_limit = 1
    endif
    let a:context.source__counter = a:context.source__count_limit
endfunction

function! s:source.hooks.on_syntax(args, context)
    
endfunction

function! s:update(context)
    let a:context.source__counter = 0
    let a:context.source.unite__cached_candidates = []
    return map(unite#twitter#home_timeline(), "{
                \ 'word' : '@'.v:val.user.screen_name.': '.v:val.text.' ['.v:val.created_at.']',
                \ 'is_multiline' : 1,
                \ }")
endfunction

" get script local ID
function! s:source.async_gather_candidates(args, context)
    echo "utwit:".a:context.source__counter
    if a:context.source__counter < a:context.source__count_limit
        let a:context.source__counter += 1
        return []
    endif

    return s:update(a:context)
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
