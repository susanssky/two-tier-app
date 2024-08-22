import './App.css'
import DataTable from './components/DataTable'
import { useState, useEffect } from 'react'
import { Button } from '@radix-ui/themes'

type instanceType = {
  instanceId: string
  availabilityZone: string
}

function App() {
  const [data, setData] = useState<DataType[]>([])
  const [currentEc2, setCurrentEc2] = useState<instanceType>({
    instanceId: '',
    availabilityZone: '',
  })
  useEffect(() => {
    const fetchData = async (): Promise<void> => {
      try {
        const response = await fetch(`${import.meta.env.VITE_SERVER_URL}/ec2`)
        if (!response.ok) throw Error('Did not receive expected data')
        const data = await response.json()
        // console.log(data)
        setData(data)
      } catch (error) {
        console.log(error)
      }
    }
    fetchData()
  }, [])
  useEffect(() => {
    const fetchData = async (): Promise<void> => {
      try {
        const response = await fetch(`${import.meta.env.VITE_SERVER_URL}/aws`)
        if (!response.ok) throw Error('Did not receive expected data')
        const data = await response.json()
        setCurrentEc2(data)
      } catch (error) {
        console.log(error)
      }
    }
    fetchData()
  }, [])
  const handleRefresh = async () => {
    const response = await fetch(`${import.meta.env.VITE_SERVER_URL}/ec2`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
    })
    console.log(`>>>handleRefresh`)
    const data = await response.json()
    console.log(data)
    setData(data)
  }

  return (
    <>
      <div>
        <h1>EC2 CPU Monitoring</h1>
        <Button color='indigo' onClick={handleRefresh}>
          refresh
        </Button>
        <p>
          {currentEc2.instanceId &&
            `You are in ${currentEc2.instanceId} of the ec2 instance`}
        </p>
        <DataTable data={data} />
      </div>
    </>
  )
}

export default App
