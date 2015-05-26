let s:save_cpo = &cpo
set cpo&vim

let s:di_source = {
      \ 'name' : 'amazingbookmark',
      \ }

call unite#util#set_default('g:unite_source_amazingbookmark_directory',
      \ unite#get_data_directory() . '/amazingbookmark')

function! unite#sources#amazingbookmark#define() "{{{
  return s:di_source
endfunction "}}}

function! unite#sources#amazingbookmark#get_bookmark_list(st_file) "{{{
  let st_path = g:unite_source_amazingbookmark_directory . '/' . a:st_file
  if empty(glob(st_path))
    echom 'file not found ' . st_path
  endif
  let li_file = readfile(st_path)

  " setting default value
  let li_bookmarks = []
  for st_line in li_file
    let di_book = s:di_func.get_default()

    let [nu_level, st_title] = s:di_func.get_header(st_line)
    if nu_level != 0
      let di_book.name = st_line
    endif

    let [st_name, st_url] = s:di_func.get_url(st_line)
    if !empty(st_url)
      let di_book.name = st_name
      let di_book.url = st_url
      let di_book.type = s:di_func.is_dir(st_line) ? 'd' : 'f'
    endif

    if empty(st_line) || !empty(di_book.name)
      call add(li_bookmarks, di_book)
    endif
  endfor

  return li_bookmarks
endfunction "}}}

let s:di_func = {}
function! s:di_func.get_default() "{{{
  let di = {}
  let di.name = ''
  let di.url = ''
  let di.type = ''
  return di
endfunction "}}}
function! s:di_func.get_header(st_line) "{{{
  return [0, 'test']
endfunction "}}}
function! s:di_func.get_url(st_line) "{{{
  return ['google', 'http://www.google.co.jp/']
endfunction "}}}
function! s:di_func.is_dir(st_line) "{{{
  return 0
endfunction "}}}

function! s:di_source.gather_candidates(args, context) "{{{
  if len(a:args) != 1
    echom 'support only 1 args'
    return []
  endif

  let li_bookmarks = unite#sources#amazingbookmark#get_bookmark_list(a:args[0])

  let li_candidates = []
  for di_book in li_bookmarks
    let di_line = {}
    let di_line.word = di_book.name . '(' . di_book.url . ')'
    let di_line.action__path = di_book.url
    let di_line.action__text = di_book.url
    let di_line.action__line = di_book.line_no

    let kind = ''
    if !di_book.disabled
      if di_book.type == 'f'
        let kind = 'jump_list'
      endif
      if di_book.type == 'd'
        let kind = 'directory'
      endif
    endif
    let di_line.kind = kind

    call add(li_candidates, di_line)
  endfor

  return li_candidates
endfunction "}}}

let &cpo = s:save_cpo
unlet s:save_cpo

