scriptencoding utf-8

let s:save_cpo = &cpo
set cpo&vim

" source definition {{{
let s:source = {
    \   "name" : "twitter",
    \   "description" : "A Twitter timeline in unite.vim with a asynchronous update",
    \   "action_table" : {},
    \   "hooks" : {},
    \   "syntax" : "uniteSource__Twitter",
    \}

function! unite#sources#twitter#define()
    return s:source
endfunction
"}}}

" init and syntax hooks "{{{
function! s:source.hooks.on_init(args, context)
    " init timestamp
    let a:context.source__interval_seconds = g:unite_twitter_update_seconds
    call writefile([localtime() - a:context.source__interval_seconds - 1],
                \ g:unite_twitter_config_dir.'/last_update')

    " for highlight
    setlocal conceallevel=2
    setlocal concealcursor=nc

endfunction

function! s:source.hooks.on_syntax(args, context)
    " syntax match uniteSource__Twitter_ScreenName /\<@[a-zA-Z0-9_]\+\>/ contained containedin=uniteSource__Twitter
    syntax match uniteSource__Twitter_ScreenName /@[a-zA-Z0-9_]\+\>/ contained containedin=uniteSource__Twitter
    syntax match uniteSource__Twitter_Time       /\[<\[[^\]]\+\]>\]/ contained containedin=uniteSource__Twitter
    syntax match uniteSource__Twitter_TimeBlock  /\[<\[/ conceal contained containedin=uniteSource__Twitter_Time
    syntax match uniteSource__Twitter_TimeBlock  /\]>\]/ conceal contained containedin=uniteSource__Twitter_Time
    highlight default link uniteSource__Twitter_ScreenName String
    highlight default link uniteSource__Twitter_Time       NonText
    highlight default link uniteSource__Twitter_TimeBlock  Ignore
endfunction
"}}}

" gather candidates asynchronously "{{{
function! s:update(context)
    let a:context.source__counter = 0
    let a:context.source.unite__cached_candidates = []
    let timeline = []

    for tweet in unite#twitter#home_timeline({
                \ 'per_page' : g:unite_twitter_num_of_tweets,
                \ 'count' : g:unite_twitter_num_of_tweets
                \ })
        let timeline += ['@'. tweet.user.screen_name . '   [<[' . tweet.created_at . ']>]',
                        \ substitute(tweet.text, '[\n]', ' ', 'g'),
                        \ g:unite_twitter_separator]
    endfor

    " update a timestamp
    call writefile([localtime()], g:unite_twitter_config_dir.'/last_update')

    return map( timeline, "{
                \ 'word' : v:val,
                \ 'is_multiline' : 1,
                \ }")
endfunction

function! s:source.async_gather_candidates(args, context)
    " read timestamp and now seconds
    let last_update = readfile(g:unite_twitter_config_dir.'/last_update')[0]

    if localtime() - last_update <= a:context.source__interval_seconds
        return []
    endif

    return s:update(a:context)
endfunction
"}}}

let &cpo = s:save_cpo
unlet s:save_cpo
