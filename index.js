const { cleaner } = require('./Cleaner')
const { fnObj } = require('./fnObjs')
const path = require('path')
const fs = require('fs')
const R = require('ramda')

const findStringDiff = R.curry( (str1, str2) => R.difference(
    R.split(/\r\n|\n/g, str1), R.split(/\r\n|\n/g, str2) ) )

const getDiff = R.curry( (file, otherDirFile) => {
    let findDiff = findStringDiff(
        cleaner.runFile(file),
        cleaner.runFile( otherDirFile + path.basename(file) )
    )
    if ( arrayIsEmpty(findDiff) ) {
        return findStringDiff(
            cleaner.runFile( otherDirFile + path.basename(file) ),
            cleaner.runFile(file)
        )
    } else {
        return findDiff
    }

})

const arrayIsEmpty = array => (array.length == 0 && array.length == 0) ? true : false

const isDiff = R.curry( (file, otherDirFile) => {
    if ( fs.existsSync(otherDirFile + path.basename(file) ) ) {
        console.log('Process: ',path.basename(file))

        let diffFile = getDiff(file, otherDirFile)
        console.log('diffFile: ',diffFile)
        if ( arrayIsEmpty(diffFile) )
            return { 'file': path.basename(file), status: false }
        else return {
            'file': path.basename(file),
            status: true,
            'diff': diffFile
        }
    } else return
})

const conctRoot = R.curry( (files, root) => R.map(file => {
    return path.resolve(root, file) }, files) )

const conctDirIsFile = R.pipe(
    conctRoot,
    R.filter( file => fs.statSync(file).isFile() )
)

const getFiles = dir => conctDirIsFile( fs.readdirSync(dir), dir )

const isDir = dir => fs.statSync(dir).isDirectory()

const existAndIsDir = R.both(fs.existsSync, isDir)

const chekAndGetFiles = R.both(existAndIsDir, getFiles)

const chekAndGetFiltFls = R.curry( (ext, dir) => R.filter(file => {
        return ext.indexOf( path.extname(file) ) > -1 }, chekAndGetFiles(dir)
    )
)

const getStatusDiffFile = (file, dir2 ) => isDiff(file, dir2)

const getStatusDiffDir = R.curry( (dir1, dir2, ext) => {
    return R.map( file => {
       return getStatusDiffFile(file, dir2) }, chekAndGetFiltFls(ext, dir1)
    )
})

const getTrueDiffFilesDetails = R.pipe(
    getStatusDiffDir,
    R.filter( R.prop('status') )
)

const getTrueDiffFilesList = R.pipe(
    getStatusDiffDir,
    R.filter( R.prop('status') ),
    R.map( R.prop('file') )
)

const getFalseDiffFilesList = R.pipe(
    getStatusDiffDir,
    R.filter( x => R.prop('status', x) == false ),
    R.map( R.prop('file') )
)

const generateReport = obj => {
    if (Array.isArray(obj) && obj.length != 0) {
        fs.writeFileSync('Report.txt', 'Reporte de diferencias:\n' + obj.join('\n') )
    } else {
        fs.writeFileSync('Report.txt', 'Reporte de diferencias:\n' + fnObj.deepObjToTxt(obj) )
    }
}

const reportGeneral = R.curry( (dir1, dir2) => generateReport(
        getStatusDiffDir(
            dir1,
            dir2,
            ['.sql']
        )
    )
)

const reportChangesList = R.curry( (dir1, dir2) => generateReport(
        getTrueDiffFilesList(
            dir1,
            dir2,
            ['.sql']
        )
    )
)

const reportNoChangeList = R.curry( (dir1, dir2) => generateReport(
        getFalseDiffFilesList(
            dir1,
            dir2,
            ['.sql']
        )
    )
)

const reportChangesDetailList = R.curry( (dir1, dir2) => generateReport(
        getTrueDiffFilesDetails(
            dir1,
            dir2,
            ['.sql']
        )
    )
)

const reportFile = R.curry( ( file, dir2) => generateReport( getDiff(file, dir2 ) ) )

/* Usage */
const dir1 = 'C:\\Users\\lapena\\Documents\\Luis Angel\\Sección Mavi\\Intelisis\\ObjsSQL\\SQL3100\\'
const dir2 = 'C:\\Users\\lapena\\Documents\\Luis Angel\\Sección Mavi\\Intelisis\\ObjsSQL\\SQL5000\\'

// const file = dir1 + 'dbo.Art.Table.sql'
const file = 'Data\\dbo.AjusteAnual.StoredProcedure.sql'
// const dir1 = 'Data\\'
// const dir2 = 'Data2\\'

/* Usage */
/*
    One file
        runFile: get 'true' if has diff,
        getDiff: get the diff in the file,
        reportFile: generate diff report file.

*/
// console.log(isDiff(file, dir2))
// console.log(getDiff(file, dir2))
// reportFile(file, dir2)

/*
    Dir
        reportGeneral: Generate a report of all the files True and False Diff.
        reportTrueList: Generate a list of all the files who´s have diff.
        reportFalseList: Generate a list of all the files who´s haven´t diff.
        reportTrueDetailsList: Generate a report detail of all the files who´s have diff.
*/
// reportGeneral(dir1, dir2)
// reportChangesList(dir1, dir2)
reportNoChangeList(dir1, dir2)
// reportChangesDetailList(dir1, dir2)

// module.exports.diffX = {
//     isDiff,
//     getDiff,
//     reportFile,
//     reportGeneral,
//     reportChangesList,
//     reportNoChangeList,
//     reportChangesDetailList
// }