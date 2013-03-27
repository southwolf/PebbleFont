# http://pebbledev.org/wiki/Resource_Font_Format

class Character
  attr_accessor :index, :ascii, :offset, :length, :width, :height, :image #:byte2, :byte3, :bytes4to7,
end


File.open('res37', 'rb') do |f|
  f.seek(2)
  numOfChars = f.read(1)[0].ord

  chars = Array.new(numOfChars)
  
  f.seek(6)

  fCharsOut = File.open('chars.txt', 'a+:BOM|UTF-8')
  f2 = File.open('res37', 'rb')
  chars.each_with_index  do |c,i|
    c = Character.new
    charInfo = f.read(4)
    c.index = i
    c.ascii = charInfo[0..1].unpack('S*')[0]
    c.offset = charInfo[2..3].unpack('S*')[0]
    chars[i] = c
    

    f2.seek(926 + 4 * c.offset)
    if(i == 0)
      dataLen = 4 * (3 - 1)
      leng = ""
    end
    if(i >= 1)
      dataLen = 4 * (c.offset - chars[i-1].offset)
      chars[i-1].length = dataLen  
      #puts "i: #{i}, Len: #{dataLen}"
      leng = " ,l: #{chars[i-1].length}\n"
    end
    fCharsOut.print(leng + "i: #{c.index}, n:#{c.ascii}, c:#{[c.ascii].pack('U*')}, o: #{c.offset}")
  end
  lastDataLen = f2.size - (926+4*chars.last.offset)
  chars.last.length = lastDataLen
  fCharsOut.print(" ,l: #{lastDataLen}")
  # (1..numOfChars).each do |i|
  #   charInfo = f.read(4)
  #   chars[i-1].index = i - 1
  #   chars[i-1].ascii = charInfo[0..1].unpack('S*')[0]
  #   chars[i-1].offset = charInfo[2..3].unpack('S*')[0]
  #   fCharsOut.puts("i: #{chars[i-1].index}, n:#{chars[i-1].ascii}, c:#{[chars[i-1].ascii].pack('U*')} o: #{chars[i-1].offset}")

  #   f2.seek(926 + 4 * chars[i-1].offset)
  #   if(i == 1)
  #     dataLen = 4 * (3 - 1)
  #   end
  #   if(i == 2)
  #     dataLen = 4 * (11 - 3)
  #   end
  #   if(i > 2)
  #     dataLen = 4 * (chars[i-1].offset - chars[i-2].offset)

  #   end
  f2.seek(926 + 4 * chars[0].offset)
  chars.each_with_index do |c,i|
      charData = f2.read(c.length)
      c.width = charData[0].ord
      c.height = charData[1].ord
      # c.byte2 = charData[2].ord
      # c.byte3 = charData[3].ord
      # c.bytes4to7 = charData[4..7].unpack('L*')[0]
      c.image = charData[8..c.length]
      puts "i: #{c.index}, l: #{c.length} w: #{c.width}, h: #{c.height}"
      fout = File.open("font#{i}", 'wb')
      fout.write(c.image)
  end
end