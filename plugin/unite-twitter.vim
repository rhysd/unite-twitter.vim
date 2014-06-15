
function! s:set_global(name, default)
    let g:{a:name} = get(g:, a:name, a:default)
endfunction

call s:set_global('unite_twitter_config_dir', unite#get_data_directory().'/twitter')
call s:set_global('unite_twitter_consumer_key', 'TUGmA7swBfvAE84C3fkhJA')
call s:set_global('unite_twitter_consumer_secret', 'drnAzeAC6dgpJynXXBtSaRPE9cGT6vvVkI5ibQN2JY')
call s:set_global('unite_twitter_update_seconds', 60)
call s:set_global('unite_twitter_num_of_tweets', 40)
call s:set_global('unite_twitter_separator', '')

if ! isdirectory(g:unite_twitter_config_dir)
    call mkdir(g:unite_twitter_config_dir, 'p')
endif

command! -nargs=* Utwit execute 'Unite' 'twitter' <q-args> '-update-time='.&updatetime
