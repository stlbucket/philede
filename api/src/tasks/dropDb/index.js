const {exec} = require('execa-pro')

async function dropDb(databaseName){
  const command = `dropdb -h ${process.env.DB_HOST} -p ${process.env.DB_PORT} -U ${process.env.DB_USER}  ${databaseName}`

  try {
    await exec(command)
    return true
  } catch(e) {
    if (e.toString().indexOf('does not exist') > -1) {
      return true
    } else {
      throw e
    }
  }
}

module.exports = dropDb
