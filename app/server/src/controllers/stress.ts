import os from 'os'
import { Request, Response } from 'express'
import { SSMClient, CreateAssociationCommand } from '@aws-sdk/client-ssm' // ES Modules import

export const requestStress = async (req: Request, res: Response) => {
  try {
    console.log(req.body)
    const { instance_id } = req.body
    if (!instance_id) {
      return res.status(400).json({ error: 'Invalid input' })
    }
    const response = await sdk(instance_id)
    return res
      .status(response.$metadata.httpStatusCode as number)
      .json(response)
  } catch (error) {
    console.log(error)
  }
}
async function sdk(instance_id: string) {
  const client = new SSMClient({ region: 'eu-west-2' })
  const input = {
    Name: process.env.STRESS_DOC_NAME,
    Targets: [
      {
        Key: 'InstanceIds',
        Values: [instance_id],
      },
    ],
  }
  const command = new CreateAssociationCommand(input)
  const response = await client.send(command)
  console.log(`response: ${JSON.stringify(response)}`)

  return response
}
