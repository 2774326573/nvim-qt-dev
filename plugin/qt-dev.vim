" nvim-qt-dev - Qt开发插件
" 版本: 1.0.0
" 作者: Your Name
" 许可证: MIT

if exists('g:loaded_qt_dev')
  finish
endif
let g:loaded_qt_dev = 1

" 保存兼容性设置
let s:save_cpo = &cpo
set cpo&vim

" 插件默认设置
if !exists('g:qt_dev_enabled')
  let g:qt_dev_enabled = 1
endif

if !exists('g:qt_dev_auto_setup')
  let g:qt_dev_auto_setup = 1
endif

" 定义命令
command! -nargs=* -complete=customlist,QtDevProjectComplete QtCreate lua require('qt-dev').create_project(<f-args>)
command! -nargs=? QtDesktop lua require('qt-dev').create_desktop(<f-args>)
command! -nargs=? QtConsole lua require('qt-dev').create_console(<f-args>)
command! -nargs=? QtQml lua require('qt-dev').create_qml(<f-args>)
command! QtSetup lua require('qt-dev.config').setup_wizard()
command! QtConfig lua require('qt-dev.config').show_config()
command! QtStatus lua require('qt-dev.tools.status').check_project_status()
command! QtBuild lua require('qt-dev.tools.build').build_project()
command! QtRun lua require('qt-dev.tools.build').run_project()
command! QtClean lua require('qt-dev.tools.build').clean_project()
command! QtDesigner lua require('qt-dev.tools.designer').open_designer()

" 项目类型补全
function! QtDevProjectComplete(ArgLead, CmdLine, CursorPos)
  return ['desktop', 'console', 'web', 'qml', 'library']
endfunction

" 自动命令组
augroup QtDev
  autocmd!
  " 检测Qt项目
  autocmd BufRead,BufNewFile *.cpp,*.h,*.hpp,*.cc,*.cxx,*.pro,*.pri,*.ui call s:CheckQtProject()
  " CMake文件变更时自动重新配置
  autocmd BufWritePost CMakeLists.txt,*.cmake call s:OnCMakeChange()
augroup END

" 检测Qt项目
function! s:CheckQtProject()
  if s:IsQtProject() && g:qt_dev_enabled
    lua require('qt-dev').on_qt_project_detected()
  endif
endfunction

" 检查是否为Qt项目
function! s:IsQtProject()
  " 检查Qt项目的标识文件
  return filereadable('CMakeLists.txt') ||
       \ filereadable('*.pro') ||
       \ filereadable('*.pri') ||
       \ isdirectory('ui') ||
       \ glob('*.ui') != '' ||
       \ glob('*.qrc') != '' ||
       \ search('find_package.*Qt[56]', 'nw') > 0
endfunction

" CMake文件变更处理
function! s:OnCMakeChange()
  if s:IsQtProject()
    lua require('qt-dev.tools.build').on_cmake_change()
  endif
endfunction

" 设置文件类型特定的功能
augroup QtDevFiletype
  autocmd!
  autocmd FileType cpp,c lua require('qt-dev').setup_cpp_features()
  autocmd FileType qml lua require('qt-dev').setup_qml_features()
augroup END

" 快捷键映射（可选，用户可以在配置中禁用）
if get(g:, 'qt_dev_default_mappings', 1)
  " 项目管理
  nnoremap <silent> <leader>qn :QtCreate<CR>
  nnoremap <silent> <leader>qb :QtBuild<CR>
  nnoremap <silent> <leader>qr :QtRun<CR>
  nnoremap <silent> <leader>qc :QtClean<CR>
  nnoremap <silent> <leader>qd :QtDesigner<CR>
  nnoremap <silent> <leader>qs :QtStatus<CR>
  nnoremap <silent> <leader>qx :QtSetup<CR>
endif

" 状态行集成（可选）
if get(g:, 'qt_dev_statusline', 0)
  function! QtDevStatusline()
    if s:IsQtProject()
      return '[Qt]'
    endif
    return ''
  endfunction
endif

" 恢复兼容性设置
let &cpo = s:save_cpo
unlet s:save_cpo