require 'zlib'

class Numeric
  def to_digits(num = 3)
    str = to_s
    (num - str.size).times { str = str.prepend("0") }
    return str
  end
end

module Scripts

  def self.from_folder(path = "Data/Scripts", rxdata = "Data/Scripts.rxdata")
    scripts = []
    aggregate_from_folder(path, scripts)
    # Save scripts to file
    File.open(rxdata, "wb") do |f|
      Marshal.dump(scripts, f)
    end
  end

  def self.aggregate_from_folder(path, scripts, level = 0)
    files = []
    folders = []
    Dir.foreach(path) do |f|
      next if f == '.' || f == '..'

      if File.directory?(path + "/" + f)
        folders.push(f)
      else
        files.push(f)
      end
    end
    # Aggregate individual script files into Scripts.rxdata
    files.sort!
    files.each do |f|
      section_name = filename_to_title(f)
      content = File.open(path + "/" + f, "rb") { |f2| f2.read }#.gsub(/\n/, "\r\n")
      scripts << [rand(999_999), section_name, Zlib::Deflate.deflate(content)]
    end
    # Check each subfolder for scripts to aggregate
    folders.sort!
    folders.each do |f|
      section_name = filename_to_title(f)
      scripts << [rand(999_999), "==================", Zlib::Deflate.deflate("")] if level == 0
      scripts << [rand(999_999), "", Zlib::Deflate.deflate("")] if level == 1
      scripts << [rand(999_999), "[[ " + section_name + " ]]", Zlib::Deflate.deflate("")]
      aggregate_from_folder(path + "/" + f, scripts, level + 1)
    end
  end

  def self.filename_to_title(filename)
    filename = filename.bytes.pack('U*')
    title = ""
    if filename[/^[^_]*_(.+)$/]
      title = $~[1]
      title = title[0..-4] if title.end_with?(".rb")
      title = title.strip
    end
    title = "unnamed" if !title || title.empty?
    title.gsub!(/&bs;/, "\\")
    title.gsub!(/&fs;/, "/")
    title.gsub!(/&cn;/, ":")
    title.gsub!(/&as;/, "*")
    title.gsub!(/&qm;/, "?")
    title.gsub!(/&dq;/, "\"")
    title.gsub!(/&lt;/, "<")
    title.gsub!(/&gt;/, ">")
    title.gsub!(/&po;/, "|")
    return title
  end
end

Scripts.from_folder
