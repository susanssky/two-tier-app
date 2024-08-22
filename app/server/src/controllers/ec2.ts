import { Request, Response } from 'express'
import { queryAndRespond, refreshInstances } from '../utils/getSqlData'
import { client } from '../server'

export const getEc2fromDb = async (req: Request, res: Response) => {
  try {
    const data = await queryAndRespond('SELECT * FROM ec2_status')
    console.log(`data: ${JSON.stringify(data)}`)
    return res.status(200).json(data)
  } catch (err) {
    console.log(err)
    return res.status(500).json({ error: 'An error occurred' })
  }
}
export const callSdkToGetEc2Again = async (req: Request, res: Response) => {
  try {
    await queryAndRespond('DELETE FROM ec2_status;')
    const response = await refreshInstances()
    // console.log(`data: ${JSON.stringify(data)}`)
    return res.status(200).json(response)
    // return res.status(200).json(data)
  } catch (err) {
    console.log(err)
    return res.status(500).json({ error: 'An error occurred' })
  }
}
export const updateEc2Bookmarked = async (req: Request, res: Response) => {
  try {
    const { instance_id, is_bookmarked } = req.body
    if (!instance_id || is_bookmarked === undefined) {
      return res.status(400).json({ error: 'Invalid input' })
    }

    await checkExistById(instance_id)
    const updateSql = `
    UPDATE ec2_status 
    SET is_bookmarked = $1 
    WHERE instance_id = $2 
    RETURNING *
  `
    const update = await client.query(updateSql, [is_bookmarked, instance_id])

    return res.status(200).json(update.rows[0])
  } catch (err) {
    console.log(err)
    return res.status(400).json({ error: 'An error occurred' })
  }
}
async function checkExistById(instanceId: string) {
  const checkSql = `SELECT instance_id FROM ec2_status WHERE instance_id = $1`
  const checkExist = await client.query(checkSql, [instanceId])
  if (checkExist.rowCount === 0) {
    throw new Error(`instanceId does not exist.`)
  }
  return checkExist.rows[0].id
}
