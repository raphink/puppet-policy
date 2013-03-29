require 'spec_helper'

describe Puppet::Type.type(:spec) do
  subject { Puppet::Type.type(:spec).new(:test => '/bin/true') }

  it 'should accept should' do
    subject[:should] = :succeed
    subject[:should].should == :succeed
  end

  it 'should accept should_not' do
    subject[:should_not] = :succeed
    subject[:should_not].should == :succeed
  end

  it 'should accept type' do
    subject[:type] = :output
    subject[:type].should == :output
  end
end
