require "input_processor.rb"

describe InputProcessor do
  let(:processor) { InputProcessor.new }
  context "parse a line" do
    before do
      # Quiesce the error logging for bad commands
      # during the test run
      processor.logger.level = Logger::FATAL
    end

    it "should accept valid commands" do
      expect(processor.process("INDEX|derp|")).to eq("OK")
      expect(processor.process("INDEX|derp|")).to eq("OK")
      expect(processor.process("INDEX|herp|")).to eq("OK")
      expect(processor.process("INDEX|foo|herp,derp")).to eq("OK")
      expect(processor.process("QUERY|herp|")).to eq("OK")
      expect(processor.process("REMOVE|doesntexist|")).to eq("OK")
      expect(processor.process("REMOVE|foo|")).to eq("OK")
      expect(processor.process("REMOVE|derp|")).to eq("OK")
    end
    it "should accept invalid commands" do
      expect(processor.process("INDEX|derp|")).to eq("OK")
      expect(processor.process("INDEX|foo|herp,derp")).to eq("FAIL")
      expect(processor.process("INDEX|foo|derp")).to eq("OK")
      expect(processor.process("QUERY|herp|")).to eq("FAIL")
      expect(processor.process("REMOVE|derp|")).to eq("FAIL")
    end
    it "should work with characters in the unicode categories of Letter/Mark/Numbers" do
      expect(processor.process("INDEX|💩 👻 💀 ☠️ 👽 |")).to eq("ERROR")
      expect(processor.process("INDEX|grüner|")).to eq("OK")
      expect(processor.process("INDEX|ﻥﻦﻧﻨﻩﻪﻫﻬﻭﻮﻯﻰﻱ|")).to eq("OK")
    end
    it "should ignore extra characters after a linebreaks and ignore leading linebreaks" do
      expect(processor.process("INDEX|derp|\ngarbage")).to eq("OK")
      expect(processor.process("\n\n\n\nINDEX|bar|")).to eq("OK")
      expect(processor.process("\n")).to eq("ERROR")
    end
    it "should allow dashes and underscore characters in names" do
      expect(processor.process("INDEX|herp-derp_|")).to eq("OK")
    end
    it "should not allow space characters in names" do
      expect(processor.process("INDEX| derp|")).to eq("ERROR")
      expect(processor.process("QUERY|derp |")).to eq("ERROR")
      expect(processor.process("INDEX |foo|")).to eq("ERROR")
      expect(processor.process(" INDEX|herp|")).to eq("ERROR")
    end
    it "should reject linebreaks in names" do
      expect(processor.process("INDEX|\nherp|")).to eq("ERROR")
      expect(processor.process("INDEX\n|herp|")).to eq("ERROR")
    end
    it "should reject malformed commands with ctrl characters" do
      expect(processor.process("INDEX|nh|")).to eq("ERROR")
    end
  end
end
