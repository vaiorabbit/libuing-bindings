# Yet another libui-ng wrapper for Ruby
#
# * https://github.com/vaiorabbit/libuing-bindings

require 'ffi'
require_relative 'libuing_main.rb'

module UI
  extend FFI::Library

  @@libuing_import_done = false
  def self.load_lib(libpath, output_error = false)

    unless @@libuing_import_done
      # Ref.: Using Multiple and Alternate Libraries
      # https://github.com/ffi/ffi/wiki/Using-Multiple-and-Alternate-Libraries
      begin
        lib_paths = [libpath].compact

        ffi_lib_flags :now, :global
        ffi_lib *lib_paths
        setup_symbols(output_error)
      rescue => error
        $stderr.puts("[Warning] Failed to load libraries (#{error}).") if output_error
      end
    end

  end

  def self.setup_symbols(output_error = false)
    setup_main_symbols(output_error)
  end

end
