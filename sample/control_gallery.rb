require_relative 'util/setup_dll'

$onClosing = FFI::Function.new(:int, [:pointer, :pointer]) do |sender, sender_data|
  UI.Quit()
  return 1
end

$onShouldQuit = FFI::Function.new(:int, [:pointer]) do |mainwin|
  UI.ControlDestroy(mainwin)
  return 1
end

def makeBasicControlsPage()
  vbox = UI.NewVerticalBox()
  UI.BoxSetPadded(vbox, 1)

  hbox = UI.NewHorizontalBox()
  UI.BoxSetPadded(hbox, 1)
  UI.BoxAppend(vbox, hbox, 0)

  UI.BoxAppend(hbox, UI.NewButton('Button'), 0)
  UI.BoxAppend(hbox, UI.NewCheckbox('Checkbox'), 0)

  UI.BoxAppend(vbox, UI.NewLabel("This is a label.\nLabels can span multiple lines."), 0)

  UI.BoxAppend(vbox, UI.NewHorizontalSeparator(), 0)

  group = UI.NewGroup('Entries')
  UI.GroupSetMargined(group, 1)
  UI.BoxAppend(vbox, group, 1)

  entryForm = UI.NewForm()
  UI.FormSetPadded(entryForm, 1)
  UI.GroupSetChild(group, entryForm)

  UI.FormAppend(entryForm, 'Entry', UI.NewEntry(), 0)
  UI.FormAppend(entryForm, 'Password Entry', UI.NewPasswordEntry(), 0)
  UI.FormAppend(entryForm, 'Search Entry', UI.NewSearchEntry(), 0)
  UI.FormAppend(entryForm, 'Multiline Entry', UI.NewMultilineEntry(), 1)
  UI.FormAppend(entryForm, 'Multiline Entry No Wrap', UI.NewNonWrappingMultilineEntry(), 1)

  return vbox
end

$spinbox = nil
$slider = nil
$pbar = nil

$onSpinboxChanged = FFI::Function.new(:void, [:pointer, :pointer]) do |s, data|
  UI.SliderSetValue($slider, s)
  UI.ProgressBarSetValue($pbar, s)
end

$onSliderChanged = FFI::Function.new(:void, [:pointer, :pointer]) do |s, data|
  UI.SpinboxSetValue($spinbox, s)
  UI.ProgressBarSetValue($pbar, s)
end

def makeNumbersPage()
  hbox = UI.NewHorizontalBox()
  UI.BoxSetPadded(hbox, 1)

  group = UI.NewGroup('Numbers')
  UI.GroupSetMargined(group, 1)
  UI.BoxAppend(hbox, group, 1)

  vbox = UI.NewVerticalBox()
  UI.BoxSetPadded(vbox, 1)
  UI.GroupSetChild(group, vbox)

  $spinbox = UI.NewSpinbox(0, 100)
  $slider = UI.NewSlider(0, 100)
  $pbar = UI.NewProgressBar()
  UI.SpinboxOnChanged($spinbox, $onSpinboxChanged, nil)
  UI.SliderOnChanged($slider, $onSliderChanged, nil)
  UI.BoxAppend(vbox, $spinbox, 0)
  UI.BoxAppend(vbox, $slider, 0)
  UI.BoxAppend(vbox, $pbar, 0)

  ip = UI.NewProgressBar()
  UI.ProgressBarSetValue(ip, -1)
  UI.BoxAppend(vbox, ip, 0)

  group = UI.NewGroup('Lists')
  UI.GroupSetMargined(group, 1)
  UI.BoxAppend(hbox, group, 1)

  vbox = UI.NewVerticalBox()
  UI.BoxSetPadded(vbox, 1)
  UI.GroupSetChild(group, vbox)

  cbox = UI.NewCombobox()
  UI.ComboboxAppend(cbox, 'Combobox Item 1')
  UI.ComboboxAppend(cbox, 'Combobox Item 2')
  UI.ComboboxAppend(cbox, 'Combobox Item 3')
  UI.BoxAppend(vbox, cbox, 0)

  ecbox = UI.NewEditableCombobox()
  UI.EditableComboboxAppend(ecbox, 'Editable Item 1')
  UI.EditableComboboxAppend(ecbox, 'Editable Item 2')
  UI.EditableComboboxAppend(ecbox, 'Editable Item 3')
  UI.BoxAppend(vbox, ecbox, 0)

  rb = UI.NewRadioButtons()
  UI.RadioButtonsAppend(rb, 'Radio Button 1')
  UI.RadioButtonsAppend(rb, 'Radio Button 2')
  UI.RadioButtonsAppend(rb, 'Radio Button 3')
  UI.BoxAppend(vbox, rb, 0)

  return hbox
end

$mainwin = nil

$onOpenFileClicked = FFI::Function.new(:void, [:pointer, :pointer]) do |button, entry|
  filename = UI.OpenFile($mainwin)
  if filename == nil
    UI.EntrySetText(entry, '(cancelled)')
  else
    UI.EntrySetText(entry, filename)
    UI.FreeText(filename)
  end
end

$onOpenFolderClicked = FFI::Function.new(:void, [:pointer, :pointer]) do |button, entry|
  filename = UI.OpenFolder($mainwin)
  if filename == nil
    UI.EntrySetText(entry, '(cancelled)')
  else
    UI.EntrySetText(entry, filename)
    UI.FreeText(filename)
  end
