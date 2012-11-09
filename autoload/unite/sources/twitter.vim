scriptencoding utf-8

let s:save_cpo = &cpo
set cpo&vim

" source definition {{{
let s:source = {
    \   "name" : "twitter",
    \   "description" : "A Twitter timeline in unite.vim with a asynchronous update",
    \   "action_table" : {},
    \   "default_action" : "next_tweet",
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
    let a:context.source__timestamp = localtime() - a:context.source__interval_seconds - 1

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
    syntax match uniteSource__Twitter_Hashtag  /#[^ \n]\+/ contained containedin=uniteSource__Twitter
    highlight default link uniteSource__Twitter_ScreenName String
    highlight default link uniteSource__Twitter_Time       NonText
    highlight default link uniteSource__Twitter_Hashtag    Constant
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
        let text = has_key(tweet, 'retweeted_status')
                    \ ? 'RT @' . tweet.retweeted_status.user.screen_name . ': ' . tweet.retweeted_status.text
                    \ : tweet.text
        let text = substitute(tweet.text, '[\n]', ' ', 'g')
        let timeline += ['@'. tweet.user.screen_name . '   [<[' . tweet.created_at . ']>]',
                        \ text,
                        \ g:unite_twitter_separator]
    endfor

    return map( timeline, "{
                \ 'word' : v:val,
                \ 'is_multiline' : 1,
                \ }")
endfunction

function! s:source.async_gather_candidates(args, context)
    " check timestamp
    let now = localtime()
    if now - a:context.source__timestamp
                \ <= a:context.source__interval_seconds
        return []
    endif

    let a:context.source__timestamp = now
    return s:update(a:context)
endfunction
"}}}

" actions "{{{
let s:source.action_table.next_tweet = {
            \ 'description' : 'choose next tweet',
            \ 'is_quit' : 0
            \ }

function! s:source.action_table.next_tweet.func(candidate)
    if ! search('\n-\s\+'.g:unite_twitter_separator.'\s*\n\zs-\s\+@\w\+\s\+')
        normal gg
    endif
endfunction
"}}}

let &cpo = s:save_cpo
unlet s:save_cpo
