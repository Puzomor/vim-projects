let g:vim_projects_filename = get(g:, 'vim_projects_filename', '.project.vim')

let b:separator = {0: '/', 1: '\'}[has('win32')]

function s:IsPathSame(path1, path2)
  if has('win32')
    return a:path1 ==? a:path2
  endif

  return a:path1 ==# a:path2
endfunction

function s:FindProjectFile(directory)
  let l:project_file = globpath(a:directory, g:vim_projects_filename)

  if !empty(l:project_file)
    return l:project_file
  endif

  let l:newdir = fnamemodify(a:directory, ':h')
  if !empty(l:newdir) && !s:IsPathSame(l:newdir, a:directory)
    return s:FindProjectFile(l:newdir)
  endif

  return ""
endfunction

function s:LoadProjectFile(directory)
  let l:project_file = s:FindProjectFile(a:directory)
  if !empty(l:project_file)
    execute("source ".l:project_file)
  endif
endfunction

function s:PrepArgs(file)
  if !s:IsPathSame(fnamemodify(a:file, ":t"), g:vim_projects_filename)
    call s:LoadProjectFile(fnamemodify(a:file, ":h"))
  endif
endfunction

function s:OpenProjectFile(directory)
  l:project_file = s:FindProjectFile(a:directory)
  if !empty(l:project_file)
    execute("edit ".l:project_file)
  endif
endfunction

augroup VimProjects
  autocmd!
  autocmd BufReadPre * :call s:PrepArgs(expand("<afile>:p"))
augroup END

command VimProjectsOpen :call s:OpenProjectFile(expand("%:p:h"))
