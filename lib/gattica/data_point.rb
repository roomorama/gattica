require 'csv'

module Gattica

  # Represents a single "row" of data containing any number of dimensions, metrics

  class DataPoint

    include Convertible

    attr_reader :dimensions, :metrics, :json

    # Parses the JSON <row> element
    def initialize(json, column_headers)
      @json = json.to_s
      @dimensions = []
      @metrics = []
      column_headers.each_with_index do |column_header, index|
        if column_header['columnType'] == 'DIMENSION'
          @dimensions << {column_header['name'].split(':').last.to_sym => json[index]}
        elsif column_header['columnType'] == 'METRIC'
          @metrics << {column_header['name'].split(':').last.to_sym => json[index]}
        end
      end
    end


    # Outputs in Comma Seperated Values format
    def to_csv(format = :short)
      output = ''
      columns = []

      # only output
      case format
        when :long
          [@id, @updated, @title].each { |c| columns << c }
      end

      # output all dimensions
      @dimensions.map {|d| d.values.first}.each { |c| columns << c }
      # output all metrics
      @metrics.map {|m| m.values.first}.each { |c| columns << c }

      output = CSV.generate_line(columns)

    end


    def to_yaml
      { 'id' => @id,
        'updated' => @updated,
        'title' => @title,
        'dimensions' => @dimensions,
        'metrics' => @metrics }.to_yaml
    end

    def to_hash
      res_hash = {}

      @dimensions.each{|d| res_hash.merge!(d) }
      # output all metrics
      @metrics.each{|m| res_hash.merge!(m) }
      res_hash

    end


  end

end