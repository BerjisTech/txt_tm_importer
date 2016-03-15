require 'spec_helper'

describe TxtTmImporter do
  it 'has a version number' do
    expect(TxtTmImporter::VERSION).not_to be nil
  end

  describe '#stats' do
    it 'reports the stats of a wordfast txt file 1' do
      file_path = File.expand_path('../txt_tm_importer/spec/sample_files/wordfast_1.txt')
      txt = TxtTmImporter::Tm.new(file_path: file_path).stats
      expect(txt).to eq({:tu_count=>407, :seg_count=>814, :language_pairs=>[['PT-BR', 'EN-US']]})
    end

    it 'reports the stats of a wordfast txt file 2' do
      file_path = File.expand_path('../txt_tm_importer/spec/sample_files/wordfast_2.txt')
      txt = TxtTmImporter::Tm.new(file_path: file_path).stats
      expect(txt).to eq({:tu_count=>1859, :seg_count=>3718, :language_pairs=>[["EN", "ES"]]})
    end

    it 'reports the stats of a wordfast txt file 3' do
      file_path = File.expand_path('../txt_tm_importer/spec/sample_files/wordfast_1(utf-8).txt')
      txt = TxtTmImporter::Tm.new(file_path: file_path).stats
      expect(txt).to eq({:tu_count=>407, :seg_count=>814, :language_pairs=>[['PT-BR', 'EN-US']]})
    end

    it 'reports the stats of a wordfast txt file 4' do
      file_path = File.expand_path('../txt_tm_importer/spec/sample_files/rtf_1.txt')
      txt = TxtTmImporter::Tm.new(file_path: file_path).stats
      expect(txt).to eq({:tu_count=>2, :seg_count=>4, :language_pairs=>[['ES-EM', 'EN-US']]})
    end
  end

  describe '#import' do
    it 'imports a txt file 1' do
      file_path = File.expand_path('../txt_tm_importer/spec/sample_files/wordfast_1.txt')
      txt = TxtTmImporter::Tm.new(file_path: file_path).import
      expect(txt[0][-1][0]).to eq(txt[1][-1][0])
    end

    it 'imports a txt file 2' do
      file_path = File.expand_path('../txt_tm_importer/spec/sample_files/wordfast_1.txt')
      txt = TxtTmImporter::Tm.new(file_path: file_path).import
      expect(txt[0].length).to eq(407)
    end

    it 'imports a txt file 3' do
      file_path = File.expand_path('../txt_tm_importer/spec/sample_files/wordfast_1.txt')
      txt = TxtTmImporter::Tm.new(file_path: file_path).import
      expect(txt[1].length).to eq(814)
    end

    it 'imports a txt file 4' do
      file_path = File.expand_path('../txt_tm_importer/spec/sample_files/wordfast_1.txt')
      txt = TxtTmImporter::Tm.new(file_path: file_path).import
      expect(txt[1][5][3]).to eq("EN-US")
    end

    it 'imports a txt file 5' do
      file_path = File.expand_path('../txt_tm_importer/spec/sample_files/wordfast_1.txt')
      txt = TxtTmImporter::Tm.new(file_path: file_path).import
      expect(txt[1][6][3]).to eq("PT-BR")
    end

    it 'imports a txt file 6' do
      file_path = File.expand_path('../txt_tm_importer/spec/sample_files/wordfast_1(utf-8).txt')
      txt = TxtTmImporter::Tm.new(file_path: file_path).import
      expect(txt[0][-1][0]).to eq(txt[1][-1][0])
    end

    it 'imports a txt file 7' do
      file_path = File.expand_path('../txt_tm_importer/spec/sample_files/wordfast_1(utf-8).txt')
      txt = TxtTmImporter::Tm.new(file_path: file_path).import
      expect(txt[0].length).to eq(407)
    end

    it 'imports a txt file 8' do
      file_path = File.expand_path('../txt_tm_importer/spec/sample_files/wordfast_1(utf-8).txt')
      txt = TxtTmImporter::Tm.new(file_path: file_path).import
      expect(txt[1].length).to eq(814)
    end

    it 'imports a txt file 9' do
      file_path = File.expand_path('../txt_tm_importer/spec/sample_files/wordfast_1(utf-8).txt')
      txt = TxtTmImporter::Tm.new(file_path: file_path).import
      expect(txt[1][5][3]).to eq("EN-US")
    end

    it 'imports a txt file 10' do
      file_path = File.expand_path('../txt_tm_importer/spec/sample_files/wordfast_1(utf-8).txt')
      txt = TxtTmImporter::Tm.new(file_path: file_path).import
      expect(txt[1][6][3]).to eq("PT-BR")
    end

    it 'imports a txt file 11' do
      file_path = File.expand_path('../txt_tm_importer/spec/sample_files/wordfast_2.txt')
      txt = TxtTmImporter::Tm.new(file_path: file_path).import
      expect(txt[0][-1][0]).to eq(txt[1][-1][0])
    end

    it 'imports a txt file 12' do
      file_path = File.expand_path('../txt_tm_importer/spec/sample_files/wordfast_2.txt')
      txt = TxtTmImporter::Tm.new(file_path: file_path).import
      expect(txt[0].length).to eq(1859)
    end

    it 'imports a txt file 13' do
      file_path = File.expand_path('../txt_tm_importer/spec/sample_files/wordfast_2.txt')
      txt = TxtTmImporter::Tm.new(file_path: file_path).import
      expect(txt[1].length).to eq(3718)
    end

    it 'imports a txt file 14' do
      file_path = File.expand_path('../txt_tm_importer/spec/sample_files/wordfast_2.txt')
      txt = TxtTmImporter::Tm.new(file_path: file_path).import
      expect(txt[1][5][3]).to eq("ES")
    end

    it 'imports a txt file 15' do
      file_path = File.expand_path('../txt_tm_importer/spec/sample_files/wordfast_2.txt')
      txt = TxtTmImporter::Tm.new(file_path: file_path).import
      expect(txt[1][6][3]).to eq("EN")
    end

    it 'imports a txt file 16' do
      file_path = File.expand_path('../txt_tm_importer/spec/sample_files/rtf_1.txt')
      txt = TxtTmImporter::Tm.new(file_path: file_path).import
      expect(txt[0][-1][0]).to eq(txt[1][-1][0])
    end

    it 'imports a txt file 17' do
      file_path = File.expand_path('../txt_tm_importer/spec/sample_files/rtf_1.txt')
      txt = TxtTmImporter::Tm.new(file_path: file_path).import
      expect(txt[0].length).to eq(2)
    end

    it 'imports a txt file 18' do
      file_path = File.expand_path('../txt_tm_importer/spec/sample_files/rtf_1.txt')
      txt = TxtTmImporter::Tm.new(file_path: file_path).import
      expect(txt[1].length).to eq(4)
    end

    it 'imports a txt file 19' do
      file_path = File.expand_path('../txt_tm_importer/spec/sample_files/rtf_1.txt')
      txt = TxtTmImporter::Tm.new(file_path: file_path).import
      expect(txt[1][3][3]).to eq("EN-US")
    end

    it 'imports a txt file 20' do
      file_path = File.expand_path('../txt_tm_importer/spec/sample_files/rtf_1.txt')
      txt = TxtTmImporter::Tm.new(file_path: file_path).import
      expect(txt[1][2][4]).to eq("La renovación de procesos con nuevos equipamientos beneficiará directamente a clientes y pacientes que utilizan medicamentos y alimentación parenteral suministrados por el grupo")
    end
  end
end
