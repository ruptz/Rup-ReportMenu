export const fetchNui = async <T>(eventName: string, data: unknown): Promise<T> => {
  const resourceName = (window as any).GetParentResourceName?.() ?? 'Rup-ReportMenu'
  
  const resp = await fetch(`https://${resourceName}/${eventName}`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: JSON.stringify(data),
  })

  const responseData = await resp.json()

  return responseData
}