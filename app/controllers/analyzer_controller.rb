# analyzer_controller.rb
class AnalyzerController < ApplicationController
  def index
    sales_header
    @filtered_data = []
  end

  def filter_data
    @uploaded_file = params[:attachment]
    sales_header
    analyze_data
    
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.update('filtered-data', partial: 'filtered_data')
      end
    end
  end

  private

  def analyze_data
    xls = Roo::Spreadsheet.open(@uploaded_file.path)
    sheet = xls.sheet('Sponsored Products Campaigns')
    @sheet_header = sheet.first
    @filtered_data = []

    sheet.each do |row|
      next if row == @sheet_header
      
      sales_hash = @sheet_header.zip(row).to_h
      
      next if sales_hash['Sales'].nil? || sales_hash['Ad Group Name (Informational only)'].nil? || sales_hash['Spend'].nil?

      if sales_hash['Sales'] == 0.0 && sales_hash['Spend'] >= 1.0 && sales_hash['Ad Group Name (Informational only)'].include?('NB')
        @filtered_data << sales_hash
      end
    end
  end

  private

  def sales_header
    @sales_header ||= ['Campaign Name (Informational only)',
      'Ad Group Name (Informational only)',
      'Keyword Text',
      'Match Type',
      'Impressions',
      'Clicks',
      'Click-through Rate',
      'Spend',
      'Sales',
      'Orders',
      'Units',
      'Conversion Rate',
      'ACOS',
      'CPC',
      'ROAS']
  end
end