end

$onSaveFileClicked = FFI::Function.new(:void, [:pointer, :pointer]) do |button, entry|
  filename = UI.SaveFile($mainwin)
  if filename == nil
    UI.EntrySetText(entry, '(cancelled)')
  else
    UI.EntrySetText(entry, filename)
    UI.FreeText(filename)
  end
end

$onMsgBoxClicked = FFI::Function.new(:void, [:pointer, :pointer]) do |button, entry|
  UI.MsgBox($mainwin, "This is a normal message box.", "More detailed information can be shown here.")
end

$onMsgBoxErrorClicked = FFI::Function.new(:void, [:pointer, :pointer]) do |button, entry|
  UI.MsgBoxError($mainwin, "This message box describes an error.", "More detailed information can be shown here.")
end

def makeDataChoosersPage()
  hbox = UI.NewHorizontalBox()
  UI.BoxSetPadded(hbox, 1)

  vbox = UI.NewVerticalBox()
  UI.BoxSetPadded(vbox, 1)
  UI.BoxAppend(hbox, vbox, 0)

  UI.BoxAppend(vbox, UI.NewDatePicker(), 0)
  UI.BoxAppend(vbox, UI.NewTimePicker(), 0)
  UI.BoxAppend(vbox, UI.NewDateTimePicker(), 0)

  UI.BoxAppend(vbox, UI.NewFontButton(), 0)
  UI.BoxAppend(vbox, UI.NewColorButton(), 0)

  UI.BoxAppend(hbox, UI.NewVerticalSeparator(), 0)

  vbox = UI.NewVerticalBox()
  UI.BoxSetPadded(vbox, 1)
  UI.BoxAppend(hbox, vbox, 1)

  grid = UI.NewGrid()
  UI.GridSetPadded(grid, 1)
  UI.BoxAppend(vbox, grid, 0)

  button = UI.NewButton("  Open File  ")
  entry = UI.NewEntry()
  UI.EntrySetReadOnly(entry, 1)
  UI.ButtonOnClicked(button, $onOpenFileClicked, entry)
  UI.GridAppend(grid, button,
                0, 0, 1, 1,
                0, UI::AlignFill, 0, UI::AlignFill)
  UI.GridAppend(grid, entry,
                1, 0, 1, 1,
                1, UI::AlignFill, 0, UI::AlignFill)

  button = UI.NewButton("Open Folder")
  entry = UI.NewEntry()
  UI.EntrySetReadOnly(entry, 1)
  UI.ButtonOnClicked(button, $onOpenFolderClicked, entry)
  UI.GridAppend(grid, button,
                0, 1, 1, 1,
                0, UI::AlignFill, 0, UI::AlignFill)
  UI.GridAppend(grid, entry,
                1, 1, 1, 1,
                1, UI::AlignFill, 0, UI::AlignFill)

  button = UI.NewButton("  Save File  ")
  entry = UI.NewEntry()
  UI.EntrySetReadOnly(entry, 1)
  UI.ButtonOnClicked(button, $onSaveFileClicked, entry)
  UI.GridAppend(grid, button,
                0, 2, 1, 1,
                0, UI::AlignFill, 0, UI::AlignFill)
  UI.GridAppend(grid, entry,
                1, 2, 1, 1,
                1, UI::AlignFill, 0, UI::AlignFill)

  msggrid = UI.NewGrid()
  UI.GridSetPadded(msggrid, 1)
  UI.GridAppend(grid, msggrid,
                0, 3, 2, 1,
                0, UI::AlignCenter, 0, UI::AlignStart)

  button = UI.NewButton("Message Box")
  UI.ButtonOnClicked(button, $onMsgBoxClicked, nil)
  UI.GridAppend(msggrid, button,
                0, 0, 1, 1,
                0, UI::AlignFill, 0, UI::AlignFill)
  button = UI.NewButton("Error Box")
  UI.ButtonOnClicked(button, $onMsgBoxErrorClicked, nil)
  UI.GridAppend(msggrid, button,
                1, 0, 1, 1,
                0, UI::AlignFill, 0, UI::AlignFill)

  return hbox
end

if __FILE__ == $PROGRAM_NAME
  init_opts = UI::InitOptions.new
  UI.Init(init_opts)

  $mainwin = UI.NewWindow('libui Control Gallery', 640, 480, 1)
  UI.WindowOnClosing($mainwin, $onClosing, nil)
  UI.OnShouldQuit($onShouldQuit, $mainwin)

  tab = UI.NewTab()
  UI.WindowSetChild($mainwin, tab)
  UI.WindowSetMargined($mainwin, 1)

  UI.TabAppend(tab, 'Basic Controls', makeBasicControlsPage())
  UI.TabSetMargined(tab, 0, 1)

  UI.TabAppend(tab, 'Numbers and Lists', makeNumbersPage())
  UI.TabSetMargined(tab, 1, 1)

  UI.TabAppend(tab, 'Data Choosers', makeDataChoosersPage())
  UI.TabSetMargined(tab, 2, 1)

  UI.ControlShow($mainwin)
  UI.Main()
  UI.Uninit()
end
