import { Table } from '@radix-ui/themes'

import DataTableHead from './DataTableHead'
import DataTableBody from './DataTableBody'

export default function DataTable({ data }: DataTableBodyProps) {
  return (
    <Table.Root>
      <DataTableHead />
      <Table.Body>
        <DataTableBody data={data} />
      </Table.Body>
    </Table.Root>
  )
}
