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

function! unite#sources#bookmarkamazing#get_bookmark_file_list(st_file) "{{{
  let st_path = a:st_file
  let st_path = (empty(st_path) ? 'default.md' : st_path)
  let st_path = (st_path =~? '\.md$') ? st_path : st_path . '.md'
  let st_path = (st_path =~ '/$' ? st_path[: -2] : st_path)
  let st_path = g:unite_source_bookmarkamazing_directory . '/' . st_path

  if stridx(st_path, '*') != -1
    return map(filter(
          \ unite#util#glob(st_path),
          \ 'filereadable(v:val)'),
          \ 'fnamemodify(v:val, ":p")'
          \)
  endif

  return [st_path]
endfunction "}}}
function! unite#sources#bookmarkamazing#get_bookmark_list(st_fullpath) "{{{
  if empty(glob(a:st_fullpath))
    return []
  endif

  let li_bookmarks = []
  let li_headers_buffer = s:di_func.get_default_headers()
  for st_line in readfile(a:st_fullpath)
    " setting default value
    let di_book = s:di_func.get_default()

    let [nu_level, st_title] = s:di_func.get_title(st_line)
    if nu_level != -1
      let li_headers_buffer[nu_level] = st_title
      let di_book.name = st_line

      let di_book.headers = copy(li_headers_buffer)
      call add(li_bookmarks, di_book)
      continue
    endif

    if empty(st_line)

      let di_book.headers = copy(li_headers_buffer)
      call add(li_bookmarks, di_book)
      continue
    endif

    let [st_name, st_path] = s:di_func.get_path(st_line)
    if !empty(st_path)
      let di_book.name = '[' . st_name . ']'
      let di_book.path = st_path
      let di_book.type = s:di_func.is_dir(st_path) ? 'd' : 'f'

      let di_book.headers = copy(li_headers_buffer)
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
  let di.headers = []
  return di
endfunction "}}}
function! s:di_func.get_default_headers() "{{{
  return map(s:di_func.get_title_range(), '"undefined"')
endfunction "}}}
function! s:di_func.get_title_range() "{{{
  return range(0, 5)
endfunction "}}}
function! s:di_func.get_title(st_line) "{{{
  let nu_level = len(matchstr(a:st_line, '^#\+\ze\s')) - 1
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
function! s:di_func.is_skip(li_header, li_params) "{{{
  for nu_idx in s:di_func.get_title_range()
    if len(a:li_params) == nu_idx
      return 0
    endif
    if a:li_header[nu_idx] != a:li_params[nu_idx]
      return 1
    endif
  endfor
  return 0
endfunction "}}}

function! s:di_source.gather_candidates(args, context) "{{{
  let li_params = a:args[1:]

  let li_candidates = []
  let li_bookmark_files = unite#sources#bookmarkamazing#get_bookmark_file_list(get(a:args, 0, ''))
  for st_bookmark_file in li_bookmark_files
    let li_bookmarks = unite#sources#bookmarkamazing#get_bookmark_list(st_bookmark_file)
    for di_book in li_bookmarks
      if s:di_func.is_skip(di_book.headers, li_params)
        continue
      endif

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
  endfor

  return li_candidates
endfunction "}}}

function! unite#sources#bookmarkamazing#get_bookmark_file_complete_list(ArgLead, CmdLine, CursorPos) "{{{
  return uniq(['*' , 'default.md'] + map(split(glob(
        \ g:unite_source_bookmarkamazing_directory . '/' . a:ArgLead . '*.md'), '\n'),
        \ "fnamemodify(v:val, ':t')"))
endfunction  "}}}

function! s:di_source.complete(args, context, arglead, cmdline, cursorpos) "{{{
  return unite#sources#bookmarkamazing#get_bookmark_file_complete_list(a:arglead, a:cmdline, a:cursorpos)
endfunction "}}}

let &cpo = s:save_cpo
unlet s:save_cpo
