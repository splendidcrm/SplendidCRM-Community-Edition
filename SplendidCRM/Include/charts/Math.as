function numberFormat (num, thousandsDelim, decimalDelim, spaceFill) {
  // Default to a comma for thousands and a period for decimals.
  if (thousandsDelim == undefined) {thousandsDelim = "";}
  if (decimalDelim   == undefined) {decimalDelim= "";}

  // Convert the number to a string and split it at the decimal point.
  parts = String(num).split(".");

  // Take the whole number portion and store it as an array of single characters. 
  // This makes it easier to insert the thousands delimiters, as needed.
  partOneAr = parts[0].split("");

  // Reverse the array so we can process the characters right to left.
  partOneAr.reverse(  );

  // Insert the thousands delimiter after every third character.
  for (var i = 0, counter = 0; i < partOneAr.length; i++) {
    counter++;
    if (counter > 3) {
      counter = 0;
      partOneAr.splice(i, 0, thousandsDelim);
    }
  }

  // Reverse the array again so that it is back in the original order.
  partOneAr.reverse(  );

  // Create the formatted string using decimalDelim, if necessary.
  var val = partOneAr.join("");
  if (parts[1] != undefined) {
    val += decimalDelim + parts[1];
  }

  // If spaceFill is defined, add the necessary number of leading spaces.
  if (spaceFill != undefined) {
    // Store the original length before adding spaces.
    var origLength = val.length;
    for (var i = 0; i < spaceFill - origLength; i++) {
      val = " " + val;
    }
  }

  // Return the value.
  return val;
};
