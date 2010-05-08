require 'dl'


class CineSync::UI::Win32SaveFileDialog
  OFN_READONLY = 0x00000001
  OFN_OVERWRITEPROMPT = 0x00000002
  OFN_HIDEREADONLY = 0x00000004
  OFN_NOCHANGEDIR = 0x00000008
  OFN_SHOWHELP = 0x00000010
  OFN_ENABLEHOOK = 0x00000020
  OFN_ENABLETEMPLATE = 0x00000040
  OFN_ENABLETEMPLATEHANDLE = 0x00000080
  OFN_NOVALIDATE = 0x00000100
  OFN_ALLOWMULTISELECT = 0x00000200
  OFN_EXTENSIONDIFFERENT = 0x00000400
  OFN_PATHMUSTEXIST = 0x00000800
  OFN_FILEMUSTEXIST = 0x00001000
  OFN_CREATEPROMPT = 0x00002000
  OFN_SHAREAWARE = 0x00004000
  OFN_NOREADONLYRETURN = 0x00008000
  OFN_NOTESTFILECREATE = 0x00010000
  OFN_NONETWORKBUTTON = 0x00020000
  OFN_NOLONGNAMES = 0x00040000
  OFN_EXPLORER = 0x00080000
  OFN_NODEREFERENCELINKS = 0x00100000
  OFN_LONGNAMES = 0x00200000
  OFN_ENABLEINCLUDENOTIFY = 0x00400000
  OFN_ENABLESIZING = 0x00800000
  OFN_DONTADDTORECENT = 0x02000000
  OFN_FORCESHOWHIDDEN = 0x10000000
  OFN_EX_NOPLACESBAR = 0x00000001
  PROTOTYPE = 'LIISSLLSLSLSSLHHSIPS'
  MAX_PATH = 260

  def initialize(opts = {})
    @opts = {:title => "", :default_name => "", :extension => nil, :file_type => nil}.merge(opts)
    @opts[:file_type] ||= "#{opts[:extension].upcase} file"

    @ofn = DL.malloc(DL.sizeof(PROTOTYPE))
    @ofn.struct!(PROTOTYPE,
      :lStructSize,
      :hwndOwner,
      :hInstance,
      :lpstrFilter,
      :lpstrCustomFilter,
      :nMaxCustFilter,
      :nFilterIndex,
      :lpstrFile,
      :nMaxFile,
      :lpstrFileTitle,
      :nMaxFileTitle,
      :lpstrInitialDir,
      :lpstrTitle,
      :Flags,
      :nFileOffset,
      :nFileExtension,
      :lpstrDefExt,
      :lCustData,
      :lpfnHook,
      :lpTemplateName)

    @ofn[:lStructSize] = DL.sizeof(PROTOTYPE)
    @ofn[:hwndOwner] = 0
    @ofn[:lpstrFile] = DL.malloc(1024)
    @ofn[:lpstrFile] = @opts[:default_name] + "\0"
    @ofn[:nMaxFile] = MAX_PATH
    if @opts[:extension]
      ext = "*#{@opts[:extension]}"
      @ofn[:lpstrFilter] = "#{@opts[:file_type]} (#{ext})\0#{ext}\0"
    else
      @ofn[:lpstrFilter] = "\0"
    end
    @ofn[:nFilterIndex] = 1
    @ofn[:lpstrTitle] = @opts[:title] + "\0"
    @ofn[:lpstrFileTitle] = "\0"
    @ofn[:nMaxFileTitle] = 0
    @ofn[:lpstrInitialDir] = "\0"
    @ofn[:Flags] = OFN_OVERWRITEPROMPT

    @@comdlg32 ||= DL.dlopen('comdlg32.dll')
    @GetSaveFileName = @@comdlg32['GetSaveFileName','IP']
  end

  def execute!
    if @GetSaveFileName.call(@ofn)[0]
      @ofn[:lpstrFile].to_s
    else
      nil
    end
  end

  def filename
    @ofn[:lpstrFile].to_s
  end
end
