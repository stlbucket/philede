require('../../../.env')
const createDb = require('../createDb')
const dropDb = require('../dropDb')

const TEST_DB = 'test_db'

test('create and drop test db', () => {
  createDb(TEST_DB)
  .then(result => {
    expect(result).toBe(true)
    return dropDb(TEST_DB)
  })
  .then(result => {
    expect(result).toBe(true)
  })
  .catch(error => {
    console.error(error)
  })

}, 5000);


test('create and drop test db', () => {
  dropDb(TEST_DB)
  .then(result => {
    expect(result).toBe(true)
  })
  .catch(error => {
    console.error(error)
  })

}, 5000);
