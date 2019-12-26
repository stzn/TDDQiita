const express = require('express')
const bodyParser = require('body-parser')
const cors = require('cors')
const https = require('https')

const config = {
  name: 'api',
  port: 3000,
  host: '0.0.0.0',
  key: ''
}

const app = express()

app.use(bodyParser.json())
app.use(cors())

app.get('/', (req, res) => {
  const data = getQiitaList()
  res.status(200).send(data)
})

let data = []

function getQiitaList() {
  const req = https.request('https://qiita.com/api/v2/items', res => {
    res.on('data', chunk => {
      data.push(chunk)
    })
    res.on('end', () => {
      const items = Buffer.concat(data)
      const json = JSON.parse(items)
      data = []
      return json
    })
  })
  req.on('error', e => {
    console.error(`problem with request: ${e.message}`)
  })
  req.end()
}

app.listen(config.port, config.host, e => {
  if (e) {
    throw new Error('Internal Server Error')
  }
  console.log(`${config.name} running on ${config.host}:${config.port}`)
})
