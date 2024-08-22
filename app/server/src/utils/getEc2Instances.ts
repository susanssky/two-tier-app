import {
  EC2Client,
  DescribeInstancesCommand,
  DescribeSubnetsCommand,
} from '@aws-sdk/client-ec2'
import {
  CloudWatchClient,
  GetMetricStatisticsCommand,
} from '@aws-sdk/client-cloudwatch'
import 'dotenv/config'

export async function getEc2Instances() {
  const client = new EC2Client({ region: 'eu-west-2' })
  const input = {
    Filters: [
      {
        Name: 'vpc-id',
        Values: [process.env.VPC_ID as string],
      },
    ],
  }
  const command = new DescribeInstancesCommand(input)
  const response = await client.send(command)
  const { $metadata, Reservations } = response
  console.log(`Reservations: ${JSON.stringify(Reservations)}`)

  if (
    $metadata.httpStatusCode === 200 &&
    Reservations &&
    Reservations.length > 0
  ) {
    const instancesInfo = []

    for (const reservation of Reservations) {
      if (reservation.Instances) {
        for (const instance of reservation.Instances) {
          const {
            InstanceId,
            Placement,
            PublicDnsName,
            PublicIpAddress,
            SubnetId,
            Tags,
          } = instance

          const subnetNames = await getSubnetName(SubnetId!)
          const outputCw = await getCloudWatch(InstanceId!)

          console.log(`outputCw: ${JSON.stringify(outputCw)}`)
          console.log(`Tags: ${JSON.stringify(Tags)}`)

          instancesInfo.push({
            InstanceId,
            AvailabilityZone: Placement?.AvailabilityZone,
            PublicDnsName,
            PublicIpAddress,
            subnetNames,
            ec2Name:
              Tags?.find((tag) => tag.Key === 'Name')?.Value ?? undefined,
            cpu: outputCw!.toString(),
          })
        }
      }
    }

    return instancesInfo
  }
}

async function getCloudWatch(instanceId: string) {
  try {
    const client = new CloudWatchClient({ region: 'eu-west-2' })

    const input = {
      Namespace: 'AWS/EC2',
      MetricName: 'CPUUtilization',
      Dimensions: [
        {
          Name: 'InstanceId',
          Value: instanceId,
        },
      ],
      StartTime: new Date(Date.now() - 3600 * 1000), // before 1 hour
      EndTime: new Date(),
      Period: 60,
      Statistics: ['Average'],
    }
    // @ts-ignore
    const command = new GetMetricStatisticsCommand(input)
    const response = await client.send(command)

    const dataPoints = response.Datapoints || []
    const latestDataPoint = dataPoints.sort(
      (a: any, b: any) => b.Timestamp! - a.Timestamp!
    )[0]

    const cpuUtilization = latestDataPoint?.Average
    return cpuUtilization ?? 'No data found for the specified instance'
  } catch (err) {
    console.error(err)
  }
}
async function getSubnetName(subnetId: string) {
  try {
    const client = new EC2Client({ region: 'eu-west-2' })
    const command = new DescribeSubnetsCommand({
      SubnetIds: [subnetId],
    })

    const response = await client.send(command)

    if (response.Subnets && response.Subnets.length > 0) {
      const subnet = response.Subnets[0]
      if (subnet.Tags) {
        const nameTag = subnet.Tags.find((tag) => tag.Key === 'Name')
        const subnetName = nameTag ? nameTag.Value : 'Unnamed Subnet'
        return subnetName
      }
    } else {
      console.log('Subnet not found')
      return null
    }
  } catch (error) {
    console.error(error)
    return null
  }
}
