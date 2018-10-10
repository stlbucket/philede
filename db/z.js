const project = require('./cards-1886559526354682903.json')

console.log(project)

const stringified = JSON.stringify(project).split("'").join("''")

console.log(stringified)