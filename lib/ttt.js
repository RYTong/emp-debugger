
function test(){
  var editor = atom.workspace.activePaneItem
  var debug_text = editor.getText()
  console.log("ttttt-------test"+debug_text);
}

exports.test = test;
