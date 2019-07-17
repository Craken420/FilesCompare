const fs = require('fs')
const path = require('path')
const R = require('ramda')
const chardet = require('chardet')
const iconvlite = require('iconv-lite')

 /* SQL */
const patt = {
    /* SQL */
    ansis: /SET(?:[\s\n])*(QUOTED_IDENTIFIER|ANSI_NULLS|ANSI_WARNINGS)(?:[\s\n])*(OFF|on)|GO/gi,
    intlsComments: /^;.*?/gm,
    sqlMultiLineComments: /\/\*(?:[^/*]|\/(?!\*)|\*(?!\/))*\*\//g,
    sqlLineComments: /(\-\-+).*/gm,
    withNo: /(?:[\s\n])*with\((?:[\s\n])*(row|no)lock(?:[\s\n])*\)(?:[\s\n])*/gi
}

const ansis =  R.replace(patt.ansis, '')

const sqlLineComments = R.replace(patt.sqlLineComments, '')

const sqlMultiLineComments = function clsMultiLineCommentsSql (txt) {
    txt = txt.replace(patt.sqlMultiLineComments, '')
    if ( patt.sqlMultiLineComments.test(txt) ) {
        return clsMultiLineCommentsSql(txt)
    } else {
        return txt
    }
}

const withNo = R.replace(patt.withNo, ' ')

const tab = R.replace(/\t+/g, '')

const iniEndSpace = R.pipe( R.split(/\r\n|\r/g), R.map(R.trim), R.join('\n') )

const multiSpaceToOne = R.pipe(
    R.split(/\r\n|\r|\n/g),
    R.map(R.replace(/\s+/g, ' ')),
    R.join('\n')
)

const emptyLines = R.pipe( R.split(/\r\n|\r|\n/g), R.filter(Boolean), R.join('\n') )

const cmpEnterInHead = R.replace(/^\[(?=.*?\]$)/gm, '\n[')

const cleaner = R.pipe(
    withNo,
    // tab,
    // iniEndSpace,
    // multiSpaceToOne,
    // emptyLines,
    // R.toLower
)

const recode = R.curry( (cod, file) => iconvlite.decode( fs.readFileSync(file), cod) )

const getTxtInOrgnCod = file => recode(  chardet.detectFileSync(file), file )

const runFile = file => {
    if ( path.extname(file) == '.sql' ) { 
        return cleaner( getTxtInOrgnCod(file) )
    }
    else {
        return cleaner( getTxtInOrgnCod(file) )
    }
}

module.exports.cleaner = {
    runFile: runFile
}