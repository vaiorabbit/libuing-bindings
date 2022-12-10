require_relative '../lib/libuing'

# Ref.: https://github.com/ffi/ffi/wiki/Callbacks
onClosing = FFI::Function.new(:int, [:pointer, :pointer]) do |sender, sender_data|
  puts 'Closing...'
  UI.Quit()
  return 1
end

if __FILE__ == $PROGRAM_NAME
  UI.load_lib(Dir.pwd + '/../lib/libui.dylib')
  init_opts = UI::InitOptions.new
  UI.Init(init_opts)

  w = UI.NewWindow('Hello', 200, 50, 0)
  UI.WindowOnClosing(w, onClosing, nil)

  l = UI.NewLabel('World')
  UI.WindowSetChild(w, l)

  UI.ControlShow(w)
  UI.Main()
  UI.Uninit()
end
