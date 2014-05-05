require 'spec_helper'

describe Configuration do
  context 'with default configuration' do
    describe 'settings' do
      subject { Configuration.instance.settings(nil) }

      its(:host) { should eq 'sandbox' }
      its(:key) { should eq 'MerchantRutravel' }
      its(:password) { should eq '123' }

      it 'should build api' do
        allow(Api.any_instance).to receive(:new).with('sandbox', 'MerchantRutravel', '123')
        Configuration.instance.api_for(nil)
      end
    end
  end

  context 'set up' do
    context 'host' do
      before do
        Configuration.setup :settings do |config|
          config.host = 'host'
          config.key = 'key'
          config.password = 'password'
        end
      end

      subject { Configuration.instance.settings(:settings) }

      its(:host) { should eq 'host' }
      its(:key) { should eq 'key' }
      its(:password) { should eq 'password' }


      it 'should build api' do
        allow(Api.any_instance).to receive(:new).with('host', 'key', 'password')
        Configuration.instance.api_for(nil)
      end
    end
  end
end