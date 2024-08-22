import { Table, Button } from '@radix-ui/themes'
import { useState, useEffect } from 'react'

export default function DataTableBody({ data }: DataTableBodyProps) {
  const [instances, setInstances] = useState<DataType[]>(data)

  useEffect(() => {
    setInstances(data)
  }, [data])

  const handleCheckBox = (instanceId: string) => {
    setInstances((prevState) =>
      prevState.map((instance) =>
        instance.instance_id === instanceId
          ? { ...instance, is_bookmarked: !instance.is_bookmarked }
          : instance
      )
    )
    console.log(instances)

    fetch(`${import.meta.env.VITE_SERVER_URL}/ec2`, {
      method: 'PATCH',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        instance_id: instanceId,
        is_bookmarked: !data.find((item) => item.instance_id === instanceId)
          ?.is_bookmarked,
      }),
    })
  }

  const handleStress = (instanceId: string) => {
    fetch(`${import.meta.env.VITE_SERVER_URL}/stress`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        instance_id: instanceId,
      }),
    })
  }
  const formatCpu = (cpu: string) => {
    const cpuNumber = parseFloat(cpu)

    // Check if cpuNumber is a valid number
    if (isNaN(cpuNumber)) return cpu

    // Format the number with a percentage symbol
    return `${cpuNumber.toFixed(2)}%`
  }
  return (
    <>
      {instances.map((instance) => (
        <Table.Row key={instance.instance_id}>
          <Table.Cell justify='center'>
            <input
              type='checkbox'
              id='horns'
              name='horns'
              defaultChecked={instance.is_bookmarked}
              onChange={() => handleCheckBox(instance.instance_id)}
            />
          </Table.Cell>
          <Table.RowHeaderCell justify='center'>
            {instance.ec2_name}
          </Table.RowHeaderCell>
          <Table.Cell justify='center'>{instance.instance_id}</Table.Cell>
          <Table.Cell justify='center'>{formatCpu(instance.cpu)}</Table.Cell>
          <Table.Cell justify='center'>
            <Button
              color='crimson'
              variant='soft'
              onClick={() => handleStress(instance.instance_id)}
              size='1'
            >
              Stress Test Request
            </Button>
          </Table.Cell>
        </Table.Row>
      ))}
    </>
  )
}
