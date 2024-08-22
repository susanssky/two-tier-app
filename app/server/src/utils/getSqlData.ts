import { client } from '../server'
import { getEc2Instances } from '../utils/getEc2Instances'

export const refreshInstances = async () => {
  try {
    const data = await getEc2Instances()

    const queries = data!.map(({ InstanceId, ec2Name, cpu }) => {
      const sql =
        'INSERT INTO ec2_status (instance_id, ec2_name, cpu) values ($1, $2, $3) ON CONFLICT (instance_id) DO UPDATE SET ec2_name = EXCLUDED.ec2_name, cpu = EXCLUDED.cpu RETURNING *'
      const arr = [InstanceId!, ec2Name!, cpu!]
      return queryAndRespond(sql, arr)
    })
    const results = await Promise.all(queries)
    return results.flat()
  } catch (err) {
    console.error(err)
  }
}
export async function queryAndRespond(
  sql: string,
  arr: (string | number)[] = []
) {
  try {
    const result = await client.query(sql, arr)
    return result.rows
  } catch (err) {
    console.error(err)
  }
}
