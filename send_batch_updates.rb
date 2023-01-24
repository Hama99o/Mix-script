  def send_batch_updates
    batch =           {
            requests: [{
              update_sheet_properties: {
                fields: 'grid_properties',
                properties: {
                  sheet_id: 'some_sheet_id',
                  grid_properties: {
                    column_count: 10,
                    row_count: 15,
                  }
                }
              }
            }]
          }

    batch_update_spreadsheet('spreadsheet_id', batch)
  end