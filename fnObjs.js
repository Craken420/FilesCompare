const R = require('ramda')

module.exports.fnObj = (function () {

    const _objToTxt = R.pipe(
        R.toPairs,
        R.map(R.join('\n')),
        R.join('\n')
    )
    
    const _isObj = R.pipe(
        R.clone,
        Object.getPrototypeOf,
        R.equals({})
    )

    const _hasObj = objEntry => {
        let obj = R.clone(objEntry)
        for (key in obj ) {
            if (isObj(obj[key])) {
                return true
            }
        }
        return false
    }

    const _hasArray = objEntry => {
        let obj = R.clone(objEntry)
        for (key in obj ) {
            if (isArray(obj[key])) {
                return true
            }
        }
        return false
    }
    
    const _hasntObj = R.complement(hasObj)
    const _hasntArray = R.complement(hasArray)
    
    const _isArray = R.pipe(
        Object.getPrototypeOf,
        R.equals([])
    )
    
    const _arrayToText = val => {
        if ( isArray(val) ) {
            if ( hasntArray(val) && hasntObj(val) ) {
                val = val.join('\n')
            } else if ( hasObj(val) ) {
                val = deepObjToTxt(val)
            } else if ( hasArray(val) ) {
                val = R.map(arrayToText, val)
            } else {
                val = val
            }
        } else if ( hasObj(val) ) {
            val = deepObjToTxt(val)
        } else {
            val = val
        }
    
        return val
    }

   
    
    const _multiObjsToTxt = val => {
    
        if ( isObj(val) ) {
    
            if ( hasArray(val) ) {
                val = R.map(arrayToText, val)
            }
    
            if ( hasntObj(val) ) {
                val = objToTxt(val)
            } else {
                val = deepObjToTxt(val)
            }
    
        } else if ( isArray(val) ) {
            val = arrayToText(val)
        } else {
            val = val
        }
    
        return val
    }
   
    const _deepObjToTxt = entryObj => {
    
        let obj = R.clone(entryObj)
    
        if ( hasObj(obj) ) {
            obj = R.map(multiObjsToTxt, obj)
        }
    
        if ( hasArray(obj) ) {
            obj = R.map(arrayToText, obj)
        }
    
        if ( hasObj(obj) && hasArray(val) ) {
            deepObjToTxt(obj)
        } else {
            return objToTxt(obj)
        }
    }

    function objToTxt       (val) { return _objToTxt(val)   }
    function isObj          (val) { return _isObj(val)      }
    function hasObj         (val) { return _hasObj(val)     }
    function hasArray       (val) { return _hasArray(val)   }
    function hasntObj       (val) { return _hasntObj(val)   }
    function hasntArray     (val) { return _hasntArray(val) }
    function isArray        (val) { return _isArray(val)    }
    function arrayToText    (val) { return _arrayToText(val)    }
    function multiObjsToTxt (val) { return _multiObjsToTxt(val) }
    function deepObjToTxt   (val) { return _deepObjToTxt(val)   }

    return {
        objToTxt,
        isObj,
        hasObj,
        hasArray,
        hasntObj,
        hasntArray,
        isArray,
        arrayToText,
        multiObjsToTxt,
        deepObjToTxt
    }
})();

