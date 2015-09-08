var path = require('path');
var parse = require('./lib/parser').parse;


module.exports.insert = function(content, filename, indent) {
    var ret = /<head>[\s\S]*?<\/head>/g.exec(content);

    if (ret) {
        var ast = parse(ret[0]);
        var out = process(ast, filename, indent);
        return content.replace(/<head>[\s\S]*?<\/head>/g, out.trim());
    } else {
        throw("No head content found");
    }
}

function process(ast, filename, indent) {
    if (path.extname(filename) == '.lua') {
        ast = insert_lua(ast, filename);
    } else {
        ast = insert_css(ast, filename);
    }

    return stringify(ast, indent);
}

function insert_lua(ast, filename) {
    var notfound = true;

    ast.forEach(function(node) {
        if (node.type == 'script-src') {
            node.props.forEach(function(prop) {
                if (prop.key == 'src' && prop.value == filename) {
                    notfound = false;
                }
            })
        }
    });

    if (notfound) {
        ast.push({
            "type": "script-src",
            "props": [
                {
                    "key": "type",
                    "value": "text/x-lua"
                },
                {
                    "key": "src",
                    "value": filename
                }
            ]
        });
    }

    return ast;
}

function insert_css(ast, filename) {
    var notfound = true;

    ast.forEach(function(node) {
        if (node.type == 'link') {
            node.props.forEach(function(prop) {
                if (prop.key == 'ref' && prop.value == filename) {
                    notfound = false;
                }
            })
        }
    });

    if (notfound) {
        ast.push({
            "type": "link",
            "props": [
                {
                    "key": "type",
                    "value": "text/css"
                },
                {
                    "key": "ref",
                    "value": filename
                }
            ]
        });
    }

    return ast;
}

function stringify(ast, indent) {
    var out = indent + "<head>\n"

    ast.forEach(function(node) {
        out += stringify_(node, indent+indent, indent);
    });
    out += indent + "</head>";

    return out;
}

function stringify_(node, indent, i) {
    var out = "";

    if (node.type == 'style') {
        out += indent + "<style>\n";
        out += align(node.value, i) + "\n";
        out += indent + "</style>\n";
    } else if (node.type == 'script-src') {
        out += indent + "<script";
        out += stringify_props(node.props);
        out += "/>\n";
    } else if (node.type == 'script-code') {
        out += indent + "<script";
        out += stringify_props(node.props);
        out += ">\n";
        out += i + i + i + node.value + "\n";
        out += indent + "</script>\n";
    } else if (node.type == 'link') {
        out += indent + "<link";
        out += stringify_props(node.props);
        out += "/>\n";
    } else if (node.type == 'comment') {
        out += align("<!--" + node.value + "-->", i) + "\n";
    }

    return out;
}

function stringify_props(props) {
    var out = "";

    props.forEach(function(prop) {
        out += ' ' + prop.key + '="' + prop.value + '"';
    });

    return out;
}

function align(value, indent) {
    value = value.replace(/\n\s*/g, "\n" + indent + indent + indent);
    value = indent + indent + indent + value;
    return value;
}