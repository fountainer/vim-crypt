if exists('g:vim_crypt_loaded')
  finish
else
  if !has('python3')
    throw "has('python3') = 0"
  " check if has simplecrypt module
  endif
  let g:vim_crypt_loaded = 1
endif

function g:GetBuffStr()
  let l:buff = join(getline(1, '$'), "\n")
  return buff
endfunction

function g:PutBuffStr(str)
  execute "normal! ggdG"
  call append(line('$'), a:str)
  execute "normal! dd"
  " hide Pattern not found Error
  " "\n" means a null character in vim. Replace it with newline.
  execute ":silent! %s/\\%x00/\r/g"
endfunction

function g:Encrypt(passwd, data)

  echom "Encrypting..."
python3 << EOF
import simplecrypt
import vim
import base64
passwd = vim.eval('a:passwd')
data = vim.eval('a:data')
encrypted_data = simplecrypt.encrypt(passwd, data)
encrypted_string = base64.b64encode(encrypted_data).decode('utf-8')
vim.command("let encrypted_string = '%s'" % encrypted_string)
EOF

  return encrypted_string
endfunction

" reduntant code
function g:Decrypt(passwd, data)
  echom "Decrypting..."
  try
python3 << EOF
import simplecrypt
import vim
import base64
passwd = vim.eval('a:passwd')
data = vim.eval('a:data')
data = base64.b64decode(data)
decrypted_data = simplecrypt.decrypt(passwd, data).decode('utf-8')
vim.command("let decrypted_data = '%s'" % decrypted_data)
EOF
  return decrypted_data
  " Do not know how to catch exception thrown by Python.
  " Other errors may occur.
  catch
    throw "Wrong pass word or modified data!"
  endtry
endfunction

function g:EncryptBuff(passwd)
  let text = GetBuffStr()
  let text = Encrypt(a:passwd, text)
  call PutBuffStr(text)
endfunction


function g:DecryptBuff(passwd)
  let text = GetBuffStr()
  let text = Decrypt(a:passwd, text)
  call PutBuffStr(text)
endfunction

command! -bar -nargs=1 Encrypt call EncryptBuff(<q-args>)
command! -bar -nargs=1 Decrypt call DecryptBuff(<q-args>)