const obj1 = {
    "glossary": {
        "title": "example glossary",
		"GlossDiv": {
            "title": "S",
			"GlossList": {
                "GlossEntry": {
                    "ID": "SGML",
					"SortAs": "SGML",
					"GlossTerm": "Standard Generalized Markup Language",
                    "Acronym": "SGML",
                    "popup": {
                        "menuitem": [
                            {"value": "New", "onclick": "CreateNewDoc()"},
                            {"value": "Open", "onclick": "OpenDoc()"},
                            {
                                "value": "Close", 
                                "onclick": {
                                    "menuitem": [
                                        {"value": "New", "onclick": "CreateNewDoc()"},
                                        {"value": "Open", "onclick": "OpenDoc()"},
                                        {
                                            "value": "Close",
                                            "popup": {
                                                "menuitem": [
                                                    {"value": "New", "onclick": "CreateNewDoc()"},
                                                    {"value": "Open", "onclick": "OpenDoc()"},
                                                    {"value": ["File", "Folder"], "onclick": "CloseDoc()"}
                                                ]
                                            }
                                        }
                                    ]
                                }
                            }
                        ]
                    },
					"Abbrev": "ISO 8879:1986",
					"GlossDef": {
                        "para": "A meta-markup language, used to create markup languages such as DocBook.",
						"GlossSeeAlso": ["GML", {
                            "menuitem": [
                                {"value": "New", "onclick": "CreateNewDoc()"},
                                {"value": "Open", "onclick": "OpenDoc()"},
                                {"value": ["File", "Folder"], "onclick": "CloseDoc()"}
                            ]
                        }]
                    },
					"GlossSee": ["File", "Folder"]
                }
            }
        }
    }
}

const obj11 = {
    "glossary": {
        "title": "example glossary",
		"GlossDiv": {
            "title": "S",
			"GlossList": {
                "GlossEntry": {
                    "ID": "SGML",
					"SortAs": "SGML",
					"GlossTerm": "Standard Generalized Markup Language",
                    "Acronym": "SGML",
                    "popup": {
                        "menuitem": [
                            {"value": "New", "onclick": "CreateNewDoc()"},
                            {"value": "Open", "onclick": "OpenDoc()"},
                            {
                                "value": "Close", 
                                "onclick": {
                                    "menuitem": [
                                        {"value": "New", "onclick": "CreateNewDoc()"},
                                        {"value": "Open", "onclick": "OpenDoc()"},
                                        {
                                            "value": "Close"
                                        }
                                    ]
                                }
                            }
                        ]
                    },
					"Abbrev": "ISO 8879:1986",
					"GlossDef": {
                        "para": "A meta-markup language, used to create markup languages such as DocBook.",
						"GlossSeeAlso": ["GML", "lao"]
                    },
					"GlossSee": ["File", "Folder"]
                }
            }
        }
    }
}

const obj2 = {
    "menu": {
        "id": "file",
        "value": "File",
        "popup": {
            "menuitem": [
                {"value": "New", "onclick": "CreateNewDoc()"},
                {"value": "Open", "onclick": "OpenDoc()"},
                {"value": "Close", "onclick": "CloseDoc()"}
            ]
        }
    }
}

const obj22 = {
    "menu": {
        "id": "file",
        "value": "File",
        "popup": {
            "menuitem": [
                "value",
                "Open",
               "onclick"
            ]
        }
    }
}

const obj3 = [
    {
        "menu": {
            "id": "file",
            "value": "File"
        }
    }
]

const obj44 = {
    "id": "file",
    "value": "File",
    "menu": {
        "id": {
            "idieee": "fileeee",
            "valueeeee": "Fileeeee"
        },
        "value": "File"
    }
}

const obj4 = {
    "id": "file",
    "value": "File",
    "menu": {
        "id": "file",
        "value": "File"
    }
}

const obj55 = {
    "id": "1726",
    "value": ["File", "Folder"]
}

const obj5 = {
    "id": "1726",
    "value": "File"
}

// console.log('lol: obj5 \n',this.fnObj.deepObjToTxt(obj55))
// console.log('lol: obj5 \n',this.fnObj.deepObjToTxt(obj5))
// console.log('lol: obj4 \n'this.fnObj.deepObjToTxt(obj4))
// console.log('lol: obj4 \n',this.fnObj.deepObjToTxt(obj1))
// console.log('lol: obj5 \n',this.fnObj.deepObjToTxt(obj1))
// console.log('lol: obj5 \n',this.fnObj.deepObjToTxt(obj1))
// console.log('lol: obj5 \n',this.fnObj.deepObjToTxt(obj1))
// console.log('lol: obj5 \n',this.fnObj.deepObjToTxt(obj1))
// console.log('lol: obj5 \n',this.fnObj.deepObjToTxt(obj1))