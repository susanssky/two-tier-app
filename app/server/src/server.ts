import express, { Express, Request, Response } from 'express'
import cors from 'cors'
import 'dotenv/config'

import { Client } from 'pg'
import { clientConfig } from './utils/clientConfig'

import { default as ec2Routes } from './routers/ec2'
import { default as awsRoutes } from './routers/aws'
import { default as stressRoutes } from './routers/stress'
import { refreshInstances } from './utils/getSqlData'

const app: Express = express()
app.use(cors())
app.use(express.json())

export const client = new Client(clientConfig)
async function runSeeding() {
  try {
    await client.connect()
    await getLatestInstances()
    console.log('Seeding Completed!')
  } catch (err) {
    console.error('Error during seeding:', err)
  } finally {
    // await client.end()
  }
}

runSeeding()
app.get('/', (req: Request, res: Response) => {
  return res.status(200).json({ message: 'hi' })
})
app.use('/ec2', ec2Routes)
app.use('/aws', awsRoutes)
app.use('/stress', stressRoutes)

app.listen(process.env.SERVER_PORT, () => {
  console.log(`Server is listening on port ${process.env.SERVER_PORT}`)
})

export async function getLatestInstances() {
  await refreshInstances()
}
