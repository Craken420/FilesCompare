function checkDifferences(text1, text2){
  if (text1.length && text2.length){
    var words1 = text1.split(' ');
    var words2 = text2.split(' ');
    // Busca la mayor coincidencia
    for(var i=(words1.length > words2.length ? words2.length : words1.length); i > 0; i--){
      for(var j=0; j<=words1.length - i; j++){
        var pattern = words1.slice(j, j+i).join(' ');
        console.log(pattern)
        var coincidence = text2.indexOf(pattern);
        if (coincidence >= 0){
          // Coincidencia encontrada
          // Objeto diferencias de los textos anteriores a la coincidencia
          var differencesBefore = checkDifferences(words1.slice(0, j).join(' '),
                                      text2.substring(0, coincidence).trim());
          // Objeto diferencias de los textos posteriores a la coincidencia
          var differencesAfter = checkDifferences(words1.slice(j+i).join(' '),
                                      text2.substring(coincidence + pattern.length).trim());
          // Devuelve diferencias anteriores, posteriores y coincidencia actual
          return{
            differences1: differencesBefore.differences1.concat(differencesAfter.differences1),
            differences2: differencesBefore.differences2.concat(differencesAfter.differences2),
          }
        }
      }
    }
  }
  // No se ha encontrado coincidencias
  return {
    differences1: text1.length ? [text1] : [],
    differences2: text2.length ? [text2] : []
  };
}

function checkDifferencesByLength(text1, text2, length){
  var words1 = text1.split(' ');
  if (words1.length < length) return null;
  
  var differences = [];
  for (var i=0; i+length<=words1.length; i++){
    var pattern = words1.slice(i, i+length).join(' ');
    if (text2.indexOf(pattern)<0) differences.push(pattern);
  }
  return differences;
}

module.exports.diff = {
  checkDifferencesByLength,
  checkDifferences
}
// Usage
// var texto = "Aquí va el el primer texto a analizar e incluso con palabras repetidas repetidas";
// var texto2 = "Aquí va el segundo texto a analizar analizar e incluso con algunas palabras repetidas";

// var result = checkDifferences(texto, texto2);

// console.log('Primer texto: ' + texto);
// console.log('Segundo texto: ' + texto2);

// console.log('Coincidencias:\n' + result.coincidences.join('\n'));
// console.log('Elementos diferentes en primer texto:\n' + result.differences1.join('\n'));
// console.log('Elementos diferentes en segundo texto:\n' + result.differences2.join('\n'));

// var resultByLength = checkDifferencesByLength(texto, texto2, 4);
// console.log('Grupos de 4 palabras del primer texto que no existen en el segundo:\n'
//   + resultByLength.join('\n'));
// resultByLength = checkDifferencesByLength(texto2, texto, 4);
// console.log('Grupos de 4 palabras del segundo texto que no existen en el primero:\n'
//   + resultByLength.join('\n'));