require_relative 'util/setup_dll'

onClosing = FFI::Function.new(:int, [:pointer, :pointer]) do |sender, sender_data|
  UI.Quit()
  return 1
end

onShouldQuit = FFI::Function.new(:int, [:pointer]) do |mainwin|
  UI.ControlDestroy(mainwin)
  return 1
end

def makeBasicControlsPage()
  vbox = UI.NewVerticalBox()
  UI.BoxSetPadded(vbox, 1)
  vbox
end

def makeNumbersPage()
  hbox = UI.NewHorizontalBox()
  UI.BoxSetPadded(hbox, 1)
  hbox
end

def makeDataChoosersPage()
  hbox = UI.NewHorizontalBox()
  UI.BoxSetPadded(hbox, 1)
  hbox
end

if __FILE__ == $PROGRAM_NAME
  init_opts = UI::InitOptions.new
  UI.Init(init_opts)

  mainwin = UI.NewWindow('libui Control Gallery', 640, 480, 1)
  UI.WindowOnClosing(mainwin, onClosing, nil)
  UI.OnShouldQuit(onShouldQuit, mainwin)

  tab = UI.NewTab()
  UI.WindowSetChild(mainwin, tab)
  UI.WindowSetMargined(mainwin, 1)

  UI.TabAppend(tab, 'Basic Controls', makeBasicControlsPage())
  UI.TabSetMargined(tab, 0, 1)

  UI.TabAppend(tab, 'Numbers and Lists', makeNumbersPage())
  UI.TabSetMargined(tab, 1, 1)

  UI.TabAppend(tab, "Data Choosers", makeDataChoosersPage())
  UI.TabSetMargined(tab, 2, 1)

  UI.ControlShow(mainwin)
  UI.Main()
  UI.Uninit()
end
