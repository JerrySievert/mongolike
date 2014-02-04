var fs = require('fs');

if (process.argv.length !== 4) {
  console.log("USAGE: node convert.js infile outfile");
  process.exit(1);
}

var inFile  = process.argv[2],
    outFile = process.argv[3];


var inData = fs.readFileSync(inFile, 'utf8');

var lines = inData.split("\n");

var out = "create_collection('us_cities');\n";

for (var i = 0; i < lines.length; i++) {
  var parts = lines[i].split(",");

  var obj = {
    "Country":   parts[0],
    "City":      parts[1],
    "Region":    parts[2],
    "Latitude":  Number(parts[3]),
    "Longitude": Number(parts[4])
  };

  out += "SELECT save('us_cities', '" + JSON.stringify(obj) + "');\n";
}

fs.writeFileSync(outFile, out, 'utf8');

console.log("done!");
