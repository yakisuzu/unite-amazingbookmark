let s:save_cpo = &cpo
set cpo&vim

let s:di_source = {
      \ 'name' : 'bookmarkamazing',
      \ }

call unite#util#set_default('g:unite_source_bookmarkamazing_directory',
      \ unite#get_data_directory() . '/bookmarkamazing')

function! unite#sources#bookmarkamazing#define() "{{{
  return s:di_source
endfunction "}}}

function! unite#sources#bookmarkamazing#get_bookmark_list(st_file) "{{{
  let st_path = g:unite_source_bookmarkamazing_directory . '/' . a:st_file
  if empty(glob(st_path))
    echom 'file not found ' . st_path
    return []
  endif
  let li_file = readfile(st_path)

  let li_bookmarks = []
  for st_line in li_file
    " setting default value
    let di_book = s:di_func.get_default()

    if empty(st_line)
      call add(li_bookmarks, di_book)
      continue
    endif

    let [nu_level, st_title] = s:di_func.get_header(st_line)
    if nu_level != 0
      let di_book.name = st_line
      call add(li_bookmarks, di_book)
      continue
    endif

    let [st_name, st_path] = s:di_func.get_path(st_line)
    if !empty(st_path)
      let di_book.name = '[' . st_name . ']'
      let di_book.path = st_path
      let di_book.type = s:di_func.is_dir(st_path) ? 'd' : 'f'
      call add(li_bookmarks, di_book)
      continue
    endif
  endfor

  return li_bookmarks
endfunction "}}}

let s:di_func = {}
function! s:di_func.get_default() "{{{
  let di = {}
  let di.name = ''
  let di.path = ''
  let di.type = ''
  return di
endfunction "}}}
function! s:di_func.get_header(st_line) "{{{
  let nu_level = len(matchstr(a:st_line, '^#\+\ze\s'))
  let st_title = matchstr(a:st_line, '\v^#+\s+\zs.+$')
  return [nu_level, st_title]
endfunction "}}}
function! s:di_func.get_path(st_line) "{{{
  let st_name = matchstr(a:st_line, '^\[\zs.\+\ze\](')
  let st_path = matchstr(a:st_line, '^\[.\+\](\zs.\+\ze)')
  return [st_name, st_path]
endfunction "}}}
function! s:di_func.is_dir(st_line) "{{{
  return a:st_line =~? '\v(\\|\/)$'
endfunction "}}}

function! s:di_source.gather_candidates(args, context) "{{{
  if len(a:args) != 1
    echom 'support only 1 args'
    return []
  endif

  let li_bookmarks = unite#sources#bookmarkamazing#get_bookmark_list(a:args[0])

  let li_candidates = []
  for di_book in li_bookmarks
    let di_line = {}

    let st_type = empty(di_book.type) ? '' : '[' . di_book.type . ']'
    let st_path = empty(di_book.path) ? '' : '(' . di_book.path . ')'
    let di_line.word = join([st_type, di_book.name, st_path], '')

    let di_line.action__path = di_book.path
    let di_line.action__text = di_book.path

    let st_kind = ''
    if di_book.type == 'f'
      let st_kind = 'jump_list'
    endif
    if di_book.type == 'd'
      let st_kind = 'directory'
    endif
    let di_line.kind = st_kind

    call add(li_candidates, di_line)
  endfor

  return li_candidates
endfunction "}}}

let &cpo = s:save_cpo
unlet s:save_cpo

