module Spreadsheet
  class Worksheet
    def column_widths(w)
      w.each_with_index {|value, idx| self.column(idx).width = value}
    end
  end
end

  def process_spreadsheet(f)
    # Istanza oggetto xls
    xls = Spreadsheet::Workbook.new
    yield(xls)
    # Scrivo fisicamente il file xls
    xls.write f
  end

  def process_worksheet(xls, name, intest, w)
    # Istanzio un oggetto sheet
    sheet = xls.create_worksheet :name => name
    # Intestazione
    sheet.row(0).concat intest
    yield(sheet)
    # Setto larghezza colonne
    sheet.column_widths(w)
  end

