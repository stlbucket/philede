const clog = require('fbkt-clog')
const execDDL = require('./execDDL')

async function rollbackDevDeployment(args, pgClient) {
  const sql = `
    select * 
    from pde.dev_deployment 
    where id in (
      select dev_deployment_id 
      from pde.patch 
      where project_id = (
        select project_id from pde.release where id = ${args.input.releaseId}
      )
    )
    order by id desc
    ;`
  const devDeployments = await pgClient.query(sql, []);
  // clog('minors', minors)            

  for (let i = 0; i < devDeployments.rows.length; i++) {
    try {
      const devDeployment = devDeployments.rows[i]
      console.log('devDeployment', devDeployment)
      const devDeploymentResult = await execDDL(devDeployment.ddl_down, pgClient)
      clog('devDeploymentResult', devDeploymentResult)

      const deleteSql = `
      delete from pde.dev_deployment where id = ${devDeployment.id};
      `
      clog('deleteSql', deleteSql)
      const deleteResult = await pgClient.query(deleteSql, []);
      clog('deleteResult', deleteResult)
    }
    catch (e) {
      clog('rollback ERROR', e)
      throw e
    }
  }

  return {
    result: 'Deployment Rolled Back'
  }
}

module.exports = rollbackDevDeployment