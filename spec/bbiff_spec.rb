require 'spec_helper'

describe Bbiff do
  it 'has a version number' do
    expect(Bbiff::VERSION).not_to be nil
  end

  it 'does something useful' do
    expect(render_date(Time.now)).to eq('たった今')
  end
end
