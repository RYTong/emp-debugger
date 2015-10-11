head
    = '<head>' ws* value:element* '</head>' {
        return value;
    }

element
    = script
    / style
    / link
    / comment

script
    = script_src
    / script_code

style
    = '<style>' value:(!'</style>' .)* '</style>' ws* {
        var value2 = [];
        value.forEach(function(x){ value2.push(x[1]); });
        return {
            type: 'style',
            value: value2.join('').trim()
        };
    }

script_src
    = value:script_src0 '/>' ws* { return value; }
    / value:script_src0 '>' ws* '</script>' ws* { return value; }

script_src0
    = '<script' ws* value:property* {
        return {
            type: 'script-src',
            props: value
        };
    }

script_code
    = '<script' ws* props:property* '>' value:(!'</script>' .)* '</script>' ws* {
        var value2 = [];
        value.forEach(function(x){ value2.push(x[1]); });
        return {
            type: 'script-code',
            props: props,
            value: value2.join('').trim()
        };
    }

link
    = value:link0 '/>' ws* { return value; }
    / value:link0 '>' ws* '</link>' ws* {return value; }

link0
    = '<link' ws* value:property* {
        return {
            type: 'link',
            props: value
        };
    }

comment
    = '<!--' value:(!'-->' .)* '-->' ws* {
        var value2 = [];
        value.forEach(function(x){ value2.push(x[1]); });
        return {
            type: 'comment',
            value: value2.join('').trim()
        };
    }

property
    = key:[a-z]+ '="' value:(!'"' .)* '"' ws* {
        var value2 = [];
        value.forEach(function(x){ value2.push(x[1]); });
        return {
            key: key.join(''),
            value: value2.join('')
        };
    }

ws
    = [ \t\r\n]