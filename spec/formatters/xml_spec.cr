# require "../spec_helper"

# describe Crul::Formatters::XML do
#   describe "#print" do
#     context "with valid XML" do
#       it "formats it" do
#         output = IO::Memory.new
#         response = FakeResponse.new("<a><b>c</b></a>")
#         formatter = Crul::Formatters::XML.new(output: output, response: response)

#         formatter.print
#       end
#     end

#     context "with malformed XML" do
#       it "formats it (falling back to plain)" do
#         output = IO::Memory.new
#         response = FakeResponse.new("<<<")
#         formatter = Crul::Formatters::XML.new(output: output, response: response)

#         formatter.print

#         output.to_s.strip.should eq("<<<")
#       end
#     end
#   end
# end
