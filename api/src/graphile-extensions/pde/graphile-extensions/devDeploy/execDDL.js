const clog = require('fbkt-clog')

async function execDDL(ddl, pgClient) {
  try {
    clog('execDDL', ddl)

    const result = await pgClient.query(ddl, []);

    clog('execDDL result', result)

    // await pgClient.query("RELEASE SAVEPOINT graphql_mutation");

    return {
      sql: ddl,
      result: result
    };
  } catch (e) {
    // Oh noes! If at first you don't succeed,
    // destroy all evidence you ever tried.
    // await pgClient.query("ROLLBACK TO SAVEPOINT graphql_mutation");
    clog('execDDL ERROR', e)
    throw new Error(JSON.stringify({
      message: e.toString().replace('error: ', ''),
      position: e.position
    }));
  }
}

module.exports = execDDL
