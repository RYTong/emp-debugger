path = require 'path'
fs = require 'fs-plus'
Dialog = require './dialog'
_ = require 'underscore-plus'
{repoForPath} = require '../util/path-util'
emp = require '../exports/emp'

module.exports =
class AddDialog extends Dialog
  constructor: (initialPath, isCreatingFile) ->
    @isCreatingFile = isCreatingFile
    sNewFileName = initialPath
    #
    bCheckFlag = true
    if fs.isFileSync(sNewFileName)
      directoryPath = path.dirname(sNewFileName)
      directoryPath = path.join directoryPath, emp.DEFAULT_LESS_NAME
    else
      # bCheckFlag = false
      directoryPath = sNewFileName
      directoryPath = path.join directoryPath, emp.DEFAULT_LESS_NAME

    relativeDirectoryPath = directoryPath
    [@rootProjectPath, relativeDirectoryPath] = atom.project.relativizePath(directoryPath)
    # console.log directoryPath , relativeDirectoryPath
    # if bCheckFlag
    #   relativeDirectoryPath += path.sep if relativeDirectoryPath.length > 0
    relativeDirectoryPath

    super
      prompt: "Enter the path for the new " + if isCreatingFile then "file." else "folder."
      promptOut: "Enter the path of CSS file to create. (Like ../test.css)"
      promptImport: "Import styles from other style sheets"
      initialPath: relativeDirectoryPath
      outPath: emp.DEFAULT_OUT_LESS_PATH
      select: true
      iconClass: if isCreatingFile then 'icon-file-add' else 'icon-file-directory-create'

  onConfirm: (newPath, sOutName, lLessList) ->
    newPath = newPath.replace(/\s+$/, '') # Remove trailing whitespace
    sOutName = sOutName?.replace /\s+$/, ''
    endsWithDirectorySeparator = newPath[newPath.length - 1] is path.sep
    unless path.isAbsolute(newPath)
      unless @rootProjectPath?
        @showError("You must open a directory to create a file with a relative path")
        return

      newPath = path.join(@rootProjectPath, newPath)

    return unless newPath
    sNewFileCon = ""
    sNewLessCon = "// out: $sOutName \n\r "
    sImportFile = "@import \"$sImportFile\"; \n\r "
    unless !sOutName
      sNewFileCon = sNewFileCon + sNewLessCon.replace /\$sOutName/, sOutName


    sRelativePath = "/*<atom_emp_related_file_info>$relativePath</atom_emp_related_file_info>*/ \n\r "

    sTmpPath = path.dirname newPath
    sOutAbPath = path.resolve sTmpPath, sOutName
    sReAbPath = path.relative @rootProjectPath, sOutAbPath
    sReCon = sRelativePath.replace /\$relativePath/ , sReAbPath
    sNewFileCon = sNewFileCon + sReCon

    _.each lLessList, (sImportFileName ) =>
      sImportFileName = path.relative sTmpPath, sImportFileName
      sNewFileCon = sNewFileCon + sImportFile.replace /\$sImportFile/, sImportFileName

    try
      if fs.existsSync(newPath)
        @showError("'#{newPath}' already exists.")
      else if @isCreatingFile
        if endsWithDirectorySeparator
          @showError("File names must not end with a '#{path.sep}' character.")
        else
          fs.writeFileSync(newPath, sNewFileCon)
          repoForPath(newPath)?.getPathStatus(newPath)
          @trigger 'file-created', [newPath]
          @close()
      else
        fs.makeTreeSync(newPath)
        @trigger 'directory-created', [newPath]
        @cancel()
    catch error
      @showError("#{error.message}.")
