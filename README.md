# .txt Translation Memory File Importer

[![Gem Version](https://badge.fury.io/rb/txt_tm_importer.svg)](https://badge.fury.io/rb/txt_tm_importer) [![Build Status](https://travis-ci.org/diasks2/txt_tm_importer.png)](https://travis-ci.org/diasks2/txt_tm_importer) [![License](https://img.shields.io/badge/license-MIT-brightgreen.svg?style=flat)](https://github.com/diasks2/txt_tm_importer/blob/master/LICENSE.txt)

This gem handles the importing and parsing of .txt translation memory files.

## Installation

Add this line to your application's Gemfile:

**Ruby**  
```
gem install txt_tm_importer
```

**Ruby on Rails**  
Add this line to your application’s Gemfile:  
```ruby 
gem 'txt_tm_importer'
```

## Usage

```ruby
# Get the high level stats of .txt translation memory file
# Including the encoding is optional. If not included the gem will attempt to detect the encoding.
file_path = File.expand_path('../txt_tm_importer/spec/sample_files/sampletxt')
tm = TxtTmImporter::Tm.new(file_path: file_path)
tm.stats
# => {:tu_count=>2, :seg_count=>4, :language_pairs=>[["de-DE", "en-US"]]}

# Extract the segments of a .txt translation memory file
# Result: [translation_units, segments]
# translation_units = [tu_id, creation_date]
# segments = [tu_id, segment_role, word_count, language, segment_text, creation_date]

tm.import
# => [[["3638-1457683912-1", "2016-03-11T17:11:52+09:00"], ["7214-1457683912-3", "2016-03-11T17:11:52+09:00"]], [["3638-1457683912-1", "", 1, "de-DE", "überprüfen", "2016-03-11T17:11:52+09:00"], ["3638-1457683912-1", "target", 1, "en-US", "check", "2016-03-11T17:11:52+09:00"], ["7214-1457683912-3", "source", 1, "de-DE", "Rückenlehneneinstellung", "2016-03-11T17:11:52+09:00"], ["7214-1457683912-3", "target", 2, "en-US", "Backrest adjustment", "2016-03-11T17:11:52+09:00"]]]
```

## Contributing

1. Fork it ( https://github.com/diasks2/txt_tm_importer/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## License

The MIT License (MIT)

Copyright (c) 2016 Kevin S. Dias

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
