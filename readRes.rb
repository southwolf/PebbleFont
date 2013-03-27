# http://pebbledev.org/wiki/Firmware_Updates
class Resource
  attr_accessor :index, :offset, :size, :crc, :data
end


File.open('system_resources.pbpack', 'rb') do |f|
  
  # 0x00 : Number of resources
  numOfRes = f.read(1)[0].ord
  # numOfRes = f.read(1).chars.first.ord
	
  puts "Number of resources: " + numOfRes.to_s

  # 0x04 - 0x07 : CRC of 0x101C-EOF (all resource data without header)
  f.seek(4)

  # http://www.rubycentral.com/pickaxe/ref_c_string.html#String.unpack
  puts "CRC of resources: " + f.read(4).unpack('H*')[0].to_s

  # TODO: CRC16 instead of CRC32
  # require 'zlib'
  # f.seek(4124)
  # puts Zlib::crc32(f.read)

  # 0x0C - 0x1B
  f.seek(12)
  version = f.read(15)
  puts "Version: " + version

  # 0x1C - 0x101B: Resource entries
  resources = Array.new(numOfRes)
  f.seek(28)

  (1..numOfRes).each do
    res = f.read(16) # Length of a entry
    resIdx = res[0].ord - 1 # Ensure the index
    resources[resIdx].index = res[0].ord
    resources[resIdx].offset = res[4..7].unpack('L*')[0]
    resources[resIdx].size = res[8..11].unpack('L*')[0]
    resources[resIdx].crc = res[12..15].unpack('H*')[0]
    

    # Read Data
    f2 = File.open('system_resources.pbpack', 'rb')
    f2.seek(4124+resources[resIdx].offset)
    resources[resIdx].data = f2.read(resources[resIdx].size)
      
      #puts resources[resIdx].data.length

      # puts "i: #{resources[resIdx].index}, s: #{resources[resIdx].size}, o: #{resources[resIdx].offset}"
    
      # resOffset = res[4..7].unpack('L*')[0]
      # resSize = res[8..11].unpack('L*')[0]
      # resCrc = res[12..15].unpack('H*')[0]
      # puts "Index  : " + (resIdx + 1).to_s
      # puts "Offset : " + resOffset.to_s
      # puts "Size   : " + resSize.to_s
      # puts "CRC    : " + resCrc.to_s
      fout = File.open("res#{resIdx+1}", 'wb')
      fout.write(resources[resIdx].data)
  end

end