let s:save_cpo = &cpo
set cpo&vim

let s:vjson = vital#of("amazingbookmark").import("Web.JSON")
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
  let di_bookmarks = s:vjson.decode(join(readfile(st_path)))

  " setting default value
  let di_bookmarks.bookmarks = map(di_bookmarks.bookmarks, "{
        \ 'name' : get(v:val, 'name', ''),
        \ 'url' : get(v:val, 'url', ''),
        \ 'type' : get(v:val, 'type', 'd'),
        \ 'disabled' : get(v:val, 'disabled', 0),
        \ 'line_no' : get(v:val, 'line_no', 0),
        \ }")
  return di_bookmarks
endfunction "}}}

function! s:di_source.gather_candidates(args, context) "{{{
  if len(a:args) != 1
    echom 'support only 1 args'
    return []
  endif

  let di_bookmarks = unite#sources#amazingbookmark#get_bookmark_list(a:args[0])

  let li_candidates = []
  for di_book in di_bookmarks.bookmarks
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

