function! s:twibill()
    if ! exists('s:twibill_instance')
        let tokens = unite#twitter#get_token()
        let config = {
                    \ 'consumer_key'        : g:unite_twitter_consumer_key,
                    \ 'consumer_secret'     : g:unite_twitter_consumer_secret,
                    \ 'access_token'        : tokens[0],
                    \ 'access_token_secret' : tokens[1],
                    \ }
        let s:twibill_instance = twibill#new(config)
    endif
    return s:twibill_instance
endfunction

function! unite#twitter#get_token()
    let token_path = g:unite_twitter_config_dir . '/token'
    let screen_name_path = g:unite_twitter_config_dir . '/screen_name'
    if filereadable(token_path) && filereadable(screen_name_path)
      return readfile(token_path)
    endif

    try
        let ctx = twibill#access_token({
                    \ 'consumer_key'        : g:unite_twitter_consumer_key ,
                    \ 'consumer_secret'     : g:unite_twitter_consumer_secret ,
                    \ })

        let tokens = [ctx.access_token, ctx.access_token_secret]
        call writefile(tokens, token_path)

        let config = {
                     \ 'consumer_key'        : g:unite_twitter_consumer_key ,
                     \ 'consumer_secret'     : g:unite_twitter_consumer_secret ,
                     \ 'access_token'        : tokens[0] ,
                     \ 'access_token_secret' : tokens[1] ,
                     \ }

        let account    = twibill#new(config).verify_credentials()
        call writefile([account.screen_name], screen_name_path)

        return tokens
    catch
        " TODO appropriate error handling
        redraw
        echohl Error
        echo 'error at authentication'
        echo v:throwpoint
        echo v:exception
        echohl None
    endtry
endfunction

function! unite#twitter#home_timeline(...)
    let params = empty(a:000) ? {} : a:1
    try
        let result = s:twibill().home_timeline(params)
    catch
        echohl Error
        echo 'network error when getting hometimeline data'
        echo v:throwpoint
        echo v:exception
        echohl None
        return []
    endtry

    if type(result) == type({}) && has_key(result, 'error')
        echohl Error
        echo 'Twitter API returns error when getting hometimeline data'
        echo 'error: '.result.error
        echohl None
        return []
    endif

    return result
endfunction

function! unite#twitter#screen_name()
    let screen_name_path = g:unite_twitter_config_dir . '/screen_name'
    return filereadable(screen_name_path) ?
                \ readfile(screen_name_path)[0] : ''
endfunction
