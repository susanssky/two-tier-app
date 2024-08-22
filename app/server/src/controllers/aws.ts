import { Request, Response } from 'express'

export const getCurrentInstance = async (req: Request, res: Response) => {
  try {
    const response = await getInstanceInfo()
    console.log(response)
    return res.status(200).json(response)
  } catch (error) {
    console.log(error)
  }
}

async function getInstanceInfo() {
  try {
    const tokenResponse = await fetch(
      'http://169.254.169.254/latest/api/token',
      {
        method: 'PUT',
        headers: {
          'X-aws-ec2-metadata-token-ttl-seconds': '21600',
        },
      }
    )
    const token = await tokenResponse.text()

    // 使用令牌獲取實例ID和可用區
    const [instanceIdResponse, availabilityZoneResponse] = await Promise.all([
      fetch('http://169.254.169.254/latest/meta-data/instance-id', {
        headers: { 'X-aws-ec2-metadata-token': token },
      }),
      fetch(
        'http://169.254.169.254/latest/meta-data/placement/availability-zone',
        {
          headers: { 'X-aws-ec2-metadata-token': token },
        }
      ),
    ])

    const instanceId = await instanceIdResponse.text()
    const availabilityZone = await availabilityZoneResponse.text()

    return {
      instanceId,
      availabilityZone,
    }
  } catch (error) {
    console.error('Error fetching instance info:', error)
    return null
  }
}
