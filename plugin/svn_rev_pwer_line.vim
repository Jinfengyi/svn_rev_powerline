
" svn function
if exists('g:svn_rev_pwer_line_en')
  finish
endif

function! GetSvnLastRev() abort
  let s:file_name = expand('%:p')
  let s:svnLastRev = "svn log -l 1 ".s:file_name." | head -n 2 | tail -n 1 |awk '{print $1}'"
  let s:svnCmdLog = (system(s:svnLastRev))
  if(s:svnCmdLog =~"is not ")
    return ""
  else
    return s:svnCmdLog
  endif
endfunction

function! ChkSvnDiff()
  let s:d_file_name = expand('%:p')
  let s:svndiffcmd = "svn diff ".s:d_file_name." |less | head -n 2 | tail -n 1 |awk '{print $1}'"
  let s:svndiff = (system(s:svndiffcmd))
  if empty(s:svndiff)
    return ''
  elseif(s:svndiff=~"is not")
    return ''
  else
    return '!'
  endif
endfunction

let g:dic_svnrev={}
function! AddSvnRevToDict()
  if !has_key(g:dic_svnrev,bufnr('%'))
    let s:file_name = expand('%:p')
    let s:svnrev = substitute(GetSvnLastRev(), '\n', "", "g")
    let s:svndif = substitute(ChkSvnDiff(), '\n', "", "g")
    let g:dic_svnrev[bufnr('%')]=s:svnrev.s:svndif
  endif
endfunction

function! MoveSvnRevToDict()
  if has_key(g:dic_svnrev,bufnr('%'))
    unlet g:dic_svnrev[bufnr('%')]
  endif
endfunction

function! ClearSvnRevToDict()
  let g:dic_svnrev={}
endfunction

function! DispSvnRev()
  if has_key(g:dic_svnrev,bufnr('%'))
    let g:airline#extensions#branch#empty_message = g:dic_svnrev[bufnr('%')]
  endif
endfunction
"com! UpdateSvnRev   call DispSvnRev()

autocmd BufRead * call AddSvnRevToDict()
autocmd BufRead,WinEnter * call DispSvnRev()
autocmd QuitPre * call MoveSvnRevToDict()
