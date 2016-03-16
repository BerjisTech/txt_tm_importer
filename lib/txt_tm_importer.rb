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
      if @encoding.eql?('UTF-8')
        @text = @content
      else
        @text = CharlockHolmes::Converter.convert(@content, @encoding, 'UTF-8')
      end
    end

    def stats
      if wordfast?
        wordfast_stats
      else
        if @text.include?('<RTF Preamble>')
          twb_export_file_stats
        else
          raise "File type not recognized"
        end
      end
      if @doc[:tu][:counter].eql?(0) && @doc[:seg][:counter].eql?(0) && @doc[:language_pairs].uniq.empty?
        raise "File type not recognized"
      else
        { tu_count: @doc[:tu][:counter], seg_count: @doc[:seg][:counter], language_pairs: @doc[:language_pairs].uniq }
      end
    end

    def import
      if wordfast?
        import_wordfast_file
      else
        if @text.include?('<RTF Preamble>')
          import_twb_file
        else
          raise "File type not recognized"
        end
      end
      [@doc[:tu][:vals], @doc[:seg][:vals]]
    end

    private

    def set_twb_date(line)
      string = line.scan(/(?<=>).+/)[0]
      year = string.match(/(?<=\A\d{4})\d{4}/)[0].to_i
      month = string.match(/(?<=\A\d{2})\d{2}/)[0].to_i
      day = string.match(/(?<=\A)\d{2}/)[0].to_i
      hour = string.match(/(?<=\A\d{8},\s)\d{2}/)[0].to_i
      minute = string.match(/(?<=\A\d{8},\s\d{2}\:)\d{2}/)[0].to_i
      @doc[:tu][:creation_date] = DateTime.new(year,month,day,hour,minute).to_s
    end

    def import_wordfast_file
      wordfast_lines.each_with_index do |line, index|
        line_array = line.split("\t")
        @doc[:source_language] = line_array[3].gsub(/%/, '').gsub(/\s/, '') if index.eql?(0)
        @doc[:target_language] = line_array[5].gsub(/%/, '').gsub(/\s/, '') if index.eql?(0)
        next if index.eql?(0)
        timestamp = create_timestamp(line.split("\t")[0])
        @doc[:tu][:creation_date] = timestamp unless timestamp.nil?
        generate_unique_id
        write_tu
        write_seg(remove_wordfast_tags(line_array[4]), 'source', line_array[3]) unless line_array[4].nil?
        write_seg(remove_wordfast_tags(line_array[6]), 'target', line_array[5]) unless line_array[6].nil?
      end
    end

    def import_twb_file
      role_counter = 0
      tu_tracker = 0
      @text.each_line do |line|
        generate_unique_id if line.include?('<TrU')
        tu_tracker += 1 if line.include?('<TrU')
        set_twb_date(line) if line.include?('<CrD>')
        if line.include?('<Seg')
          write_tu if tu_tracker.eql?(1)
          tu_tracker = 0 if tu_tracker > 0
          language = line.scan(/(?<=<Seg L=)\S+(?=>)/)[0] if !line.scan(/(?<=<Seg L=)\S+(?=>)/).empty?
          if role_counter.eql?(0)
            write_seg(line.scan(/(?<=>).+/)[0], 'source', language)
            role_counter += 1
          else
            write_seg(line.scan(/(?<=>).+/)[0], 'target', language)
            role_counter = 0
          end
        end
        role_counter = 0 if line.include?('</TrU>')
      end
    end

    def wordfast_stats
      lines = wordfast_lines
      @doc[:tu][:counter] = lines.size - 1
      @doc[:seg][:counter] = @doc[:tu][:counter] * 2
      @doc[:source_language] = lines[0].split("\t")[3].gsub(/%/, '').gsub(/\s/, '')
      @doc[:target_language] = lines[0].split("\t")[5].gsub(/%/, '').gsub(/\s/, '')
      @doc[:language_pairs] << [@doc[:source_language], @doc[:target_language]]
    end

    def twb_export_file_stats
      @doc[:tu][:counter] = @text.scan(/<\/TrU>/).count
      @doc[:seg][:counter] = @text.scan(/<Seg/).count
      role_counter = 0
      @text.each_line do |line|
        if line.include?('<Seg L=')
          @doc[:source_language] = line.scan(/(?<=<Seg L=)\S+(?=>)/)[0] if !line.scan(/(?<=<Seg L=)\S+(?=>)/).empty? && role_counter.eql?(0)
          @doc[:target_language] = line.scan(/(?<=<Seg L=)\S+(?=>)/)[0] if !line.scan(/(?<=<Seg L=)\S+(?=>)/).empty? && role_counter.eql?(1)
          role_counter += 1 if role_counter.eql?(0)
        end
        @doc[:language_pairs] << [@doc[:source_language], @doc[:target_language]] if !@doc[:source_language].nil? && !@doc[:target_language].nil? && role_counter > 0
        role_counter = 0 if line.include?('</TrU>')
      end
    end

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
      @doc[:tu][:vals] << [@doc[:tu][:id], @doc[:tu][:creation_date]]
    end

    def write_seg(string, role, language)
      return if string.nil?
      text = PrettyStrings::Cleaner.new(string).pretty.gsub("\\","&#92;").gsub("'",%q(\\\'))
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
