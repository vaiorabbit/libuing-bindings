def libuing_bindings_gem_available?
  Gem::Specification.find_by_name('libuing-bindings')
rescue Gem::LoadError
  false
rescue
  Gem.available?('libuing-bindings')
end

if libuing_bindings_gem_available?
  # puts("Loading from Gem system path.")
  require 'libuing'

  s = Gem::Specification.find_by_name('libuing-bindings')
  shared_lib_path = s.full_gem_path + '/lib/'

  case RUBY_PLATFORM
  when /mswin|msys|mingw|cygwin/
    UI.load_lib(shared_lib_path + 'libui.dll')
  when /darwin/
    UI.load_lib(shared_lib_path + 'libui.dylib')
  when /linux/
    UI.load_lib(shared_lib_path + 'libui.so')
  else
    raise RuntimeError, "setup_dll.rb : Unknown OS: #{RUBY_PLATFORM}"
  end
else
  # puts("Loaging from local path.")
  require '../lib/libuing'

  case RUBY_PLATFORM
  when /mswin|msys|mingw|cygwin/
    UI.load_lib(Dir.pwd + '/../lib/' + 'libui.dll')
  when /darwin/
    UI.load_lib(Dir.pwd + '/../lib/' + 'libui.dylib')
  when /linux/
    UI.load_lib(Dir.pwd + '/../lib/' + 'libui.so')
  else
    raise RuntimeError, "setup_dll.rb : Unknown OS: #{RUBY_PLATFORM}"
  end
end
