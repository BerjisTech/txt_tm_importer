require 'txt_tm_importer/version'
require 'open-uri'
require 'pretty_strings'
require 'charlock_holmes'

module TxtTmImporter
  class Tm
    attr_reader :file_path, :encoding
    def initialize(file_path:, **args)
      @file_path = file_path
      @content = File.read(open(@file_path))
      if args[:encoding].nil?
        @encoding = CharlockHolmes::EncodingDetector.detect(@content[0..100_000])[:encoding]
        @encoding = 'UTF-16LE' if @encoding.nil?
      else
        @encoding = args[:encoding].upcase
      end
      @doc = {
        source_language: "",
        tu: { id: "", counter: 0, vals: [] },
        seg: { counter: 0, vals: [] },
        language_pairs: []
      }
      raise "Encoding type could not be determined. Please set an encoding of UTF-8, UTF-16LE, or UTF-16BE" if @encoding.nil?
      raise "Encoding type not supported. Please choose an encoding of UTF-8, UTF-16LE, or UTF-16BE" unless @encoding.eql?('UTF-8') || @encoding.eql?('UTF-16LE') || @encoding.eql?('UTF-16BE')
      if @encoding.eql?('UTF-8')
        @text = @content
      else
        @text = CharlockHolmes::Converter.convert(@content, @encoding, 'UTF-8')
      end
    end

    def stats
      if wordfast?
        lines = wordfast_lines
        tu_count = lines.size - 1
        @doc[:source_language] = lines[0].split("\t")[3].gsub(/%/, '').gsub(/\s/, '')
        @doc[:target_language] = lines[0].split("\t")[5].gsub(/%/, '').gsub(/\s/, '')
        @doc[:language_pairs] << [@doc[:source_language], @doc[:target_language]]
      else

      end
      { tu_count: tu_count, seg_count: tu_count * 2, language_pairs: @doc[:language_pairs] }
    end

    def import
      if wordfast?
        wordfast_lines.each_with_index do |line, index|
          line_array = line.split("\t")
          @doc[:source_language] = line_array[3].gsub(/%/, '').gsub(/\s/, '') if index.eql?(0)
          @doc[:target_language] = line_array[5].gsub(/%/, '').gsub(/\s/, '') if index.eql?(0)
          next if index.eql?(0)
          timestamp = create_timestamp(line.split("\t")[0])
          @doc[:tu][:creation_date] = timestamp unless timestamp.nil?
          write_tu
          write_seg(remove_wordfast_tags(line_array[4]), 'source', line_array[3]) unless line_array[4].nil?
          write_seg(remove_wordfast_tags(line_array[6]), 'target', line_array[5]) unless line_array[6].nil?
        end
      end
      [@doc[:tu][:vals], @doc[:seg][:vals]]
    end

    private

    def wordfast?
      @wordfast ||= detect_wordfast
    end

    def detect_wordfast
      @text =~ /\s%Wordfast/i
    end

    def wordfast_lines
      @wordfast_lines || strip_spaces_wordfast
    end

    def strip_spaces_wordfast
      @text.gsub(/\n/, "\r").gsub(/\r\r/, "\r").split("\r")
    end

    def remove_wordfast_tags(txt)
      txt.gsub(/&t[A-Z];/, '')
    end

    def write_tu
      generate_unique_id
      @doc[:tu][:vals] << [@doc[:tu][:id], @doc[:tu][:creation_date]]
    end

    def write_seg(string, role, language)
      return if string.nil?
      text = PrettyStrings::Cleaner.new(string).pretty.gsub("\\","&#92;").gsub("'",%q(\\\'))
      return if text.nil? || text.empty?
      word_count = text.gsub("\s+", ' ').split(' ').length
      @doc[:seg][:vals] << [@doc[:tu][:id], role, word_count, language, text, @doc[:tu][:creation_date]]
    end

    def generate_unique_id
      @doc[:tu][:id] = [(1..4).map{rand(10)}.join(''), Time.now.to_i, @doc[:tu][:counter] += 1 ].join("-")
    end

    def create_timestamp(string)
      return if string.nil?
      return if string.match(/\A\d{4}/).nil? ||
        string.match(/(?<=\A\d{4})\d{2}/).nil? ||
        string.match(/(?<=\A\d{6})\d{2}/).nil? ||
        string.match(/(?<=\A\d{8}~)\d{2}/).nil? ||
        string.match(/(?<=\A\d{8}~\d{2})\d{2}/).nil? ||
        string.match(/(?<=\A\d{8}~\d{4})\d{2}/).nil?
      year = string.match(/\A\d{4}/)[0].to_i
      month = string.match(/(?<=\A\d{4})\d{2}/)[0].to_i
      day = string.match(/(?<=\A\d{6})\d{2}/)[0].to_i
      hour = string.match(/(?<=\A\d{8}~)\d{2}/)[0].to_i
      minute = string.match(/(?<=\A\d{8}~\d{2})\d{2}/)[0].to_i
      seconds = string.match(/(?<=\A\d{8}~\d{4})\d{2}/)[0].to_i
      seconds = 59 if seconds > 59
      DateTime.new(year,month,day,hour,minute,seconds).to_s
      rescue
    end
  end
end
