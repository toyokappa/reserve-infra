'use strict';

const AWS = require('aws-sdk')
const ssm = new AWS.SSM({ region: 'ap-northeast-1' })
const basicUserKey = `/sympl-reserve/shared/admin_basic_user`
const basicPassKey = `/sympl-reserve/shared/admin_basic_pass`

exports.handler = async (event, context, callback) => {
  const userRes = await ssm.getParameter({
    Name: basicUserKey,
    WithDecryption: true
  }).promise()
  const passRes = await ssm.getParameter({
    Name: basicPassKey,
    WithDecryption: true
  }).promise()

  const user = userRes.Parameter.Value
  const pass = passRes.Parameter.Value
  
  const { request } = event.Records[0].cf
  const { headers } = request
  
  const authString = 'Basic ' + new Buffer(`${user}:${pass}`).toString('base64');
      
  if (typeof headers.authorization == 'undefined' || headers.authorization[0].value != authString) {
    const body = 'Unauthorized'
    const response = {
      status: '401',
      statusDescription: body,
      headers: {
        'www-authenticate': [{ key: 'WWW-Authenticate', value: 'Basic' }],
      },
    }
    callback(null, response)
  }
  callback(null, request)
};
