const {exec} = require('execa-pro')

async function createDb(databaseName){
  const command = `createdb -h ${process.env.DB_HOST} -p ${process.env.DB_PORT} -U ${process.env.DB_USER} ${databaseName}`

  try {
    await exec(command)
    return true
  } catch(e) {
    if (e.toString().indexOf('already exists') > -1) {
      return true
    } else {
      throw e
    }
  }
}

module.exports = createDb
