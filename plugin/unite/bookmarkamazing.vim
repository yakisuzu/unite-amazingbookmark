let s:save_cpo = &cpo
set cpo&vim


" ------------------------------
" init
" ------------------------------
call unite#sources#bookmarkamazing#make_directory()

"TODO custom korosu
"call unite#custom#action('file', 'bookmark', s:file_bookmark_action)
"call unite#custom#action('buffer', 'bookmark', s:buffer_bookmark_action)
if exists(':UniteBookmarkAdd')
  delcommand UniteBookmarkAdd
endif


" ------------------------------
" public
" ------------------------------
command! -nargs=? -complete=customlist,s:unite_bookmarkamazing_edit_comp
      \ UniteBookmarkAmazingEdit call s:unite_bookmarkamazing_edit(<q-args>)


" ------------------------------
" private function edit
" ------------------------------
function! s:unite_bookmarkamazing_edit(st_arg) "{{{
  let st_file = empty(a:st_arg) ? 'default.md' : a:st_arg
  let st_file = (st_file =~? '\.md$') ? st_file : st_file . '.md'
  let st_path = g:unite_source_bookmarkamazing_directory . '/' . st_file
  if empty(glob(st_path))
    echom 'file not found ' . st_path
  endif

  silent exe join(['sp', st_path])
endfunction "}}}
function! s:unite_bookmarkamazing_edit_comp(A,L,P) "{{{
  return unite#sources#bookmarkamazing#get_bookmark_file_complete_list(a:A, a:L, a:P, ['*'])
endfunction "}}}


let &cpo = s:save_cpo
unlet s:save_cpo
